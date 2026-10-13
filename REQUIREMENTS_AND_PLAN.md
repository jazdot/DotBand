# DotBand — Technical Requirements, Architecture & Execution Plan

**Document Version:** 2.0.0 (Master Engineering Specification)  
**Target Platform:** Android (API Level 33–36 / Android 13–16), iOS (Connected Link & Network Diagnostics Mode + Remote Spectrum Probe)  
**Author:** Jazdot Enterprises Architecture Team (Telco & Mobile Core SME Review)  
**Status:** Approved for Engineering Implementation — 10-Iteration Hardened Master  

---

## 1. Executive Product Charter & Jazdot Ecosystem Blueprint

### 1.1 Vision & Mission
**DotBand** is an ad-free, carrier-grade Wi-Fi spectrum instrument engineered specifically for **Wi-Fi 6E (6 GHz)** and **Wi-Fi 7 (IEEE 802.11be Multi-Link Operation)**. It eliminates the friction of legacy, abandoned analyzer tools and delivers real-time electromagnetic spectrum visibility across 2.4 GHz, 5 GHz, and 6 GHz bands without subscription gates, account mandates, or intrusive telemetry.

Together with **DotSignal** (Cellular 2G/3G/4G/5G baseband telemetry) and **DotLan** (Local subnet & IoT reconnaissance), DotBand completes the Jazdot Enterprises wireless triad.

### 1.2 Core Success Metrics
* **Play Store Velocity**: Attain Top 5 ranking in Google Play *Tools / Utilities* for keywords `WiFi 6E analyzer`, `6GHz channel scanner`, `WiFi 7 MLO`, and `ad-free wifi analyzer`.
* **Zero Crash / ANR Rate**: Sentry / Firebase Crashlytics error rate < 0.005% under aggressive scan throttling and OEM HAL stress.
* **Conversion Funnel**: 18%+ of active prosumers and network administrators explore the Jazdot Industrial Drawer, learning about **dotedge** and **DotNetwork** for private 5G and industrial Wi-Fi 6E/7 coexistence.

### 1.3 Jazdot Ecosystem Uniformity Matrix

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        THE JAZDOT BRAND & ARCHITECTURE UNIFORMITY MATRIX               │
├──────────────────────┬─────────────────────────────────────────────────────────────────┤
│ Component            │ DotBand Implementation (Parity with DotSignal)                  │
├──────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Visual Design System │ Obsidian Luxury CAD Theme (`#05070B` OLED background, hairline  │
│                      │ `#33D97706` gold borders, monospace tabular data figures).       │
├──────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Signature Brand Mark │ `DotBandAnimatedLogo` with pulsing Jazdot Gold Dot (`#FBBF24` / │
│                      │ `#D97706`) anchored alongside tri-band radiation wave arcs.     │
├──────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Top App Bar Wordmark │ Unified "DOT" (White 900) + "BAND" (Violet 700) layout with the │
│                      │ official Jazdot crest logo.                                     │
├──────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Telemetry Standard   │ Emits OCSF v1.3.0 Class 4001 (Network Activity) JSONL events,   │
│                      │ directly ingestible by `dotsec` SIEM and `dotops` cloud.        │
├──────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Verification Seals   │ Exported PDF audits bear cryptographic proof badges:             │
│                      │ `VERIFIED_WIFI7_MLO_PROVENANCE` & `JAZDOT_SEAL_V2`.              │
├──────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Cross-App Navigation │ "Jazdot Suite" navigation drawer featuring one-tap access to    │
│                      │ DotSignal and DotLan.                                           │
├──────────────────────┼─────────────────────────────────────────────────────────────────┤
│ Enterprise Bridge    │ High-visibility promotion: "Planning factory wireless? Deploy   │
│                      │ Private 5G + Wi-Fi 6E/7 with Jazdot dotedge".                   │
└──────────────────────┴─────────────────────────────────────────────────────────────────┘
```

---

## 2. Deep Research, Platform Analysis & 10-Iteration Hardening Record

Prior to finalizing specifications, DotBand underwent a brutal 10-iteration critique conducted across Telco/RF SME, Android Systems, iOS Security Sandbox, UX Graphics Engine, and Product Growth dimensions.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                            16-ITERATION HARDENING TIMELINE                             │
├─────────┬──────────────────────────────────┬───────────────────────────────────────────┤
│ Cycle   │ Dimension Evaluated              │ Critical Vulnerability Identified & Fixed │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 1  │ IEEE RF & Spectrum Physical Math │ Fixed off-by-one 6 GHz channel formula;   │
│         │                                  │ integrated 6 GHz PSC & 320 MHz schemes.   │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 2  │ iOS Platform Sandbox Reality     │ Debunked invalid "CoreWLAN on iOS" claim; │
│         │                                  │ architected Connected Diagnostics + Probe │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 3  │ Android Scan Throttling & APIs   │ Solved 4 scans/120s limit via token bucket│
│         │                                  │ & registerScanResultsCallback API 31+.    │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 4  │ Wi-Fi 7 MLO & Wi-Fi 6E Specs     │ Parsed STR/NSTR/eMLSR, MLD MAC, Link IDs, │
│         │                                  │ and AFC Standard Power vs LPI detection.  │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 5  │ Interference Rating Physics      │ Replaced naive star scores with physics   │
│         │                                  │ CCI vs ACI spectral emission mask math.   │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 6  │ Security & Protocol Auditing     │ Added WPA3 Dragonblood downgrade sentry,  │
│         │                                  │ OWE classifier, PMF, and Evil Twin radar. │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 7  │ High-FPS CAD Rendering Pipeline  │ Engineered LOD zoom & pan across 1.2 GHz  │
│         │                                  │ spectrum; eliminated canvas clutter.      │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 8  │ Business Value, ASO & Virality   │ Built zero-ad competitive moat, PDF share │
│         │                                  │ loops, and frictionless B2B lead funnel.  │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 9  │ Offline Intelligence & Field Ops │ Embedded 85k Trie OUI lookup; built live  │
│         │                                  │ roaming tracker & acoustic Geiger locator.│
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 10 │ Master Architecture Synthesis    │ Synthesized complete Cubit state machine, │
│         │                                  │ native Kotlin bridge, and test suite.     │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 11 │ 802.11 Airtime & QBSS Load IEs   │ Extracted Element ID 11 channel           │
│         │                                  │ utilization % & station count for math.   │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 12 │ 802.11mc/az Wi-Fi RTT Radar      │ Integrated WifiRttManager FTM for         │
│         │                                  │ sub-meter indoor distance AP ranging.     │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 13 │ Global Regulatory & Country IEs  │ Resolved FCC vs ETSI 6 GHz discrepancies; │
│         │                                  │ masked channels 97-233 in EU with alert.  │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 14 │ Mesh Virtual BSSID Clustering    │ Grouped multi-BSSID mesh nodes via        │
│         │                                  │ locally-administered MAC bit heuristics.  │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 15 │ Dual STA & P2P/NAN Coexistence   │ Detected STA+STA concurrency & social     │
│         │                                  │ channel interference (Nearby Share/AWDL). │
├─────────┼──────────────────────────────────┼───────────────────────────────────────────┤
│ Iter 16 │ Thermal Governor & Split Console │ Added frame rate step-down (120->30 FPS)  │
│         │                                  │ & foldable/tablet dual-pane CAD layout.   │
└─────────┴──────────────────────────────────┴───────────────────────────────────────────┘
```

