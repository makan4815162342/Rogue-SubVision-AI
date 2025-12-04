import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// ============================================================================
// --- TRANSLATION & CONSTANTS ---
// ============================================================================

const Map<String, Map<String, String>> lang = {
  'en': {
    'find': 'Find Subtitles',
    'import': 'Import File',
    'saved': 'Bookmarks',
    'translate_menu': 'Translation',
    'use_web': 'Use Web Website',
    'use_ai': 'Use Gemini AI',
    'screen': 'Full Screen',
    'lang': 'Language',
    'adblock': 'Ad Blocker',
    'sync': 'Sync',
    'refresh': 'Reload',
    'delete': 'Memory/Cache',
    'ready': '', // Default empty to hide text
    'loaded': 'Subtitle Loaded:',
    'lines': 'lines',
    'tool_title': 'Subtitle Tools',
    'downloading': 'Downloading...',
    'search_for': 'Search Query:',
    'search_hint': 'Type movie/episode name...',
    'menu_title': 'Cleanup Options',
    'opt_unload': 'Unload Subtitle',
    'opt_cache': 'Purge Memory & Cache',
    'opt_all': 'Factory Reset App',
    'msg_unloaded': 'Subtitle unloaded.',
    'msg_cache_cleared': 'Memory purged successfully.',
    'txt_size': 'Text',
    'zoom': 'Zoom',
    'panel_adj': 'Panel',
    'manual_mode': 'Manual Mode',
    'auto_mode': 'Auto Sync (Omni-Spy)',
    'cinema_mode': 'Cinema Mode',
    'grab_video': 'Grab Video',
    'jump': 'Jump Time',
    'about': 'Settings & AI',
    'visit_github': 'Visit GitHub',
    'sync_on': 'Sync Active',
    'sync_off': 'Sync Paused',
    'ai_processing': 'Translating with Gemini... (Batching)',
    'ai_done': 'Translation Complete!',
    'api_key_hint': 'Paste Gemini API Key Here',
    'get_api_key': 'Get Free API Key',
    'save': 'Save',
    'guide': 'App Guide (Read Me)',
    'add_bookmark': 'Add Bookmark',
    'overlay_mode': 'Overlay Subtitles',
    'tag_button': 'Link Play Button',
    'home': 'Home Page',
    'set_home': 'Set Home URL',
    'back_settings': 'Back to Settings',
    'close': 'Close',
    'source_google': 'Google',
    'source_subcat': 'SubtitleCat',
    'source_opensub_com': 'OpenSub.com',
    'source_opensub_org': 'OpenSub.org',
    'source_subdl': 'SubDL',
  },
  'fa': {
    'find': 'جستجوی زیرنویس',
    'import': 'وارد کردن فایل',
    'saved': 'نشان‌کذاری‌ها',
    'translate_menu': 'ترجمه',
    'use_web': 'استفاده از وب‌سایت',
    'use_ai': 'استفاده از هوش مصنوعی',
    'screen': 'تمام صفحه',
    'lang': 'زبان / Lang',
    'adblock': 'حذف تبلیغات',
    'sync': 'هماهنگی',
    'refresh': 'بازنشانی',
    'delete': 'حافظه',
    'ready': '', // Empty default
    'loaded': 'زیرنویس بارگذاری شد:',
    'lines': 'خط',
    'tool_title': 'ابزار زیرنویس',
    'downloading': 'در حال دانلود...',
    'search_for': 'عبارت جستجو:',
    'search_hint': 'نام فیلم یا قسمت را اینجا بنویسید...',
    'menu_title': 'گزینه‌های پاکسازی',
    'opt_unload': 'فقط بستن زیرنویس',
    'opt_cache': 'پاکسازی رم و حافظه',
    'opt_all': 'بازنشانی کارخانه',
    'msg_unloaded': 'زیرنویس بسته شد.',
    'msg_cache_cleared': 'حافظه آزاد شد.',
    'txt_size': 'متن',
    'zoom': 'زوم',
    'panel_adj': 'پنل',
    'manual_mode': 'حالت دستی',
    'auto_mode': 'حالت خودکار',
    'cinema_mode': 'حالت سینما',
    'grab_video': 'دریافت ویدیو',
    'jump': 'پرش زمانی',
    'about': 'تنظیمات',
    'visit_github': 'مشاهده گیت‌هاب',
    'sync_on': 'هماهنگی فعال',
    'sync_off': 'هماهنگی متوقف',
    'ai_processing': 'در حال ترجمه با هوش مصنوعی...',
    'ai_done': 'ترجمه کامل شد!',
    'api_key_hint': 'کد API جمینای را اینجا وارد کنید',
    'get_api_key': 'دریافت کد رایگان',
    'save': 'ذخیره',
    'guide': 'راهنمای برنامه',
    'add_bookmark': 'افزودن نشان',
    'overlay_mode': 'زیرنویس شناور',
    'tag_button': 'اتصال دکمه پخش',
    'home': 'خانه',
    'set_home': 'تنظیم آدرس خانه',
    'back_settings': 'بازگشت به تنظیمات',
    'close': 'بستن',
    'source_google': 'گوگل',
    'source_subcat': 'SubtitleCat',
    'source_opensub_com': 'OpenSub.com',
    'source_opensub_org': 'OpenSub.org',
    'source_subdl': 'SubDL',
  },
};

class SubtitleLine {
  final double start;
  final double end;
  String text;
  SubtitleLine({required this.start, required this.end, required this.text});
}

// ============================================================================
// --- MAIN ENTRY POINT ---
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const WindowOptions windowOptions = WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: "Rogue SubVision AI",
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          // FIX: No Global Dialog/Card Themes to prevent Build Errors.
          // Using ColorScheme surfaceTint to fix Gray Box issue.
          colorScheme: const ColorScheme.dark(
            primary: Colors.teal,
            secondary: Colors.cyanAccent,
            surface: Color(0xFF222222),
            surfaceTint: Colors.transparent, // Key for fixing gray wash on M3
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.tealAccent,
              padding: const EdgeInsets.all(15),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.black54,
            filled: true,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.tealAccent)),
          )),
      home: const MediaWorkstation(),
    ),
  );
}

class MediaWorkstation extends StatefulWidget {
  const MediaWorkstation({super.key});
  @override
  State<MediaWorkstation> createState() => _MediaWorkstationState();
}

class _MediaWorkstationState extends State<MediaWorkstation> {
  // --- SETTINGS ---
  bool isPersian = false;
  bool isAdBlockerEnabled = true;
  bool isFullScreen = false;
  String geminiApiKey = "";
  String homePageUrl = "https://duckduckgo.com";
  bool isOverlayMode = false;

  // --- STATE ---
  String currentSubtitle = "";
  List<SubtitleLine> subtitles = [];
  double subtitleFontSize = 26.0;
  double webZoomLevel = 1.0;
  Color subtitleColor = const Color(0xFFFFD700);
  bool hasSubtitleBackground = true;
  List<String> actionLogs = [];

  // --- PLAYER & SYNC STATE ---
  bool isManualMode = false;
  bool isSyncActive = true;
  bool isPlaying = false;
  double currentManualTime = 0.0;
  double maxSubtitleDuration = 1.0;
  double syncDelay = 0.0;

  // --- CINEMA MODE ---
  bool isCinemaMode = false;
  String? sniffedVideoUrl;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  Timer? _manualPlayTimer;
  Timer? _spyTimer;

  // --- BROWSERS & CONTROLLERS ---
  InAppWebViewController? mainWebController;
  InAppWebViewController? toolWebController;
  TextEditingController urlController = TextEditingController(
    text: "https://duckduckgo.com",
  );
  ScrollController logScrollController = ScrollController();

