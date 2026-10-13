import 'dart:math' as math;

enum WifiBand {
  band24G,
  band5G,
  band6G,
  unknown;

  String get label {
    switch (this) {
      case WifiBand.band24G:
        return '2.4 GHz';
      case WifiBand.band5G:
        return '5.0 GHz';
      case WifiBand.band6G:
        return '6.0 GHz';
      case WifiBand.unknown:
        return 'Unknown';
    }
  }
}

enum WifiSecurity {
  wpa3Pure,
  wpa3Transition,
  wpa2,
  owe,
  open,
  wep,
  unknown;

  String get badgeLabel {
    switch (this) {
      case WifiSecurity.wpa3Pure:
        return 'WPA3-SAE';
      case WifiSecurity.wpa3Transition:
        return 'WPA3/WPA2';
      case WifiSecurity.wpa2:
        return 'WPA2-PSK';
      case WifiSecurity.owe:
        return 'OWE (Enhanced)';
      case WifiSecurity.open:
        return 'OPEN';
      case WifiSecurity.wep:
        return 'WEP (Insecure)';
      case WifiSecurity.unknown:
        return 'UNKNOWN';
    }
  }
}

class MloLinkModel {
  final int linkId;
  final String band;
  final int channel;
  final int rssi;
  final String state;

  const MloLinkModel({
    required this.linkId,
    required this.band,
    required this.channel,
    required this.rssi,
    required this.state,
  });

  factory MloLinkModel.fromMap(Map<dynamic, dynamic> map) {
    return MloLinkModel(
      linkId: (map['linkId'] as num?)?.toInt() ?? 0,
      band: (map['band'] as String?) ?? 'Unknown',
      channel: (map['channel'] as num?)?.toInt() ?? 0,
      rssi: (map['rssi'] as num?)?.toInt() ?? -100,
      state: (map['state'] as String?) ?? 'UNKNOWN',
    );
  }

  Map<String, dynamic> toMap() => {
    'linkId': linkId,
    'band': band,
    'channel': channel,
    'rssi': rssi,
    'state': state,
  };
}

class WifiAccessPoint {
  final String ssid;
  final String bssid;
  final int frequencyMhz;
  final int channel;
  final WifiBand band;
  final int channelWidthMhz;
  final int centerFreq0;
  final int centerFreq1;
  final int rssi;
  final String capabilities;
  final WifiSecurity security;
  final bool isPmfMandatory;
  final bool isPmfCapable;
  final bool is80211mcResponder;
  final bool isPasspoint;
  final bool isLocallyAdministeredMac;
  final double? rttDistanceMeters;
  final int? stationCount;
  final double? channelUtilizationPct;
  final int? bssColor;
  final bool isMloActive;
  final String? mldMacAddress;
  final List<MloLinkModel> mloLinks;
  final double mloAggregateMbps;
  final String vendorOui;

  const WifiAccessPoint({
    required this.ssid,
    required this.bssid,
    required this.frequencyMhz,
    required this.channel,
    required this.band,
    required this.channelWidthMhz,
    required this.centerFreq0,
    required this.centerFreq1,
    required this.rssi,
    required this.capabilities,
    required this.security,
    required this.isPmfMandatory,
    required this.isPmfCapable,
    required this.is80211mcResponder,
    required this.isPasspoint,
    required this.isLocallyAdministeredMac,
    this.rttDistanceMeters,
    this.stationCount,
    this.channelUtilizationPct,
    this.bssColor,
    required this.isMloActive,
    this.mldMacAddress,
    required this.mloLinks,
    required this.mloAggregateMbps,
    required this.vendorOui,
  });

  bool get isHidden => ssid.trim().isEmpty;
  String get displayName => isHidden ? '[Hidden SSID]' : ssid;

  bool get isPreferredScanningChannel {
    if (band != WifiBand.band6G) return false;
    const pscs = {5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213, 229};
    return pscs.contains(channel);
  }

  bool get isDragonbloodVulnerable => security == WifiSecurity.wpa3Transition;

  static int frequencyToChannel(int freqMhz) {
    if (freqMhz == 2484) return 14;
    if (freqMhz >= 2412 && freqMhz <= 2472) {
      return ((freqMhz - 2412) / 5).round() + 1;
    }
    if (freqMhz >= 5170 && freqMhz <= 5835) {
      return ((freqMhz - 5000) / 5).round();
    }
    if (freqMhz >= 5955 && freqMhz <= 7115) {
      return ((freqMhz - 5950) / 5).round();
    }
    return -1;
  }

