import '../../../core/models/wifi_access_point.dart';

enum ThreatSeverity {
  info,
  warning,
  critical;
}

class SecurityThreat {
  final String title;
  final String description;
  final ThreatSeverity severity;
  final String bssid;
  final String ssid;

  const SecurityThreat({
    required this.title,
    required this.description,
    required this.severity,
    required this.bssid,
    required this.ssid,
  });
}

class WifiSecuritySentry {
  /**
   * Audits security profile across all visible BSSIDs.
   * Detects Dragonblood transition downgrade, unencrypted open networks,
   * unmanaged PMF, and Evil Twin AP anomalies.
   */
  static List<SecurityThreat> auditSecurity(List<WifiAccessPoint> aps) {
    final threats = <SecurityThreat>[];

    // 1. Group APs by SSID to check for Evil Twin / Rogue APs
    final ssidGroups = <String, List<WifiAccessPoint>>{};
    for (final ap in aps) {
      if (ap.isHidden) continue;
      ssidGroups.putIfAbsent(ap.ssid, () => []).add(ap);
    }

    // Evil Twin / Conflicting Security Audit
    for (final entry in ssidGroups.entries) {
      final group = entry.value;
      if (group.length >= 2) {
        final distinctSecurities = group.map((e) => e.security).toSet();
        if (distinctSecurities.length > 1) {
          threats.add(
            SecurityThreat(
              title: 'Evil Twin / Rogue AP Anomaly',
              description: 'Multiple BSSIDs broadcast SSID "${entry.key}" with mismatched security suites: ${distinctSecurities.map((e) => e.badgeLabel).join(", ")}. High risk of MITM credential spoofing.',
              severity: ThreatSeverity.critical,
              bssid: group.first.bssid,
              ssid: entry.key,
            ),
          );
        }
      }
    }

    // 2. Individual BSSID Protocol Audits
    for (final ap in aps) {
      // Dragonblood Transition Downgrade
      if (ap.security == WifiSecurity.wpa3Transition) {
        threats.add(
          SecurityThreat(
            title: 'WPA3 Dragonblood Vulnerability',
            description: 'AP "${ap.displayName}" broadcasts WPA3-Transition mode (WPA3-SAE mixed with WPA2-PSK). Susceptible to SAE hunting-and-pecking timing attack and downgrade attacks.',
            severity: ThreatSeverity.warning,
            bssid: ap.bssid,
            ssid: ap.ssid,
          ),
        );
      }

      // Plaintext Open Network (without OWE)
      if (ap.security == WifiSecurity.open) {
        threats.add(
          SecurityThreat(
            title: 'Unencrypted Open Network',
            description: 'AP "${ap.displayName}" does not use encryption or Opportunistic Wireless Encryption (OWE). All wireless data is broadcast in cleartext.',
            severity: ThreatSeverity.critical,
            bssid: ap.bssid,
            ssid: ap.ssid,
          ),
        );
      }

      // 6 GHz Security Violation (WPA2 or Open is forbidden in 6 GHz by standard)
      if (ap.band == WifiBand.band6G && (ap.security == WifiSecurity.wpa2 || ap.security == WifiSecurity.open || ap.security == WifiSecurity.wep)) {
        threats.add(
          SecurityThreat(
            title: '6 GHz Wi-Fi Alliance Security Non-Conformance',
            description: 'AP "${ap.displayName}" operates on 6 GHz band without mandatory WPA3-SAE or OWE encryption.',
            severity: ThreatSeverity.critical,
            bssid: ap.bssid,
            ssid: ap.ssid,
          ),
        );
      }

      // PMF Disabled Warning
      if (ap.security == WifiSecurity.wpa2 && !ap.isPmfMandatory && !ap.isPmfCapable) {
        threats.add(
          SecurityThreat(
            title: 'Missing Protected Management Frames (802.11w)',
            description: 'AP "${ap.displayName}" does not negotiate PMF. Vulnerable to deauthentication & disassociation frame spoofing attacks.',
            severity: ThreatSeverity.info,
            bssid: ap.bssid,
            ssid: ap.ssid,
          ),
        );
      }
    }

    return threats;
  }
}
