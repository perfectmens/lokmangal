# Lokmangal — Industrial Telemetry & In-App Remote Update Platform

A production-grade Flutter application built for the **Lokmangal Sugar & Ethanol Agro-Industrial Complex** implementing:
1. **CI/CD Remote Update Engine (`/android-ci-cd`)**: Fully automated OTA update delivery directly from GitHub Releases with SHA-256 integrity verification, release signing fingerprint checks, and runtime `PackageInfo` versioning to permanently eliminate Flutter's infinite update loop bug.
2. **Dual-Tone Neumorphic UI (`/dual-tone-neumorphic-ui`)**: 90% neutral off-white foundation (`#F6F6F7`, `#FFFFFF`), 5% Orange Intent (`#F68420`) for user actions/controls, and 3% Teal State (`#11CFC9`) for live system status and verified indicators.
3. **API Governance (`/api-governance`)**: `api-mapping.yaml` serves as the authoritative single source of truth for all network endpoints, payloads, and consumer bindings, accompanied by automated validator `scripts/validate-api-mapping.py`.
4. **Vertical Slice Development (`/vertical-slice-development`)**: End-to-end decoupled functional slices handling the full 6-state matrix (Success, Loading, Empty, Error, Disabled, Edge).
5. **Mobile MVVM Architecture (`/mobile-mvvm-architecture`)**: Unidirectional dependency flow (`View` -> `ViewModel` -> `Repository` -> `API Client` -> `Backend`).

---

## 🏛️ Application Architecture

### 1. Home Screen & Modular Page Registry
The Home Screen displays **2 active pages** in a synchronized `PageView` and **Floating Neumorphic Dock**:
- **Page 0 (`menu1`)**: Milling & Boiler Process Telemetry (Live boiler pressure dial, steam temperature dial, milling efficiency, cane crushing tonnage, and fuel-grade distillation rates).
- **Page 1 (`menu2`)**: Cogeneration & Energy Analytics (Power generation in MW, grid export sync, turbine RPM dial, carbon offset credits, and hourly load profile).

#### Developer Provision for Extra Pages
To allow future expansion without cluttering the active user interface:
- Extra modules (`menu3: Quality Assurance`, `menu4: Machine Diagnostics`, `menu5: Logistics & Dispatch`) are pre-configured in `HomeScreenPageRegistry` with `isVisibleInUi = false`.
- Developers can register new modules dynamically via `HomeScreenPageRegistry.registerModule(...)` or toggle visibility with `setModuleVisibility(id, true)`.

### 2. In-App Remote Update Engine
Located under **Side Drawer -> Settings & Updates**:
- **Dynamic Version Resolution**: Reads actual installed `versionCode` and `versionName` directly from Android's PackageManager via `package_info_plus`, preventing compile-time version drift and infinite loops.
- **Auto-Scan Toggle**: Automatically queries the latest GitHub release on app startup.
- **GitHub Direct Download**: Downloads the release APK asset directly with real-time streaming progress percentage and downloaded bytes.
- **Private Repository Support**: Optional input for GitHub Personal Access Token (PAT) with bearer authentication for private repos.
- **Cryptographic SHA-256 Checksum Verification**: Computes streaming SHA-256 digest and validates against the release manifest `version.json`.
- **Certificate Fingerprint Enforcement**: Validates APK certificate signature against the expected production keystore fingerprint:
  `A6:4B:6D:FB:3C:5B:7F:A5:A0:A3:36:3F:AC:69:21:1D:4D:C0:C5:26:93:17:7E:64:29:0A:AB:E4:A0:F7:CB:59`.
- **Native Installation Trigger**: Launches Android package installer via FileProvider.

---

## 🚀 CI / CD Pipeline (GitHub Actions)

### Continuous Integration (`.github/workflows/ci.yml`)
Triggers on Pull Requests and merges to `main`:
- JDK 17 & Flutter stable toolchain setup
- API Governance validation: `python scripts/validate-api-mapping.py`
- Lints: `flutter analyze`
- Tests: `flutter test`
- Build verification: `flutter build apk --debug`

### Continuous Delivery Release (`.github/workflows/release.yml`)
Triggers on Git tag push (`v*.*.*`) or manual workflow dispatch:
- Strict SemVer enforcement (3 segments: e.g., `0.0.1+1`)
- Production keystore decoding from `KEYSTORE_BASE64` secret
- Build signed production APK: `flutter build apk --release`
- Computes SHA-256 checksum and generates standardized `version.json`
- Signature verification with `apksigner`
- Automated publishing to GitHub Releases using `softprops/action-gh-release@v2`.

---

## 🎨 Dual-Tone Neumorphic Color Roles

| Role | Color | Hex | Semantic Meaning |
| :--- | :--- | :--- | :--- |
| **Canvas** | Soft Gray | `#F6F6F7` | Neutral 90% app canvas and page background |
| **Surface** | Crisp White | `#FFFFFF` | Tactile raised cards, dials, and floating pill docks |
| **Text Primary** | Deep Navy | `#0A0D2F` | Headings, critical metrics, high-emphasis text |
| **Text Secondary**| Steel Navy | `#223B57` | Subtitles, labels, secondary body copy |
| **Text Muted** | Slate Gray | `#8C929C` | Captions, neutral icons, disabled states |
| **Intent Accent** | Warm Orange | `#F68420` | User actions, Update button, Install CTA, attention |
| **State Accent** | Vibrant Teal | `#11CFC9` | Healthy status, Grid Synced, Verified SHA-256, active tabs |