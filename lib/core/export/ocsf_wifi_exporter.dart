import 'dart:convert';
import '../models/wifi_access_point.dart';
import '../models/wifi_scan_snapshot.dart';

/**
 * Exporter converting DotBand Wi-Fi snapshots into Open Cybersecurity Schema
 * Framework (OCSF) v1.3.0 Class 4001 (Network Activity) JSONL events.
 * Directly ingestible by dotsec SIEM and dotops telemetry ingestion pipelines.
 */
class OcsfWifiExporter {
  static String exportSnapshotToJsonl(WifiScanSnapshot snapshot) {
    final buffer = StringBuffer();

    for (final ap in snapshot.accessPoints) {
      final ocsfEvent = {
        'class_uid': 4001, // Network Activity
        'category_uid': 4, // Network Activity Category
        'activity_id': 1,  // Scan / Beacon Discovery
        'severity_id': ap.security == WifiSecurity.open ? 4 : (ap.isDragonbloodVulnerable ? 3 : 1),
        'time': snapshot.timestampMs,
        'metadata': {
          'version': '1.3.0',
          'product': {
            'name': 'DotBand',
            'vendor_name': 'Jazdot Enterprises',
            'feature': 'Tri-Band Wi-Fi Spectrum Telemetry'
          },
          'profiles': ['wifi_rf_telemetry'],
        },
        'network_endpoint': {
          'mac': ap.bssid,
          'hostname': ap.displayName,
          'type': 'Access Point',
        },
        'wifi_telemetry': {
          'ssid': ap.ssid,
          'bssid': ap.bssid,
          'band': ap.band.label,
          'channel': ap.channel,
          'frequency_mhz': ap.frequencyMhz,
          'channel_width_mhz': ap.channelWidthMhz,
          'signal_dbm': ap.rssi,
          'security_standard': ap.security.badgeLabel,
          'is_pmf_mandatory': ap.isPmfMandatory,
          'is_pmf_capable': ap.isPmfCapable,
          'is_ftm_rtt_capable': ap.is80211mcResponder,
          'is_mesh_virtual_bssid': ap.isLocallyAdministeredMac,
          'vendor_oui': ap.vendorOui,
          'country_code': snapshot.detectedCountryCode,
          'qbss_load': {
            'station_count': ap.stationCount,
            'channel_utilization_pct': ap.channelUtilizationPct,
          },
          'mlo_affiliations': {
            'is_mlo_active': ap.isMloActive,
            'mld_mac_address': ap.mldMacAddress,
            'affiliated_links': ap.mloLinks.map((e) => e.toMap()).toList(),
            'aggregate_theoretical_mbps': ap.mloAggregateMbps,
          },
        },
        'security_analysis': {
          'dragonblood_vulnerable': ap.isDragonbloodVulnerable,
          'unencrypted_cleartext': ap.security == WifiSecurity.open,
          'rogue_anomaly_suspected': false,
        },
      };

      buffer.writeln(jsonEncode(ocsfEvent));
    }

    return buffer.toString();
  }
}
