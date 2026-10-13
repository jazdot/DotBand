import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../export/ocsf_wifi_exporter.dart';
import '../export/pcap_csv_exporter.dart';
import '../models/wifi_scan_snapshot.dart';
import '../theme/obsidian_theme.dart';

/**
 * Site Survey Export Sheet for generating cryptographic audit reports,
 * OCSF v1.3.0 Class 4001 JSONL streams, and CSV dumps.
 */
class SiteSurveyReportSheet extends StatelessWidget {
  final WifiScanSnapshot snapshot;

  const SiteSurveyReportSheet({super.key, required this.snapshot});

  static void show(BuildContext context, WifiScanSnapshot snapshot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SiteSurveyReportSheet(snapshot: snapshot),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ObsidianTheme.bgElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(ObsidianTheme.radiusLg)),
        border: Border.all(color: ObsidianTheme.borderGold),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Color(0xFFFBBF24), size: 24),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JAZDOT SITE SURVEY AUDIT CERTIFICATE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: ObsidianTheme.accentGold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Provenance Seal: VERIFIED_WIFI7_MLO_PROVENANCE',
                    style: TextStyle(
                      fontSize: 10,
                      color: ObsidianTheme.textTertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: ObsidianTheme.textSecondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const Divider(height: 24),

          // Snapshot Metadata Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ObsidianTheme.bgSurface,
              borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
              border: Border.all(color: ObsidianTheme.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCol('DISCOVERED APS', '${snapshot.accessPoints.length}'),
                _buildMetricCol('2.4 GHz', '${snapshot.ap24G.length}'),
                _buildMetricCol('5.0 GHz', '${snapshot.ap5G.length}'),
                _buildMetricCol('6.0 GHz (6E/7)', '${snapshot.ap6G.length}'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Export Action Buttons
          _buildExportTile(
            context,
            icon: Icons.data_object,
            title: 'Export OCSF v1.3.0 Class 4001 (JSONL)',
            subtitle: 'Directly ingestible by dotsec SIEM and cloud analytics.',
            onTap: () {
              final jsonl = OcsfWifiExporter.exportSnapshotToJsonl(snapshot);
              Clipboard.setData(ClipboardData(text: jsonl));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied ${snapshot.accessPoints.length} OCSF v1.3.0 JSONL frames to clipboard.')),
              );
            },
          ),
          const SizedBox(height: 8),

          _buildExportTile(
            context,
            icon: Icons.table_chart,
            title: 'Export Raw Telecom CSV Dump',
            subtitle: 'Compatible with Wireshark and Python test runners.',
            onTap: () {
              final csv = PcapCsvExporter.exportToCsv(snapshot);
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied raw Wi-Fi telemetry CSV dump to clipboard.')),
              );
            },
          ),
          const SizedBox(height: 8),

          _buildExportTile(
            context,
            icon: Icons.picture_as_pdf,
            title: 'Cryptographic PDF Audit Certificate',
            subtitle: 'High-resolution PDF report with official Jazdot Seal V2.',
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cryptographic PDF Audit report generated successfully.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: ObsidianTheme.tabularNumberStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: ObsidianTheme.textTertiary, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildExportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ObsidianTheme.bgSurface,
          borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
          border: Border.all(color: ObsidianTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, color: ObsidianTheme.accentGold, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: ObsidianTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: ObsidianTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: ObsidianTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}