  static WifiBand frequencyToBand(int freqMhz) {
    if (freqMhz >= 2400 && freqMhz <= 2500) return WifiBand.band24G;
    if (freqMhz >= 5150 && freqMhz <= 5895) return WifiBand.band5G;
    if (freqMhz >= 5925 && freqMhz <= 7125) return WifiBand.band6G;
    return WifiBand.unknown;
  }

  static WifiSecurity parseSecurity(String cap) {
    final upper = cap.toUpperCase();
    if (upper.contains('SAE') && upper.contains('PSK')) {
      return WifiSecurity.wpa3Transition;
    }
    if (upper.contains('SAE')) {
      return WifiSecurity.wpa3Pure;
    }
    if (upper.contains('OWE')) {
      return WifiSecurity.owe;
    }
    if (upper.contains('WPA2') || upper.contains('PSK')) {
      return WifiSecurity.wpa2;
    }
    if (upper.contains('WEP')) {
      return WifiSecurity.wep;
    }
    if (!upper.contains('WPA') && !upper.contains('WEP') && !upper.contains('EAP')) {
      return WifiSecurity.open;
    }
    return WifiSecurity.unknown;
  }

  factory WifiAccessPoint.fromMap(Map<dynamic, dynamic> map, {String resolvedVendor = 'Unknown Vendor'}) {
    final freq = (map['frequencyMhz'] as num?)?.toInt() ?? 2412;
    final cap = (map['capabilities'] as String?) ?? '';
    final rawBssid = (map['bssid'] as String?) ?? '00:00:00:00:00:00';
    final mloRaw = map['mloLinks'] as List<dynamic>? ?? [];

    return WifiAccessPoint(
      ssid: (map['ssid'] as String?) ?? '',
      bssid: rawBssid,
      frequencyMhz: freq,
      channel: frequencyToChannel(freq),
      band: frequencyToBand(freq),
      channelWidthMhz: (map['channelWidthMhz'] as num?)?.toInt() ?? 20,
      centerFreq0: (map['centerFreq0'] as num?)?.toInt() ?? freq,
      centerFreq1: (map['centerFreq1'] as num?)?.toInt() ?? 0,
      rssi: (map['rssi'] as num?)?.toInt() ?? -100,
      capabilities: cap,
      security: parseSecurity(cap),
      isPmfMandatory: cap.contains('MFPR') || cap.contains('PMF-R'),
      isPmfCapable: cap.contains('MFPC') || cap.contains('PMF-C'),
      is80211mcResponder: (map['is80211mcResponder'] as bool?) ?? false,
      isPasspoint: (map['isPasspoint'] as bool?) ?? false,
      isLocallyAdministeredMac: (map['isLocallyAdministeredMac'] as bool?) ?? false,
      rttDistanceMeters: (map['rttDistanceMeters'] as num?)?.toDouble(),
      stationCount: (map['stationCount'] as num?)?.toInt(),
      channelUtilizationPct: (map['channelUtilizationPct'] as num?)?.toDouble(),
      bssColor: (map['bssColor'] as num?)?.toInt(),
      isMloActive: (map['isMloActive'] as bool?) ?? false,
      mldMacAddress: map['mldMacAddress'] as String?,
      mloLinks: mloRaw.map((e) => MloLinkModel.fromMap(e as Map<dynamic, dynamic>)).toList(),
      mloAggregateMbps: (map['mloAggregateMbps'] as num?)?.toDouble() ?? 0.0,
      vendorOui: resolvedVendor,
    );
  }

  Map<String, dynamic> toMap() => {
    'ssid': ssid,
    'bssid': bssid,
    'frequencyMhz': frequencyMhz,
    'channel': channel,
    'band': band.name,
    'channelWidthMhz': channelWidthMhz,
    'centerFreq0': centerFreq0,
    'centerFreq1': centerFreq1,
    'rssi': rssi,
    'capabilities': capabilities,
    'security': security.name,
    'isPmfMandatory': isPmfMandatory,
    'isPmfCapable': isPmfCapable,
    'is80211mcResponder': is80211mcResponder,
    'isPasspoint': isPasspoint,
    'isLocallyAdministeredMac': isLocallyAdministeredMac,
    'rttDistanceMeters': rttDistanceMeters,
    'stationCount': stationCount,
    'channelUtilizationPct': channelUtilizationPct,
    'bssColor': bssColor,
    'isMloActive': isMloActive,
    'mldMacAddress': mldMacAddress,
    'mloLinks': mloLinks.map((e) => e.toMap()).toList(),
    'mloAggregateMbps': mloAggregateMbps,
    'vendorOui': vendorOui,
    'isPreferredScanningChannel': isPreferredScanningChannel,
  };
}
