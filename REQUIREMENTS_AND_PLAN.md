# DotBand — Technical Requirements, Architecture & Execution Plan

**Document Version:** 1.0.0  
**Target Platform:** Android (API Level 33–36 / Android 13–16), iOS (CoreWLAN sandbox)  
**Author:** Jazdot Enterprises Architecture Team  
**Status:** Approved for Engineering Implementation  

---

## 1. Executive Product Charter

### 1.1 Vision & Mission
**DotBand** is an ad-free, carrier-grade Wi-Fi spectrum instrument engineered for **Wi-Fi 6E (6 GHz)** and **Wi-Fi 7 (802.11be Multi-Link Operation)**. It eliminates the friction of legacy, abandoned analyzer tools and delivers real-time electromagnetic spectrum visibility across 2.4 GHz, 5 GHz, and 6 GHz bands without subscription gates, account mandates, or intrusive telemetry.

### 1.2 Core Success Metrics
* **Play Store Velocity**: Attain Top 10 ranking in the Google Play *Tools / Utilities* category for keywords `WiFi 6E analyzer`, `6GHz channel scanner`, and `WiFi 7 MLO`.
* **Zero Crash / ANR Rate**: Sentry / Crashlytics error rate under 0.01% under aggressive scan throttling.
* **Top-of-Funnel Conversion**: 15%+ of active users explore the embedded **Jazdot Enterprises** drawer, learning about **dotedge** and **DotNetwork** for industrial wireless deployments.

---

## 2. Jazdot Ecosystem Similarity & Organization Visibility Blueprint

