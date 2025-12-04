# Rogue-SubVision-AI
 A Flutter-based streaming browser with subtitle injection, DOM-based video synchronization, and Gemini AI translation.

👁️ Rogue SubVision AI
Rogue SubVision AI is a cross-platform application (Windows & Android) built with Flutter. It functions as a specialized web browser that wraps flutter_inappwebview to inject custom subtitle overlays onto third-party streaming websites.
It solves the problem of missing or unsynchronized subtitles on the web by handling the rendering layer natively in Flutter while controlling the web content via JavaScript injection.
🚀 Features & Architecture
Split-View & Overlay UI:
Uses a customizable split-pane layout (Web content vs. Subtitle Controller).
Overlay Mode: Renders subtitles in a Stack on top of the WebView, utilizing a custom CSS injection to force video elements into a "Fake Fullscreen" mode that stays beneath the Flutter UI layer.
Omni-Spy Engine (JavaScript Bridge):
Injected JavaScript recursively drills through the DOM (and Shadow DOMs) to locate HTML5 <video> tags.
Establishes a 100ms polling bridge to sync the Flutter subtitle state with the WebView video timestamp (currentTime, paused, duration).
AI-Powered Translation:
Integrates Google Generative AI (Gemini).
Batches subtitle lines and sends them to the LLM for context-aware translation (e.g., translating English SRT to Persian on the fly).
Android TV Support:
Implements a Virtual Cursor system, allowing D-Pad remotes to simulate mouse movements and clicks on non-TV-optimized websites.
Custom file explorer logic to handle Android 11+ Scoped Storage and USB Drive access.
🛠️ Tech Stack
Framework: Flutter (Dart)
Web Engine: flutter_inappwebview
Video Playback: video_player & chewie (for Cinema Mode)
AI: google_generative_ai SDK
State Management: setState (optimized for low-latency sync)
🔧 Installation
Clone the repository.
Ensure you have the Flutter SDK installed.
Windows: Visual Studio C++ workload required.
Android: Android SDK 34+.
code
Bash
flutter pub get
flutter run -d windows
# or
flutter run -d android
⚠️ Known Limitations
DRM Content: Some DRM-protected streams (Widevine) may block screen scraping, though the subtitle overlay usually works as it renders independently.
Complex DOMs: Sites with heavily obfuscated video players (custom Canvas players) may not be detected by the Omni-Spy script.
