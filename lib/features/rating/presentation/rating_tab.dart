import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/wifi_access_point.dart';
import '../../../core/theme/obsidian_theme.dart';
import '../../telemetry/presentation/cubit/wifi_scan_cubit.dart';
import '../../telemetry/presentation/cubit/wifi_scan_state.dart';
import '../domain/interference_engine.dart';

class RatingTab extends StatelessWidget {
  const RatingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WifiScanCubit, WifiScanState>(
      builder: (context, state) {
        final aps = state.filteredAccessPoints;
        final targetBand = state.selectedBandFilter == WifiBand.unknown ? WifiBand.band5G : state.selectedBandFilter;
        final ratings = InterferenceEngine.computeRatings(aps, targetBand);
        final topChannel = ratings.isNotEmpty ? ratings.first : null;

        return Column(
          children: [
            // Band Filter Selector Bar
            _buildBandSelector(context, state),

            // Top Recommendation Banner
            if (topChannel != null)
              _buildRecommendationBanner(topChannel, targetBand),

            // Channel Rating List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: ratings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _buildRatingCard(context, ratings[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBandSelector(BuildContext context, WifiScanState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: ObsidianTheme.bgSurface,
      child: Row(
        children: [
          _buildFilterChip(context, '2.4 GHz', WifiBand.band24G, state.selectedBandFilter),
          const SizedBox(width: 8),
          _buildFilterChip(context, '5.0 GHz', WifiBand.band5G, state.selectedBandFilter),
          const SizedBox(width: 8),
          _buildFilterChip(context, '6.0 GHz (6E/7)', WifiBand.band6G, state.selectedBandFilter),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, WifiBand band, WifiBand activeBand) {
    final isSelected = band == activeBand || (activeBand == WifiBand.unknown && band == WifiBand.band5G);
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

  Widget _buildRecommendationBanner(ChannelRating top, WifiBand band) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1F10B981), // Emerald glow
        borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Color(0xFF10B981), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECOMMENDED: CHANNEL ${top.channel}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Score: ${top.score.toStringAsFixed(1)}/100 • ${top.cciCount} Co-Channel APs • ${top.aciCount} Adjacent APs • ${top.isDfs ? "DFS Required" : "Clean Spectrum"}',
                  style: ObsidianTheme.tabularNumberStyle(
                    fontSize: 11,
                    color: ObsidianTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(BuildContext context, ChannelRating rating) {
    Color scoreColor;
    if (rating.score >= 80.0) {
      scoreColor = const Color(0xFF10B981);
    } else if (rating.score >= 50.0) {
      scoreColor = const Color(0xFFFBBF24);
    } else {
      scoreColor = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ObsidianTheme.bgSurface,
        borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
        border: Border.all(color: ObsidianTheme.borderSubtle),
      ),
      child: Row(
        children: [
          // Channel Number & Frequency
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'CH ${rating.channel}',
                    style: ObsidianTheme.tabularNumberStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: ObsidianTheme.textPrimary,
                    ),
                  ),
                  if (rating.isPsc) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: ObsidianTheme.accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'PSC',
                        style: TextStyle(color: ObsidianTheme.accentGold, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  if (rating.isDfs) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0x333B82F6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'DFS',
                        style: TextStyle(color: Color(0xFF3B82F6), fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${rating.frequencyMhz} MHz',
                style: ObsidianTheme.tabularNumberStyle(
                  fontSize: 11,
                  color: ObsidianTheme.textTertiary,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Star Rating & Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.stars ? Icons.star : Icons.star_border,
                    color: index < rating.stars ? ObsidianTheme.accentGold : ObsidianTheme.textTertiary,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '${rating.score.toStringAsFixed(0)} pts • ${rating.cciCount} CCI / ${rating.aciCount} ACI',
                style: ObsidianTheme.tabularNumberStyle(
                  fontSize: 11,
                  color: scoreColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
