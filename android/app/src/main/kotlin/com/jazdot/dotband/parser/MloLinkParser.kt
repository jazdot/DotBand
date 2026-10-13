package com.jazdot.dotband.parser

import android.net.wifi.MloLink
import android.net.wifi.ScanResult
import android.os.Build

/**
 * Parses Wi-Fi 7 (802.11be) Multi-Link Operation (MLO) affiliations from Android ScanResult.
 * Supported on API 33+ (Android 13 Tiramisu and Android 14+).
 */
object MloLinkParser {

    data class MloLinkData(
        val linkId: Int,
        val band: String,
        val channel: Int,
        val rssi: Int,
        val state: String
    )

    data class MloTopology(
        val isMloActive: Boolean,
        val mldMacAddress: String?,
        val affiliatedLinks: List<MloLinkData>,
        val aggregateTheoreticalThroughputMbps: Double
    )

    fun parseMlo(scanResult: ScanResult): MloTopology {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return MloTopology(
                isMloActive = false,
                mldMacAddress = null,
                affiliatedLinks = emptyList(),
                aggregateTheoreticalThroughputMbps = 0.0
            )
        }

        try {
            val affiliatedMloLinks = scanResult.affiliatedMloLinks
            if (affiliatedMloLinks.isNullOrEmpty()) {
                return MloTopology(
                    isMloActive = false,
                    mldMacAddress = null,
                    affiliatedLinks = emptyList(),
                    aggregateTheoreticalThroughputMbps = 0.0
                )
            }

            val linkList = mutableListOf<MloLinkData>()
            var totalTheoreticalBw = 0.0

            for (link in affiliatedMloLinks) {
                val bandStr = when (link.band) {
                    ScanResult.WIFI_BAND_24_GHZ -> "2.4 GHz"
                    ScanResult.WIFI_BAND_5_GHZ -> "5 GHz"
                    ScanResult.WIFI_BAND_6_GHZ -> "6 GHz"
                    ScanResult.WIFI_BAND_60_GHZ -> "60 GHz"
                    else -> "Unknown"
                }

                val stateStr = when (link.state) {
                    MloLink.MLO_LINK_STATE_ACTIVE -> "ACTIVE"
                    MloLink.MLO_LINK_STATE_IDLE -> "IDLE"
                    MloLink.MLO_LINK_STATE_ASSOCIATED -> "ASSOCIATED"
                    else -> "UNKNOWN"
                }

                linkList.add(
                    MloLinkData(
                        linkId = link.linkId,
                        band = bandStr,
                        channel = link.channel,
                        rssi = link.rssi,
                        state = stateStr
                    )
                )

                // Approximate theoretical throughput calculation based on band and MLO aggregation
                totalTheoreticalBw += when (link.band) {
                    ScanResult.WIFI_BAND_24_GHZ -> 574.0 // 2x2 40MHz 1024/4096-QAM
                    ScanResult.WIFI_BAND_5_GHZ -> 2402.0 // 2x2 160MHz 4096-QAM
                    ScanResult.WIFI_BAND_6_GHZ -> 5764.0 // 2x2 320MHz 4096-QAM
                    else -> 0.0
                }
            }

            val mldMac = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                try {
                    // In API 34 ScanResult.getApMldMacAddress()
                    val method = scanResult.javaClass.getMethod("getApMldMacAddress")
                    val macObj = method.invoke(scanResult)
                    macObj?.toString() ?: scanResult.BSSID
                } catch (_: Exception) {
                    scanResult.BSSID
                }
            } else {
                scanResult.BSSID
            }

            return MloTopology(
                isMloActive = linkList.isNotEmpty(),
                mldMacAddress = mldMac,
                affiliatedLinks = linkList,
                aggregateTheoreticalThroughputMbps = Math.round(totalTheoreticalBw * 10.0) / 10.0
            )
        } catch (_: Exception) {
            return MloTopology(
                isMloActive = false,
                mldMacAddress = null,
                affiliatedLinks = emptyList(),
                aggregateTheoreticalThroughputMbps = 0.0
            )
        }
    }
}
