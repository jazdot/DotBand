import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/audio/acoustic_geiger_engine.dart';
import '../../../core/models/wifi_access_point.dart';
import '../../../core/theme/obsidian_theme.dart';
import '../telemetry/presentation/cubit/wifi_scan_cubit.dart';
import '../telemetry/presentation/cubit/wifi_scan_state.dart';

class SignalTimePoint {
  final int timestampMs;
  final int rssiDbm;

  const SignalTimePoint({required this.timestampMs, required this.rssiDbm});
}

class RoamingEvent {
  final int timestampMs;
  final String fromBssid;
  final String toBssid;
  final String ssid;
  final int deltaRssi;

  const RoamingEvent({
    required this.timestampMs,
    required this.fromBssid,
    required this.toBssid,
    required this.ssid,
    required this.deltaRssi,
  });
}

class TimeGraphTab extends StatefulWidget {
  const TimeGraphTab({super.key});

  @override
  State<TimeGraphTab> createState() => _TimeGraphTabState();
}

class _TimeGraphTabState extends State<TimeGraphTab> {
  final Map<String, List<SignalTimePoint>> _historyMap = {};
  final List<RoamingEvent> _roamingEvents = [];
  String? _lastConnectedBssid;
  int _timeWindowSeconds = 60; // 60s or 120s
  Timer? _pruneTimer;