### Iteration 1: IEEE RF Physical Layer & Frequency Math Verification
* **The Flaw**: The original formula for 6 GHz channel mapping was:
  `((freqMhz - 5950) / 5).round() + 1`
  In IEEE 802.11ax-2021 / 802.11be Annex E, channel center frequency is defined as:
  $$f_c = 5950 + 5 \times n_{ch} \quad \text{for } n_{ch} \in \{1, 5, 9, \dots, 233\}$$
  For Channel 1 ($f_c = 5955\text{ MHz}$), $(5955 - 5950)/5 = 1$. The flawed formula added $+1$, incorrectly mapping 5955 MHz to non-existent Channel 2!
* **The Fix**: Exact mathematical mapping enforced:
  $$n_{ch} = \frac{f_c - 5950}{5}$$
* **PSC (Preferred Scanning Channels)**: In 6 GHz, clients do not scan all 59 20-MHz channels. Scanning is concentrated on Preferred Scanning Channels spaced every 80 MHz (Channels 5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213, 229), or discovered via Out-of-Band Reduced Neighbor Reports (RNR) from 2.4/5 GHz beacons. DotBand explicitly flags and visualizes PSC channels.
* **320 MHz Channelization**: Wi-Fi 7 defines overlapping 320 MHz schemes (320-1 and 320-2). Center frequencies are mapped dynamically using `ScanResult.centerFreq0` and `ScanResult.centerFreq1`.

### Iteration 2: iOS Platform Sandbox Reality & Cross-Platform Truthfulness
* **The Flaw**: Requirements v1.0.0 claimed: *"Target Platform: ... iOS (CoreWLAN sandbox)"*.
  **Factual Reality Check**: `CoreWLAN` is a macOS-only framework (`#if os(macOS)`). Apple iOS has **zero** public APIs for scanning ambient Wi-Fi BSSIDs. `CNCopyCurrentNetworkInfo` was deprecated in iOS 14. `NEHotspotNetwork.fetchCurrent` requires the `com.apple.developer.networking.wifi-info` entitlement and returns **only the currently connected** BSSID/SSID.
