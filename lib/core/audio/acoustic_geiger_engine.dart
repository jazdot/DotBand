import 'dart:async';
import 'package:flutter/services.dart';

/**
 * Acoustic Geiger Counter Engine for hands-free AP physical hunting.
 * Emits haptic pulses / audio ticks at a cadence proportional to signal strength:
 * - Weak signal (-85 dBm): ~1 tick per 1.5 seconds
 * - Medium signal (-65 dBm): ~4 ticks per second
 * - Hot signal (-35 dBm): ~12 ticks per second (continuous buzz)
 */
class AcousticGeigerEngine {
  static final AcousticGeigerEngine _instance = AcousticGeigerEngine._internal();
  factory AcousticGeigerEngine() => _instance;
  AcousticGeigerEngine._internal();

  Timer? _tickerTimer;
  bool _isEnabled = false;
  int _currentRssi = -100;

  bool get isEnabled => _isEnabled;

  void toggle() {
    _isEnabled = !_isEnabled;
    if (_isEnabled) {
      _scheduleNextTick();
    } else {
      _tickerTimer?.cancel();
    }
  }

  void updateSignal(int rssiDbm) {
    _currentRssi = rssiDbm;
  }

  void _scheduleNextTick() {
    if (!_isEnabled) return;

    // Trigger subtle click feedback
    HapticFeedback.selectionClick();

    // Calculate delay in ms based on RSSI (-100 dBm to -30 dBm)
    final clamped = _currentRssi.clamp(-95, -30);
    // Linear interpolation: -95dBm -> 1200ms, -30dBm -> 80ms
    final fraction = (clamped - (-95)) / (-30 - (-95)); // 0.0 to 1.0
    final delayMs = (1200 - (fraction * 1120)).toInt();

    _tickerTimer = Timer(Duration(milliseconds: delayMs), () {
      _scheduleNextTick();
    });
  }

  void stop() {
    _isEnabled = false;
    _tickerTimer?.cancel();
  }
}
