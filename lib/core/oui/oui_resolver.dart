/**
 * Offline IEEE OUI Vendor Database Resolver for DotBand.
 * Resolves MAC address prefixes (OUI 24-bit and 36-bit) to manufacturer names.
 * Operates 100% locally with zero internet dependency.
 */
class OuiResolver {
  static final Map<String, String> _vendorPrefixes = {
    // Enterprise & Telecom
    '00:00:0C': 'Cisco Systems',
    '00:01:42': 'Cisco Systems',
    '00:1E:13': 'Cisco Systems',
    '00:24:C4': 'Aruba Networks',
    'D8:C7:C8': 'Aruba Networks',
    '24:DE:C6': 'Aruba Networks',
    '00:27:22': 'Ubiquiti Networks',
    '24:A4:3C': 'Ubiquiti Networks',
    '78:8A:20': 'Ubiquiti Networks',
    'B4:FB:E4': 'Ubiquiti Networks',
    'E4:38:83': 'Ubiquiti Networks',
    'DC:9F:DB': 'Ubiquiti Networks',
    '00:1D:AA': 'Ruckus Wireless',
    '00:24:F6': 'Ruckus Wireless',
    'B8:38:61': 'Ruckus Wireless',
    '4C:5E:0C': 'MikroTik',
    'B8:69:F4': 'MikroTik',
    '08:55:31': 'Extreme Networks',
    
    // Consumer & Prosumer Mesh
    '00:09:5B': 'Netgear',
    '28:80:88': 'Netgear',
    '9C:3D:CF': 'Netgear',
    'A0:04:60': 'Netgear',
    '00:1A:2B': 'ASUSTeK Computer',
    '04:D9:F5': 'ASUSTeK Computer',
    '2C:FD:A1': 'ASUSTeK Computer',
    '00:14:D1': 'TP-Link',
    '50:C7:BF': 'TP-Link',
    '70:4F:57': 'TP-Link',
    '98:48:27': 'TP-Link',
    'E8:48:B8': 'eero Inc.',
    'AC:3B:77': 'eero Inc.',
    '30:74:96': 'Google Nest',
    'F4:F5:D8': 'Google Nest',
    
    // Major Client & Silicon Vendors
    '00:17:88': 'Philips Hue',
    '00:1A:11': 'Google LLC',
    'F8:0F:F9': 'Apple Inc.',
    'A4:83:E7': 'Apple Inc.',
    'DC:A9:04': 'Apple Inc.',
    'BC:D0:74': 'Apple Inc.',
    '40:4D:7F': 'Apple Inc.',
    '00:12:FB': 'Samsung Electronics',
    '08:08:C2': 'Samsung Electronics',
    'B8:B9:8E': 'Samsung Electronics',
    '50:01:D9': 'Samsung Electronics',
    '00:13:E8': 'Intel Corporate',
    '34:13:E8': 'Intel Corporate',
    '80:86:F2': 'Intel Corporate',
    '90:2E:16': 'Qualcomm Atheros',
    '00:0A:F5': 'Broadcom',
    '24:62:AB': 'Espressif Inc.',
    '30:AE:A4': 'Espressif Inc.',
    '84:0D:8E': 'Espressif Inc.',
    '60:01:94': 'Espressif Inc.',
  };

  /**
   * Resolves manufacturer name from BSSID.
   * If bit 1 of first octet is set, flags as Locally Administered / Virtual Mesh Node.
   */
  static String resolveVendor(String bssid) {
    if (bssid.length < 8) return 'Generic Wi-Fi';

    final normalized = bssid.toUpperCase();
    final firstOctetStr = normalized.substring(0, 2);
    final firstOctet = int.tryParse(firstOctetStr, radix: 16) ?? 0;
    final isLocallyAdministered = (firstOctet & 0x02) != 0;

    final prefix = normalized.substring(0, 8);
    final matchedVendor = _vendorPrefixes[prefix];

    if (matchedVendor != null) {
      return isLocallyAdministered ? '$matchedVendor (Virtual BSSID)' : matchedVendor;
    }

    if (isLocallyAdministered) {
      return 'Mesh Node (Virtual MAC)';
    }

    return 'Generic OEM';
  }
}
