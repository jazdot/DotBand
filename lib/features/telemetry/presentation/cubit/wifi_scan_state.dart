import '../../../../core/models/wifi_access_point.dart';
import '../../../../core/models/wifi_scan_snapshot.dart';

enum ScanStatus {
  idle,
  scanning,
  cooldown,
  error;
}

class WifiScanState {
  final ScanStatus status;
  final WifiScanSnapshot snapshot;
  final int remainingCooldownSeconds;
  final String? errorMessage;
  final WifiBand selectedBandFilter;
  final String? selectedBssid; // For AP spotlight focus

  const WifiScanState({
    required this.status,
    required this.snapshot,
    required this.remainingCooldownSeconds,
    this.errorMessage,
    required this.selectedBandFilter,
    this.selectedBssid,
  });

  factory WifiScanState.initial() => WifiScanState(
    status: ScanStatus.idle,
    snapshot: WifiScanSnapshot.empty(),
    remainingCooldownSeconds: 0,
    selectedBandFilter: WifiBand.unknown, // unknown means ALL TRI-BAND
    selectedBssid: null,
  );

  WifiScanState copyWith({
    ScanStatus? status,
    WifiScanSnapshot? snapshot,
    int? remainingCooldownSeconds,
    String? errorMessage,
    WifiBand? selectedBandFilter,
    String? selectedBssid,
    bool clearSelectedBssid = false,
  }) {
    return WifiScanState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      remainingCooldownSeconds: remainingCooldownSeconds ?? this.remainingCooldownSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedBandFilter: selectedBandFilter ?? this.selectedBandFilter,
      selectedBssid: clearSelectedBssid ? null : (selectedBssid ?? this.selectedBssid),
    );
  }

  List<WifiAccessPoint> get filteredAccessPoints {
    if (selectedBandFilter == WifiBand.unknown) {
      return snapshot.accessPoints;
    }
    return snapshot.accessPoints.where((ap) => ap.band == selectedBandFilter).toList();
  }

  WifiAccessPoint? get selectedAccessPoint {
    if (selectedBssid == null) return null;
    return snapshot.accessPoints.firstWhere(
      (ap) => ap.bssid == selectedBssid,
      orElse: () => snapshot.accessPoints.first,
    );
  }
}