  @override
  void initState() {
    super.initState();
    _pruneTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pruneHistory());
  }

  @override
  void dispose() {
    _pruneTimer?.cancel();
    AcousticGeigerEngine().stop();
    super.dispose();
  }

  void _pruneHistory() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - (_timeWindowSeconds * 1000);
    setState(() {
      for (final key in _historyMap.keys) {
        _historyMap[key]!.removeWhere((pt) => pt.timestampMs < cutoff);
      }
    });
  }

  void _recordSnapshot(WifiScanState state) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final topAps = state.snapshot.accessPoints.take(8); // Track top 8 strongest APs

    for (final ap in topAps) {
      final list = _historyMap.putIfAbsent(ap.bssid, () => []);
      list.add(SignalTimePoint(timestampMs: now, rssiDbm: ap.rssi));
    }

    // Check for roaming handover if selected or top AP changed
    if (topAps.isNotEmpty) {
      final currentTop = topAps.first;
      if (_lastConnectedBssid != null && _lastConnectedBssid != currentTop.bssid) {
        _roamingEvents.insert(
          0,
          RoamingEvent(
            timestampMs: now,
            fromBssid: _lastConnectedBssid!,
            toBssid: currentTop.bssid,
            ssid: currentTop.displayName,
            deltaRssi: currentTop.rssi - (_historyMap[_lastConnectedBssid]?.lastOrNull?.rssiDbm ?? currentTop.rssi),
          ),
        );
      }
      _lastConnectedBssid = currentTop.bssid;
      AcousticGeigerEngine().updateSignal(currentTop.rssi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WifiScanCubit, WifiScanState>(
      listener: (context, state) {
        _recordSnapshot(state);
      },
      builder: (context, state) {
        final geiger = AcousticGeigerEngine();

        return Column(
          children: [
            // Controls Bar (Window toggle & Geiger switch)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: ObsidianTheme.bgSurface,
              child: Row(
                children: [
                  Text(
                    'HISTORY WINDOW:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: ObsidianTheme.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildWindowToggle(60),
                  const SizedBox(width: 6),
                  _buildWindowToggle(120),

                  const Spacer(),

                  // Acoustic Geiger Button
                  InkWell(
                    onTap: () {
                      setState(() {
                        geiger.toggle();
                      });
                    },
                    borderRadius: BorderRadius.circular(ObsidianTheme.radiusPill),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: geiger.isEnabled ? ObsidianTheme.accentGold.withOpacity(0.25) : Colors.transparent,
                        borderRadius: BorderRadius.circular(ObsidianTheme.radiusPill),
                        border: Border.all(
                          color: geiger.isEnabled ? ObsidianTheme.accentGold : ObsidianTheme.borderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            geiger.isEnabled ? Icons.volume_up : Icons.volume_off,
                            size: 14,
                            color: geiger.isEnabled ? ObsidianTheme.accentGold : ObsidianTheme.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'GEIGER LOCATOR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: geiger.isEnabled ? ObsidianTheme.accentGold : ObsidianTheme.textTertiary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Time Series Line Graph Canvas
            Expanded(
              flex: 3,
              child: Container(
                color: ObsidianTheme.bgBase,
                padding: const EdgeInsets.all(12),
                child: CustomPaint(
                  painter: _TimeGraphPainter(
                    historyMap: _historyMap,
                    aps: state.snapshot.accessPoints,
                    windowSeconds: _timeWindowSeconds,
                  ),
                  child: Container(),
                ),
              ),
            ),

            // Roaming Handover Log
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: ObsidianTheme.bgSurface,
              alignment: Alignment.centerLeft,
              child: Text(
                'ROAMING & HANDOVER LOGS (${_roamingEvents.length} EVENTS)',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981),
                  fontFamily: 'monospace',
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _roamingEvents.isEmpty
                  ? Center(
                      child: Text(
                        'No roaming handovers detected during walk test.',
                        style: TextStyle(fontSize: 11, color: ObsidianTheme.textTertiary, fontFamily: 'monospace'),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _roamingEvents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final ev = _roamingEvents[index];
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ObsidianTheme.bgSurface,
                            borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                            border: Border.all(color: ObsidianTheme.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sync_alt, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Handover on "${ev.ssid}": ${ev.fromBssid} ➔ ${ev.toBssid}',
                                  style: ObsidianTheme.tabularNumberStyle(fontSize: 10, color: ObsidianTheme.textPrimary),
                                ),
                              ),
                              Text(
                                '${ev.deltaRssi >= 0 ? "+" : ""}${ev.deltaRssi} dBm',
                                style: ObsidianTheme.tabularNumberStyle(
                                  fontSize: 10,
                                  color: ev.deltaRssi >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWindowToggle(int seconds) {
    final isSelected = _timeWindowSeconds == seconds;
    return InkWell(
      onTap: () {
        setState(() {
          _timeWindowSeconds = seconds;
        });
      },
      borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? ObsidianTheme.accentGold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
          border: Border.all(color: isSelected ? ObsidianTheme.accentGold : ObsidianTheme.borderSubtle),
        ),
        child: Text(
          '${seconds}s',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? ObsidianTheme.accentGold : ObsidianTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TimeGraphPainter extends CustomPainter {
  final Map<String, List<SignalTimePoint>> historyMap;
  final List<WifiAccessPoint> aps;
  final int windowSeconds;

  _TimeGraphPainter({
    required this.historyMap,
    required this.aps,
    required this.windowSeconds,
  });

  static const List<Color> _lineColors = [
    Color(0xFFFBBF24), // Gold
    Color(0xFF00E5FF), // Cyan
    Color(0xFFA855F7), // Purple
    Color(0xFF10B981), // Emerald
    Color(0xFFF97316), // Orange
    Color(0xFFEC4899), // Pink
    Color(0xFF6366F1), // Indigo
    Color(0xFF14B8A6), // Teal
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final startTime = now - (windowSeconds * 1000);

    // Draw grid
    final gridPaint = Paint()
      ..color = ObsidianTheme.isLight ? const Color(0x1F0F172A) : const Color(0x14FFFFFF)
      ..strokeWidth = 1.0;

    for (final dbm in [-30, -50, -70, -90]) {
      final y = _rssiToY(dbm, size);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    int colorIdx = 0;
    for (final entry in historyMap.entries) {
      final bssid = entry.key;
      final points = entry.value;
      if (points.isEmpty) continue;

      final color = _lineColors[colorIdx % _lineColors.length];
      colorIdx++;

      final path = Path();
      bool first = true;

      for (final pt in points) {
        if (pt.timestampMs < startTime) continue;
        final x = ((pt.timestampMs - startTime) / (windowSeconds * 1000)) * size.width;
        final y = _rssiToY(pt.rssi, size);

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }

      final strokePaint = Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, strokePaint);
    }
  }

  double _rssiToY(int rssiDbm, Size size) {
    const minDbm = -100.0;
    const maxDbm = -20.0;
    final clamped = rssiDbm.clamp(minDbm, maxDbm).toDouble();
    final norm = (clamped - minDbm) / (maxDbm - minDbm);
    return (1.0 - norm) * size.height;
  }

  @override
  bool shouldRepaint(covariant _TimeGraphPainter oldDelegate) => true;
}
