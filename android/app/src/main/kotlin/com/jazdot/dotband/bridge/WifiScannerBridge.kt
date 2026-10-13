package com.jazdot.dotband.bridge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.wifi.ScanResult
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat
import com.jazdot.dotband.parser.InformationElementParser
import com.jazdot.dotband.parser.MloLinkParser
import com.jazdot.dotband.rtt.WifiRttController
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicInteger

/**
 * Carrier-grade Wi-Fi Telemetry & Scanner Bridge for DotBand.
 * Implements token-bucket scan throttling management, API 31+ callback listeners,
 * Wi-Fi 7 MLO parsing, and Information Element extraction.
 */
class WifiScannerBridge(private val context: Context) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
    private val connectivityManager = context.applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
    private val rttController = WifiRttController(context.applicationContext)

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // Token Bucket Rate Limiter (4 tokens per 120-second window to comply with Android foreground scan limits)
    private val maxTokens = 4
    private val refillIntervalMs = 30_000L // Refill 1 token every 30 seconds
    private val availableTokens = AtomicInteger(maxTokens)
    private var lastScanTriggerTimeMs = 0L

    // RTT distances cache (BSSID -> Distance in meters)
    private val rttDistances = mutableMapOf<String, Double>()

    private val scanReceiver = object : BroadcastReceiver() {
        override fun onReceive(c: Context?, intent: Intent?) {
            if (intent?.action == WifiManager.SCAN_RESULTS_AVAILABLE_ACTION) {
                val success = intent.getBooleanExtra(WifiManager.EXTRA_RESULTS_UPDATED, false)
                dispatchScanResults(isUpdated = success)
            }
        }
    }

    private var scanCallback: Any? = null // WifiManager.ScanResultsCallback on API 31+

    init {
        startTokenRefillLoop()
        registerConnectedNetworkCallback()
    }

    private fun startTokenRefillLoop() {
        mainHandler.postDelayed(object : Runnable {
            override fun run() {
                val current = availableTokens.get()
                if (current < maxTokens) {
                    availableTokens.incrementAndGet()
                    notifyRateLimitStatus()
                }
                mainHandler.postDelayed(this, refillIntervalMs)
            }
        }, refillIntervalMs)
    }

    private fun registerConnectedNetworkCallback() {
        try {
            val networkCallback = object : ConnectivityManager.NetworkCallback() {
                override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) {
                    if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                        // In API 31+, WifiInfo can be obtained from TransportInfo
                        dispatchScanResults(isUpdated = true)
                    }
                }
            }
            connectivityManager?.registerDefaultNetworkCallback(networkCallback)
        } catch (_: Exception) {}
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startScan" -> {
                val currentTokens = availableTokens.get()
                if (currentTokens <= 0) {
                    val remainingCooldownSeconds = Math.max(1, ((refillIntervalMs - (System.currentTimeMillis() - lastScanTriggerTimeMs)) / 1000).toInt())
                    result.error(
                        "SCAN_THROTTLED",
                        "Android scan throttle limit reached. Rate-limited for $remainingCooldownSeconds seconds.",
                        mapOf("tokens" to 0, "cooldown_seconds" to remainingCooldownSeconds)
                    )
                    return
                }

                availableTokens.decrementAndGet()
                lastScanTriggerTimeMs = System.currentTimeMillis()

                val started = wifiManager?.startScan() ?: false
                result.success(
                    mapOf(
                        "started" to started,
                        "remaining_tokens" to availableTokens.get()
                    )
                )
            }
            "getRateLimitStatus" -> {
                result.success(
                    mapOf(
                        "available_tokens" to availableTokens.get(),
                        "max_tokens" to maxTokens,
                        "refill_interval_ms" to refillIntervalMs
                    )
                )
            }
            "triggerRttRanging" -> {
                val scanResults = wifiManager?.scanResults ?: emptyList()
                rttController.startRanging(
                    scanResults,
                    onSuccess = { distances ->
                        rttDistances.putAll(distances)
                        dispatchScanResults(isUpdated = true)
                        result.success(distances)
                    },
                    onError = { err ->
                        result.error("RTT_ERROR", err, null)
                    }
                )
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        registerScanListeners()
        // Send initial results immediately if available
        dispatchScanResults(isUpdated = false)
    }

    override fun onCancel(arguments: Any?) {
        unregisterScanListeners()
        eventSink = null
    }

    private fun registerScanListeners() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && wifiManager != null) {
            try {
                val executor = ContextCompat.getMainExecutor(context)
                val cb = object : WifiManager.ScanResultsCallback() {
                    override fun onScanResultsAvailable() {
                        dispatchScanResults(isUpdated = true)
                    }
                }
                wifiManager.registerScanResultsCallback(executor, cb)
                scanCallback = cb
            } catch (_: Exception) {
                // Fallback to BroadcastReceiver
                registerBroadcastReceiverFallback()
            }
        } else {
            registerBroadcastReceiverFallback()
        }
    }

    private fun registerBroadcastReceiverFallback() {
        try {
            val filter = IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
            context.registerReceiver(scanReceiver, filter)
        } catch (_: Exception) {}
    }

    private fun unregisterScanListeners() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && scanCallback != null && wifiManager != null) {
            try {
                wifiManager.unregisterScanResultsCallback(scanCallback as WifiManager.ScanResultsCallback)
                scanCallback = null
            } catch (_: Exception) {}
        }
        try {
            context.unregisterReceiver(scanReceiver)
        } catch (_: Exception) {}
    }

    private fun notifyRateLimitStatus() {
        val payload = mapOf(
            "type" to "RATE_LIMIT_UPDATE",
            "available_tokens" to availableTokens.get(),
            "max_tokens" to maxTokens
        )
        mainHandler.post {
            eventSink?.success(payload)
        }
    }

    private fun dispatchScanResults(isUpdated: Boolean) {
        val rawResults = try {
            wifiManager?.scanResults ?: emptyList()
        } catch (_: SecurityException) {
            emptyList()
        }

        val apList = mutableListOf<Map<String, Any?>>()
        var detectedCountryCode: String? = null

        for (res in rawResults) {
            // Information element extraction
            var qbssInfo: InformationElementParser.QbssLoad? = null
            var heInfo: InformationElementParser.HeOperationInfo? = null

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                try {
                    val ies = res.informationElements
                    if (ies != null) {
                        for (ie in ies) {
                            when (ie.id) {
                                7 -> { // Country IE
                                    if (detectedCountryCode == null) {
                                        detectedCountryCode = InformationElementParser.parseCountryCode(ie.bytes)
                                    }
                                }
                                11 -> { // QBSS Load
                                    qbssInfo = InformationElementParser.parseQbssLoad(ie.bytes)
                                }
                                255 -> { // Extended elements (HE/EHT)
                                    if (ie.idExt == 36) {
                                        heInfo = InformationElementParser.parseHeOperation(ie.bytes)
                                    }
                                }
                            }
                        }
                    }
                } catch (_: Exception) {}
            }

            // Wi-Fi 7 MLO extraction
            val mloTopology = MloLinkParser.parseMlo(res)

            // Bandwidth determination
            val channelWidthMhz = when (res.channelWidth) {
                ScanResult.CHANNEL_WIDTH_20MHZ -> 20
                ScanResult.CHANNEL_WIDTH_40MHZ -> 40
                ScanResult.CHANNEL_WIDTH_80MHZ -> 80
                ScanResult.CHANNEL_WIDTH_160MHZ -> 160
                ScanResult.CHANNEL_WIDTH_80MHZ_PLUS_MHZ -> 160
                else -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                        res.channelWidth == ScanResult.CHANNEL_WIDTH_320MHZ) 320 else 20
                }
            }

            val bssid = res.BSSID ?: "00:00:00:00:00:00"
            val isLocallyAdministered = InformationElementParser.isLocallyAdministeredMac(bssid)
            val distanceMeters = rttDistances[bssid]

            val apMap = mapOf<String, Any?>(
                "ssid" to (res.SSID ?: ""),
                "bssid" to bssid,
                "frequencyMhz" to res.frequency,
                "rssi" to res.level,
                "channelWidthMhz" to channelWidthMhz,
                "centerFreq0" to res.centerFreq0,
                "centerFreq1" to res.centerFreq1,
                "capabilities" to (res.capabilities ?: ""),
                "is80211mcResponder" to res.is80211mcResponder,
                "isPasspoint" to (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) res.isPasspointNetwork else false),
                "isLocallyAdministeredMac" to isLocallyAdministered,
                "rttDistanceMeters" to distanceMeters,
                "stationCount" to qbssInfo?.stationCount,
                "channelUtilizationPct" to qbssInfo?.channelUtilizationPct,
                "bssColor" to heInfo?.bssColor,
                "isMloActive" to mloTopology.isMloActive,
                "mldMacAddress" to mloTopology.mldMacAddress,
                "mloLinks" to mloTopology.affiliatedLinks.map {
                    mapOf(
                        "linkId" to it.linkId,
                        "band" to it.band,
                        "channel" to it.channel,
                        "rssi" to it.rssi,
                        "state" to it.state
                    )
                },
                "mloAggregateMbps" to mloTopology.aggregateTheoreticalThroughputMbps
            )
            apList.add(apMap)
        }

        val payload = mapOf(
            "type" to "SCAN_SNAPSHOT",
            "timestampMs" to System.currentTimeMillis(),
            "isResultsUpdated" to isUpdated,
            "detectedCountryCode" to (detectedCountryCode ?: "UNKNOWN"),
            "availableTokens" to availableTokens.get(),
            "accessPoints" to apList
        )

        mainHandler.post {
            eventSink?.success(payload)
        }
    }
}