* **The Fix**: 100% factual dual-mode architecture:
  1. **iOS Native Mode (Connected Link & Subnet Diagnostics)**: Focuses on deep real-time metrics for the active Wi-Fi connection: Tx/Rx PHY rate, link round-trip time (RTT), gateway jitter, DNS latency, MTU, packet loss, and full local subnet ARP/Bonjour device enumeration.
  2. **Remote Spectrum Probe Mode**: DotBand on iOS can connect over local Wi-Fi to a DotBand probe running on Android or Linux/Raspberry Pi (`ws://probe-ip:8088/telemetry`), rendering live full-band spectrum parabolas on iPad and iPhone displays.
  3. **App Store Review Safety**: Zero deceptive claims. Explicit UI badge on iOS: *"iOS Sandbox: Ambient RF spectrum scanning restricted by Apple OS. Displaying active link diagnostics & remote probe feed."*

### Iteration 3: Android Native Lifecycle & Scan Throttling Engineering
* **The Flaw**: Polling `WifiManager.startScan()` triggers Android's OS-level throttling (4 scans per 2-minute window for foreground apps, 1 scan per 30 minutes in background), causing silent scan freezes.
* **The Fix**:
  1. Implement a **Token Bucket Rate Limiter** (4 tokens / 120s) with UI cooldown visualizers.
  2. Register for `registerScanResultsCallback(executor, callback)` (Android 12+ / API 31+) and fall back to `WifiManager.SCAN_RESULTS_AVAILABLE_ACTION` dynamic BroadcastReceiver on API 30.
  3. Passive opportunistic harvesting: Whenever system UI, Google Play Services, or navigation apps trigger a scan, DotBand immediately catches the broadcast and updates the HUD without consuming the app's rate-limit tokens.
  4. Permissions: Must declare `ACCESS_FINE_LOCATION` and `ACCESS_WIFI_STATE`. On Android 13+ (API 33+), declaring `NEARBY_WIFI_DEVICES` with `neverForLocation` causes Android to redact BSSIDs to `02:00:00:00:00:00` and SSIDs to null. Therefore, DotBand explicitly requests `ACCESS_FINE_LOCATION` with a clear, honest pre-permission disclosure.

### Iteration 4: Wi-Fi 7 Multi-Link Operation (MLO) & Wi-Fi 6E Deep SME Specification
* **MLO Topologies**:
  * **Simultaneous Transmit & Receive (STR)**: Independent PHYs on distinct bands operate concurrently with zero inter-link blocking.
  * **Non-Simultaneous Transmit & Receive (NSTR)**: Links share RF chains; transmitting on one band desensitizes or blocks receiving on another.
  * **Enhanced Multi-Link Single Radio (eMLSR)**: Single radio dynamically switches channels based on clear-channel assessment.
* **Multi-Link Device (MLD) Parsing**:
  * Extract unified MLD MAC address.
  * Parse individual `MloLink` instances (`ScanResult.getAffiliatedMloLinks()` in API 33+): Link ID (0–15), Band (2.4G, 5G, 6G), Channel, and Link State.
  * Visual Bridge: In the spectrum view, affiliated MLO links are interconnected with dynamic CAD bracket arches, displaying aggregate channel capacity (e.g., 20 MHz + 160 MHz + 320 MHz = 500 MHz total channel aggregation).
* **Automated Frequency Coordination (AFC)**: In 6 GHz, detect Standard Power (SP) APs (which require AFC to protect incumbent fixed satellite and radio astronomy services) vs Low Power Indoor (LPI) APs from beacon Information Elements.

### Iteration 5: Physics-Based Interference Scoring Engine
* **The Flaw**: Traditional Wi-Fi analyzers award naive "stars" based merely on how many SSIDs share a channel. This is physically incorrect.
* **The Physics**:
  * **Co-Channel Interference (CCI)**: Transmitters on the exact same channel detect each other's 802.11 preambles at $\ge -82\text{ dBm}$ (Energy Detect / Carrier Sense threshold). They defer transmissions via CSMA/CA clear channel assessment. Airtime is shared cleanly without RF collision.
  * **Adjacent-Channel Interference (ACI)**: Overlapping channels (e.g., Ch 1 vs Ch 2 or Ch 3) cannot decode preambles. They transmit simultaneously, causing devastating frame corruption, CRC failures, and retransmissions.
* **The Formula**:
  $$\text{Interference Index}(ch) = \sum_{ap \in \text{CCI}} 10^{\frac{RSSI_{ap}}{20}} \cdot \frac{BW_{ap}}{20} + \sum_{ap \in \text{ACI}} 10^{\frac{RSSI_{ap}}{10}} \cdot \text{MaskOverlap}(ch, ap)$$
  where $\text{MaskOverlap}$ applies standard IEEE spectral emission mask attenuation ($0\text{ dB}$ on-channel, decaying to $-20\text{ dB}$ at $1\times BW$ offset, $-40\text{ dB}$ at $2\times BW$ offset).
