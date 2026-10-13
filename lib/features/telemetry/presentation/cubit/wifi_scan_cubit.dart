import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bridge/wifi_channel.dart';
import '../../../../core/models/wifi_access_point.dart';
import 'wifi_scan_state.dart';

class WifiScanCubit extends Cubit<WifiScanState> {
  final WifiChannel _bridge;
  StreamSubscription? _telemetrySub;
  Timer? _cooldownTimer;

  WifiScanCubit({WifiChannel? bridge})
      : _bridge = bridge ?? WifiChannel(),
        super(WifiScanState.initial());

  void init() {
    _telemetrySub = _bridge.snapshotStream.listen(
      (snapshot) {
        emit(state.copyWith(
          snapshot: snapshot,
          status: state.remainingCooldownSeconds > 0 ? ScanStatus.cooldown : ScanStatus.idle,
          errorMessage: null,
        ));
      },
      onError: (err) {
        emit(state.copyWith(
          status: ScanStatus.error,
          errorMessage: err.toString(),
        ));
      },
    );
  }

  Future<void> triggerManualScan() async {
    if (state.remainingCooldownSeconds > 0) return;

    emit(state.copyWith(status: ScanStatus.scanning));

    final res = await _bridge.triggerScan();
    final started = res['started'] as bool? ?? false;

    if (!started) {
      final code = res['error_code'] as String?;
      if (code == 'SCAN_THROTTLED') {
        final details = res['details'] as Map?;
        final cooldown = (details?['cooldown_seconds'] as num?)?.toInt() ?? 30;
        _startCooldown(cooldown);
        return;
      }
      emit(state.copyWith(
        status: ScanStatus.idle,
        errorMessage: res['error_message'] as String? ?? 'Scan trigger failed.',
      ));
    } else {
      // Successful scan trigger, start a standard safety cooldown of 15 seconds
      _startCooldown(15);
    }
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    emit(state.copyWith(
      status: ScanStatus.cooldown,
      remainingCooldownSeconds: seconds,
    ));

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state.remainingCooldownSeconds - 1;
      if (current <= 0) {
        timer.cancel();
        emit(state.copyWith(
          status: ScanStatus.idle,
          remainingCooldownSeconds: 0,
        ));
      } else {
        emit(state.copyWith(remainingCooldownSeconds: current));
      }
    });
  }

  void setBandFilter(WifiBand band) {
    emit(state.copyWith(selectedBandFilter: band));
  }

  void selectBssid(String? bssid) {
    if (bssid == null) {
      emit(state.copyWith(clearSelectedBssid: true));
    } else {
      emit(state.copyWith(selectedBssid: bssid));
    }
  }

  Future<void> triggerRttRanging() async {
    await _bridge.triggerRttRanging();
  }

  @override
  Future<void> close() {
    _telemetrySub?.cancel();
    _cooldownTimer?.cancel();
    return super.close();
  }
}
