import 'wifi_access_point.dart';

class WifiScanSnapshot {
  final int timestampMs;
  final bool isResultsUpdated;
  final String detectedCountryCode;
  final int availableTokens;
  final List<WifiAccessPoint> accessPoints;

  const WifiScanSnapshot({
    required this.timestampMs,
    required this.isResultsUpdated,
    required this.detectedCountryCode,
    required this.availableTokens,
    required this.accessPoints,
  });

  factory WifiScanSnapshot.empty() => WifiScanSnapshot(
    timestampMs: DateTime.now().millisecondsSinceEpoch,
    isResultsUpdated: false,
    detectedCountryCode: 'UNKNOWN',
    availableTokens: 4,
    accessPoints: const [],
  );

  List<WifiAccessPoint> get ap24G => accessPoints.where((ap) => ap.band == WifiBand.band24G).toList();
  List<WifiAccessPoint> get ap5G => accessPoints.where((ap) => ap.band == WifiBand.band5G).toList();
  List<WifiAccessPoint> get ap6G => accessPoints.where((ap) => ap.band == WifiBand.band6G).toList();

  Map<String, dynamic> toMap() => {
    'timestampMs': timestampMs,
    'isResultsUpdated': isResultsUpdated,
    'detectedCountryCode': detectedCountryCode,
    'availableTokens': availableTokens,
    'accessPoints': accessPoints.map((ap) => ap.toMap()).toList(),
  };
}