* **BSS Coloring Discount**: On 802.11ax/be, networks with distinct BSS Colors utilize Spatial Reuse (SR / OBSS_PD), reducing effective contention penalty by 40%.

### Iteration 6: Enterprise Security & Protocol Auditing
* **WPA3 Dragonblood Sentry**: Detects WPA3 Transition Mode networks that are vulnerable to downgrade attacks. Alerts user if SAE hunting-and-pecking loop is exposed.
* **OWE (Opportunistic Wireless Encryption / RFC 8110)**: Categorizes modern open networks that employ Diffie-Hellman unauthenticated encryption vs vulnerable plaintext open networks.
* **Protected Management Frames (802.11w PMF)**: Audits whether AP mandates or negotiates PMF to prevent deauthentication and disassociation flooding attacks.
* **Rogue AP / Evil Twin Sentry**: Flags conflicting BSSIDs broadcasting the same SSID with mismatched encryption suites, disparate vendor OUIs, or sudden 30+ dBm signal anomalies.

### Iteration 7: High-FPS CAD Rendering Pipeline (60/120 FPS)
* **The Flaw**: Rendering 1.2 GHz of spectrum (59 20-MHz channels in 6 GHz alone) plus 5 GHz and 2.4 GHz on a single mobile screen creates microscopic, unreadable clutter.
* **The Solution**:
  * Dedicated Tab Navigation + Sub-Band Toggle Chips (`ALL`, `2.4 GHz`, `5 GHz`, `6 GHz`).
  * **Canvas Gesture Engine**: Horizontal inertia panning and pinch-to-zoom (1.0x to 10.0x) on 5 GHz and 6 GHz canvases.
  * **Level-of-Detail (LOD) Rendering**: At < 2.0x zoom, congested channels collapse into spectral power density bars. At > 2.0x zoom, detailed parabolas with SSID labels, RSSI badges, and channel bandwidth curves expand dynamically.
  * **AP Spotlight Focus**: Tapping any card or parabola spotlights that network in gold `#FBBF24` with glowing halo, dimming background networks to 15% opacity.

### Iteration 8: Business Value, ASO, Viral Growth Loops & Lead Funnel
* **Competitive Moat**: 100% free, 0% ads, zero trackers. Existing apps (NetSpot, WiFi Analyzer) bombard users with 30-second unskippable video ads and \$9.99/mo subscriptions. DotBand builds instant goodwill and viral organic recommendations on Reddit (r/HomeNetworking, r/Ubiquiti, r/sysadmin).
* **Viral Acquisition Engine**:
  * One-tap export of cryptographic **Jazdot PDF Site Survey Audit Reports** with shareable vector spectrum parabolas.
  * "Wi-Fi Health Score" share card formatted for social media and customer support tickets.
* **B2B Funnel**: Prominently features the **Jazdot Industrial Wireless Bridge**:
  *"Deploying factory Wi-Fi 6E/7 or Private 5G? Request an enterprise site survey with Jazdot dotedge & DotNetwork."*

### Iteration 9: Offline Intelligence & Field Operations
* **Offline OUI Database**: Embedded, trie-indexed IEEE OUI database (85,000+ manufacturer prefixes: Cisco, Aruba, Ubiquiti, Apple, Samsung, Intel, TP-Link, MikroTik, etc.) compressed to < 350 KB. Instant zero-network vendor resolution.
* **Rolling Roaming Waterfall**: 60s/120s real-time dBm graph per AP to diagnose 802.11k/v/r roaming transitions and signal drops during walk tests.
* **Acoustic Geiger AP Locator**: Optional audio feedback clicker that pulses faster as signal approaches -30 dBm, allowing technicians to locate hidden ceiling or wall APs eyes-free.

### Iteration 10: Master Architecture Synthesis
* Clean separation of concerns:
  * Native Kotlin Bridge: `WifiScannerBridge.kt` + `MloParser.kt`.
  * Reactive Dart Layer: `WifiScanCubit`, `SpectrumParabolaPainter`, `InterferenceEngine`, `OcsfWifiExporter`.
  * Comprehensive automated test suite with Python conformance verification.

### Iteration 11: Real-World 802.11 Airtime Saturation & QBSS Load Elements
* **The Blindspot**: Interference scoring based solely on RSSI ignores real-world traffic load. An AP at -45 dBm with zero connected clients consumes only 0.3% airtime (beacons), while a -72 dBm AP with 30 active video streams consumes 90% airtime!
* **The Solution**: Parse IEEE 802.11 Element ID 11 (**BSS Load / QBSS**) via `ScanResult.getInformationElements()` (Android 11+ / API 30+):
  * `stationCount`: Associated client count.
  * `channelUtilization`: Normalized 0–255 airtime busy percentage ($\frac{\text{val}}{255} \times 100\%$).
  * `availableAdmissionCapacity`: Remaining QoS bandwidth.
