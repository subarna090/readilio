# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Readilio** is an offline-first Android app (Flutter) that lets parents photograph physical storybook pages and converts them into interactive read-aloud experiences with word-by-word TTS highlighting. No internet required, no accounts, no data leaves the device.

Primary spec: `Readilio_Spec_v1.0.docx`

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.x (Dart) |
| OCR | Google ML Kit Text Recognition v2 (on-device) |
| TTS | flutter_tts (offline) |
| Audio Export | flutter_tts + ffmpeg_kit_flutter → M4A/AAC 64kbps |
| Local Storage | Hive (NoSQL) + shared_preferences |
| Camera | camera plugin + image_picker |
| Image Processing | image package + flutter_image_compress |
| Animations | Rive (mascot) or Lottie |
| Analytics | Firebase Analytics (anonymous, COPPA-compliant) |
| Crash Reporting | Firebase Crashlytics |

## Flutter Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build release APK
flutter build apk --release

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Analyze code
flutter analyze

# Format code
dart format lib/
```

## Architecture

### Core Processing Pipeline

```
Camera Capture → Image Pre-processing → ML Kit OCR → Text Post-processing → TTS Playback
```

1. **Capture** — JPEG at min 2048×1536px; camera coach detects blur/glare/darkness in real time
2. **Pre-processing** — Resize to max 1600px, grayscale, adaptive threshold, crop to text region
3. **OCR** — ML Kit processes per-page; returns text blocks with bounding boxes + confidence scores
4. **Post-processing** — Confidence filtering, punctuation repair, paragraph reconstruction, hyphenation handling
5. **TTS** — Cleaned text fed to flutter_tts in sentence chunks; word highlighting synchronized to playback

Background batch processing runs while user continues capturing subsequent pages.

### Key Design Principles

- **Offline-first**: All OCR and TTS run on-device via ML Kit and flutter_tts. No API calls.
- **Review before playback**: Users see extracted text per page and can inline-edit before audio starts — this is the critical UX gate.
- **Tier limits**: Free = 10 pages/story; Premium = 20 pages/story. Oldest free-tier audio auto-deletes when storage quota is exceeded.

### Screens / User Flows

1. **Onboarding** — 3 skippable animated screens
2. **Home** — Mascot "Pip" (Rive owl), "Start New Story" CTA, recent stories strip
3. **Capture** — Full-screen camera, page counter, real-time guidance overlays
4. **Processing** — Animated character with progress; pages process in background
5. **Review & Edit** — Per-page text display with inline editing
6. **Playback** — Word-by-word highlighting, speed control (0.5×–1.5×), sentence navigation
7. **Library** — Saved stories with thumbnails, duration, file size, last-read timestamps
8. **Settings** — Voice, language, accessibility toggles (dyslexia font, high contrast, large text)

### Mascot ("Pip" the Owl)

Pip appears in 5 states driven by Rive animations: idle bounce (home), peeking (capture), reading (processing), mouth-sync (playback), celebrating (story end). All animations respect the system "Reduce Motion" accessibility setting.

## Accessibility Requirements

- TalkBack semantic labels on all interactive elements
- Minimum touch target: 48×48dp
- Color contrast: 4.5:1 (body text), 3:1 (large text)
- Font scaling capped at 1.5× on playback screen
- Full RTL layout mirroring
- OpenDyslexic font toggle
- High contrast mode (increased borders, no gradients)

## Testing Strategy

Unit tests cover OCR post-processing (11 cases) and TTS controller (6 cases). Integration tests cover happy path, single-page story, re-scan, text editing, capture guidance, and 50+ documented edge cases including: ML Kit not downloaded, OCR timeout, headphones disconnected mid-playback, app killed during processing, storage full, device rotation mid-flow.

## MVP Success Targets

- Crash-free rate ≥ 98.5%
- OCR word accuracy ≥ 92% on clear printed text
- Time from first photo to playback < 8 seconds
- Play Store rating ≥ 4.2 stars (30 days post-launch)
