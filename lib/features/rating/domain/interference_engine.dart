import 'dart:math' as math;
import '../../../core/models/wifi_access_point.dart';

class ChannelRating {
  final int channel;
  final int frequencyMhz;
  final WifiBand band;
  final double score; // 0.0 (severely congested) to 100.0 (spotless clean)
  final int cciCount;
  final int aciCount;
  final double averageChannelUtilizationPct;
  final bool isDfs;
  final bool isPsc;

  const ChannelRating({
    required this.channel,
    required this.frequencyMhz,
    required this.band,
    required this.score,
    required this.cciCount,
    required this.aciCount,
    required this.averageChannelUtilizationPct,
    required this.isDfs,
    required this.isPsc,
  });

  int get stars {
    if (score >= 90.0) return 5;
    if (score >= 75.0) return 4;
    if (score >= 55.0) return 3;
    if (score >= 35.0) return 2;
    return 1;
  }
}

class InterferenceEngine {
  /**
   * Physics-based interference score engine.
   * Differentiates Co-Channel Interference (CSMA/CA airtime sharing) from
   * Adjacent-Channel Interference (uncoordinated destructive collision).
   */
  static List<ChannelRating> computeRatings(List<WifiAccessPoint> aps, WifiBand band) {
    final channels = _getBandChannels(band);
    final ratings = <ChannelRating>[];

    for (final ch in channels) {
      final freq = _channelToFrequency(ch, band);
      final isDfs = _isDfsChannel(ch);
      final isPsc = band == WifiBand.band6G && _isPscChannel(ch);

      double totalCciPower = 0.0;
      double totalAciPower = 0.0;
      int cciCount = 0;
      int aciCount = 0;
      double totalUtilization = 0.0;
      int utilizationSampleCount = 0;

      for (final ap in aps) {
        if (ap.band != band) continue;

        final apFreq = ap.frequencyMhz;
        final deltaFreq = (apFreq - freq).abs().toDouble();
        final apPowerMw = math.pow(10.0, ap.rssi / 10.0).toDouble();

        // Track QBSS utilization if available
        if (ap.channelUtilizationPct != null) {
          totalUtilization += ap.channelUtilizationPct!;
          utilizationSampleCount++;
        }

        if (deltaFreq == 0.0) {
          // Exact Co-Channel Contender (CCI)
          cciCount++;
          double cciWeight = apPowerMw * (ap.channelWidthMhz / 20.0);
          // 40% spatial reuse discount if distinct BSS Color is active
          if (ap.bssColor != null && ap.bssColor! > 0) {
            cciWeight *= 0.6;
          }
          totalCciPower += cciWeight;
        } else if (deltaFreq < (ap.channelWidthMhz / 2.0 + 10.0)) {
          // Adjacent-Channel Overlap (ACI)
          aciCount++;
          // Spectral emission mask attenuation
          final relativeOffset = deltaFreq / (ap.channelWidthMhz / 2.0);
          final attenuationDb = relativeOffset <= 1.0 ? 0.0 : (relativeOffset <= 1.5 ? -20.0 : -40.0);
          final spilloverMw = apPowerMw * math.pow(10.0, attenuationDb / 10.0);
          // Collision penalty: ACI lacks CSMA/CA preamble decodability
          const collisionPenalty = 2.5;
          totalAciPower += spilloverMw * collisionPenalty;
        }
      }

      final totalInterference = totalCciPower + totalAciPower;
      double rawScore = 100.0 / (1.0 + (totalInterference * 1e5));

      // Weight score by measured real-world QBSS channel utilization if samples exist
      final avgUtil = utilizationSampleCount > 0 ? (totalUtilization / utilizationSampleCount) : 0.0;
      if (avgUtil > 0.0) {
        rawScore *= (1.0 - (0.6 * (avgUtil / 100.0)));
      }

      final finalScore = rawScore.clamp(0.0, 100.0);

      ratings.add(
        ChannelRating(
          channel: ch,
          frequencyMhz: freq,
          band: band,
          score: MathRound(finalScore),
          cciCount: cciCount,
          aciCount: aciCount,
          averageChannelUtilizationPct: MathRound(avgUtil),
          isDfs: isDfs,
          isPsc: isPsc,
        ),
      );
    }

    ratings.sort((a, b) => b.score.compareTo(a.score));
    return ratings;
  }

  static double MathRound(double val) => (val * 10.0).round() / 10.0;

  static List<int> _getBandChannels(WifiBand band) {
    switch (band) {
      case WifiBand.band24G:
        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
      case WifiBand.band5G:
        return [36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165];
      case WifiBand.band6G:
        return [1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57, 61, 65, 69, 73, 77, 81, 85, 89, 93, 97, 101, 105, 109, 113, 117, 121, 125, 129, 133, 137, 141, 145, 149, 153, 157, 161, 165, 169, 173, 177, 181, 185, 189, 193, 197, 201, 205, 209, 213, 217, 221, 225, 229, 233];
      case WifiBand.unknown:
        return [1, 6, 11, 36, 44, 149, 157, 5, 21, 37, 69, 101];
    }
  }

  static int _channelToFrequency(int ch, WifiBand band) {
    if (band == WifiBand.band24G) {
      return ch == 14 ? 2484 : 2412 + (ch - 1) * 5;
    }
    if (band == WifiBand.band5G) {
      return 5000 + (ch * 5);
    }
    if (band == WifiBand.band6G) {
      return 5950 + (ch * 5);
    }
    return 2412;
  }

  static bool _isDfsChannel(int ch) {
    return (ch >= 52 && ch <= 64) || (ch >= 100 && ch <= 144);
  }

  static bool _isPscChannel(int ch) {
    const pscs = {5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213, 229};
    return pscs.contains(ch);
  }
}