* **Formula Integration**: Channel Interference Score directly multiplies co-channel contention by actual channel utilization:
  $$\text{Airtime-Weighted Score}(ch) = \text{Score}(ch) \times \left(1.0 - 0.7 \times \frac{\text{Utilization \%}}{100\%}\right)$$

### Iteration 12: IEEE 802.11mc / 802.11az Wi-Fi RTT (Fine Time Measurement) & Centimeter AP Radar
* **The Blindspot**: Traditional Wi-Fi analyzers estimate physical distance using RSSI path loss, which carries a $\pm 300\%$ indoor error margin due to multi-path reflections and concrete attenuation.
* **The Solution**: Native integration of Android **Wi-Fi RTT** (`android.net.wifi.rtt.WifiRttManager`):
  * Query `ScanResult.is80211mcResponder()`.
  * Issue nanosecond Fine Timing Measurement (FTM) ranging requests to supporting APs.
  * Deliver sub-meter physical distance measurements (in millimeters/meters) directly on the AP detail card and acoustic locator HUD, turning DotBand into an indoor radar for field technicians.

### Iteration 13: International Regulatory Domains, 802.11d Country Codes & Global 6 GHz Boundary Masking
* **The Blindspot**: 6 GHz spectrum availability varies radically by jurisdiction:
  * **US FCC**: Channels 1–233 (5925–7125 MHz, 1,200 MHz width).
  * **EU ETSI / UK / Japan / India**: Only Channels 1–93 (5945–6425 MHz, 480 MHz width). Channels 97–233 are strictly reserved.
* **The Trap**: European OEM devices physically reject scans above 6425 MHz. Showing empty channels 97–233 without explanation triggers negative user reviews ("6 GHz scanning broken in my country!").
* **The Solution**:
  * Inspect 802.11d Country Information Elements (Element ID 7).
  * Render dynamic **Regulatory Boundary Masks** on the 6 GHz canvas: clearly demarcating authorized spectrum vs reserved spectrum with international territory badges (e.g. `[ETSI DOMAIN: CH 1-93 AUTHORIZED]`).

### Iteration 14: Virtual BSSID Clustering, Mesh AP Aggregation & Hidden SSID Sentry
* **The Blindspot**: Modern enterprise and home mesh routers (UniFi, Cisco Meraki, Aruba, Eero, Google Nest Wifi, Asus AiMesh) broadcast 6–12 separate BSSIDs from a single physical radio enclosure (IoT, Guest, Main, Backhaul). This floods the AP list with redundant cards.
* **The Solution**:
  * **Locally Administered MAC Bit Detection**: Check bit 1 of the first octet of the BSSID (`b1 == 1`, e.g., `x2:`, `x6:`, `xA:`, `xE:`).
  * **Physical Node Aggregator**: Cluster virtual BSSIDs sharing the same physical radio into a unified "Mesh Node Card", displaying the physical router with all its child SSIDs and frequencies.
  * **Hidden SSID Sentry**: Cleanly parse and label unbroadcast SSIDs as `[Hidden Network]` with vendor OUI, RSSI, and security parameters intact, without throwing null-pointer exceptions or breaking table sorting.

### Iteration 15: Dual Station (STA + STA) Concurrency & Peer-to-Peer (NAN / Quick Share / AirDrop) Interference
* **The Blindspot**: Modern Android 13+ devices support concurrent Dual Station (`isStaConcurrencyForLocalOnlyConnectionSupported()`), while Wi-Fi Direct and Wi-Fi Aware (NAN) file sharing (Quick Share, Nearby Share, AirDrop) lock Social Channels (Channel 6 in 2.4 GHz, Channel 149 in 5 GHz).
* **The Solution**:
  * Telemetry Inspector reports device concurrency capabilities (STA+STA, STA+AP).
  * **P2P Interference Warning**: Flags when active local peer-to-peer transmissions are inducing radio time-sharing and throughput degradation.

### Iteration 16: Device Thermal Sentry & Adaptive Canvas Power Governor + Responsive Foldable Split Console
* **The Blindspot**: Running a 120 FPS GPU `CustomPainter` canvas during a 2-hour physical walk test drains battery and induces device thermal throttling. Unfolded 7.6" foldable displays look sparse on single-column layouts.
* **The Solution**:
  * **Adaptive Power Governor & Thermal Sentry**: Monitors `PowerManager.getCurrentThermalStatus()`. Automatically steps canvas down from 120 FPS to 30 FPS under `THERMAL_STATUS_MODERATE`, disables expensive glow shaders, and pauses painting when app is backgrounded.
  * **Responsive Foldable/Tablet Split Console**: On displays $\ge 600\text{dp}$ wide, dynamically splits the viewport into a dual-pane CAD workbench (Interactive Spectrum Canvas on the left, Real-Time AP Inspector and Channel Rating on the right).

---

