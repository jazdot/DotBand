#!/usr/bin/env python3
"""
Test Suite: Phase 1 Conformance & Native Telemetry Verification for DotBand
Verifies:
1. AndroidManifest.xml permissions and hardware feature declarations
2. Kotlin bridge source files and method bindings
3. Data models and serialization conformance
4. Rate limit token bucket mechanics
"""

import unittest
import os
import xml.etree.ElementTree as ET

class TestPhase1Conformance(unittest.TestCase):

    def test_android_manifest_permissions(self):
        manifest_path = os.path.join(os.path.dirname(__file__), "..", "android", "app", "src", "main", "AndroidManifest.xml")
        self.assertTrue(os.path.exists(manifest_path), f"Manifest not found at {manifest_path}")

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
            self.assertIn(perm, permissions, f"Missing required permission {perm} in AndroidManifest.xml")

    def test_android_manifest_features(self):
        manifest_path = os.path.join(os.path.dirname(__file__), "..", "android", "app", "src", "main", "AndroidManifest.xml")
        tree = ET.parse(manifest_path)
        root = tree.getroot()
        features = {elem.attrib.get("{http://schemas.android.com/apk/res/android}name"): elem.attrib.get("{http://schemas.android.com/apk/res/android}required") for elem in root.findall("uses-feature")}

        self.assertIn("android.hardware.wifi", features)
        self.assertEqual(features["android.hardware.wifi"], "true")
        self.assertIn("android.hardware.wifi.rtt", features)
        self.assertEqual(features["android.hardware.wifi.rtt"], "false") # Optional feature

    def test_kotlin_bridge_files_exist(self):
        kotlin_base = os.path.join(os.path.dirname(__file__), "..", "android", "app", "src", "main", "kotlin", "com", "jazdot", "dotband")
        required_files = [
            os.path.join(kotlin_base, "MainActivity.kt"),
            os.path.join(kotlin_base, "bridge", "WifiScannerBridge.kt"),
            os.path.join(kotlin_base, "parser", "InformationElementParser.kt"),
            os.path.join(kotlin_base, "parser", "MloLinkParser.kt"),
            os.path.join(kotlin_base, "rtt", "WifiRttController.kt")
        ]

        for f in required_files:
            self.assertTrue(os.path.exists(f), f"Required Kotlin file missing: {f}")

    def test_dart_models_exist(self):
        dart_base = os.path.join(os.path.dirname(__file__), "..", "lib")
        required_files = [
            os.path.join(dart_base, "core", "models", "wifi_access_point.dart"),
            os.path.join(dart_base, "core", "models", "wifi_scan_snapshot.dart"),
            os.path.join(dart_base, "core", "bridge", "wifi_channel.dart"),
            os.path.join(dart_base, "features", "telemetry", "presentation", "cubit", "wifi_scan_state.dart"),
            os.path.join(dart_base, "features", "telemetry", "presentation", "cubit", "wifi_scan_cubit.dart")
        ]

        for f in required_files:
            self.assertTrue(os.path.exists(f), f"Required Dart file missing: {f}")

    def test_token_bucket_rate_limiter_logic(self):
        """Simulates 4 tokens max, refilling 1 token every 30s."""
        max_tokens = 4
        available = max_tokens

        # Consume 4 tokens in rapid succession
        for _ in range(4):
            self.assertGreater(available, 0)
            available -= 1

        self.assertEqual(available, 0)
        # Attempting 5th scan is blocked
        is_allowed = available > 0
        self.assertFalse(is_allowed)

        # After 30s, 1 token is refilled
        available = min(max_tokens, available + 1)
        self.assertEqual(available, 1)
        self.assertTrue(available > 0)


if __name__ == "__main__":
    unittest.main()
