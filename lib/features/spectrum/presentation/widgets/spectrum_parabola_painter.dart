import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/models/wifi_access_point.dart';
import '../../../../core/theme/obsidian_theme.dart';

/**
 * GPU-Accelerated Parabola Spectrum Painter for DotBand.
 * Renders 2.4 GHz, 5.0 GHz, and 6.0 GHz spectrum congestion with:
 * - Accurate bandwidth scaling (20, 40, 80, 160, 320 MHz).
 * - Level-of-Detail (LOD) rendering for congested bands.
 * - AP spotlighting and dimming.
 * - 6 GHz Preferred Scanning Channel (PSC) gold ticks.
 * - International regulatory boundary shading.
 */
class SpectrumParabolaPainter extends CustomPainter {
  final List<WifiAccessPoint> accessPoints;
  final WifiBand band;
  final double zoomScale;
  final double panOffset;
  final String? spotlightBssid;
  final String countryCode;

  SpectrumParabolaPainter({
    required this.accessPoints,
    required this.band,
    required this.zoomScale,
    required this.panOffset,
    this.spotlightBssid,
    this.countryCode = 'UNKNOWN',
  });

  // Frequency spectrum ranges (MHz)
  static const double minFreq24G = 2400.0;
  static const double maxFreq24G = 2495.0;

  static const double minFreq5G = 5150.0;
  static const double maxFreq5G = 5895.0;

  static const double minFreq6G = 5925.0;
  static const double maxFreq6G = 7125.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Background CAD Grid
    _drawGrid(canvas, size);

    // Regulatory Domain Masks (e.g. ETSI 6 GHz restrictions)
    _drawRegulatoryMasks(canvas, size);

    // Preferred Scanning Channels (PSC) for 6 GHz
    if (band == WifiBand.band6G || band == WifiBand.unknown) {
      _drawPscMarkers(canvas, size);
    }

    // Determine LOD mode: if zoomed out (< 1.8x) and AP count is high (> 20), render thermal density
    final isDense = accessPoints.length > 20 && zoomScale < 1.8;

    if (isDense) {
      _drawThermalDensity(canvas, size);
    } else {
      _drawParabolas(canvas, size);
    }

