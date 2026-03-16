# Flutter WebView ProGuard Rules
# Keep WebView JavaScript interface
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep WebView classes
-keep class android.webkit.** { *; }
