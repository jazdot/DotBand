import 'dart:math' as math;
import 'package:flutter/material.dart';

enum LogoVariant {
  compact, // 28-36dp: For AppBar
  hero,    // 56-80dp: For Dashboard HUD banner
  splash,  // 120-160dp: For initialization splash
}

/**
 * Animated DotBand Logo.
 * 
 * Implements the official DotNetwork / Jazdot brand design language:
 * - Dark squircle badge container (#05070B) with hairline gold border.
 * - Tri-band concentric radiating electromagnetic spectrum arcs:
 *   - 2.4 GHz (Warm Amber #F59E0B)
 *   - 5.0 GHz (Sky Cyan #00E5FF)
 *   - 6.0 GHz (Electric Violet #A855F7 - Wi-Fi 6E/7)
 * - Signature Jazdot Gold Dot (#FBBF24 / #D97706) pulsing with continuous heartbeat rhythm.
 */
class DotBandAnimatedLogo extends StatefulWidget {
  final double size;
  final LogoVariant variant;
  final bool showWordmark;

  const DotBandAnimatedLogo({
    super.key,
    this.size = 32.0,
    this.variant = LogoVariant.compact,
    this.showWordmark = false,
  });

  @override
  State<DotBandAnimatedLogo> createState() => _DotBandAnimatedLogoState();
}

class _DotBandAnimatedLogoState extends State<DotBandAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoWidget = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _DotBandLogoPainter(
              progress: _controller.value,
              variant: widget.variant,
            ),
          );
        },
      ),
    );

    if (!widget.showWordmark) {
      return logoWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoWidget,
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'DOT',
                  style: TextStyle(
                    color: Color(0xFFFAFAFA),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'BAND',
                  style: TextStyle(
                    color: Color(0xFFC084FC),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const Text(
              'WI-FI 6E / 7 SPECTRUM ANALYZER',
              style: TextStyle(
                color: Color(0xFF71717A),
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DotBandLogoPainter extends CustomPainter {
  final double progress;
  final LogoVariant variant;

  _DotBandLogoPainter({
    required this.progress,
    required this.variant,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Dark Squircle Container (rx = 22%)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.22),
    );

    final bgPaint = Paint()
      ..color = const Color(0xFF05070B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0x33D97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rect, borderPaint);

    // 2. Tri-Band Concentric Spectrum Arcs radiating from bottom-left
    final origin = Offset(w * 0.24, h * 0.78);
    final arcConfigs = [
      // (radiusRatio, strokeRatio, Color, wavePhaseOffset)
      (0.30, 0.080, const Color(0xFFF59E0B), 0.0), // 2.4 GHz (Amber)
      (0.48, 0.085, const Color(0xFF00E5FF), 0.33), // 5.0 GHz (Cyan)
      (0.66, 0.090, const Color(0xFFA855F7), 0.66), // 6.0 GHz (Violet)
    ];

    for (int i = 0; i < arcConfigs.length; i++) {
      final config = arcConfigs[i];
      final radius = w * config.$1;
      final strokeW = w * config.$2;
      final phaseOffset = config.$4;

      // Sequential wave opacity & glow
      final waveTime = (progress + phaseOffset) % 1.0;
      final shimmer = 0.50 + 0.50 * math.sin(waveTime * 2 * math.pi);

      final arcPaint = Paint()
        ..color = config.$3.withOpacity(shimmer)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: radius),
        -math.pi * 0.48, // Start angle
        math.pi * 0.44,  // Sweep angle
        false,
        arcPaint,
      );
    }

    // 3. Signature Jazdot Gold Dot (#FBBF24 / #D97706)
    final dotX = w * 0.76;
    final dotY = h * 0.72;
    final baseDotRadius = w * 0.095;

    // Heartbeat pulse calculation
    final pulseScale = 1.0 + 0.18 * math.sin(progress * 2 * math.pi);
    final activeDotRadius = baseDotRadius * pulseScale;

    // Outer subtle gold glow
    final glowPaint = Paint()
      ..color = const Color(0xFFD97706).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), activeDotRadius * 1.8, glowPaint);

    // Inner vibrant gold gradient circle
    final dotPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(dotX, dotY), radius: activeDotRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), activeDotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DotBandLogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
