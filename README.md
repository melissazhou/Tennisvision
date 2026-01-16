# TennisVision (iOS, Offline MVP)

TennisVision is an offline iOS MVP that records tennis sessions and automatically trims non-play segments, then lets users review and export a condensed video.

## What’s Included
- **SwiftUI app skeleton** with recording, analysis progress, timeline editing, and export flows.
- **Offline MVP detection** using frame-difference activity scoring.
- **Segment editing** (keep/delete toggle + start/end trim window).
- **Composition/export pipeline** (AVMutableComposition + export presets).
- **Local project storage** (basic JSON metadata + file management).

## Project Structure
```
TennisVision/
  Models/           Data models (ClipSegment, AnalysisResult, Project)
  Domain/           Session manager + store
  Media/            AVFoundation recording/reading/composition
  Inference/        Activity detector + segmenter
  UI/               SwiftUI screens
```

## Build & Run (Xcode)
> This repo contains app source files but not an `.xcodeproj`. To run:

1. **Create a new Xcode project**
   - iOS → App → *TennisVision*
   - Interface: **SwiftUI**
   - Language: **Swift**
2. **Replace the generated `ContentView.swift` and `App` file** with the files in `TennisVision/UI` and `TennisVision/TennisVisionApp.swift`.
3. **Add all files under `TennisVision/`** to the Xcode project (drag and drop, *Copy items if needed*).
4. **Add permissions** to your app target (Info → Custom iOS Target Properties):
   - `NSCameraUsageDescription`
   - `NSMicrophoneUsageDescription`
   - `NSPhotoLibraryAddUsageDescription`
5. **Build & run** on an iPhone (real device required for camera recording).

## Deployment (Ad Hoc / TestFlight)
1. Update the **Bundle Identifier** and **Signing Team** in Xcode.
2. Archive: **Product → Archive**.
3. Distribute:
   - **Ad Hoc**: export an .ipa for device distribution.
   - **TestFlight**: upload through Organizer → Distribute App → App Store Connect.
4. On the device, grant camera/microphone permissions when prompted.

## Debugging & Performance Tips
- **Slow analysis**: reduce `frameSampleRate` or `analysisSize` in `Config`.
- **False positives**: increase `activityThreshold` or `minKeepDuration`.
- **Missed rallies**: decrease `activityThreshold`, increase `padStart/padEnd`.
- **Export failures**: check free disk space and output preset. The exporter returns descriptive errors.
- **Profiling**: use Instruments → Time Profiler + Allocations to watch frame decoding and memory.

## Configuration (MVP Defaults)
Defaults live in `Config.defaultTraining` and `Config.defaultMatch`.
- `frameSampleRate`: 3 fps
- `activityThreshold`: 0.18 (heuristic)
- `minKeepDuration`: 4s
- `mergeGap`: 2s
- `padStart/padEnd`: 1s

## Notes
- This MVP prioritizes **offline processing** and **manual correction** over perfect accuracy.
- Audio peak detection and human detection are stubbed for future expansion.
