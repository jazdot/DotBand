import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/wifi_access_point.dart';
import '../../../core/theme/obsidian_theme.dart';
import '../../telemetry/presentation/cubit/wifi_scan_cubit.dart';
import '../../telemetry/presentation/cubit/wifi_scan_state.dart';
import 'widgets/spectrum_parabola_painter.dart';

class SpectrumTab extends StatefulWidget {
  const SpectrumTab({super.key});

  @override
  State<SpectrumTab> createState() => _SpectrumTabState();
}

class _SpectrumTabState extends State<SpectrumTab> {
  double _zoomScale = 1.0;
  double _panOffset = 0.0;
  double _baseScale = 1.0;
  double _basePan = 0.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WifiScanCubit, WifiScanState>(
      builder: (context, state) {
        final aps = state.filteredAccessPoints;
        final selectedAp = state.selectedAccessPoint;

        return Column(
          children: [
            // Top Band Filter Selector Chips
            _buildBandFilterRow(context, state),

            // Main Interactive Canvas
            Expanded(
              child: GestureDetector(
                onScaleStart: (details) {
                  _baseScale = _zoomScale;
                  _basePan = _panOffset;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _zoomScale = (_baseScale * details.scale).clamp(1.0, 10.0);
                    _panOffset = _basePan + details.focalPointDelta.dx;
                  });
                },
                onDoubleTap: () {
                  setState(() {
                    _zoomScale = 1.0;
                    _panOffset = 0.0;
                  });
                },
                child: Container(
                  color: ObsidianTheme.bgBase,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: SpectrumParabolaPainter(
                            accessPoints: aps,
                            band: state.selectedBandFilter,
                            zoomScale: _zoomScale,
                            panOffset: _panOffset,
                            spotlightBssid: state.selectedBssid,
                            countryCode: state.snapshot.detectedCountryCode,
                          ),
                        ),
                      ),

                      // Zoom Level Badge & Reset
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ObsidianTheme.bgSurface.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                            border: Border.all(color: ObsidianTheme.borderGold),
                          ),
                          child: Text(
                            '${_zoomScale.toStringAsFixed(1)}x ZOOM',
                            style: ObsidianTheme.tabularNumberStyle(
                              fontSize: 10,
                              color: ObsidianTheme.accentGold,
                            ),
                          ),
                        ),
                      ),

                      // Selected AP Spotlight Overlay Card
                      if (selectedAp != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: _buildSpotlightCard(context, selectedAp),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBandFilterRow(BuildContext context, WifiScanState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: ObsidianTheme.bgSurface,
      child: Row(
        children: [
          _buildFilterChip(context, 'ALL TRI-BAND', WifiBand.unknown, state.selectedBandFilter),
          const SizedBox(width: 6),
          _buildFilterChip(context, '2.4 GHz', WifiBand.band24G, state.selectedBandFilter),
          const SizedBox(width: 6),
          _buildFilterChip(context, '5.0 GHz', WifiBand.band5G, state.selectedBandFilter),
          const SizedBox(width: 6),
          _buildFilterChip(context, '6.0 GHz (6E/7)', WifiBand.band6G, state.selectedBandFilter),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, WifiBand band, WifiBand activeBand) {
    final isSelected = band == activeBand;
    return InkWell(
      onTap: () {
        context.read<WifiScanCubit>().setBandFilter(band);
      },
      borderRadius: BorderRadius.circular(ObsidianTheme.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? ObsidianTheme.accentGold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(ObsidianTheme.radiusPill),
          border: Border.all(
            color: isSelected ? ObsidianTheme.accentGold : ObsidianTheme.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? ObsidianTheme.accentGold : ObsidianTheme.textSecondary,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildSpotlightCard(BuildContext context, WifiAccessPoint ap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ObsidianTheme.bgElevated,
        borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
        border: Border.all(color: ObsidianTheme.accentGold, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      ap.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFAFAFA),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ObsidianTheme.accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                      ),
                      child: Text(
                        ap.security.badgeLabel,
                        style: TextStyle(
                          color: ObsidianTheme.accentGold,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${ap.bssid} • Ch ${ap.channel} (${ap.frequencyMhz}MHz) • ${ap.channelWidthMhz}MHz BW • ${ap.vendorOui}',
                  style: ObsidianTheme.tabularNumberStyle(
                    fontSize: 11,
                    color: ObsidianTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: ObsidianTheme.textSecondary,
            onPressed: () {
              context.read<WifiScanCubit>().selectBssid(null);
            },
          ),
        ],
      ),
    );
  }
}
