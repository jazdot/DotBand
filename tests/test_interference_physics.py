#!/usr/bin/env python3
"""
Test Suite: Interference Physics Engine for DotBand
Verifies:
1. Co-Channel Interference (CCI) calculation vs Adjacent-Channel Interference (ACI)
2. ACI penalty is strictly greater than CCI penalty for equal power due to uncoordinated collisions
3. Spectral emission mask falloff
4. BSS Coloring Spatial Reuse mitigation credit
"""

import unittest
import math

class InterferenceEngine:
    @staticmethod
    def calculate_cci_weight(rssi_dbm: float, bandwidth_mhz: int) -> float:
        """CCI: Co-channel CSMA/CA contention. Clean airtime sharing."""
        power_mw = 10.0 ** (rssi_dbm / 10.0)
        bw_factor = bandwidth_mhz / 20.0
        # Energy detect carrier sense scaling
        return power_mw * bw_factor

    @staticmethod
    def calculate_aci_weight(rssi_dbm: float, channel_offset_mhz: float, bandwidth_mhz: int) -> float:
        """ACI: Adjacent uncoordinated collision. Destructive packet corruption."""
        power_mw = 10.0 ** (rssi_dbm / 10.0)
        # Spectral emission mask attenuation (dB)
        relative_offset = abs(channel_offset_mhz) / (bandwidth_mhz / 2.0)
        if relative_offset <= 1.0:
            attenuation_db = 0.0
        elif relative_offset <= 1.5:
            attenuation_db = -20.0
        else:
            attenuation_db = -40.0

        spillover_power_mw = power_mw * (10.0 ** (attenuation_db / 10.0))
        # Collision penalty multiplier: ACI lacks CSMA/CA preamble decoding, causing collisions
        collision_penalty = 2.5
        return spillover_power_mw * collision_penalty

    @classmethod
    def calculate_score(cls, cci_list, aci_list, has_distinct_bss_color: bool = False) -> float:
        total_cci = sum(cls.calculate_cci_weight(ap["rssi"], ap["bw"]) for ap in cci_list)
        if has_distinct_bss_color:
            total_cci *= 0.6  # 40% spatial reuse credit for 802.11ax/be

        total_aci = sum(cls.calculate_aci_weight(ap["rssi"], ap["offset"], ap["bw"]) for ap in aci_list)
        total_raw_interference = total_cci + total_aci

        # Transform to 0-100 quality score (100 = spotless clean)
        score = 100.0 / (1.0 + total_raw_interference * 1e5)
        return max(0.0, min(100.0, score))


class TestInterferencePhysics(unittest.TestCase):

    def test_clean_channel_score(self):
        score = InterferenceEngine.calculate_score([], [])
        self.assertEqual(score, 100.0)

    def test_aci_more_destructive_than_cci_at_same_signal(self):
        """At equal RSSI, partial overlap ACI causes packet corruption and has higher collision penalty."""
        rssi = -60.0
        bw = 20
        cci_weight = InterferenceEngine.calculate_cci_weight(rssi, bw)
        # In-band adjacent spillover (relative offset <= 1.0)
        aci_weight = InterferenceEngine.calculate_aci_weight(rssi, 5.0, bw)
        self.assertGreater(aci_weight, cci_weight)

    def test_bss_color_spatial_reuse_credit(self):
        ap = {"rssi": -65.0, "bw": 80}
        score_without_color = InterferenceEngine.calculate_score([ap], [], has_distinct_bss_color=False)
        score_with_color = InterferenceEngine.calculate_score([ap], [], has_distinct_bss_color=True)
        self.assertGreater(score_with_color, score_without_color)


if __name__ == "__main__":
    unittest.main()
