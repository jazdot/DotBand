import 'dart:async';
import 'package:flutter/services.dart';
import '../models/wifi_access_point.dart';
import '../models/wifi_scan_snapshot.dart';

/**
 * Native bridge client interfacing with com.jazdot.dotband/telemetry & control.
 */
class WifiChannel {
  static final WifiChannel _instance = WifiChannel._internal();
  factory WifiChannel() => _instance;
  WifiChannel._internal();

  static const MethodChannel _controlChannel = MethodChannel('com.jazdot.dotband/control');
  static const EventChannel _telemetryChannel = EventChannel('com.jazdot.dotband/telemetry');

  Stream<WifiScanSnapshot>? _snapshotStream;
  StreamSubscription? _sub;
  final _controller = StreamController<WifiScanSnapshot>.broadcast();

  Stream<WifiScanSnapshot> get snapshotStream {
    _ensureSubscribed();
    return _controller.stream;
  }

  void _ensureSubscribed() {
    if (_snapshotStream == null) {
      _snapshotStream = _telemetryChannel.receiveBroadcastStream().map((event) {
        if (event is Map) {
          final type = event['type'];
          if (type == 'SCAN_SNAPSHOT') {
            final rawAps = event['accessPoints'] as List<dynamic>? ?? [];
            final aps = rawAps.map((e) => WifiAccessPoint.fromMap(e as Map<dynamic, dynamic>)).toList();

            return WifiScanSnapshot(
              timestampMs: (event['timestampMs'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
              isResultsUpdated: (event['isResultsUpdated'] as bool?) ?? false,
              detectedCountryCode: (event['detectedCountryCode'] as String?) ?? 'UNKNOWN',
              availableTokens: (event['availableTokens'] as num?)?.toInt() ?? 4,
              accessPoints: aps,
            );
          }
        }
        return WifiScanSnapshot.empty();
      });

      _sub = _snapshotStream!.listen(
        (snap) => _controller.add(snap),
        onError: (err) => _controller.addError(err),
      );
    }
  }

  Future<Map<String, dynamic>> triggerScan() async {
    try {
      final res = await _controlChannel.invokeMethod<Map<dynamic, dynamic>>('startScan');
      return Map<String, dynamic>.from(res ?? {});
    } on PlatformException catch (e) {
      return {
        'started': false,
        'error_code': e.code,
        'error_message': e.message,
        'details': e.details,
      };
    }
  }

  Future<Map<String, dynamic>> getRateLimitStatus() async {
    try {
      final res = await _controlChannel.invokeMethod<Map<dynamic, dynamic>>('getRateLimitStatus');
      return Map<String, dynamic>.from(res ?? {});
    } catch (_) {
      return {'available_tokens': 4, 'max_tokens': 4};
    }
  }

  Future<Map<String, double>> triggerRttRanging() async {
    try {
      final res = await _controlChannel.invokeMethod<Map<dynamic, dynamic>>('triggerRttRanging');
      if (res == null) return {};
      return res.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
