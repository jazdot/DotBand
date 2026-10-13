import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/wifi_access_point.dart';
import '../../../core/theme/obsidian_theme.dart';
import '../telemetry/presentation/cubit/wifi_scan_cubit.dart';
import '../telemetry/presentation/cubit/wifi_scan_state.dart';

class AccessPointsTab extends StatefulWidget {
  const AccessPointsTab({super.key});

  @override
  State<AccessPointsTab> createState() => _AccessPointsTabState();
}

class _AccessPointsTabState extends State<AccessPointsTab> {
  String _searchQuery = '';
  final Set<String> _expandedBssids = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WifiScanCubit, WifiScanState>(
      builder: (context, state) {
        final aps = state.filteredAccessPoints.where((ap) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return ap.displayName.toLowerCase().contains(q) ||
              ap.bssid.toLowerCase().contains(q) ||
              ap.vendorOui.toLowerCase().contains(q);
        }).toList();

        return Column(
          children: [
            // Search & Filter Header
            _buildSearchHeader(),

            // AP List
            Expanded(
              child: aps.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: aps.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final ap = aps[index];
                        final isExpanded = _expandedBssids.contains(ap.bssid);
                        return _buildApCard(context, ap, isExpanded);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: ObsidianTheme.bgSurface,
      child: TextField(
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search SSID, BSSID, or Vendor...',
          hintStyle: TextStyle(color: ObsidianTheme.textTertiary, fontSize: 13),
          prefixIcon: Icon(Icons.search, size: 18, color: ObsidianTheme.textSecondary),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: ObsidianTheme.bgBase,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
            borderSide: BorderSide(color: ObsidianTheme.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
            borderSide: BorderSide(color: ObsidianTheme.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
            borderSide: BorderSide(color: ObsidianTheme.accentGold),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 48, color: ObsidianTheme.textTertiary),
          const SizedBox(height: 12),
          Text(
            'No Access Points Discovered',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ObsidianTheme.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApCard(BuildContext context, WifiAccessPoint ap, bool isExpanded) {
    Color rssiColor;
    if (ap.rssi >= -60) {
      rssiColor = const Color(0xFF10B981); // Emerald
    } else if (ap.rssi >= -75) {
      rssiColor = const Color(0xFFFBBF24); // Gold
    } else {
      rssiColor = const Color(0xFFEF4444); // Crimson
    }

    return InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedBssids.remove(ap.bssid);
          } else {
            _expandedBssids.add(ap.bssid);
          }
        });
      },
      borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ObsidianTheme.bgSurface,
          borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
          border: Border.all(
            color: ap.isMloActive ? const Color(0xFFA855F7) : ObsidianTheme.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // RSSI Indicator
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: rssiColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                    border: Border.all(color: rssiColor.withOpacity(0.5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${ap.rssi}',
                    style: TextStyle(
                      color: rssiColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // SSID, BSSID, Vendor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              ap.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: ap.isHidden ? ObsidianTheme.textTertiary : ObsidianTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (ap.isMloActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0x33A855F7),
                                borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                                border: Border.all(color: const Color(0xFFA855F7)),
                              ),
                              child: const Text(
                                'Wi-Fi 7 MLO',
                                style: TextStyle(color: Color(0xFFA855F7), fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ap.bssid} • ${ap.vendorOui}',
                        style: ObsidianTheme.tabularNumberStyle(
                          fontSize: 11,
                          color: ObsidianTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Security & Band Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ObsidianTheme.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                      ),
                      child: Text(
                        ap.security.badgeLabel,
                        style: TextStyle(
                          color: ObsidianTheme.accentGold,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ch ${ap.channel} (${ap.channelWidthMhz}MHz)',
                      style: ObsidianTheme.tabularNumberStyle(
                        fontSize: 10,
                        color: ObsidianTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Expanded Telemetry Drawer
            if (isExpanded) ...[
              const Divider(height: 16),
              _buildExpandedDetails(context, ap),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(BuildContext context, WifiAccessPoint ap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vulnerability Warnings
        if (ap.isDragonbloodVulnerable)
          _buildWarningBanner('WPA3 Dragonblood Transition downgrade vulnerability detected.'),
        if (ap.security == WifiSecurity.open)
          _buildCriticalBanner('Unencrypted Open network — cleartext data broadcast.'),

        // MLO Links Detail
        if (ap.isMloActive) ...[
          Text(
            'AFFILIATED WI-FI 7 MLO LINKS (${ap.mloAggregateMbps.toStringAsFixed(0)} Mbps Aggregate):',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFFA855F7),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          ...ap.mloLinks.map((l) => Text(
            '• Link #${l.linkId}: ${l.band} (Ch ${l.channel}) • RSSI: ${l.rssi} dBm • State: ${l.state}',
            style: ObsidianTheme.tabularNumberStyle(fontSize: 10, color: ObsidianTheme.textSecondary),
          )),
          const SizedBox(height: 8),
        ],

        // QBSS Airtime & Station Count
        if (ap.channelUtilizationPct != null || ap.stationCount != null) ...[
          Row(
            children: [
              Text(
                'Airtime Utilization: ${ap.channelUtilizationPct ?? 0}%',
                style: ObsidianTheme.tabularNumberStyle(fontSize: 11, color: ObsidianTheme.textPrimary),
              ),
              const SizedBox(width: 12),
              Text(
                'Clients: ${ap.stationCount ?? 0}',
                style: ObsidianTheme.tabularNumberStyle(fontSize: 11, color: ObsidianTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],

        // RTT Distance
        if (ap.rttDistanceMeters != null) ...[
          Text(
            '802.11mc FTM RTT Distance: ${ap.rttDistanceMeters!.toStringAsFixed(2)} meters',
            style: ObsidianTheme.tabularNumberStyle(fontSize: 11, color: const Color(0xFF10B981)),
          ),
          const SizedBox(height: 4),
        ],

        // Raw Capabilities & Spotlight Action
        Row(
          children: [
            Expanded(
              child: Text(
                'Capabilities: ${ap.capabilities}',
                style: TextStyle(fontSize: 10, color: ObsidianTheme.textTertiary, fontFamily: 'monospace'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<WifiScanCubit>().selectBssid(ap.bssid);
              },
              child: const Text('Spotlight on Spectrum', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWarningBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0x28F59E0B),
        borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, size: 14, color: Color(0xFFF59E0B)),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCriticalBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0x28EF4444),
        borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
        border: Border.all(color: const Color(0xFFEF4444)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: Color(0xFFEF4444)),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
