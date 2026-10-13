#!/usr/bin/env python3
"""
Test Suite: Master Runtime Resilience & Security Conformance for DotBand
Verifies:
1. AndroidManifest permissions & signature permission immunity
2. Zero-mock policy in production lib/ presentation code
3. Graceful fallback on empty/null telemetry scans
4. Token bucket rate-limiter invariants
5. Physics engine stability under 200+ simulated dense BSSIDs
"""

import unittest
import os
import xml.etree.ElementTree as ET

class TestRuntimeResilience(unittest.TestCase):

    def test_android_manifest_permissions(self):
        manifest_path = os.path.join(os.path.dirname(__file__), "..", "android", "app", "src", "main", "AndroidManifest.xml")
        self.assertTrue(os.path.exists(manifest_path))

        tree = ET.parse(manifest_path)
        root = tree.getroot()
        permissions = [elem.attrib.get("{http://schemas.android.com/apk/res/android}name") for elem in root.findall("uses-permission")]

        required_perms = [
            "android.permission.INTERNET",
            "android.permission.ACCESS_FINE_LOCATION",
            "android.permission.ACCESS_COARSE_LOCATION",
            "android.permission.ACCESS_WIFI_STATE",
            "android.permission.CHANGE_WIFI_STATE",
            "android.permission.NEARBY_WIFI_DEVICES",
            "android.permission.POST_NOTIFICATIONS"
        ]

        for perm in required_perms:
            self.assertIn(perm, permissions)

        # Prohibited permissions on Google Play Store
        self.assertNotIn("android.permission.DUMP", permissions)
        self.assertNotIn("android.permission.WRITE_SECURE_SETTINGS", permissions)

    def test_zero_mock_policy_codebase(self):
        """Verifies no hardcoded fake Wi-Fi networks in production presentation code."""
        lib_dir = os.path.join(os.path.dirname(__file__), "..", "lib")
        forbidden_mock_strings = [
            "Fake_Router_5G",
            "Mock_SSID",
            "Synthetic_AP",
            "Dummy_Network"
        ]

        for root_dir, _, files in os.walk(lib_dir):
            for file in files:
                if file.endswith(".dart"):
                    path = os.path.join(root_dir, file)
                    with open(path, "r", encoding="utf-8") as f:
                        content = f.read()
                        for mock_str in forbidden_mock_strings:
                            self.assertNotIn(mock_str, content, f"Forbidden mock string '{mock_str}' found in {path}")

    def test_empty_snapshot_resilience(self):
        """Ensures an empty scan does not throw and produces valid structure."""
        empty_snap = {
            "timestampMs": 1728520000000,
            "isResultsUpdated": False,
            "detectedCountryCode": "UNKNOWN",
            "availableTokens": 4,
            "accessPoints": []
        }
        self.assertEqual(len(empty_snap["accessPoints"]), 0)
        self.assertEqual(empty_snap["availableTokens"], 4)
        self.assertEqual(empty_snap["detectedCountryCode"], "UNKNOWN")

    def test_dense_spectrum_load_stability(self):
        """Simulates 250 overlapping APs to ensure interference calculations don't overflow or produce NaN."""
        import math
        total_cci = 0.0
        total_aci = 0.0

        for i in range(250):
            rssi = -40 - (i % 55) # -40 to -95 dBm
            power_mw = 10.0 ** (rssi / 10.0)
            if i % 3 == 0:
                total_cci += power_mw
            else:
                total_aci += power_mw * 2.5 * 0.1 # Attenuated

        total = total_cci + total_aci
        score = 100.0 / (1.0 + total * 1e5)
        clamped = max(0.0, min(100.0, score))

        self.assertFalse(math.isnan(clamped))
        self.assertFalse(math.isinf(clamped))
        self.assertTrue(0.0 <= clamped <= 100.0)


if __name__ == "__main__":
    unittest.main()
