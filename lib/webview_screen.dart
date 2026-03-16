import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'app_config.dart';
import 'loading_widget.dart';
import 'error_screen.dart';

/// ============================================================
/// WebView Screen
/// ============================================================
/// The main screen that loads the website inside a WebView.
/// Handles navigation, back button, pull-to-refresh, and errors.
/// ============================================================

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with SingleTickerProviderStateMixin {
  late WebViewController _controller;

  // State management
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _loadingProgress = 0;

  // Animation for the progress bar
  late AnimationController _progressFadeController;
  late Animation<double> _progressFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeWebView();
  }

  /// Set up animation for progress bar fade out
  void _setupAnimations() {
    _progressFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressFadeController, curve: Curves.easeOut),
    );
  }

  /// Initialize the WebView controller with all required settings
  void _initializeWebView() {
    _controller = WebViewController()
      // Enable JavaScript for full web app functionality
      ..setJavaScriptMode(AppConfig.enableJavaScript
          ? JavaScriptMode.unrestricted
          : JavaScriptMode.disabled)
      // Set background color to match app theme (prevents white flash)
      ..setBackgroundColor(const Color(AppConfig.backgroundColorValue))
      // Handle navigation requests - block external links
      ..setNavigationDelegate(
        NavigationDelegate(
          // Called when the page starts loading
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _loadingProgress = 0;
            });
            _progressFadeController.reverse();
          },
          // Called when the page finishes loading
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Fade out the progress bar after a brief delay
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _progressFadeController.forward();
            });
          },
          // Track loading progress for the progress bar
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          // Handle navigation errors (network issues, etc.)
          onWebResourceError: (WebResourceError error) {
            // Only show error screen for main frame errors
            if (error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.timeout ||
                error.errorType == WebResourceErrorType.unknown) {
              setState(() {
                _hasError = true;
                _isLoading = false;
                _errorMessage = _getErrorMessage(error.errorType);
              });
            }
          },
          // Block navigation to external URLs
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            // Allow navigation to configured hosts only
            if (AppConfig.allowedHosts.contains(uri.host) ||
                request.url.startsWith('about:') ||
                request.url.startsWith('data:')) {
              return NavigationDecision.navigate;
            }
            // Block external URLs - prevent opening in browser
            return NavigationDecision.prevent;
          },
        ),
      )
      // Load the configured website URL
      ..loadRequest(Uri.parse(AppConfig.websiteUrl));
  }

  /// Convert WebView error types to user-friendly messages
  String _getErrorMessage(WebResourceErrorType? errorType) {
    switch (errorType) {
      case WebResourceErrorType.connect:
        return 'Unable to connect to the server.\nPlease check your internet connection.';
      case WebResourceErrorType.hostLookup:
        return 'Could not find the server.\nPlease check your internet connection.';
      case WebResourceErrorType.timeout:
        return 'The connection timed out.\nPlease try again later.';
      default:
        return 'Something went wrong.\nPlease check your connection and try again.';
    }
  }

  /// Reload the WebView (used for retry and pull-to-refresh)
  Future<void> _reloadWebView() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    await _controller.reload();
  }

  /// Handle Android back button: go back in WebView history or exit
  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false; // Don't exit the app
    }
    // Show exit confirmation
    if (mounted) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(AppConfig.surfaceColorValue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Exit NoorQuran?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to exit?',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Stay',
                style: TextStyle(
                  color: const Color(AppConfig.accentColorValue),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Exit',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    _progressFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use PopScope for back button handling (replaces deprecated WillPopScope)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(AppConfig.backgroundColorValue),
        body: SafeArea(
          child: Stack(
            children: [
              // ── WebView Layer ──
              if (!_hasError)
                RefreshIndicator(
                  onRefresh: _reloadWebView,
                  color: const Color(AppConfig.accentColorValue),
                  backgroundColor: const Color(AppConfig.surfaceColorValue),
                  child: WebViewWidget(controller: _controller),
                ),

              // ── Error Screen Layer ──
              if (_hasError)
                ErrorScreen(
                  message: _errorMessage,
                  onRetry: _reloadWebView,
                ),

              // ── Loading Overlay ──
              if (_isLoading && !_hasError) const LoadingWidget(),

              // ── Progress Bar at Top ──
              if (_isLoading && !_hasError)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _progressFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _progressFadeAnimation.value,
                        child: LinearProgressIndicator(
                          value: _loadingProgress / 100.0,
                          minHeight: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(
                              const Color(AppConfig.accentColorValue),
                              const Color(AppConfig.goldColorValue),
                              _loadingProgress / 100.0,
                            )!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