  // --- BOOKMARKS ---
  List<Map<String, String>> bookmarks = [];
  bool showBookmarksPanel = false;
  bool isToolPanelOpen = false;
  String currentToolUrl = "";
  double _splitRatio = 0.75;

  String t(String key) => isPersian ? lang['fa']![key]! : lang['en']![key]!;

  static const String stealthUserAgent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36";

  // ==========================================================================
  // --- INJECTABLE SCRIPTS ---
  // ==========================================================================

  // 1. DARK MODE + FAKE FULLSCREEN (Forces video to fill container)
  final UserScript _fakeFullscreenScript = UserScript(
    source: """
      var _originalStyles = new Map();
      document.addEventListener('fullscreenchange', function(e) {
          if(document.fullscreenElement) {
             var v = document.querySelector('video');
             if(v) {
               _originalStyles.set(v, v.getAttribute('style'));
               v.style.position = 'fixed'; 
               v.style.top = '0'; 
               v.style.left = '0';
               v.style.width = '100vw'; 
               v.style.height = '100vh'; 
               v.style.zIndex = '9998'; 
               v.style.background = '#000';
             }
             var header = document.getElementById('masthead-container');
             if(header) { header.style.display = 'none'; }
          } else {
             var v = document.querySelector('video');
             if(v && _originalStyles.has(v)) {
                v.setAttribute('style', _originalStyles.get(v));
             } else if(v) {
                 v.style.position = ''; v.style.width = ''; v.style.height = ''; v.style.zIndex = ''; 
             }
             var header = document.getElementById('masthead-container');
             if(header) { header.style.display = 'block'; }
          }
      });
    """,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    forMainFrameOnly: false,
  );

  final UserScript _darkModeScript = UserScript(
    source: """
      (function() {
        var style = document.createElement('style');
        style.innerHTML = `
          html, body, #page-manager, #columns, ytd-watch-flexy { 
             background-color: #000000 !important; 
             color: #e0e0e0 !important; 
          }
        `;
        document.head.appendChild(style);
      })();
    """,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    forMainFrameOnly: true,
  );

  // --- 2. IMPROVED OMNI SPY (Deep Shadow DOM Drilling) ---
  final UserScript _omniSpyScript = UserScript(
    source: """
          // Recursive function to pierce through Shadow DOMs to find the active video
          function findVideoDeep(root) {
              if (!root) return null;
              
              // 1. Check this root level
              var v = root.querySelector('video');
              if (v && !v.ended) return v;

              // 2. Loop through all children to check for Shadow Roots
              // (Standard loop for Desktop Site compatibility)
              var allElements = root.querySelectorAll('*');
              for (var i = 0; i < allElements.length; i++) {
                  var el = allElements[i];
                  if (el.shadowRoot) {
                      var found = findVideoDeep(el.shadowRoot);
                      if (found) return found;
                  }
              }
              return null;
          }

          setInterval(function() {
            try {
              // Start looking from the very top (document)
              var v = findVideoDeep(document);
              
              if (v && !v.paused && window.flutter_inappwebview) {
                // Args: (Time, isPaused?, Duration)
                window.flutter_inappwebview.callHandler('rogueTick', v.currentTime, false, v.duration);
              } else if (v && v.paused && window.flutter_inappwebview) {
                // Explicitly send paused state to handle stops better on Windows
                window.flutter_inappwebview.callHandler('rogueTick', v.currentTime, true, v.duration);
              }
            } catch(e) {}
          }, 100); // High speed poll (100ms)
        """,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    forMainFrameOnly: false,
  );

  final UserScript _videoSnifferScript = UserScript(
    source: """
        setInterval(function() {
          try {
            var v = document.querySelector('video');
            if (v) {
              var url = v.currentSrc || v.src;
              if (url && url.startsWith('http')) {
                  window.flutter_inappwebview.callHandler('rogueSniffed', url);
              }
            }
          } catch(e) {}
        }, 2000);
      """,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
    forMainFrameOnly: false,
  );

  // 3. TV REMOTE D-PAD HELPER (Key mapping)
  final UserScript _keyboardListenerScript = UserScript(
    source: """
      window.addEventListener('keydown', function(e) {
          if ((e.code === 'Space' || e.keyCode === 32 || e.keyCode === 13) && !['INPUT','TEXTAREA'].includes(e.target.tagName)) {
              if (document.activeElement !== document.body) {
                 return; // Let native click happen
              }
              if(window.flutter_inappwebview) {
                  window.flutter_inappwebview.callHandler('rogueKeyTrigger', 'space');
              }
          }
      }, true);
    """,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    forMainFrameOnly: false,
  );

  @override
  void initState() {
    super.initState();
    _log("Initializing Rogue SubVision AI...");
    // Default empty to hide distractions
    currentSubtitle = "";
    _loadSettings();
    _startSpyEngine();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _spyTimer?.cancel();
    _manualPlayTimer?.cancel();
    _disposeCinemaMode();
    WakelockPlus.disable();
    logScrollController.dispose();
    super.dispose();
  }

