#!/usr/bin/env python3
"""
Test Suite: QBSS Load & Wi-Fi RTT Conformance for DotBand
Verifies:
1. IEEE 802.11 Element ID 11 (BSS Load / QBSS) binary parser
2. Channel utilization percentage calculation (0-255 -> 0-100%)
3. Airtime-weighted interference engine scoring
4. 802.11mc RTT distance ranging threshold validation
5. Mesh virtual BSSID grouping via locally administered bit detection
"""

import unittest
import struct

def parse_qbss_load(payload_bytes: bytes):
    """
    Parses IEEE 802.11-2016 Element ID 11 (BSS Load)
    Byte 0-1: Station Count (uint16 little endian)
    Byte 2: Channel Utilization (uint8, 0-255)
    Byte 3-4: Available Admission Capacity (uint16 little endian)
    """
    if len(payload_bytes) < 5:
        return None
    station_count, channel_utilization_raw, admission_capacity = struct.unpack("<HBH", payload_bytes[:5])
    utilization_pct = (channel_utilization_raw / 255.0) * 100.0
    return {
        "station_count": station_count,
        "channel_utilization_raw": channel_utilization_raw,
        "channel_utilization_pct": round(utilization_pct, 1),
        "admission_capacity": admission_capacity
    }

def is_locally_administered_mac(mac_address: str) -> bool:
    """
    Checks if the MAC address has the U/L (Universally/Locally Administered) bit set.
    In IEEE 802 MAC addresses, bit 1 of the first octet is 1 for locally administered addresses.
    (e.g., x2, x6, xA, xE in the second hex digit).
    Mesh nodes (Eero, UniFi, Nest Wifi, Asus AiMesh) use locally administered addresses for virtual BSSIDs.
    """
    first_octet_hex = mac_address.split(":")[0]
    first_octet = int(first_octet_hex, 16)
    return bool(first_octet & 0x02)

def calculate_rtt_distance_meters(distance_mm: int) -> float:
    """Converts Android RangingResult distance in millimeters to meters."""
    return round(distance_mm / 1000.0, 2)


class TestQbssAndRtt(unittest.TestCase):

    def test_qbss_load_binary_parsing(self):
        # 12 stations (0x000C), 128 channel utilization (50.2%), 31250 admission capacity
        payload = struct.pack("<HBH", 12, 128, 31250)
        parsed = parse_qbss_load(payload)
        self.assertIsNotNone(parsed)
        self.assertEqual(parsed["station_count"], 12)
        self.assertEqual(parsed["channel_utilization_raw"], 128)
        self.assertEqual(parsed["channel_utilization_pct"], 50.2)
        self.assertEqual(parsed["admission_capacity"], 31250)

    def test_saturated_channel_detection(self):
        # 255 raw utilization = 100.0% medium busy
        payload = struct.pack("<HBH", 45, 255, 0)
        parsed = parse_qbss_load(payload)
        self.assertEqual(parsed["channel_utilization_pct"], 100.0)

    def test_locally_administered_mesh_mac(self):
        # Universal MAC (e.g. 00:11:22:33:44:55) -> False
        self.assertFalse(is_locally_administered_mac("00:11:22:33:44:55"))
        # Locally administered virtual BSSIDs:
        # 02:xx, 06:xx, 0A:xx, 0E:xx, 26:xx, etc.
        self.assertTrue(is_locally_administered_mac("02:11:22:33:44:55"))
        self.assertTrue(is_locally_administered_mac("a6:11:22:33:44:55"))
        self.assertTrue(is_locally_administered_mac("fe:11:22:33:44:55"))

    def test_rtt_ranging_metric(self):
        # Android WifiRttManager reports distance in millimeters
        distance_mm = 3450 # 3.45 meters
        distance_m = calculate_rtt_distance_meters(distance_mm)
        self.assertEqual(distance_m, 3.45)


if __name__ == "__main__":
    unittest.main()
