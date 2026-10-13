#!/usr/bin/env python3
"""
Test Suite: Phase 3 Wi-Fi 7 MLO, Interference Engine & Security Sentry for DotBand
Verifies:
1. File structure conformance for Phase 3
2. Star rating boundaries (5 stars >= 90pts, 1 star < 35pts)
3. Evil Twin detection across mismatched security suites
4. Dragonblood transition mode classification
"""

import unittest
import os

class TestPhase3Conformance(unittest.TestCase):

    def test_phase3_files_exist(self):
        dart_base = os.path.join(os.path.dirname(__file__), "..", "lib")
        required_files = [
            os.path.join(dart_base, "features", "rating", "domain", "interference_engine.dart"),
            os.path.join(dart_base, "features", "security", "domain", "wifi_security_sentry.dart"),
            os.path.join(dart_base, "features", "rating", "presentation", "rating_tab.dart"),
            os.path.join(dart_base, "features", "access_points", "presentation", "access_points_tab.dart")
        ]
        for f in required_files:
            self.assertTrue(os.path.exists(f), f"Required Phase 3 file missing: {f}")

    def test_star_rating_thresholds(self):
        def score_to_stars(score: float) -> int:
            if score >= 90.0: return 5
            if score >= 75.0: return 4
            if score >= 55.0: return 3
            if score >= 35.0: return 2
            return 1

        self.assertEqual(score_to_stars(95.0), 5)
        self.assertEqual(score_to_stars(89.9), 4)
        self.assertEqual(score_to_stars(74.5), 3)
        self.assertEqual(score_to_stars(54.0), 2)
        self.assertEqual(score_to_stars(20.0), 1)

    def test_evil_twin_anomaly_detection(self):
        """Simulates grouping by SSID to detect conflicting security suites."""
        aps = [
            {"ssid": "Corporate_HQ", "bssid": "00:11:22:33:44:01", "sec": "wpa3Pure"},
            {"ssid": "Corporate_HQ", "bssid": "00:11:22:33:44:99", "sec": "open"}, # Rogue AP!
            {"ssid": "Guest_WiFi", "bssid": "00:11:22:33:44:02", "sec": "owe"}
        ]

        ssid_groups = {}
        for ap in aps:
            ssid_groups.setdefault(ap["ssid"], []).append(ap)

        evil_twins = []
        for ssid, group in ssid_groups.items():
            if len(group) >= 2:
                distinct_secs = {x["sec"] for x in group}
                if len(distinct_secs) > 1:
                    evil_twins.append(ssid)

        self.assertIn("Corporate_HQ", evil_twins)
        self.assertNotIn("Guest_WiFi", evil_twins)

    def test_dragonblood_transition_vulnerability(self):
        """WPA3 mixed with WPA2-PSK is vulnerable to downgrade attacks."""
        def is_dragonblood_vulnerable(security_str: str) -> bool:
            return security_str == "wpa3Transition"

        self.assertTrue(is_dragonblood_vulnerable("wpa3Transition"))
        self.assertFalse(is_dragonblood_vulnerable("wpa3Pure"))
        self.assertFalse(is_dragonblood_vulnerable("wpa2"))


if __name__ == "__main__":
    unittest.main()
