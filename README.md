# DotBand — Carrier-Grade Wi-Fi 6E (6 GHz) & Wi-Fi 7 Tri-Band Spectrum Analyzer

[![Jazdot Enterprises](https://img.shields.io/badge/JAZDOT-ENTERPRISES-D97706?style=flat-square)](https://jazdot.com)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-blue?style=flat-square)](#)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.10+-02569B?style=flat-square&logo=flutter)](#)
[![Android API](https://img.shields.io/badge/Android-API%2033--36-3DDC84?style=flat-square&logo=android)](#)
[![Spectrum](https://img.shields.io/badge/Spectrum-2.4G%20%7C%205G%20%7C%206G%20(Wi--Fi%207)-A855F7?style=flat-square)](#)

> **Part of the Jazdot Enterprises Mobile Network Suite** alongside [DotSignal](file:///home/ros/dotsignal) (Cellular & 5G Baseband Telemetry) and [DotLan](file:///home/ros/dotlan) (Local Subnet & IoT Radar).

---

## Executive Overview

**DotBand** is a professional-grade, ad-free Wi-Fi spectrum analyzer engineered specifically for the next generation of wireless networks: **Wi-Fi 6E (6 GHz)** and **Wi-Fi 7 (802.11be Multi-Link Operation)**.

While legacy Wi-Fi analyzer applications remain stagnant in 2020—failing to display 6 GHz channels or gating basic features behind predatory subscription paywalls—**DotBand** delivers an unobstructed, zero-cost, enterprise-grade spectrum instrument for network engineers, site surveyors, and tech enthusiasts.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                            DOTBAND SPECTRAL CHASSIS                              │
├───────────────────────┬──────────────────────────┬───────────────────────────────┤
│ 2.4 GHz Spectrum      │ 5.0 GHz Spectrum         │ 6.0 GHz Spectrum (Wi-Fi 6E/7) │
│ Channels 1–14         │ Channels 36–165          │ Channels 1–233 (5925–7125MHz) │
│ 20 MHz Channels       │ 20/40/80/160 MHz Widths  │ Up to 320 MHz Ultra-Wide      │
│ Legacy Coexistence    │ Dynamic Frequency (DFS)  │ Multi-Link Operation (MLO)    │
└───────────────────────┴──────────────────────────┴───────────────────────────────┘
```

---

## Key Capabilities

1. **Simultaneous Tri-Band Visualizer**: Renders 2.4 GHz, 5 GHz, and 6 GHz spectrum congestion parabolas simultaneously in real time.
2. **Wi-Fi 7 Multi-Link Operation (MLO) Inspector**: Uncovers bonded multi-link affiliations (`getAffiliatedMloLinks()`), aggregate bandwidth, and link steering.
3. **WPA3-SAE vs. WPA2 Security Classifier**: Instantly flags security downgrades and verifies mandatory WPA3-SAE configurations on 6 GHz access points.
4. **Channel Interference Score Engine**: Calculates co-channel and adjacent-channel interference (CCI/ACI) with automated optimal channel recommendations.
5. **Obsidian Luxury CAD Dark Theme**: Ad-free, tracker-free UI consistent with the Jazdot design system.
6. **OCSF v1.3.0 & PCAP Export**: Seamlessly exports telemetry frames to enterprise SIEM platforms (`dotsec`) and cloud analytics (`dotops`).

---

## Jazdot Organization Visibility & Brand Parity

To maximize visibility for **Jazdot Enterprises**, DotBand shares a unified design language and architectural integration with **DotSignal**:

* **Signature Animated Logo**: Features the pulsing Jazdot Gold Dot anchored against tri-band radiation wave arcs (`DotBandAnimatedLogo`).
* **Corporate Header**: Consistent "DOT" + "BAND" gold typography and Jazdot crest.
* **"More by Jazdot Enterprises" Drawer**: One-tap cross-navigation between DotSignal, DotBand, and DotLan.
* **Jazdot Enterprise Proof Seals**: Exported PDF site survey audits carry cryptographic provenance seals (`VERIFIED_WIFI7_MLO_PROVENANCE`).
* **Direct Bridge to Enterprise Solutions**: Direct in-app pathways to Jazdot's commercial private wireless products: **DotNetwork** and **dotedge** (Private 5G vs. Wi-Fi 6E Industrial Coexistence).

---

## Directory Structure

```
/home/ros/dotband/
├── assets/
│   └── logos/
│       ├── dotband.svg             # Vector brand squircle with tri-band arcs & gold dot
│       └── dotband_wordmark.svg    # Horizontal wordmark for headers & reports
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   └── obsidian_theme.dart # Shared 8pt grid, OLED black palette & luxury tokens
│   │   └── widgets/
│   │       └── dot_band_animated_logo.dart # Flutter CustomPainter animated logo
│   └── main.dart                   # Application entry point & tab navigation
├── scripts/
│   └── build_apk.sh                # Automated Android release build engine
├── tests/                          # Automated unit & conformance test suite
├── pubspec.yaml                    # Flutter project configuration
├── README.md                       # Repository overview & quick start
└── REQUIREMENTS_AND_PLAN.md        # Comprehensive technical requirements & roadmap
```

---

## Detailed Specifications

For complete functional specifications, Android API bindings, Google Play launch strategy, and the phase-by-phase development roadmap, see:

👉 **[REQUIREMENTS_AND_PLAN.md](file:///home/ros/dotband/REQUIREMENTS_AND_PLAN.md)**