## 3. Comprehensive Functional Requirements (FR)

### Module 1: Spectrum Analysis & Channel Modeling
* **FR-01 (Multi-Band Spectrum Canvas)**: Interactive GPU-accelerated canvas rendering parabolas for:
  * 2.4 GHz (Channels 1–14, 2412–2484 MHz).
  * 5.0 GHz (Channels 36–165, 5170–5835 MHz: U-NII-1, U-NII-2A DFS, U-NII-2C DFS, U-NII-3, U-NII-4).
  * 6.0 GHz (Channels 1–233, 5925–7125 MHz: U-NII-5, U-NII-6, U-NII-7, U-NII-8).
* **FR-02 (Wi-Fi 7 MLO Bond Inspection)**: Extract and display Multi-Link Operation affiliations:
  * Unified MLD MAC address.
  * Individual affiliated links (Band, Channel, Link ID, RSSI).
  * Theoretical aggregated link throughput calculation.
* **FR-03 (Accurate Channel Width Geometry)**: Dynamically scale parabola base width according to channel bandwidth:
  * 20 MHz, 40 MHz, 80 MHz, 160 MHz, and 320 MHz (Wi-Fi 7 ultra-wide).
  * Align parabola apex with primary channel frequency and base center with `centerFreq0` / `centerFreq1`.
* **FR-04 (6 GHz Preferred Scanning Channel (PSC) Indicator)**: Highlight PSC channels (5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213, 229) with distinct golden tick marks to guide AP channel planning.

### Module 2: Interference Engine & Channel Rating
* **FR-05 (Physics-Based Interference Rating)**: Compute Channel Interference Score (0–100, 100 = perfectly clean) distinguishing Co-Channel Interference (CSMA/CA contention) from Adjacent-Channel Interference (destructive RF collision).
* **FR-06 (Automated Cleanest Channel Recommender)**: Suggest the optimal 20/40/80/160 MHz channel plan for router configuration based on lowest interference and DFS availability.
* **FR-07 (BSS Coloring & Spatial Reuse Detection)**: Display 802.11ax/be BSS Color IDs (0–63) and evaluate spatial reuse efficiency.
* **FR-19 (QBSS Channel Airtime Saturation Metric)**: Parse IEEE 802.11 Element ID 11 to display real-time Channel Utilization percentage and associated Station Count per BSSID.

### Module 3: Security & Enterprise Protocol Auditing
* **FR-08 (Security Protocol Classifier)**: Classify networks with color-coded security badges:
  * WPA3-Enterprise 192-bit / WPA3-Personal Pure (Cyan `#00E5FF`).
  * WPA3-Transition Mode (Amber `#F59E0B` with downgrade warning).
  * WPA2-Personal / Enterprise (White `#E2E8F0`).
  * OWE (Opportunistic Wireless Encryption / Enhanced Open) (Violet `#A855F7`).
  * Open / Unencrypted (Crimson `#EF4444`).
* **FR-09 (Protected Management Frames (PMF) Audit)**: Check 802.11w PMF requirement status (Required, Capable, Disabled).
* **FR-10 (Rogue AP & Evil Twin Sentry)**: Automatically flag duplicate SSIDs with conflicting security standards or suspicious BSSIDs.
* **FR-23 (Passpoint / Hotspot 2.0 / OpenRoaming Venue Telemetry)**: Extract Passpoint Release 1/2/3 parameters, Venue Group/Type, and Roaming Consortium OIs via `isPasspointNetwork()`.

### Module 4: Spatial Site Survey & Time Series
* **FR-11 (Rolling Roaming Stability Graph)**: 60s and 120s time-series line chart tracking signal strength (dBm) per SSID during site walk-throughs.
* **FR-12 (Handover & Roaming Event Logger)**: Log BSSID handover timestamps, signal delta ($\Delta\text{dBm}$), and frequency switches (e.g. 5 GHz $\rightarrow$ 6 GHz).
* **FR-13 (Acoustic Geiger Counter)**: Audio feedback engine producing Geiger-counter style audio ticks proportional to selected AP signal strength.
* **FR-14 (Offline IEEE OUI Lookup)**: Local binary-trie database of 85,000+ hardware vendors resolving manufacturer names without internet.
* **FR-20 (802.11mc/az Wi-Fi RTT Centimeter Distance Radar)**: Query `is80211mcResponder()` and issue Fine Timing Measurement ranging requests via `WifiRttManager` to provide sub-meter physical distance readouts.
* **FR-21 (Global Regulatory Domain Sentry & Regional Spectrum Mask)**: Read Country IE (Element ID 7), determine active regulatory domain (FCC, ETSI, MIC), and visually mask restricted spectrum bands.
* **FR-22 (Mesh Node Clustering & Virtual BSSID De-duplication)**: Group virtual BSSIDs sharing a physical radio chassis (via locally-administered MAC bit `0x02` and OUI alignment) into consolidated Mesh Node cards.

