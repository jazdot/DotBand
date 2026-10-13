import '../models/wifi_scan_snapshot.dart';

/**
 * Standard CSV and PCAP text dump generator for Wireshark and dotlab CI/CD runners.
 */
class PcapCsvExporter {
  static String exportToCsv(WifiScanSnapshot snapshot) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('TimestampMs,SSID,BSSID,Band,Channel,FrequencyMHz,BandwidthMHz,RSSI_dBm,Security,VendorOUI,ChannelUtilizationPct,Clients,MLO_Active,RTT_Meters');

    for (final ap in snapshot.accessPoints) {
      buffer.writeln([
        snapshot.timestampMs,
        '"${ap.displayName.replaceAll('"', '""')}"',
        ap.bssid,
        ap.band.label,
        ap.channel,
        ap.frequencyMhz,
        ap.channelWidthMhz,
        ap.rssi,
        ap.security.badgeLabel,
        '"${ap.vendorOui}"',
        ap.channelUtilizationPct ?? 0.0,
        ap.stationCount ?? 0,
        ap.isMloActive,
        ap.rttDistanceMeters ?? -1.0,
      ].join(','));
    }

    return buffer.toString();
  }
}