  void _log(String message) {
    if (!mounted) return;
    setState(() {
      actionLogs
          .add("${DateTime.now().hour}:${DateTime.now().minute}: $message");
      if (actionLogs.length > 50) actionLogs.removeAt(0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (logScrollController.hasClients) {
        logScrollController.animateTo(
          logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPersian = prefs.getBool('isPersian') ?? false;
      isAdBlockerEnabled = prefs.getBool('adblock') ?? true;
      subtitleFontSize = prefs.getDouble('fontSize') ?? 26.0;
      webZoomLevel = prefs.getDouble('zoom') ?? 1.0;
      geminiApiKey = prefs.getString('geminiKey') ?? "";
      isOverlayMode = prefs.getBool('overlayMode') ?? false;

      List<String> rawBookmarks = prefs.getStringList('bookmarks_v2') ?? [];
      bookmarks = rawBookmarks.map((e) {
        try {
          return Map<String, String>.from(jsonDecode(e));
        } catch (_) {
          return {'title': e, 'url': e};
        }
      }).toList();

      hasSubtitleBackground = prefs.getBool('subBg') ?? true;
      homePageUrl = prefs.getString('homeUrl') ?? "https://duckduckgo.com";
      String? lastUrl = prefs.getString('lastUrl');
      if (lastUrl != null) {
        urlController.text = lastUrl;
      } else {
        urlController.text = homePageUrl;
      }
    });
    _log("Settings loaded.");
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPersian', isPersian);
    await prefs.setBool('adblock', isAdBlockerEnabled);
    await prefs.setDouble('fontSize', subtitleFontSize);
    await prefs.setDouble('zoom', webZoomLevel);
    await prefs.setString('geminiKey', geminiApiKey);
    await prefs.setBool('overlayMode', isOverlayMode);

    List<String> rawBookmarks = bookmarks.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('bookmarks_v2', rawBookmarks);

    await prefs.setBool('subBg', hasSubtitleBackground);
    await prefs.setString('lastUrl', urlController.text);
    await prefs.setString('homeUrl', homePageUrl);
  }

  void _aggressiveMemoryClean() async {
    _log("Executing Aggressive Memory Cleanup...");
    try {
      await InAppWebViewController.clearAllCache();
      if (mainWebController != null) {
        await mainWebController!.clearHistory();
      }
      PaintingBinding.instance.imageCache.clear();
      _log("Memory Purged.");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t('msg_cache_cleared'))));
      }
    } catch (e) {
      _log("Cleanup Error: $e");
    }
  }

  // --- Smart URL Loading ---
  void _loadPage(String input) {
    if (input.isEmpty) return;
    String url = input.trim();
    bool isUrl = url.contains('.') && !url.contains(' ');

    if (isUrl) {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
    } else {
      url = "https://duckduckgo.com/?q=${Uri.encodeComponent(input)}";
    }

    mainWebController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    _log("Loading: $url");
  }

  void _toggleBookmark() {
    String currentUrl = urlController.text;
    if (currentUrl.isEmpty) return;
    int index = bookmarks.indexWhere((b) => b['url'] == currentUrl);

    if (index >= 0) {
      setState(() {
        bookmarks.removeAt(index);
      });
      _saveSettings();
      _log("Bookmark removed: $currentUrl");
    } else {
      TextEditingController nameCtrl = TextEditingController(text: "My Page");
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: const Color(0xFF222222),
          surfaceTintColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(t('add_bookmark'),
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(ctx)),
                ElevatedButton(
                  child: Text(t('save')),
                  onPressed: () {
                    setState(() {
                      bookmarks
                          .add({'title': nameCtrl.text, 'url': currentUrl});
                    });
                    _saveSettings();
                    _log("Bookmark added: ${nameCtrl.text}");
                    Navigator.pop(ctx);
                  },
                )
              ])
            ]),
          ),
        ),
      );
    }
  }

  bool _isBookmarked(String url) {
    return bookmarks.any((b) => b['url'] == url);
  }

  Future<void> _initializeCinemaMode(String url) async {
    if (_videoController != null) {
      await _disposeCinemaMode();
    }
    if (!mounted) return;
    _log("Starting Cinema Mode: $url");

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {'User-Agent': stealthUserAgent},
      );
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: true,
      );
      _videoController!.addListener(() {
        if (_videoController == null) return;
        if (isCinemaMode && mounted) {
          setState(() {
            currentManualTime =
                _videoController!.value.position.inSeconds.toDouble();
            maxSubtitleDuration =
                _videoController!.value.duration.inSeconds.toDouble();
            isPlaying = _videoController!.value.isPlaying;
            _updateSubtitleUI();
          });
        }
      });
      if (mounted) {
        setState(() => isCinemaMode = true);
      }
    } catch (e) {
      _log("Cinema Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
      _disposeCinemaMode();
    }
  }

  Future<void> _disposeCinemaMode() async {
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
    if (mounted) {
      setState(() => isCinemaMode = false);
    }
  }

  void _grabVideo() {
    TextEditingController videoUrlCtrl =
        TextEditingController(text: sniffedVideoUrl ?? "");
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF222222),
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Cinema Mode Input",
                style: TextStyle(color: Colors.white)),
            TextField(
              controller: videoUrlCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Video URL"),
            ),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(ctx)),
              ElevatedButton(
                child: const Text("PLAY"),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (videoUrlCtrl.text.isNotEmpty) {
                    _initializeCinemaMode(videoUrlCtrl.text.trim());
                  }
                },
              ),
            ])
          ]),
        ),
      ),
    );
  }

  void _startSpyEngine() {
    _spyTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted && isPlaying && isManualMode) {}
    });
  }

  void _togglePlayButton({bool fromWebView = false}) {
    _log("Toggle Play: Web=$fromWebView");
    if (isCinemaMode && _videoController != null) {
      _videoController!.value.isPlaying
          ? _videoController!.pause()
          : _videoController!.play();
    } else {
      if (isPlaying) {
        _stopManualPlayback();
      } else {
        _startManualPlayback();
      }
      if (!fromWebView) {
        mainWebController?.evaluateJavascript(
            source:
                "var v=document.querySelector('video'); if(v){v.paused?v.play():v.pause();}");
      }
    }
  }

  void _startManualPlayback() {
    if (isManualPlaying()) return;
    if (isManualMode) {
      setState(() => isPlaying = true);
    }
    _manualPlayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isManualMode) {
        setState(() {
          if (currentManualTime < maxSubtitleDuration) {
            currentManualTime += 1.0;
            _updateSubtitleUI();
          } else {
            _stopManualPlayback();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  bool isManualPlaying() =>
      _manualPlayTimer != null && _manualPlayTimer!.isActive;

  void _stopManualPlayback() {
    if (isManualMode) {
      setState(() => isPlaying = false);
    }
    _manualPlayTimer?.cancel();
  }

  void _seekManual(double value) {
    setState(() {
      currentManualTime = value;
      _updateSubtitleUI();
    });
    if (isCinemaMode && _videoController != null) {
      _videoController!.seekTo(Duration(seconds: value.toInt()));
    } else if (!isManualMode && mainWebController != null) {
      mainWebController?.evaluateJavascript(source: """
            var v = document.querySelector('video');
            if (!v && location.hostname.includes('youtube.com')) { v = document.querySelector('.html5-main-video'); }
            if (v) { v.currentTime = $value; }
          """);
    }
  }

  void _seekRelative(double seconds) {
    double newTime = currentManualTime + seconds;
    if (newTime < 0) newTime = 0;
    if (newTime > maxSubtitleDuration) newTime = maxSubtitleDuration;
    _seekManual(newTime);
  }

  void _nudgeSync(double seconds) {
    setState(() {
      syncDelay += seconds;
      _updateSubtitleUI();
    });
  }

  void _updateSubtitleUI() {
    double targetTime = currentManualTime + syncDelay;
    bool found = false;
    for (var line in subtitles) {
      if (targetTime >= line.start && targetTime <= line.end) {
        if (currentSubtitle != line.text) {
          if (mounted) setState(() => currentSubtitle = line.text);
        }
        found = true;
        break;
      }
    }
    if (!found) {
      if (mounted && currentSubtitle.isNotEmpty)
        setState(() => currentSubtitle = "");
    }
  }

  void _zoomIn() {
    setState(() {
      webZoomLevel += 0.05;
      _saveSettings();
      mainWebController?.evaluateJavascript(
          source:
              "if(document.body) document.body.style.zoom = '$webZoomLevel'");
    });
  }

  void _zoomOut() {
    setState(() {
      if (webZoomLevel > 0.3) {
        webZoomLevel -= 0.05;
      }
      _saveSettings();
      mainWebController?.evaluateJavascript(
          source:
              "if(document.body) document.body.style.zoom = '$webZoomLevel'");
    });
  }

  // --- JSON EXPORT/IMPORT LOGIC ---
  String _generateSrtContent(List<SubtitleLine> subs) {
    StringBuffer sb = StringBuffer();
    int counter = 1;
    for (var line in subs) {
      sb.writeln("$counter");
      sb.writeln(
          "${_formatSrtTime(line.start)} --> ${_formatSrtTime(line.end)}");
      sb.writeln(line.text.trim());
      sb.writeln("");
      counter++;
    }
    return sb.toString();
  }

  String _formatSrtTime(double seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = (seconds % 60).toInt();
    int ms = ((seconds - seconds.toInt()) * 1000).toInt();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')},${ms.toString().padLeft(3, '0')}";
  }

  Future<void> _exportSubtitlesToJson() async {
    if (subtitles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No subtitles!")));
      }
      return;
    }
    List<Map<String, dynamic>> jsonList = subtitles.map((line) {
      return {'start': line.start, 'end': line.end, 'text': line.text.trim()};
    }).toList();
    String jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    if (Platform.isAndroid) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/rogue_sub.json');
      await file.writeAsString(jsonString);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Saved: ${file.path}")));
      }
    } else {
      String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save JSON',
          fileName: 'subtitle.json',
          allowedExtensions: ['json']);
      if (outputFile != null) {
        if (!outputFile.endsWith('.json')) {
          outputFile += ".json";
        }
        await File(outputFile).writeAsString(jsonString);
        _log("JSON Exported: $outputFile");
      }
    }
  }

  Future<void> _importJsonAndConvertToSrt() async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result != null) {
        File jsonFile = File(result.files.single.path!);
        String content = await jsonFile.readAsString();
        List<SubtitleLine> newSubs = [];
        List<dynamic> jsonList = jsonDecode(content);
        for (var item in jsonList) {
          newSubs.add(SubtitleLine(
              start: (item['start'] as num).toDouble(),
              end: (item['end'] as num).toDouble(),
              text: item['text'].toString()));
        }

        String srtContent = _generateSrtContent(newSubs);

        if (Platform.isAndroid) {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/converted_sub.srt');
          await file.writeAsString(srtContent);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Saved to: ${file.path}")));
          }
          setState(() {
            subtitles = newSubs;
            currentSubtitle = "Imported JSON: ${newSubs.length} lines";
          });
        } else {
          String? outputFile = await FilePicker.platform.saveFile(
              dialogTitle: 'Save SRT',
              fileName: 'subtitle.srt',
              allowedExtensions: ['srt']);
          if (outputFile != null) {
            if (!outputFile.endsWith('.srt')) {
              outputFile += ".srt";
            }
            await File(outputFile).writeAsString(srtContent);
            setState(() {
              subtitles = newSubs;
              currentSubtitle = "Saved & Loaded: ${newSubs.length} lines";
            });
            _log("JSON Imported & Converted to SRT");
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _importSubtitle() async {
    _log("Opening File Picker...");
    if (Platform.isAndroid) {
      _showInternalFileExplorer();
      return;
    }
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null) {
        _loadFileAndParse(File(result.files.single.path!));
      }
    } catch (e) {
      if (mounted) _log("File Picker Failed: $e");
    }
  }

  Future<void> _loadFileAndParse(File file) async {
    try {
      String content;
      try {
        content = await file.readAsString();
      } catch (e) {
        content = await file.readAsString(encoding: latin1);
      }
      _parseRobust(content);
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Loaded: ${file.path.split('/').last}")));
        _log("Loaded: ${file.path}");
      }
    } catch (e) {
      _log("Parse Error: $e");
    }
  }

  void _showInternalFileExplorer() {
    showDialog(
      context: context,
      builder: (ctx) =>
          FileExplorerDialog(onFileSelected: (file) => _loadFileAndParse(file)),
    );
  }

  void _parseRobust(String content) {
    List<SubtitleLine> parsedLines = [];
    List<String> lines = const LineSplitter().convert(content);
    int index = 0;
    while (index < lines.length) {
      String line = lines[index].trim();
      if (line.isEmpty || int.tryParse(line) != null) {
        index++;
        continue;
      }
      if (line.contains('-->')) {
        var parts = line.split('-->');
        if (parts.length == 2) {
          double start = _parseSrtTimeStrict(parts[0].trim());
          double end = _parseSrtTimeStrict(parts[1].trim());
          String text = "";
          index++;
          while (index < lines.length) {
            String nextLine = lines[index].trim();
            if (nextLine.isEmpty) break;
            text += "$nextLine\n";
            index++;
          }
          parsedLines.add(
            SubtitleLine(start: start, end: end, text: text.trim()),
          );
          continue;
        }
      }
      index++;
    }
    setState(() {
      subtitles = parsedLines;
      maxSubtitleDuration = parsedLines.isNotEmpty ? parsedLines.last.end : 1.0;
      currentSubtitle = "Subs Loaded";
    });
  }

  double _parseSrtTimeStrict(String timeString) {
    try {
      timeString = timeString.replaceAll(',', '.');
      List<String> parts = timeString.split(':');
      return (double.parse(parts[0]) * 3600) +
          (double.parse(parts[1]) * 60) +
          double.parse(parts[2]);
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> _translateSubtitlesWithGemini() async {
    if (geminiApiKey.isEmpty) {
      _showSettingsDialog();
      return;
    }
    if (subtitles.isEmpty) return;

    setState(() => currentSubtitle = t('ai_processing'));
    _log("Starting AI Translation...");

    try {
      final model =
          GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);
      int batchSize = 20;
      for (int i = 0; i < subtitles.length; i += batchSize) {
        if (!mounted) return;
        int end = (i + batchSize < subtitles.length)
            ? i + batchSize
            : subtitles.length;
        List<SubtitleLine> batch = subtitles.sublist(i, end);
        String promptText = batch.map((e) => e.text).join(" ||| ");
        final prompt =
            """Translate to Persian (Farsi). Keep separated by '|||'.""";
        final response = await model
            .generateContent([Content.text("$prompt Input: $promptText")]);
        if (response.text != null) {
          List<String> translated = response.text!.split("|||");
          for (int j = 0; j < batch.length && j < translated.length; j++) {
            subtitles[i + j].text = translated[j].trim();
          }
        }
        setState(() => currentSubtitle =
            "Translating... ${(i / subtitles.length * 100).toInt()}%");
        await Future.delayed(const Duration(milliseconds: 200));
      }
      setState(() => currentSubtitle = t('ai_done'));
      _log("AI Translation Finished.");
    } catch (e) {
      _log("AI Error: $e");
      setState(() => currentSubtitle = "AI Error: $e");
    }
  }

  void _toggleSyncActive() {
    setState(() => isSyncActive = !isSyncActive);
    _log(isSyncActive ? "Sync Enabled" : "Sync Disabled");
  }

  Future<void> _handleDownloadedSubtitle(String url) async {
    if (!mounted) return;
    setState(() => currentSubtitle = t('downloading'));
    _log("Downloading subtitle...");
    try {
      var tempDir = await getTemporaryDirectory();
      String savePath = "${tempDir.path}/temp_sub.srt";
      await Dio().download(url, savePath);
      File file = File(savePath);
      String content = await file.readAsString();
      _parseRobust(content);
    } catch (e) {
      if (mounted) setState(() => currentSubtitle = "Error: $e");
    }
  }

  // --- FIX: Jump to Time - Hours/Minutes/Seconds inputs ---
  void _jumpToTimeDialog() {
    TextEditingController hCtrl = TextEditingController();
    TextEditingController mCtrl = TextEditingController();
    TextEditingController sCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF222222),
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t('jump'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _timeInput(hCtrl, "HH"),
                  const SizedBox(width: 10),
                  _timeInput(mCtrl, "MM"),
                  const SizedBox(width: 10),
                  _timeInput(sCtrl, "SS"),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  ElevatedButton(
                    child: const Text("GO"),
                    onPressed: () {
                      double h = double.tryParse(hCtrl.text) ?? 0;
                      double m = double.tryParse(mCtrl.text) ?? 0;
                      double s = double.tryParse(sCtrl.text) ?? 0;
                      double total = (h * 3600) + (m * 60) + s;
                      _seekManual(total);
                      _log("Jumped to ${_formatDuration(total)}");
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeInput(TextEditingController ctrl, String hint) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade700),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            fillColor: Colors.black54,
            filled: true),
      ),
    );
  }

  void _toggleFullScreen() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      bool currentlyFull = await windowManager.isFullScreen();
      await windowManager.setFullScreen(!currentlyFull);
    }
    setState(() => isFullScreen = !isFullScreen);
    _log("Fullscreen toggled.");
  }

  void _openToolTab(String url) {
    setState(() {
      currentToolUrl = url;
      isToolPanelOpen = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        toolWebController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      }
    });
  }

  void _showTranslationOptions() {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: const Color(0xFF222222),
              surfaceTintColor: Colors.transparent,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(t('translate_menu'),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.grey),
                  ListTile(
                      leading: const Icon(Icons.language, color: Colors.orange),
                      title: Text(t('use_web'),
                          style: const TextStyle(color: Colors.white)),
                      subtitle: const Text("translatesubtitles.co",
                          style: TextStyle(color: Colors.grey)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openToolTab("https://translatesubtitles.co/");
                      }),
                  ListTile(
                      leading: const Icon(Icons.auto_awesome,
                          color: Colors.purpleAccent),
                      title: Text(t('use_ai'),
                          style: const TextStyle(color: Colors.white)),
                      subtitle: const Text("Gemini AI API (Auto)",
                          style: TextStyle(color: Colors.grey)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _translateSubtitlesWithGemini();
                      }),
                  const Divider(color: Colors.grey),
                  if (!Platform.isAndroid) ...[
                    ListTile(
                        leading:
                            const Icon(Icons.output, color: Colors.blueAccent),
                        title: const Text("Export JSON for AI",
                            style: TextStyle(color: Colors.white)),
                        subtitle: const Text("Create file for ChatGPT/Claude",
                            style: TextStyle(color: Colors.grey, fontSize: 10)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _exportSubtitlesToJson();
                        }),
                    ListTile(
                        leading:
                            const Icon(Icons.input, color: Colors.greenAccent),
                        title: const Text("Import JSON from AI",
                            style: TextStyle(color: Colors.white)),
                        subtitle: const Text("Convert back to SRT & Play",
                            style: TextStyle(color: Colors.grey, fontSize: 10)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _importJsonAndConvertToSrt();
                        }),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(t('close'))),
                  ),
                ]),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection uiDir =
        isPersian ? TextDirection.rtl : TextDirection.ltr;
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.space) {
              _togglePlayButton();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _seekManual(currentManualTime + 5);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _seekManual(currentManualTime - 5);
            } else if (event.logicalKey == LogicalKeyboardKey.f11) {
              _toggleFullScreen();
            }
          }
        },
        child: Directionality(
          textDirection: uiDir,
          child: Scaffold(
            backgroundColor: const Color(0xFF121212),
            body: Row(
              children: [
                _buildSidebar(),
                if (showBookmarksPanel) _buildBookmarksPanel(),
                Expanded(
                  child: Row(
                    children: [
                      isOverlayMode
                          ? _buildOverlayModeContent()
                          : _buildSplitModeContent(),
                      if (isToolPanelOpen) _buildToolsPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayModeContent() {
    return Expanded(
      flex: isToolPanelOpen ? 6 : 10,
      child: Column(
        children: [
          if (!isCinemaMode) _buildAddressBar(),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child:
                      isCinemaMode ? _buildCinemaPlayer() : _buildTvWebView(),
                ),
                // FIX: Only show when not empty
                if (!isCinemaMode && currentSubtitle.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: _buildSubtitleWidget(),
                    ),
                  ),
              ],
            ),
          ),
          _buildDashboard(),
        ],
      ),
    );
  }

  Widget _buildSplitModeContent() {
    return Expanded(
      flex: isToolPanelOpen ? 6 : 10,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double contentHeight = isCinemaMode
              ? constraints.maxHeight - 130
              : (constraints.maxHeight - 180) * _splitRatio;

          return Column(
            children: [
              if (!isCinemaMode) _buildAddressBar(),
              SizedBox(
                height: contentHeight,
                child: isCinemaMode ? _buildCinemaPlayer() : _buildTvWebView(),
              ),
              if (!isCinemaMode)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      double delta = details.delta.dy / constraints.maxHeight;
                      _splitRatio += delta;
                      if (_splitRatio < 0.2) _splitRatio = 0.2;
                      if (_splitRatio > 0.8) _splitRatio = 0.8;
                    });
                  },
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    color: const Color(0xFF1E1E1E),
                    alignment: Alignment.center,
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),
              if (!isCinemaMode)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildSubtitleWidget(),
                    ),
                  ),
                ),
              _buildDashboard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubtitleWidget() {
    // FIX: Do not render anything if no subtitle to prevent big empty box
    if (currentSubtitle.isEmpty) return const SizedBox();

    return Container(
      padding: hasSubtitleBackground
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : null,
      decoration: hasSubtitleBackground
          ? BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10, width: 0.5))
          : null,
      child: Stack(
        children: [
          Text(
            currentSubtitle,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(
                fontSize: subtitleFontSize,
                fontWeight: FontWeight.bold,
                height: 1.3,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4.0
                  ..color = Colors.black),
          ),
          Text(
            currentSubtitle,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(
                color: subtitleColor,
                fontSize: subtitleFontSize,
                height: 1.3,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTvWebView() {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
            const ScrollIntent(direction: AxisDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowDown):
            const ScrollIntent(direction: AxisDirection.down),
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ScrollIntent: CallbackAction<ScrollIntent>(
            onInvoke: (intent) {
              // --- FIX: Precision Scrolling (Step 15) ---
              int scrollAmount = 15;
              if (intent.direction == AxisDirection.up) {
                mainWebController?.scrollBy(x: 0, y: -scrollAmount);
              } else if (intent.direction == AxisDirection.down) {
                mainWebController?.scrollBy(x: 0, y: scrollAmount);
              }
              return null;
            },
          ),
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              mainWebController?.evaluateJavascript(
                  source:
                      "var ae = document.activeElement; if(ae) { ae.click(); }");
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Container(
            color: Colors.black,
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(homePageUrl)),
              initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                domStorageEnabled: true,
                useHybridComposition: true,
                userAgent: stealthUserAgent,
                cacheEnabled: true,
                clearCache: false,
                // Essential for TV Focus/Key handling
                overScrollMode: OverScrollMode.NEVER,
                preferredContentMode: UserPreferredContentMode.DESKTOP,
              ),
              initialUserScripts: UnmodifiableListView([
                _darkModeScript,
                _fakeFullscreenScript,
                _omniSpyScript,
                _videoSnifferScript,
                _keyboardListenerScript,
              ]),
              shouldOverrideUrlLoading: (controller, action) async {
                if (isAdBlockerEnabled) {
                  String url = action.request.url.toString().toLowerCase();
                  if (url.contains("googleads") ||
                      url.contains("doubleclick") ||
                      url.contains("adservice") ||
                      url.contains("analytics")) {
                    _log("Ad Blocked");
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onWebViewCreated: (c) {
                mainWebController = c;
                c.addJavaScriptHandler(
                    handlerName: 'rogueTick',
                    callback: (args) {
                      if (args.isEmpty) return;
                      double time = double.tryParse(args[0].toString()) ?? 0.0;
                      bool paused = args[1] == true;
                      if (!isManualMode && isSyncActive && mounted) {
                        if (isPlaying == paused)
                          setState(() => isPlaying = !paused);
                        currentManualTime = time;
                        _updateSubtitleUI();
                      }
                    });
                c.addJavaScriptHandler(
                    handlerName: 'rogueEvent',
                    callback: (args) {
                      if (args.isNotEmpty) _log("Event: ${args[0]}");
                    });
                c.addJavaScriptHandler(
                    handlerName: 'rogueSniffed',
                    callback: (args) {
                      if (args.isNotEmpty) {
                        setState(() => sniffedVideoUrl = args[0].toString());
                      }
                    });
                c.addJavaScriptHandler(
                    handlerName: 'rogueKeyTrigger',
                    callback: (args) {
                      if (args.isNotEmpty && args[0] == 'space') {
                        _togglePlayButton(fromWebView: true);
                      }
                    });
              },
              onEnterFullscreen: (controller) {
                _toggleFullScreen();
              },
              onLoadStop: (c, url) {
                if (mounted) {
                  setState(() => urlController.text = url.toString());
                  mainWebController?.evaluateJavascript(
                      source:
                          "if(document.body) document.body.style.zoom = '$webZoomLevel'");
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaPlayer() {
    if (_chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
        color: Colors.black, child: Chewie(controller: _chewieController!));
  }

  Widget _buildAddressBar() {
    return Container(
      height: 50,
      color: const Color(0xFF252525),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Tooltip(
              message: "Back",
              child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => mainWebController?.goBack())),
          Tooltip(
              message: "Forward",
              child: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () async {
                    if (await mainWebController?.canGoForward() ?? false) {
                      mainWebController?.goForward();
                    }
                  })),
          Expanded(
            child: TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF333333),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
                hintText: "URL...",
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                  Tooltip(
                      message: "Go",
                      child: IconButton(
                          icon: const Icon(Icons.play_arrow,
                              color: Colors.greenAccent),
                          onPressed: () {
                            // --- FIX: Use Smart URL Loader ---
                            _loadPage(urlController.text);
                          })),
                ]),
              ),
              // --- FIX: Use Smart URL Loader ---
              onSubmitted: (value) => _loadPage(value),
            ),
          ),
          Tooltip(
              message: _isBookmarked(urlController.text) ? "Saved" : "Bookmark",
              child: IconButton(
                icon: Icon(
                    _isBookmarked(urlController.text)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.yellow),
                onPressed: _toggleBookmark,
              )),
          // --- FIX: Windows Controls with Tooltips ---
          if (Platform.isWindows) ...[
            const SizedBox(width: 10),
            Tooltip(
                message: "Minimize",
                child: IconButton(
                    icon: const Icon(Icons.minimize, color: Colors.white),
                    onPressed: () => windowManager.minimize())),
            Tooltip(
                message: "Maximize/Restore",
                child: IconButton(
                    icon: const Icon(Icons.crop_square, color: Colors.white),
                    onPressed: () async {
                      if (await windowManager.isMaximized()) {
                        windowManager.restore();
                      } else {
                        windowManager.maximize();
                      }
                    })),
            Tooltip(
                message: "Close",
                child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => windowManager.close())),
          ]
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Material(
      color: const Color(0xFF222222),
      child: Container(
        height: 130,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Row(
              textDirection: TextDirection.ltr,
              children: [
                _controlIcon(
                    Icons.replay_10, () => _seekRelative(-10), "Rewind 10s",
                    color: Colors.cyanAccent),
                const SizedBox(width: 5),
                _controlIcon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    _togglePlayButton,
                    "Play/Pause",
                    color: isManualMode
                        ? Colors.orangeAccent
                        : Colors.greenAccent),
                const SizedBox(width: 5),
                _controlIcon(
                    Icons.forward_10, () => _seekRelative(10), "Forward 10s",
                    color: Colors.cyanAccent),
                const SizedBox(width: 10),
                Text(_formatDuration(currentManualTime),
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'monospace')),
                Expanded(
                    child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            trackHeight: 2),
                        child: Slider(
                            value: currentManualTime.clamp(
                                0.0, maxSubtitleDuration),
                            min: 0.0,
                            max: maxSubtitleDuration > 0
                                ? maxSubtitleDuration
                                : 1.0,
                            activeColor:
                                isManualMode ? Colors.orange : Colors.teal,
                            inactiveColor: Colors.grey[800],
                            onChanged: (val) => _seekManual(val)))),
                Text(_formatDuration(maxSubtitleDuration),
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontFamily: 'monospace')),
                _controlIcon(Icons.access_time, _jumpToTimeDialog, t('jump')),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.ltr,
                  children: [
                    Row(children: [
                      GestureDetector(
                        onLongPress: _toggleSyncActive,
                        child: Icon(Icons.sync,
                            color: isSyncActive ? Colors.green : Colors.grey,
                            size: 16),
                      ),
                      _controlIcon(
                          Icons.remove, () => _nudgeSync(-0.5), "-0.5s"),
                      Text("${syncDelay}s",
                          style: const TextStyle(color: Colors.white)),
                      _controlIcon(Icons.add, () => _nudgeSync(0.5), "+0.5s")
                    ]),
                    const SizedBox(width: 15),
                    Row(children: [
                      const Icon(Icons.text_fields,
                          color: Colors.grey, size: 16),
                      _controlIcon(
                          Icons.remove,
                          () => setState(() {
                                if (subtitleFontSize > 12) {
                                  subtitleFontSize -= 2;
                                  _saveSettings();
                                }
                              }),
                          "Size -"),
                      // --- FIX: Show Text Size ---
                      Text("${subtitleFontSize.toInt()}",
                          style: const TextStyle(color: Colors.white)),
                      _controlIcon(
                          Icons.add,
                          () => setState(() {
                                if (subtitleFontSize < 72) {
                                  subtitleFontSize += 2;
                                  _saveSettings();
                                }
                              }),
                          "Size +")
                    ]),
                    const SizedBox(width: 15),
                    Row(children: [
                      const Icon(Icons.zoom_in, color: Colors.grey, size: 16),
                      _controlIcon(Icons.remove, _zoomOut, "Zoom -"),
                      // --- FIX: Show Zoom Percentage ---
                      Text("${(webZoomLevel * 100).toInt()}%",
                          style: const TextStyle(color: Colors.white)),
                      _controlIcon(Icons.add, _zoomIn, "Zoom +")
                    ]),
                    const SizedBox(width: 15),
                    // --- RESTORED: Panel Adjust ---
                    Row(children: [
                      const Icon(Icons.height, color: Colors.grey, size: 16),
                      _controlIcon(
                          Icons.keyboard_arrow_up,
                          () => setState(() {
                                if (_splitRatio > 0.2) _splitRatio -= 0.05;
                              }),
                          "Panel Up"),
                      _controlIcon(
                          Icons.keyboard_arrow_down,
                          () => setState(() {
                                if (_splitRatio < 0.8) _splitRatio += 0.05;
                              }),
                          "Panel Down")
                    ]),
                    const SizedBox(width: 15),
                    Row(children: [
                      _controlIcon(Icons.refresh,
                          () => mainWebController?.reload(), "Reload",
                          color: Colors.blue),
                      _controlIcon(
                          Icons.delete_outline, _showSafeDeleteMenu, "Clear",
                          color: Colors.red)
                    ]),
                  ]),
            ),
            // --- FIX: Better Status Bar ---
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                    color: Colors.black,
                    border:
                        Border(top: BorderSide(color: Colors.grey.shade800))),
                child: ListView.builder(
                  controller: logScrollController,
                  itemCount: actionLogs.length,
                  itemBuilder: (ctx, i) {
                    return Text(
                      actionLogs[i],
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 10,
                          fontFamily: 'monospace'),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildToolsPanel() {
    return Expanded(
      flex: 4,
      child: Container(
        decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Colors.teal, width: 2)),
            color: Color(0xFF222222)),
        child: Column(
          children: [
            Container(
                height: 40,
                color: Colors.teal,
                child: Row(children: [
                  const SizedBox(width: 10),
                  Text(t('tool_title'),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => isToolPanelOpen = false))
                ])),
            Expanded(
                child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(currentToolUrl)),
                    onWebViewCreated: (c) => toolWebController = c,
                    onDownloadStartRequest: (c, req) async {
                      _handleDownloadedSubtitle(req.url.toString());
                    })),
            Container(
                height: 30,
                color: Colors.black,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back,
                              size: 16, color: Colors.white),
                          onPressed: () => toolWebController?.goBack()),
                      IconButton(
                          icon: const Icon(Icons.refresh,
                              size: 16, color: Colors.white),
                          onPressed: () => toolWebController?.reload())
                    ]))
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksPanel() {
    return Container(
      width: 200,
      color: const Color(0xFF252525),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(t('saved'),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (ctx, idx) {
                final bm = bookmarks[idx];
                return ListTile(
                  title: Text(bm['title'] ?? "Bookmark",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(bm['url'] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 10)),
                  trailing: IconButton(
                      icon:
                          const Icon(Icons.close, size: 14, color: Colors.red),
                      onPressed: () {
                        setState(() => bookmarks.removeAt(idx));
                        _saveSettings();
                      }),
                  onTap: () {
                    // --- FIX: Use Smart URL Loader ---
                    _loadPage(bm['url']!);
                    setState(() => showBookmarksPanel = false);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionBtn(IconData icon, String key, VoidCallback onTap,
      {bool isActive = false, Color? color, VoidCallback? onLongPress}) {
    return Focus(child: Builder(builder: (context) {
      final bool hasFocus = Focus.of(context).hasFocus;
      return Tooltip(
          message: t(key),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: hasFocus
                            ? Colors.teal.withValues(alpha: 0.4)
                            : (isActive ? Colors.teal : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: hasFocus
                                ? Colors.cyanAccent
                                : Colors.grey.shade800,
                            width: hasFocus ? 3 : 1)),
                    child: Icon(icon,
                        color:
                            color ?? (hasFocus ? Colors.white : Colors.white70),
                        size: 28))),
          ));
    }));
  }

  Widget _controlIcon(IconData icon, VoidCallback onTap, String tooltip,
      {Color? color}) {
    return Focus(child: Builder(builder: (context) {
      final bool hasFocus = Focus.of(context).hasFocus;
      return Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: onTap,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: hasFocus
                            ? Colors.white.withValues(alpha: 50)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        border: hasFocus
                            ? Border.all(color: Colors.cyanAccent, width: 2)
                            : null),
                    child: Icon(icon, color: color ?? Colors.white, size: 22))),
          ));
    }));
  }

  void _showSettingsDialog() {
    TextEditingController apiCtrl = TextEditingController(text: geminiApiKey);
    TextEditingController homeCtrl = TextEditingController(text: homePageUrl);
    // --- FIX: Use Generic Dialog to avoid Gray Overlay ---
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: const Color(0xFF222222),
              surfaceTintColor: Colors.transparent,
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text("Settings",
                        style: TextStyle(
                            color: Colors.tealAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                        controller: apiCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: t('api_key_hint'),
                            labelStyle: const TextStyle(color: Colors.grey))),
                    const SizedBox(height: 10),
                    TextField(
                        controller: homeCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: t('set_home'),
                            labelStyle: const TextStyle(color: Colors.grey))),
                    const SizedBox(height: 10),
                    Row(children: [
                      Text(t('overlay_mode'),
                          style: const TextStyle(color: Colors.white)),
                      const Spacer(),
                      Switch(
                          value: isOverlayMode,
                          onChanged: (v) {
                            setState(() => isOverlayMode = v);
                          }),
                    ]),
                    Row(children: [
                      const Text("Subtitle Background:",
                          style: TextStyle(color: Colors.white)),
                      const Spacer(),
                      Switch(
                          value: hasSubtitleBackground,
                          onChanged: (v) =>
                              setState(() => hasSubtitleBackground = v)),
                    ]),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                        icon: const Icon(Icons.code),
                        label: Text(t('visit_github')),
                        onPressed: () {
                          _openToolTab("https://github.com/makan4815162342");
                          Navigator.pop(ctx);
                        }),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                        icon: const Icon(Icons.help),
                        label: Text(t('guide')),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showGuideDialog();
                        }),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            child: Text(t('close')),
                            onPressed: () => Navigator.pop(ctx)),
                        const SizedBox(width: 10),
                        ElevatedButton(
                            child: Text(t('save')),
                            onPressed: () {
                              setState(() {
                                geminiApiKey = apiCtrl.text;
                                homePageUrl = homeCtrl.text;
                              });
                              _saveSettings();
                              Navigator.pop(ctx);
                            }),
                      ],
                    )
                  ])),
            ));
  }

  void _showGuideDialog() {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: const Color(0xFF222222),
              surfaceTintColor: Colors.transparent,
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("⚠️ Known Limitations:",
                            style: TextStyle(color: Colors.orangeAccent)),
                        Text(
                            "- TV: Use mouse mode (Focus on Browser) if D-pad scrolling fails on specific sites.",
                            style: TextStyle(color: Colors.white70)),
                        Text("- Windows: Use arrow keys to nudge sync delay.",
                            style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 10),
                        Text("English Guide:",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text(
                            "1. Import: Folder icon -> select your .srt file (supports USB on TV).",
                            style: TextStyle(color: Colors.white70)),
                        Text(
                            "2. Sync: If video player doesn't auto-detect, use manual mode play button.",
                            style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 10),
                        Divider(color: Colors.grey),
                        SizedBox(height: 10),
                        Text("راهنمای فارسی:",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textDirection: TextDirection.rtl),
                        Text(
                            "۱. محدودیت‌ها: برای حرکت راحت در صفحات وب روی تلویزیون، استفاده از ماوس پیشنهاد می‌شود.",
                            style: TextStyle(color: Colors.white70),
                            textDirection: TextDirection.rtl),
                        Text(
                            "۲. وارد کردن: از آیکون پوشه برای انتخاب فایل زیرنویس استفاده کنید (پشتیبانی از فلش).",
                            style: TextStyle(color: Colors.white70),
                            textDirection: TextDirection.rtl),
                        Text(
                            "۳. هماهنگی: اگر ویدیو پلیر سایت شناسایی نشد، از دکمه پخش دستی استفاده کنید.",
                            style: TextStyle(color: Colors.white70),
                            textDirection: TextDirection.rtl),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _showSettingsDialog();
                                },
                                child: Text(t('back_settings'))),
                            const SizedBox(width: 10),
                            TextButton(
                                child: Text(t('close')),
                                onPressed: () => Navigator.pop(ctx))
                          ],
                        )
                      ])),
            ));
  }

  void _showSafeDeleteMenu() {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF222222),
        builder: (ctx) {
          return Container(
              padding: const EdgeInsets.all(20),
              height: 320,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(t('menu_title'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(ctx))
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    ListTile(
                        leading: const Icon(Icons.subtitles_off,
                            color: Colors.yellow),
                        title: Text(t('opt_unload'),
                            style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          setState(() {
                            subtitles.clear();
                            currentSubtitle = "";
                          });
                          _log("Subtitles Unloaded.");
                          Navigator.pop(ctx);
                        }),
                    ListTile(
                        leading: const Icon(Icons.cleaning_services,
                            color: Colors.blue),
                        title: Text(t('opt_cache'),
                            style: const TextStyle(color: Colors.white)),
                        onTap: () async {
                          _aggressiveMemoryClean();
                          Navigator.pop(ctx);
                        }),
                    ListTile(
                        leading:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        title: Text(t('opt_all'),
                            style: const TextStyle(color: Colors.white)),
                        onTap: () async {
                          await mainWebController?.clearHistory();
                          _aggressiveMemoryClean();
                          setState(() {
                            subtitles.clear();
                            bookmarks.clear();
                          });
                          _log("Factory Reset Complete.");
                          Navigator.pop(ctx);
                        }),
                  ]));
        });
  }

  void _openSearchStation() {
    TextEditingController searchCtrl = TextEditingController(text: "");
    showDialog(
        context: context,
        // --- FIX: Use Generic Dialog with Constraints for "Gray Box" ---
        builder: (ctx) => Dialog(
              backgroundColor: const Color(0xFF222222),
              surfaceTintColor: Colors.transparent,
              child: Container(
                width: 400, // Forces visible width
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(t('search_for'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                      controller: searchCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: t('search_hint'),
                          filled: true,
                          fillColor: Colors.black38)),
                  const SizedBox(height: 20),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    _sourceBtn(
                        ctx,
                        searchCtrl,
                        t('source_google'),
                        "https://www.google.com/search?q=QUERY+farsi+subtitle+filetype:srt",
                        Colors.blue),
                    _sourceBtn(
                        ctx,
                        searchCtrl,
                        t('source_subcat'),
                        "https://subtitlecat.com/index.php?search=QUERY",
                        Colors.orange),
                    _sourceBtn(
                        ctx,
                        searchCtrl,
                        t('source_opensub_com'),
                        "https://www.opensubtitles.com/en/search/all/QUERY",
                        Colors.green),
                    _sourceBtn(
                        ctx,
                        searchCtrl,
                        t('source_opensub_org'),
                        "https://www.opensubtitles.org/en/search/sublanguageid-all/q-QUERY",
                        Colors.green.shade800),
                    _sourceBtn(ctx, searchCtrl, t('source_subdl'),
                        "https://subdl.com/search/QUERY", Colors.purple),
                  ]),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        child: Text(t('close')),
                        onPressed: () => Navigator.pop(ctx)),
                  )
                ]),
              ),
            ));
  }

  Widget _sourceBtn(BuildContext ctx, TextEditingController ctrl, String label,
      String urlTemplate, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: () {
        String query = ctrl.text.trim();
        if (query.isEmpty) return;
        String finalUrl =
            urlTemplate.replaceAll("QUERY", Uri.encodeComponent(query));
        Navigator.pop(ctx);
        _openToolTab(finalUrl);
      },
      child: Text(label),
    );
  }

  Widget _buildSidebar() {
    // --- FIX: Use Material Widget for Background ---
    return Material(
      color: const Color(0xFF1E1E1E),
      child: SizedBox(
        width: 90,
        child: Column(children: [
          const SizedBox(height: 20),
          _buildOptionBtn(Icons.language, 'lang', () {
            setState(() => isPersian = !isPersian);
            _saveSettings();
          }),
          // --- REORDERED: Home is now at top ---
          _buildOptionBtn(
              Icons.home,
              'home',
              () => mainWebController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(homePageUrl)))),
          const Divider(color: Colors.grey),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: [
            _buildOptionBtn(
                isManualMode ? Icons.touch_app : Icons.link,
                isManualMode ? 'manual_mode' : 'auto_mode',
                () => setState(() => isManualMode = !isManualMode),
                isActive: isManualMode,
                color: isManualMode
                    ? Colors.orangeAccent
                    : Colors.lightBlueAccent),
            _buildOptionBtn(Icons.movie_filter, 'cinema_mode', _grabVideo,
                isActive: isCinemaMode,
                color:
                    sniffedVideoUrl != null ? Colors.greenAccent : Colors.grey),
            _buildOptionBtn(Icons.search, 'find', _openSearchStation),
            _buildOptionBtn(
                Icons.translate, 'translate_menu', _showTranslationOptions),
            _buildOptionBtn(Icons.folder_open, 'import', _importSubtitle,
                onLongPress: _showInternalFileExplorer),
            _buildOptionBtn(Icons.bookmark, 'saved',
                () => setState(() => showBookmarksPanel = !showBookmarksPanel),
                isActive: showBookmarksPanel),
            _buildOptionBtn(
                isAdBlockerEnabled
                    ? Icons.security
                    : Icons.security_update_warning,
                'adblock', () {
              setState(() => isAdBlockerEnabled = !isAdBlockerEnabled);
              mainWebController?.reload();
              _saveSettings();
            },
                isActive: isAdBlockerEnabled,
                color: isAdBlockerEnabled ? Colors.green : Colors.redAccent),
          ]))),
          const Divider(color: Colors.grey),
          _buildOptionBtn(Icons.settings, 'about', _showSettingsDialog),
          _buildOptionBtn(
              isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              'screen',
              _toggleFullScreen),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  String _formatDuration(double seconds) {
    int s = seconds.toInt();
    int h = s ~/ 3600;
    int m = (s % 3600) ~/ 60;
    int sec = s % 60;
    return h > 0
        ? "$h:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}"
        : "${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }
}

