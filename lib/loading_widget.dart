import 'package:flutter/material.dart';
import 'app_config.dart';

/// ============================================================
/// Loading Widget
/// ============================================================
/// A modern, animated loading indicator displayed while the
/// WebView is loading the website content.
/// ============================================================

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulsing glow animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotating ring animation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(AppConfig.backgroundColorValue).withValues(alpha: 0.85),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _rotateController]),
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated Loader ──
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(AppConfig.accentColorValue)
                                .withValues(alpha: _pulseAnimation.value * 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Spinning ring
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(
                            const Color(AppConfig.accentColorValue),
                            const Color(AppConfig.goldColorValue),
                            _pulseAnimation.value,
                          )!,
                        ),
                      ),
                    ),
                    // Center icon
                    Icon(
                      Icons.menu_book_rounded,
                      size: 24,
                      color: Colors.white.withValues(alpha: _pulseAnimation.value),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Loading Text ──
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
