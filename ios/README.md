# JJY Simulator for iPhone & iPad

Native SwiftUI + `AVAudioEngine` iOS/iPadOS app with full feature parity to the web simulator, plus an **offline bundled Natural Earth world map** (works in airplane mode / abroad with zero network access).

## Features
- **Exact JJY time-code synthesis (`AVAudioEngine` + `AVAudioSourceNode`)**: sample-accurate 13.333 kHz (40 kHz 3rd harmonic) and 20 kHz (60 kHz 3rd harmonic) phase-coherent sine wave keyed to NICT JJY pulse widths (`0` = 0.8 s, `1` = 0.5 s, `M` = 0.2 s), aligned to wall-clock UTC seconds with `AVAudioSession.outputLatency` compensation.
- **Ignores hardware mute switch**: uses `AVAudioSession.Category.playback`, stops safely on phone-call interruptions or headphone unplugging, and keeps the screen awake while transmitting (`UIApplication.shared.isIdleTimerDisabled`).
- **Offline World Map**: Natural Earth 110m equirectangular land geometry bundled in `WorldLand.json`, UTC 15° band, longitude grid, 62 curated cities, tap-to-select nearest city, and smooth horizontal auto-centering.
- **Universal iPhone & iPad UI**: single-column layout on iPhone, full-width world map + two-column adaptive layout on iPad, full Light & Dark mode support, searchable time zone picker (Major cities + all IANA time zones).
- **Localized**: Korean (`ko`), English (`en`), and Japanese (`ja`) following iOS system / per-app language settings.

## Build & Run (Xcode)
1. Open `ios/JJYSimulator.xcodeproj` in **Xcode 15 or later** (deployment target: **iOS 16.0+**).
2. Select the `JJYSimulator` target → **Signing & Capabilities** → choose your **Team** (and adjust the Bundle Identifier if needed).
3. Select an iPhone or iPad (or Simulator) and press **⌘R** to build and run.
4. Press **⌘U** to run unit tests (`JJYSimulatorTests`), covering JJY time-code frames, midnight/DST/leap-year edge cases, bit-packed minute frames, nearest-city lookup, UTC offset formatting, and offline map decoding.

## Release & App Store Distribution
- **Privacy Manifest**: `JJYSimulator/Resources/PrivacyInfo.xcprivacy` (zero tracking, zero data collection).
- **Privacy Policy Page**: `../privacy.html` (served via GitHub Pages at `https://mj-best.github.io/JJY-simulator/privacy.html`).
- **App Store Metadata (`ko`, `en-US`, `ja`)**: `AppStore/APP_STORE_METADATA.md` and `AppStore/metadata/`.
- **App Store Screenshots**: `AppStore/screenshots/{ko,en-US,ja}/` (`1320×2868` iPhone 6.9" and `2752×2064` iPad 13", opaque RGB PNG).
- **Release Checklist & Archive Script**: See `AppStore/RELEASE_CHECKLIST.md` and `scripts/archive.sh`.

> Note: `ios/project.yml` is also included if you prefer regenerating the Xcode project via [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`xcodegen generate`).