// --- EXPLORER DIALOG ---
class FileExplorerDialog extends StatefulWidget {
  final Function(File) onFileSelected;
  const FileExplorerDialog({super.key, required this.onFileSelected});
  @override
  State<FileExplorerDialog> createState() => _FileExplorerDialogState();
}

class _FileExplorerDialogState extends State<FileExplorerDialog>
    with WidgetsBindingObserver {
  Directory currentDir = Directory('/storage');
  List<FileSystemEntity> files = [];
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen for app resume
    if (!Platform.isAndroid) {
      currentDir = Directory.current;
      hasPermission = true;
      _listDir(currentDir);
    } else {
      _checkPermissionAndList();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Auto-refresh when user comes back from Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndList();
    }
  }

  Future<void> _checkPermissionAndList() async {
    if (!Platform.isAndroid) return;

    if (await Permission.manageExternalStorage.isGranted) {
      setState(() => hasPermission = true);
      _listDir(currentDir);
      return;
    }

    if (await Permission.storage.isGranted) {
      setState(() => hasPermission = true);
      _listDir(currentDir);
      return;
    }

    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      setState(() => hasPermission = true);
      _listDir(currentDir);
    } else {
      if (await Permission.storage.request().isGranted) {
        setState(() => hasPermission = true);
        _listDir(currentDir);
      }
    }
  }

  void _listDir(Directory dir) {
    try {
      // Security check
      if (dir.path == '/' || dir.path == '') {
        dir = Directory('/storage');
      }

      List<FileSystemEntity> entities = dir.listSync();

      setState(() {
        currentDir = dir;
        files = entities.where((e) {
          final name = e.path.split(Platform.pathSeparator).last;
          return !name.startsWith('.');
        }).toList();

        files.sort((a, b) {
          int typeA = (a is Directory) ? 0 : 1;
          int typeB = (b is Directory) ? 0 : 1;
          if (typeA != typeB) return typeA.compareTo(typeB);
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });
      });
    } catch (e) {
      if (dir.path == '/storage') {
        _listDir(Directory('/storage/emulated/0'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF222222),
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Subtitle",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(currentDir.path,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.grey),

              // Body
              Expanded(
                child: !hasPermission && Platform.isAndroid
                    ? Center(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, size: 50, color: Colors.red),
                          const SizedBox(height: 10),
                          const Text("Storage Permission Required",
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                              onPressed: () async {
                                await openAppSettings();
                              },
                              child: const Text("Open Settings"))
                        ],
                      ))
                    : ListView.builder(
                        itemCount: files.length + 1,
                        itemBuilder: (ctx, idx) {
                          // "Go Up" Button
                          if (idx == 0) {
                            if (currentDir.path == '/storage')
                              return const SizedBox.shrink();

                            return ListTile(
                                leading: const Icon(Icons.arrow_upward,
                                    color: Colors.teal),
                                title: const Text(".. (Go Back)",
                                    style: TextStyle(color: Colors.white70)),
                                onTap: () => _listDir(currentDir.parent));
                          }

                          final entity = files[idx - 1];
                          final String name =
                              entity.path.split(Platform.pathSeparator).last;

                          if (entity is Directory) {
                            return ListTile(
                              leading: const Icon(Icons.folder,
                                  color: Colors.orange),
                              title: Text(name,
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              onTap: () => _listDir(entity as Directory),
                            );
                          } else {
                            // File
                            bool isSub = name.endsWith('.srt') ||
                                name.endsWith('.vtt') ||
                                name.endsWith('.txt') ||
                                name.endsWith('.json'); // Allow JSON too

                            return ListTile(
                              leading: Icon(Icons.description,
                                  color: isSub
                                      ? Colors.greenAccent
                                      : Colors.white30),
                              title: Text(name,
                                  style: TextStyle(
                                      color: isSub
                                          ? Colors.white
                                          : Colors.white60),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              onTap: () =>
                                  widget.onFileSelected(File(entity.path)),
                            );
                          }
                        }),
              ),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context))
                ],
              )
            ],
          )),
    );
  }
}
