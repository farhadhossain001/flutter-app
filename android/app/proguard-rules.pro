# Flutter WebView ProGuard Rules
-keepattributes JavascriptInterface
-keepattributes *Annotation*
-keepattributes Signature

# Keep WebView and JavaScript interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class android.webkit.** { *; }

# Keep Flutter and Plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.noorquran.app.** { *; }

# Specifically for webview_flutter and connectivity_plus
-keep class io.flutter.plugins.webview_flutter.** { *; }
-keep class io.flutter.plugins.connectivity.** { *; }

# Ignore warnings from missing classes in libraries
-dontwarn io.flutter.plugins.**
-dontwarn android.webkit.**
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**
-dontwarn javax.annotation.**