### Module 5: Organization Telemetry & Hardware Control
* **FR-15 (OCSF v1.3.0 JSONL Streaming)**: Export scan results conforming to Open Cybersecurity Schema Framework Class 4001 (Network Activity).
* **FR-16 (Jazdot PDF Site Survey Audit Report)**: Generate high-resolution PDF certificates featuring vector spectrum parabolas, channel ratings, security audits, and cryptographic provenance seals (`VERIFIED_WIFI7_MLO_PROVENANCE`).
* **FR-17 (CSV / Wireshark PCAP Dump)**: Export raw scan dumps compatible with Wireshark and Python test automation runners.
* **FR-18 (Jazdot Ecosystem Drawer)**: High-visibility cross-navigation drawer connecting DotBand to DotSignal, DotLan, and Jazdot Enterprise solutions.
* **FR-24 (Dual Station Concurrency & P2P RF Interlock Sentry)**: Detect and report STA+STA concurrency and alert when active peer-to-peer file transfers occupy social channels.
* **FR-25 (Adaptive Canvas Thermal Governor & Foldable Dual-Pane Console)**: Monitor `PowerManager` thermal status to dynamically scale canvas FPS, and present a dual-pane CAD workbench on screens $\ge 600\text{dp}$.

---

## 4. Non-Functional & Regulatory Requirements (NFR)

* **NFR-01 (Zero-Root Operation)**: 100% compliant with standard Android SDK (API Level 33–36); strictly zero root or system-signature permissions required.
* **NFR-02 (Scan Throttling Resilience)**: Token-bucket scan manager enforcing a 30-second cooldown between active scans; passive listener for external OS scan broadcasts.
* **NFR-03 (Display Performance)**: CustomPainter spectrum HUD renders at sustained **60 FPS** (and 120 FPS on high-refresh-rate displays) with 100+ visible BSSIDs.
* **NFR-04 (Offline Sovereignty)**: All scanning, OUI identification, interference calculations, and PDF generation execute locally without internet connectivity.
* **NFR-05 (Battery Budget)**: Continuous spectrum scanning HUD consumes less than 4.0% battery per hour of active site survey.
* **NFR-06 (iOS Truthfulness)**: Displays active Wi-Fi link diagnostics and remote probe streaming on iOS; zero misleading claims to ensure 100% App Store review approval.
* **NFR-07 (Thermal & Frame Rate Throttling Governor)**: Canvas rendering automatically throttles to 30 FPS when `PowerManager.getCurrentThermalStatus() >= THERMAL_STATUS_MODERATE` to protect battery and RF receiver sensitivity.
* **NFR-08 (Dual-Screen / Foldable UI Conformance)**: Seamless dynamic transition between single-column tabbed mobile view and dual-pane master-detail CAD workstation on foldable displays ($\ge 600\text{dp}$).


---

## 5. Technical Architecture & Native Platform Bridges

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 DOTBAND ARCHITECTURE                                  │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Android Platform Layer (Kotlin - API 33–36)                                            │
│   • WifiManager.registerScanResultsCallback() ─► API 31+ Native Callback               │
│   • ScanResults BroadcastReceiver ─────────────► Fallback Intent Receiver              │
│   • ScanResult.getAffiliatedMloLinks() ────────► Wi-Fi 7 MLO Affiliation Parser        │
│   • ScanResult.channelWidth ───────────────────► 20/40/80/160/320 MHz Math             │
│   • ConnectivityManager.NetworkCallback ───────► Connected WifiInfo Telemetry          │
│                                      │                                                 │
│ Flutter Method & Event Channel Bridge (`com.jazdot.dotband/telemetry`)                 │
│                                      │                                                 │
│ Dart / Flutter Reactive Layer                                                          │
│   • WifiScanCubit ─────────────────────────────► Scan Lifecycle State Machine          │
│   • SpectrumCanvasPainter ─────────────────────► GPU-Accelerated Parabola Renderer     │
│   • InterferenceEngine ────────────────────────► Physics-Based CCI/ACI Rating         │
│   • OuiDatabaseResolver ───────────────────────► Local Compressed Trie Lookup          │
│   • OcsfWifiExporter ──────────────────────────► OCSF v1.3.0 Class 4001 Exporter       │
│   • PdfSurveyReportGenerator ──────────────────► Jazdot Provenance Audit Certificate   │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### 5.1 Factual Frequency-to-Channel Mapping Algorithm (Dart)

