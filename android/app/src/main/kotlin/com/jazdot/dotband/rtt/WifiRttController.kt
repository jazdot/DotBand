package com.jazdot.dotband.rtt

import android.content.Context
import android.net.wifi.ScanResult
import android.net.wifi.rtt.RangingRequest
import android.net.wifi.rtt.RangingResult
import android.net.wifi.rtt.RangingResultCallback
import android.net.wifi.rtt.WifiRttManager
import android.os.Build
import androidx.core.content.ContextCompat

/**
 * Controller for IEEE 802.11mc / 802.11az Wi-Fi Round Trip Time (RTT) Fine Timing Measurement (FTM).
 * Provides sub-meter physical distance ranging to supporting APs without active connection.
 */
class WifiRttController(private val context: Context) {

    private val rttManager: WifiRttManager? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        context.getSystemService(Context.WIFI_RTT_RANGING_SERVICE) as? WifiRttManager
    } else {
        null
    }

    val isRttSupported: Boolean
        get() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.P &&
                rttManager != null &&
                rttManager.isAvailable

    fun startRanging(
        apScanResults: List<ScanResult>,
        onSuccess: (Map<String, Double>) -> Unit,
        onError: (String) -> Unit
    ) {
        if (!isRttSupported || rttManager == null) {
            onError("Wi-Fi RTT not supported or disabled on this hardware.")
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            onError("Android 9+ (API 28+) required for Wi-Fi RTT.")
            return
        }

        // Filter APs that support 802.11mc responder
        val supportingAps = apScanResults.filter { it.is80211mcResponder }.take(10) // Limit to 10 APs per batch
        if (supportingAps.isEmpty()) {
            onSuccess(emptyMap())
            return
        }

        try {
            val builder = RangingRequest.Builder()
            for (ap in supportingAps) {
                builder.addAccessPoint(ap)
            }
            val request = builder.build()
            val executor = ContextCompat.getMainExecutor(context)

            rttManager.startRanging(request, executor, object : RangingResultCallback() {
                override fun onRangingResults(results: List<RangingResult>) {
                    val distanceMap = mutableMapOf<String, Double>()
                    for (res in results) {
                        if (res.status == RangingResult.STATUS_SUCCESS) {
                            val mac = res.macAddress?.toString() ?: ""
                            val meters = Math.round((res.distanceMm / 1000.0) * 100.0) / 100.0
                            if (mac.isNotEmpty()) {
                                distanceMap[mac] = meters
                            }
                        }
                    }
                    onSuccess(distanceMap)
                }

                override fun onRangingFailure(code: Int) {
                    val reason = when (code) {
                        RangingResultCallback.STATUS_CODE_FAIL -> "General RTT ranging failure"
                        RangingResultCallback.STATUS_CODE_FAIL_RTT_NOT_AVAILABLE -> "RTT temporarily unavailable"
                        else -> "RTT error code: $code"
                    }
                    onError(reason)
                }
            })
        } catch (e: Exception) {
            onError("Exception initiating RTT ranging: ${e.message}")
        }
    }
}
