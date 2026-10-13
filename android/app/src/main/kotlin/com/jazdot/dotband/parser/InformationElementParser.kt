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
    fun parseQbssLoad(buffer: ByteBuffer): QbssLoad? {
        if (buffer.remaining() < 5) return null
        val dup = buffer.duplicate().order(ByteOrder.LITTLE_ENDIAN)
        val stationCount = dup.short.toInt() and 0xFFFF
        val rawUtilization = dup.get().toInt() and 0xFF
        val utilizationPct = (rawUtilization / 255.0) * 100.0
        val admissionCapacity = dup.short.toInt() and 0xFFFF

        return QbssLoad(
            stationCount = stationCount,
            channelUtilizationRaw = rawUtilization,
            channelUtilizationPct = Math.round(utilizationPct * 10.0) / 10.0,
            availableAdmissionCapacity = admissionCapacity
        )
    }

    fun parseQbssLoad(bytes: ByteArray): QbssLoad? = parseQbssLoad(ByteBuffer.wrap(bytes))

    /**
     * Extracts IEEE 802.11d Element ID 7 (Country Information Element).
     * Resolves the country code string (e.g. "US ", "DE ", "JP ").
     */
    fun parseCountryCode(buffer: ByteBuffer): String? {
        if (buffer.remaining() < 3) return null
        return try {
            val dup = buffer.duplicate()
            val codeChars = byteArrayOf(dup.get(), dup.get())
            String(codeChars, Charsets.US_ASCII).trim()
        } catch (_: Exception) {
            null
        }
    }

    fun parseCountryCode(bytes: ByteArray): String? = parseCountryCode(ByteBuffer.wrap(bytes))

    /**
     * Extracts IEEE 802.11ax Element ID 255 Ext 36 (HE Operation).
     * Extracts BSS Color ID (bits 0-5) to evaluate Spatial Reuse (SR / OBSS_PD).
     */
    fun parseHeOperation(buffer: ByteBuffer): HeOperationInfo? {
        if (buffer.remaining() < 6) return null
        val dup = buffer.duplicate()
        dup.get()
        dup.get()
        dup.get()
        val bssColorByte = dup.get().toInt() and 0xFF
        val bssColor = bssColorByte and 0x3F // Bits 0-5
        val isPartial = (bssColorByte and 0x40) != 0 // Bit 6
        val isDisabled = (bssColorByte and 0x80) != 0 // Bit 7

        return HeOperationInfo(
            bssColor = bssColor,
            isPartialBssColor = isPartial,
            isBssColorDisabled = isDisabled
        )
    }

    fun parseHeOperation(bytes: ByteArray): HeOperationInfo? = parseHeOperation(ByteBuffer.wrap(bytes))

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
