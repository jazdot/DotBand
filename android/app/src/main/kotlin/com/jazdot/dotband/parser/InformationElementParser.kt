package com.jazdot.dotband.parser

import android.net.wifi.ScanResult
import android.os.Build
import androidx.annotation.RequiresApi
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Real-time parser for IEEE 802.11 Information Elements (IEs) extracted from beacon frames.
 * Requires API 30+ (Android 11) for ScanResult.informationElements.
 */
object InformationElementParser {

    data class QbssLoad(
        val stationCount: Int,
        val channelUtilizationRaw: Int,
        val channelUtilizationPct: Double,
        val availableAdmissionCapacity: Int
    )

    data class HeOperationInfo(
        val bssColor: Int,
        val isPartialBssColor: Boolean,
        val isBssColorDisabled: Boolean
    )

    /**
     * Extracts IEEE 802.11-2016 Element ID 11 (BSS Load / QBSS).
     * Yields real-time station count and channel airtime utilization percentage (0-100%).
     */
    fun parseQbssLoad(bytes: ByteArray): QbssLoad? {
        if (bytes.size < 5) return null
        val buffer = ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN)
        val stationCount = buffer.short.toInt() and 0xFFFF
        val rawUtilization = buffer.get().toInt() and 0xFF
        val utilizationPct = (rawUtilization / 255.0) * 100.0
        val admissionCapacity = buffer.short.toInt() and 0xFFFF

        return QbssLoad(
            stationCount = stationCount,
            channelUtilizationRaw = rawUtilization,
            channelUtilizationPct = Math.round(utilizationPct * 10.0) / 10.0,
            availableAdmissionCapacity = admissionCapacity
        )
    }

    /**
     * Extracts IEEE 802.11d Element ID 7 (Country Information Element).
     * Resolves the country code string (e.g. "US ", "DE ", "JP ").
     */
    fun parseCountryCode(bytes: ByteArray): String? {
        if (bytes.size < 3) return null
        return try {
            val codeChars = byteArrayOf(bytes[0], bytes[1])
            String(codeChars, Charsets.US_ASCII).trim()
        } catch (_: Exception) {
            null
        }
    }

    /**
     * Extracts IEEE 802.11ax Element ID 255 Ext 36 (HE Operation).
     * Extracts BSS Color ID (bits 0-5) to evaluate Spatial Reuse (SR / OBSS_PD).
     */
    fun parseHeOperation(bytes: ByteArray): HeOperationInfo? {
        if (bytes.size < 6) return null
        val bssColorByte = bytes[3].toInt() and 0xFF
        val bssColor = bssColorByte and 0x3F // Bits 0-5
        val isPartial = (bssColorByte and 0x40) != 0 // Bit 6
        val isDisabled = (bssColorByte and 0x80) != 0 // Bit 7

        return HeOperationInfo(
            bssColor = bssColor,
            isPartialBssColor = isPartial,
            isBssColorDisabled = isDisabled
        )
    }

    /**
     * Evaluates whether a BSSID MAC address is locally administered (Mesh virtual node).
     * Bit 1 of the first octet is set to 1 for locally administered addresses.
     */
    fun isLocallyAdministeredMac(bssid: String): Boolean {
        return try {
            val firstOctet = bssid.substringBefore(":").toInt(16)
            (firstOctet and 0x02) != 0
        } catch (_: Exception) {
            false
        }
    }
}
