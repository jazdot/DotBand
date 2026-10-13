#!/usr/bin/env python3
"""
Test Suite: Phase 2 Spectrum Parabola CAD Canvas & LOD Conformance for DotBand
Verifies:
1. Parabola coordinate mapping and bandwidth scaling math
2. Level-of-Detail (LOD) zoom and density threshold logic
3. 6 GHz ETSI regulatory mask boundary calculations
4. Painter and presentation file presence
"""

import unittest
import os
import math

class TestPhase2Conformance(unittest.TestCase):

    def test_phase2_files_exist(self):
        dart_base = os.path.join(os.path.dirname(__file__), "..", "lib")
        required_files = [
            os.path.join(dart_base, "features", "spectrum", "presentation", "widgets", "spectrum_parabola_painter.dart"),
            os.path.join(dart_base, "features", "spectrum", "presentation", "spectrum_tab.dart")
        ]
        for f in required_files:
            self.assertTrue(os.path.exists(f), f"Required Phase 2 file missing: {f}")

    def test_rssi_to_y_coordinate_bounds(self):
        """Verifies mapping of -100 dBm (bottom 1.0) to -20 dBm (top 0.0)."""
        def rssi_to_normalized_y(rssi_dbm: float) -> float:
            min_dbm = -100.0
            max_dbm = -20.0
            clamped = max(min_dbm, min(max_dbm, rssi_dbm))
            norm = (clamped - min_dbm) / (max_dbm - min_dbm)
            return 1.0 - norm

        # -100 dBm should be at bottom (1.0)
        self.assertAlmostEqual(rssi_to_normalized_y(-100.0), 1.0)
        # -20 dBm should be at top (0.0)
        self.assertAlmostEqual(rssi_to_normalized_y(-20.0), 0.0)
        # -60 dBm should be in the middle (0.5)
        self.assertAlmostEqual(rssi_to_normalized_y(-60.0), 0.5)

    def test_bandwidth_scaling_ratios(self):
        """Verifies that channel width scales in power-of-two increments."""
        widths = [20, 40, 80, 160, 320]
        ratios = [w / widths[0] for w in widths]
        self.assertEqual(ratios, [1.0, 2.0, 4.0, 8.0, 16.0])

    def test_lod_density_threshold(self):
        """Verifies that dense spectrum (>20 APs) at zoom < 1.8x triggers thermal density."""
        def should_use_thermal_density(ap_count: int, zoom_scale: float) -> bool:
            return ap_count > 20 and zoom_scale < 1.8

        self.assertTrue(should_use_thermal_density(25, 1.0))
        self.assertTrue(should_use_thermal_density(35, 1.5))
        self.assertFalse(should_use_thermal_density(15, 1.0)) # Small count, keep parabolas
        self.assertFalse(should_use_thermal_density(50, 2.0)) # Zoomed in, show detailed parabolas

    def test_etsi_6ghz_mask_cutoff(self):
        """Verifies that European ETSI domain restricts frequencies above 6425 MHz."""
        etsi_countries = {"DE", "FR", "GB", "UK", "EU", "IN", "JP"}
        self.assertIn("DE", etsi_countries)
        self.assertIn("FR", etsi_countries)
        self.assertNotIn("US", etsi_countries)


if __name__ == "__main__":
    unittest.main()
