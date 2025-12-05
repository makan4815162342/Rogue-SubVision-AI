# Rogue-SubVision-AI
 A Flutter-based streaming browser with subtitle injection, DOM-based video synchronization, and Gemini AI translation.

 <img width="682" height="685" alt="app_icon 2" src="https://github.com/user-attachments/assets/402e6aab-2dbe-4ba1-a22a-3046b4f925aa" />

## 👁️ Rogue SubVision AI

Rogue SubVision AI is a cross-platform application (Windows & Android) built with **Flutter**. It functions as a specialized web browser that wraps `flutter_inappwebview` to inject custom subtitle overlays onto third-party streaming websites.

It solves the problem of missing or unsynchronized subtitles on the web by handling the rendering layer natively in Flutter while controlling the web content via JavaScript injection.

*   **Link to Download Both Windows and Android TV Versions:**
*   **itch.IO:** https://makan-ansari.itch.io/rogue-subvision-ai

### 🚀 Features & Architecture

*   **Split-View & Overlay UI:**
    *   Uses a customizable split-pane layout (Web content vs. Subtitle Controller).
    *   **Overlay Mode:** Renders subtitles in a `Stack` on top of the WebView, utilizing a custom CSS injection to force video elements into a "Fake Fullscreen" mode that stays beneath the Flutter UI layer.

*   **Omni-Spy Engine (JavaScript Bridge):**
    *   Injected JavaScript recursively drills through the DOM (and Shadow DOMs) to locate HTML5 `<video>` tags.
    *   Establishes a 100ms polling bridge to sync the Flutter subtitle state with the WebView video timestamp (`currentTime`, `paused`, `duration`).

*   **AI-Powered Translation:**
    *   Integrates **Google Generative AI (Gemini)**.
    *   Batches subtitle lines and sends them to the LLM for context-aware translation (e.g., translating English SRT to Persian on the fly).

*   **Android TV Support:**
    *   Implements a **Virtual Cursor** system, allowing D-Pad remotes to simulate mouse movements and clicks on non-TV-optimized websites.
    *   Custom file explorer logic to handle Android 11+ Scoped Storage and USB Drive access.

### 🛠️ Tech Stack
*   **Framework:** Flutter (Dart)
*   **Web Engine:** `flutter_inappwebview`
*   **Video Playback:** `video_player` & `chewie` (for Cinema Mode)
*   **AI:** `google_generative_ai` SDK
*   **State Management:** `setState` (optimized for low-latency sync)

### 🔧 Installation
1.  Clone the repository.
2.  Ensure you have the Flutter SDK installed.
3.  **Windows:** Visual Studio C++ workload required.
4.  **Android:** Android SDK 34+.

```bash
flutter pub get
flutter run -d windows
# or
flutter run -d android
```

### ⚠️ Known Limitations
*   **DRM Content:** Some DRM-protected streams (Widevine) may block screen scraping, though the subtitle overlay usually works as it renders independently.
*   **Complex DOMs:** Sites with heavily obfuscated video players (custom Canvas players) may not be detected by the Omni-Spy script.
*   **Mouse Required:** For the best experience with Android TV, a Mouse is needed.

---

### **Some Screenshots:**

<img width="2560" height="1080" alt="Desktop Screenshot 2025 12 05 - 21 56 25 95" src="https://github.com/user-attachments/assets/59c05ce2-5132-40a1-a845-b888600fb0bd" />

<img width="2560" height="1080" alt="Desktop Screenshot 2025 12 03 - 08 44 31 24" src="https://github.com/user-attachments/assets/30381684-776d-4ee2-a674-e882c74fd444" />

<img width="706" height="582" alt="Rogue_1" src="https://github.com/user-attachments/assets/80715dc8-4963-4a65-a3c4-8ee4dabd4f4e" />

<img width="562" height="521" alt="Rogue_2" src="https://github.com/user-attachments/assets/7e4477c6-5aa4-414c-9ac3-3890c1e8f3a4" />

<img width="2537" height="526" alt="Rogue_3" src="https://github.com/user-attachments/assets/e815ab83-7ab5-49e2-a589-1193c532b481" />


---
