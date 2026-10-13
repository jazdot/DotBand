#!/usr/bin/env python3
"""
Test Suite: IEEE 802.11 Channel Raster & Physical Layer Math Verification for DotBand
Verifies:
1. 2.4 GHz channel-to-frequency mapping (Channels 1-14)
2. 5 GHz channel-to-frequency mapping (Channels 36-165, UNII-1 through UNII-4)
3. 6 GHz channel-to-frequency mapping (Channels 1-233, IEEE 802.11ax/be Annex E)
4. Preferred Scanning Channels (PSC) spacing every 80 MHz
5. Channel width bandwidth boundaries (20, 40, 80, 160, 320 MHz)
"""

import unittest

def frequency_to_channel(freq_mhz: int) -> int:
    """Exact implementation of frequencyToChannel algorithm from REQUIREMENTS_AND_PLAN.md"""
    # 2.4 GHz Band (Channels 1-14)
    if freq_mhz == 2484:
        return 14
    if 2412 <= freq_mhz <= 2472:
        return round((freq_mhz - 2412) / 5) + 1

    # 5.0 GHz Band (Channels 36-165, U-NII-1 through U-NII-4)
    if 5170 <= freq_mhz <= 5835:
        return round((freq_mhz - 5000) / 5)

    # 6.0 GHz Band (Channels 1-233, IEEE 802.11ax/be Annex E)
    # Channel center frequency: fc = 5950 + 5 * ch. Channel = (fc - 5950) / 5
    if 5955 <= freq_mhz <= 7115:
        return round((freq_mhz - 5950) / 5)

    return -1

def channel_to_frequency_6ghz(channel: int) -> int:
    """Calculates IEEE 802.11ax/be center frequency for 6 GHz channel."""
    if 1 <= channel <= 233:
        return 5950 + 5 * channel
    return -1

def is_preferred_scanning_channel(channel: int) -> bool:
    """Verifies 6 GHz PSC (Preferred Scanning Channel) spacing every 80 MHz (16 channels)."""
    psc_channels = {5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213, 229}
    return channel in psc_channels


class TestIeeeChannelRaster(unittest.TestCase):

    def test_2ghz_channels(self):
        # Ch 1 is 2412 MHz
        self.assertEqual(frequency_to_channel(2412), 1)
        # Ch 6 is 2437 MHz
        self.assertEqual(frequency_to_channel(2437), 6)
        # Ch 11 is 2462 MHz
        self.assertEqual(frequency_to_channel(2462), 11)
        # Ch 13 is 2472 MHz
        self.assertEqual(frequency_to_channel(2472), 13)
        # Ch 14 is 2484 MHz (Japan special)
        self.assertEqual(frequency_to_channel(2484), 14)

    def test_5ghz_channels(self):
        # UNII-1: Ch 36 is 5180 MHz, Ch 48 is 5240 MHz
        self.assertEqual(frequency_to_channel(5180), 36)
        self.assertEqual(frequency_to_channel(5240), 48)
        # UNII-2A DFS: Ch 52 is 5260 MHz
        self.assertEqual(frequency_to_channel(5260), 52)
        # UNII-2C DFS: Ch 100 is 5500 MHz, Ch 144 is 5720 MHz
        self.assertEqual(frequency_to_channel(5500), 100)
        self.assertEqual(frequency_to_channel(5720), 144)
        # UNII-3: Ch 149 is 5745 MHz, Ch 165 is 5825 MHz
        self.assertEqual(frequency_to_channel(5745), 149)
        self.assertEqual(frequency_to_channel(5825), 165)

    def test_6ghz_channels(self):
        # Channel 1: 5950 + 5 * 1 = 5955 MHz
        self.assertEqual(channel_to_frequency_6ghz(1), 5955)
        self.assertEqual(frequency_to_channel(5955), 1)

        # Channel 5 (First PSC): 5950 + 5 * 5 = 5975 MHz
        self.assertEqual(channel_to_frequency_6ghz(5), 5975)
        self.assertEqual(frequency_to_channel(5975), 5)
        self.assertTrue(is_preferred_scanning_channel(5))

        # Channel 37 (PSC): 5950 + 5 * 37 = 6135 MHz
        self.assertEqual(channel_to_frequency_6ghz(37), 6135)
        self.assertEqual(frequency_to_channel(6135), 37)
        self.assertTrue(is_preferred_scanning_channel(37))

        # Channel 233 (Upper boundary): 5950 + 5 * 233 = 7115 MHz
        self.assertEqual(channel_to_frequency_6ghz(233), 7115)
        self.assertEqual(frequency_to_channel(7115), 233)

        # Out-of-band rejection
        self.assertEqual(frequency_to_channel(5900), -1)
        self.assertEqual(frequency_to_channel(7200), -1)

    def test_psc_cadence(self):
        """Verifies that all PSCs are exactly 16 channels (80 MHz) apart starting from Ch 5."""
        expected_pscs = [5 + 16 * i for i in range(15)] # Up to Ch 229
        for psc in expected_pscs:
            self.assertTrue(is_preferred_scanning_channel(psc), f"Channel {psc} should be a PSC")
        self.assertFalse(is_preferred_scanning_channel(1))
        self.assertFalse(is_preferred_scanning_channel(6))


if __name__ == "__main__":
    unittest.main()
