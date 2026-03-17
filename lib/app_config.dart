/// ============================================================
/// App Configuration
/// ============================================================
/// Change the website URL and app settings here.
/// This is the single source of truth for all configurable values.
/// ============================================================

class AppConfig {
  // ── Website URL ──────────────────────────────────────────────
  // Change this URL to load a different website in the WebView
  static const String websiteUrl = 'https://quran-app-lite.vercel.app/';

  // ── App Identity ─────────────────────────────────────────────
  static const String appName = 'NoorQuran';
  static const String appTagline = 'Your Digital Quran Companion';

  // ── Theme Colors ─────────────────────────────────────────────
  // Primary teal/emerald color palette
  static const int primaryColorValue = 0xFF0D7377;
  static const int backgroundColorValue = 0xFF0A1628;
  static const int surfaceColorValue = 0xFF132240;
  static const int accentColorValue = 0xFF14BDAC;
  static const int goldColorValue = 0xFFD4A853;

  // ── Splash Screen ────────────────────────────────────────────
  static const int splashDurationMs = 2500;
  static const String splashImagePath = 'assets/images/app_icon.png';

  // ── WebView Settings ─────────────────────────────────────────
  static const bool enableJavaScript = true;
  static const bool enableDomStorage = true;
  static const String userAgent = '';  // Empty = use default

  // ── Allowed Hosts ────────────────────────────────────────────
  // Only URLs matching these hosts will open inside the WebView.
  // External links will be blocked to keep users in-app.
  static const List<String> allowedHosts = [
    'quran-app-lite.vercel.app',
  ];
}