    // Channel Axis Tick Marks & Monospace Labels
    _drawAxis(canvas, size);
  }

  double _freqToX(double freqMhz, Size size) {
    double minF = minFreq24G;
    double maxF = maxFreq6G;

    switch (band) {
      case WifiBand.band24G:
        minF = minFreq24G;
        maxF = maxFreq24G;
        break;
      case WifiBand.band5G:
        minF = minFreq5G;
        maxF = maxFreq5G;
        break;
      case WifiBand.band6G:
        minF = minFreq6G;
        maxF = maxFreq6G;
        break;
      case WifiBand.unknown:
        minF = minFreq24G;
        maxF = maxFreq6G;
        break;
    }

    final normalized = (freqMhz - minF) / (maxF - minF);
    final baseWidth = size.width;
    final zoomedWidth = baseWidth * zoomScale;
    return (normalized * zoomedWidth) + panOffset;
  }

  double _rssiToY(int rssiDbm, Size size) {
    // Map -100 dBm (bottom) to -20 dBm (top)
    const minDbm = -100.0;
    const maxDbm = -20.0;
    final clamped = rssiDbm.clamp(minDbm, maxDbm).toDouble();
    final normalized = (clamped - minDbm) / (maxDbm - minDbm); // 0.0 (bottom) to 1.0 (top)
    final drawableHeight = size.height - 40.0; // Reserve 40dp for bottom axis
    return (1.0 - normalized) * drawableHeight;
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = ObsidianTheme.isLight ? const Color(0x1F0F172A) : const Color(0x14FFFFFF)
      ..strokeWidth = 1.0;

    // dBm horizontal levels: -30, -50, -70, -90 dBm
    for (final dbm in [-30, -50, -70, -90]) {
      final y = _rssiToY(dbm, size);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: '$dbm dBm',
          style: TextStyle(
            color: ObsidianTheme.textTertiary,
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(4, y - 12));
    }
  }

  void _drawRegulatoryMasks(Canvas canvas, Size size) {
    // If in ETSI region (e.g. DE, FR, GB, EU, IN), channels above 6425 MHz are restricted
    final isEtsi = {'DE', 'FR', 'GB', 'UK', 'EU', 'IN', 'JP'}.contains(countryCode.toUpperCase());
    if (isEtsi && (band == WifiBand.band6G || band == WifiBand.unknown)) {
      final maskStartX = _freqToX(6425.0, size);
      final maskEndX = _freqToX(7125.0, size);

      if (maskEndX > 0 && maskStartX < size.width) {
        final maskPaint = Paint()
          ..color = const Color(0x28EF4444) // Subtle crimson hatching
          ..style = PaintingStyle.fill;

        final rect = Rect.fromLTRB(
          math.max(0.0, maskStartX),
          0,
          math.min(size.width, maskEndX),
          size.height - 35,
        );
        canvas.drawRect(rect, maskPaint);

        final tp = TextPainter(
          text: TextSpan(
            text: 'ETSI RESERVED (CH 97-233)',
            style: TextStyle(
              color: const Color(0xFFEF4444),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(rect.left + 8, 8));
      }
    }
  }

  void _drawPscMarkers(Canvas canvas, Size size) {
    final pscPaint = Paint()
      ..color = const Color(0x66FBBF24)
      ..strokeWidth = 1.5;

    // Preferred Scanning Channels (PSCs): Ch 5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213, 229
    for (int ch = 5; ch <= 229; ch += 16) {
      final freq = 5950.0 + (5.0 * ch);
      final x = _freqToX(freq, size);
      if (x >= 0 && x <= size.width) {
        canvas.drawLine(Offset(x, size.height - 35), Offset(x, size.height - 45), pscPaint);
      }
    }
  }

  void _drawParabolas(Canvas canvas, Size size) {
    final bottomY = size.height - 35.0;

    for (final ap in accessPoints) {
      final isSpotlighted = spotlightBssid != null && ap.bssid == spotlightBssid;
      final isDimmed = spotlightBssid != null && !isSpotlighted;

      // Base width calculation in frequency
      final bwMhz = ap.channelWidthMhz.toDouble();
      final centerF = ap.centerFreq0 > 0 ? ap.centerFreq0.toDouble() : ap.frequencyMhz.toDouble();
      final halfBw = bwMhz / 2.0;

      final leftX = _freqToX(centerF - halfBw, size);
      final centerX = _freqToX(centerF, size);
      final rightX = _freqToX(centerF + halfBw, size);
      final apexY = _rssiToY(ap.rssi, size);

      // Skip off-screen parabolas
      if (rightX < -50 || leftX > size.width + 50) continue;

      // Parabola quadratic curve path
      final path = Path();
      path.moveTo(leftX, bottomY);
      path.quadraticBezierTo(centerX, apexY, rightX, bottomY);
      path.close();

      // Color scheme based on band & signal
      Color baseColor;
      switch (ap.band) {
        case WifiBand.band24G:
          baseColor = const Color(0xFFF59E0B); // Warm Amber
          break;
        case WifiBand.band5G:
          baseColor = const Color(0xFF00E5FF); // Sky Cyan
          break;
        case WifiBand.band6G:
          baseColor = const Color(0xFFA855F7); // Electric Violet
          break;
        case WifiBand.unknown:
          baseColor = const Color(0xFF3B82F6);
          break;
      }

      if (isSpotlighted) {
        baseColor = const Color(0xFFFBBF24); // Jazdot Gold Spotlight
      }

      final fillAlpha = isDimmed ? 0.04 : (isSpotlighted ? 0.45 : 0.20);
      final strokeAlpha = isDimmed ? 0.15 : (isSpotlighted ? 1.0 : 0.85);

      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            baseColor.withOpacity(fillAlpha),
            baseColor.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTRB(leftX, apexY, rightX, bottomY))
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = baseColor.withOpacity(strokeAlpha)
        ..strokeWidth = isSpotlighted ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);

      // Label at apex
      if (!isDimmed && (isSpotlighted || zoomScale >= 1.5 || accessPoints.length <= 15)) {
        final label = '${ap.displayName} (${ap.rssi}dBm)';
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: isSpotlighted ? const Color(0xFFFBBF24) : ObsidianTheme.textPrimary,
              fontSize: isSpotlighted ? 11 : 9.5,
              fontWeight: isSpotlighted ? FontWeight.w800 : FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 160);

        final labelX = (centerX - (tp.width / 2)).clamp(4.0, size.width - tp.width - 4.0);
        tp.paint(canvas, Offset(labelX, math.max(4.0, apexY - 14.0)));
      }
    }
  }

  void _drawThermalDensity(Canvas canvas, Size size) {
    // Level-of-Detail (LOD) aggregation for congested spectrum
    final bottomY = size.height - 35.0;
    final bucketCount = 40;
    final buckets = List<double>.filled(bucketCount, 0.0);

    for (final ap in accessPoints) {
      final f = ap.frequencyMhz.toDouble();
      final x = _freqToX(f, size);
      final idx = ((x / size.width) * bucketCount).toInt().clamp(0, bucketCount - 1);
      final power = math.pow(10.0, ap.rssi / 20.0).toDouble();
      buckets[idx] += power;
    }

    final barWidth = size.width / bucketCount;
    final maxPower = buckets.reduce(math.max);
    if (maxPower <= 0) return;

    for (int i = 0; i < bucketCount; i++) {
      final norm = (buckets[i] / maxPower).clamp(0.0, 1.0);
      final barHeight = norm * (size.height - 60.0);
      final x = i * barWidth;
      final y = bottomY - barHeight;

      final paint = Paint()
        ..color = Color.lerp(const Color(0xFF3B82F6), const Color(0xFFEF4444), norm)!.withOpacity(0.65)
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromLTWH(x + 1, y, barWidth - 2, barHeight), paint);
    }
  }

  void _drawAxis(Canvas canvas, Size size) {
    final axisY = size.height - 35.0;
    final axisPaint = Paint()
      ..color = ObsidianTheme.borderGold
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(0, axisY), Offset(size.width, axisY), axisPaint);

    // Channel labels based on active band
    final channelsToDraw = <int, double>{};
    if (band == WifiBand.band24G || band == WifiBand.unknown) {
      for (final ch in [1, 6, 11, 14]) {
        channelsToDraw[ch] = (ch == 14) ? 2484.0 : 2412.0 + (ch - 1) * 5.0;
      }
    }
    if (band == WifiBand.band5G || band == WifiBand.unknown) {
      for (final ch in [36, 48, 52, 64, 100, 120, 144, 149, 161, 165]) {
        channelsToDraw[ch] = 5000.0 + (ch * 5.0);
      }
    }
    if (band == WifiBand.band6G || band == WifiBand.unknown) {
      for (final ch in [1, 37, 69, 101, 133, 165, 197, 233]) {
        channelsToDraw[ch] = 5950.0 + (ch * 5.0);
      }
    }

    for (final entry in channelsToDraw.entries) {
      final x = _freqToX(entry.value, size);
      if (x >= 0 && x <= size.width) {
        canvas.drawLine(Offset(x, axisY), Offset(x, axisY + 4), axisPaint);

        final tp = TextPainter(
          text: TextSpan(
            text: 'Ch ${entry.key}',
            style: TextStyle(
              color: ObsidianTheme.textSecondary,
              fontSize: 9,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - (tp.width / 2), axisY + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant SpectrumParabolaPainter oldDelegate) {
    return oldDelegate.accessPoints != accessPoints ||
        oldDelegate.band != band ||
        oldDelegate.zoomScale != zoomScale ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.spotlightBssid != spotlightBssid;
  }
}