To maximize brand equity and ensure high corporate visibility for **Jazdot Enterprises**, DotBand deliberately mirrors the architecture and aesthetic of **DotSignal**:

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                     THE JAZDOT BRAND UNIFORMITY MATRIX                           │
├──────────────────────┬───────────────────────────────────────────────────────────┤
│ Component            │ Implementation in DotBand (Parity with DotSignal)         │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Visual Design System │ Obsidian Luxury CAD Theme (`#05070B` OLED background,     │
│                      │ hairline `#33D97706` gold borders, monospace figures).    │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Signature Brand Mark │ `DotBandAnimatedLogo` with pulsing Jazdot Gold Dot        │
│                      │ (`#FBBF24` / `#D97706`) anchored alongside spectrum arcs. │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Top App Bar Wordmark │ Unified "DOT" (White 900) + "BAND" (Violet 700) layout   │
│                      │ with the official Jazdot crest logo.                      │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Telemetry Standard   │ Emits OCSF v1.3.0 Class 4001 (Network Activity) JSONL      │
│                      │ events, directly ingestible by `dotsec` SIEM and `dotops`.│
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Verification Seals   │ Exported PDF audits bear cryptographic proof badges:      │
│                      │ `VERIFIED_WIFI7_MLO_PROVENANCE` & `JAZDOT_SEAL_V2`.       │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Cross-App Navigation │ "Jazdot Suite" navigation drawer featuring one-tap access  │
│                      │ to [DotSignal](file:///home/ros/dotsignal) and [DotLan](file:///home/ros/dotlan).             │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Enterprise Bridge    │ High-visibility promotion: "Planning factory wireless?   │
│                      │ Deploy Private 5G + Wi-Fi 6E with Jazdot dotedge".        │
└──────────────────────┴───────────────────────────────────────────────────────────┘
```

---

## 3. Market Problem & Competitive Gap Analysis

### 3.1 Competitor Landscape
1. **Open-Source *WiFi Analyzer* (VREM / Kevin Yuan)**:
   - *Status*: Largely unmaintained since 2020–2023.
   - *Failure*: Fails to render 6 GHz channels (5925–7125 MHz), fails on Android 14+ foldable aspect ratios, lacks Wi-Fi 7 MLO aggregation.
2. **Ubiquiti *WiFiman***:
   - *Status*: Modern, but intentionally hides granular channel overlapping parabolas and raw RF metrics to push consumer simplicity.
3. **Commercial Analyzers (*NetSpot*, *Network Analyzer Pro*)**:
   - *Status*: Aggressive paywalls ($4.99–$9.99/month), full-screen interstitial video ads, mandatory cloud logins.

### 3.2 The DotBand Opportunity
DotBand enters the market as the **only free, open, ad-free Wi-Fi 6E/7 tri-band analyzer** with luxury engineering aesthetics.

---

## 4. Functional Requirements (FR)

### Spectrum Analysis & Channel Modeling
* **FR-01 (Simultaneous Tri-Band View)**: Render 2.4 GHz (Channels 1–14), 5 GHz (Channels 36–165), and 6 GHz (Channels 1–233) on synchronized interactive Canvas parabolas.
* **FR-02 (Wi-Fi 7 MLO Bond Inspection)**: Identify Multi-Link Operation (MLO) affiliated APs using `ScanResult.getAffiliatedMloLinks()`, visualizing the unified MLD MAC address and bonded secondary links.
* **FR-03 (Channel Width Representation)**: Accurately scale parabola bases according to channel bandwidth: 20 MHz, 40 MHz, 80 MHz, 160 MHz, and 320 MHz (Wi-Fi 7 ultra-wide).
* **FR-04 (Co-Channel & Adjacent Interference Rating)**: Compute a real-time Interference Score (0–100) for every channel, recommending the cleanest channel for AP configuration.
* **FR-05 (WPA3 vs. WPA2 Security Classifier)**: Flag legacy WEP/WPA/WPA2 networks in warning amber, highlight WPA3-Personal/Enterprise in cyan, and flag unencrypted open networks in crimson.

### Time-Series & Spatial Site Survey
* **FR-06 (RSSI Watermark Graph)**: Maintain a 60-second rolling signal history graph per SSID to evaluate roaming and dead zones.
* **FR-07 (Channel Overlap Matrix)**: List all overlapping BSSIDs per channel with signal strength differentials to debug co-channel interference.
* **FR-08 (Vendor OUI Identification)**: Resolve BSSID MAC prefixes against an embedded, offline IEEE OUI database (85,000+ entries) without internet dependency.

### Export & Organization Telemetry
* **FR-09 (OCSF v1.3.0 JSONL Streaming)**: Format Wi-Fi environment snapshots into Open Cybersecurity Schema Framework Class 4001 events.
* **FR-10 (Jazdot PDF Audit Report)**: Generate high-resolution PDF site survey certificates with Jazdot proof seals, channel graphs, and interference tables.
* **FR-11 (CSV / PCAP Export)**: Export raw scan dumps compatible with Wireshark and `dotlab` CI/CD regression runners.
* **FR-12 (Enterprise Cloud Uplink)**: In-app switch to stream live survey telemetry to Jazdot `dotops` via secure WebSocket (`wss://dotops.jazdot.corp/stream`).

---

## 5. Non-Functional & Regulatory Requirements (NFR)

* **NFR-01 (Zero-Root Operation)**: 100% compliant with standard Android SDK (API Level 33–36); strictly zero root or signature-level permissions required.
* **NFR-02 (Scan Throttling Resilience)**: Listen to `WifiManager.SCAN_RESULTS_AVAILABLE_ACTION` broadcasts; never trigger tight polling loops that trigger Android OS scan caps.
* **NFR-03 (Render Performance)**: Parabola spectrum canvas must render at solid **60 FPS** on 120Hz displays with 100+ visible BSSIDs.
* **NFR-04 (Offline Sovereignty)**: All core scanning, OUI lookups, and PDF generation execute 100% locally on-device with zero mandatory cloud connectivity.
* **NFR-05 (Battery Budget)**: Active scanning HUD consumes under 3.5% battery per hour of continuous survey.
* **NFR-06 (Google Play Policy Compliance)**: Zero deceptive claims; proper runtime requests for `ACCESS_FINE_LOCATION` and `ACCESS_WIFI_STATE`.

---

## 6. Technical Architecture & Android Native Bridge

```
┌────────────────────────────────────────────────────────────────────────┐
│                        DOTBAND NATIVE ARCHITECTURE                     │
├────────────────────────────────────────────────────────────────────────┤
│ Android Platform Layer (Kotlin)                                        │
│   • WifiManager.scanResults ──► BroadcastReceiver Lifecycle            │
│   • ScanResult.frequency ────► 2.4GHz / 5GHz / 6GHz Classifier         │
│   • ScanResult.channelWidth ─► 20 / 40 / 80 / 160 / 320 MHz Math       │
│   • AffiliatedMloLinks ──────► Wi-Fi 7 MLO Topology Parser             │
│                                  │                                     │
│ Flutter Method & Event Channel Bridge (`com.jazdot.dotband/telemetry`) │
│                                  │                                     │
│ Dart / Flutter Reactive Layer                                          │
│   • WifiScanCubit ───────────► State Machine (Scanning, Idle, Error)  │
│   • SpectrumParabolaPainter ─► CustomPaint GPU-accelerated Canvas      │
│   • InterferenceEngine ──────► Co-Channel Interference (CCI) Scoring   │
│   • OcsfWifiExporter ────────► OCSF v1.3.0 Class 4001 Serialization    │
└────────────────────────────────────────────────────────────────────────┘
```

### 6.1 Frequency-to-Channel Mapping Algorithm
```dart
int frequencyToChannel(int freqMhz) {
  // 2.4 GHz Band
  if (freqMhz == 2484) return 14;
  if (freqMhz >= 2412 && freqMhz <= 2472) {
    return ((freqMhz - 2412) / 5).round() + 1;
  }
  // 5.0 GHz Band
  if (freqMhz >= 5170 && freqMhz <= 5835) {
    return ((freqMhz - 5000) / 5).round();
  }
  // 6.0 GHz Wi-Fi 6E / Wi-Fi 7 Band (5925 MHz to 7125 MHz)
  if (freqMhz >= 5925 && freqMhz <= 7125) {
    return ((freqMhz - 5950) / 5).round() + 1;
  }
  return -1; // Unknown frequency
}
```

---

## 7. UI/UX Architecture & Screen Flow

1. **Tab 1: SPECTRUM (Parabola HUD)**:
   - Sticky header with Tri-Band toggle chips: `[ALL TRI-BAND]`, `[2.4 GHz]`, `[5.0 GHz]`, `[6.0 GHz (6E/7)]`.
   - Smooth vector parabolas showing channel overlaps, centered on primary frequency, width proportional to MHz bonding.
2. **Tab 2: RATING (Interference Matrix)**:
   - Bar chart scoring channels 1 through 233 from 1 to 10 stars based on SNR and CCI congestion.
3. **Tab 3: ACCESS POINTS (Detailed List)**:
   - Expandable cards displaying SSID, BSSID, resolved vendor (e.g. Cisco, Aruba, Ubiquiti, Netgear), security cipher, Wi-Fi generation badge (`Wi-Fi 7`, `Wi-Fi 6E`, `Wi-Fi 6`, `Wi-Fi 5`).
4. **Tab 4: TIME GRAPH (Roaming & Stability)**:
   - 60-second rolling dBm line chart tracking handover stability between APs.

---

## 8. Phased Development Roadmap

```
┌────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: Native Engine & Scanner Bridge (Days 1–3)                     │
│ • Kotlin WifiManager EventChannel bridge with 6 GHz parsing            │
│ • Unit tests for frequency-to-channel and 320 MHz channel width math   │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 2: Spectrum Parabola & CAD Canvas (Days 4–6)                     │
│ • CustomPainter tri-band parabola renderer with 60 FPS animation       │
│ • Filter chips (2.4G, 5G, 6G) and signal quality color gradients       │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 3: Wi-Fi 7 MLO & Interference Engine (Days 7–9)                  │
│ • API 33+ Multi-Link Operation affiliation parser                      │
│ • Co-channel interference scoring and channel rating algorithm         │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 4: Jazdot Brand & Export Architecture (Days 10–12)               │
│ • DotBandAnimatedLogo, ObsidianTheme, and Jazdot Suite drawer         │
│ • OCSF v1.3.0 exporter, CSV dump, and PDF audit generator with seals  │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 5: Testing, Hardening & Play Store Submission (Days 13–14)       │
│ • Automated resilience test suite against Android 13/14/15/16 devices  │
│ • Google Play Store assets, screenshots, and privacy policy release    │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Google Play Store Launch & SEO Strategy

* **App Title**: `DotBand: Wi-Fi 6E & 7 Analyzer`
* **Subtitle**: `Ad-free tri-band spectrum analyzer, Wi-Fi 7 MLO radar & channel rater.`
* **Keywords**: `WiFi 6E analyzer`, `6GHz channel scanner`, `WiFi 7 MLO`, `ad free wifi analyzer`, `tri band spectrum`, `channel interference tester`.
* **Screenshot Value Props**:
  1. *"The first true Wi-Fi 6E (6 GHz) & Wi-Fi 7 spectrum analyzer."*
  2. *"Zero ads. Zero tracking. 100% ad-free."*
  3. *"Inspect 320 MHz channel bonding and Multi-Link Operation."*
  4. *"Find the cleanest channel in seconds with AI interference rating."*

---

## 10. Risk Analysis & Mitigation Matrix

| Risk Factor | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Android Scan Throttling** | High | Medium | Rely on system scan broadcasts (`WIFI_SCAN_RESULTS_AVAILABLE_ACTION`); never trigger rapid polling loops. Provide manual "Scan Now" button with cooldown timer. |
| **Region-Locked 6 GHz Hardware** | Medium | Low | Check device Wi-Fi capabilities; if 6 GHz hardware is absent, display informative badge: *"6 GHz hardware not detected on this device model"*. |
| **Location Permission Rejection** | Medium | High | Display clean pre-permission dialog explaining: *"Android couples Wi-Fi BSSID scanning with location privacy. DotBand never accesses or stores your GPS coordinates."* |
| **Play Store Policy Scrutiny** | Low | Low | Standard utility permissions only (`ACCESS_FINE_LOCATION`, `ACCESS_WIFI_STATE`). Zero background VPN or root requirements. |