```dart
int frequencyToChannel(int freqMhz) {
  // 2.4 GHz Band (Channels 1–14)
  if (freqMhz == 2484) return 14;
  if (freqMhz >= 2412 && freqMhz <= 2472) {
    return ((freqMhz - 2412) / 5).round() + 1;
  }

  // 5.0 GHz Band (Channels 36–165, U-NII-1 through U-NII-4)
  if (freqMhz >= 5170 && freqMhz <= 5835) {
    return ((freqMhz - 5000) / 5).round();
  }

  // 6.0 GHz Band (Channels 1–233, IEEE 802.11ax/be Annex E)
  // Channel center frequency: fc = 5950 + 5 * ch. Channel = (fc - 5950) / 5
  if (freqMhz >= 5955 && freqMhz <= 7115) {
    return ((freqMhz - 5950) / 5).round();
  }

  return -1; // Out of range or unsupported frequency
}

bool isPreferredScanningChannel(int channel) {
  // 6 GHz Preferred Scanning Channels (spaced every 80 MHz)
  const pscChannels = {5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213, 229};
  return pscChannels.contains(channel);
}
```

---

## 6. UI/UX Architecture & Screen Flow

1. **Tab 1: SPECTRUM (Parabola HUD)**:
   * Sticky top bar with multi-band filter chips: `[ALL TRI-BAND]`, `[2.4 GHz]`, `[5.0 GHz]`, `[6.0 GHz (6E/7)]`.
   * Interactive pinch-to-zoom (1.0x to 10.0x) and horizontal inertia panning.
   * Smooth vector parabolas with gold hairline highlights for selected APs.
   * Floating Scan Button with token-bucket countdown cooldown indicator.
2. **Tab 2: RATING (Interference Matrix)**:
   * Channel rating cards (Channels 1–233) scored 0–100 with Star Badges.
   * Breakdown of Co-Channel (contenders) vs Adjacent-Channel (colliders).
   * One-tap recommendation banner: *"Best 80 MHz channel: Channel 149 (Zero CCI/ACI detected)"*.
3. **Tab 3: ACCESS POINTS (Detailed List)**:
   * Search and filter by SSID, BSSID, Vendor, Security, or Band.
   * Expandable AP cards: SSID, BSSID, resolved Vendor OUI, generation badge (`Wi-Fi 7`, `Wi-Fi 6E`, `Wi-Fi 6`, `Wi-Fi 5`), RSSI gauge, and MLO bonded links.
4. **Tab 4: TIME GRAPH (Roaming & Stability)**:
   * Rolling 60s/120s multi-line signal graph tracking dBm stability.
   * Roaming handover markers with signal drop alerts.
   * Acoustic Geiger toggle for eyes-free AP location.

---

## 7. Phased Development Roadmap

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: Native Telemetry Engine & Scan Bridge (Days 1–3)                              │
│ • Kotlin WifiScannerBridge with API 31+ callback and API 30 BroadcastReceiver fallback│
│ • Android 13/14+ MloLink parser and channelWidth math                                 │
│ • Unit tests for frequency-to-channel, PSC verification, and rate limiter             │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 2: Spectrum Parabola CAD Canvas & LOD Engine (Days 4–6)                          │
│ • CustomPainter tri-band parabola renderer with 60 FPS animation                      │
│ • Pinch-to-zoom (1x–10x), horizontal inertia pan, and LOD thermal clustering          │
│ • Filter chips (2.4G, 5G, 6G) and AP spotlight focus                                  │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 3: Wi-Fi 7 MLO, Interference Engine & Security Sentry (Days 7–9)                 │
│ • Affiliated MLO link visualizer with CAD bridge arches                               │
│ • Physics-based CCI/ACI scoring and optimal channel recommendation engine             │
│ • WPA3 Dragonblood sentry, OWE classifier, and Evil Twin radar                         │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 4: Offline OUI, Roaming Waterfall & Acoustic Geiger (Days 10–12)                 │
│ • Compressed binary-trie IEEE OUI lookup (85,000+ entries)                            │
│ • 60s/120s rolling roaming stability time graph with handover logging                  │
│ • Field feedback acoustic Geiger locator engine                                       │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 5: Brand Parity, Export Architecture & Test Hardening (Days 13–15)               │
│ • DotBandAnimatedLogo, ObsidianTheme, and Jazdot Suite drawer                         │
│ • OCSF v1.3.0 JSONL export, Wireshark PCAP/CSV dump, and Jazdot PDF audit certificate  │
│ • Comprehensive automated Python runtime resilience test suite                        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Automated Test & Conformance Suite Specifications

Following the pattern established in **DotSignal**, DotBand mandates automated resilience test suites:
1. `test_runtime_resilience.py`: Validates zero mock data in production code, non-crashing telemetry serialization, rate-limit token bucket behavior, and manifest permissions.
2. `test_ieee_channel_raster.py`: Verifies exact mathematical conformance of 2.4 GHz, 5.0 GHz, and 6.0 GHz channels, PSC lists, and 320 MHz center frequencies.
3. `test_interference_engine.py`: Tests CCI vs ACI weighting against synthetic multi-AP test vectors.
4. `test_ocsf_wifi_schema.py`: Validates OCSF v1.3.0 Class 4001 compliance.
