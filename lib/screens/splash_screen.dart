import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool showOnboarding;

  const SplashScreen({super.key, required this.showOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;
  bool _expandGreen = false;

  @override
  void initState() {
    super.initState();

    // Animation controller for moving gradient
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _alignmentAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));

    // Stop moving gradient and expand green
    _controller.stop();
    setState(() {
      _expandGreen = true;
    });

    // Wait for expansion animation
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      if (widget.showOnboarding) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstTime', false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = !_expandGreen; // Before expansion, use gradient theme
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _alignmentAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: _expandGreen
                  ? const LinearGradient(
                colors: [Color(0xFF2E7D32), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
                  : LinearGradient(
                begin: _alignmentAnimation.value,
                end: Alignment.centerRight,
                colors: [
                  Colors.black,
                  const Color(0xFF2E7D32),
                  Colors.black87,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: AnimatedOpacity(
            opacity: _expandGreen ? 0 : 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rounded Logo
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/images/logo/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ).animate().scale(
                  duration: 900.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 30),

                // App Name with Gradient Text
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDark
                        ? [Colors.white, Colors.greenAccent]
                        : [Colors.black87, Colors.green.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Quran App',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w300, // Thin font
                      letterSpacing: 1.5,
                      fontFamily: 'Poppins',
                      color: Colors.white, // overridden by shader
                    ),
                  ),
                ).animate().fadeIn(
                  duration: 700.ms,
                  delay: 400.ms,
                ).slideY(begin: 0.3),

                const SizedBox(height: 12),

                // Subtitle with Fade
                Text(
                  'Read, Learn, Reflect',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                    color: textColor.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                ).animate().fadeIn(
                  duration: 700.ms,
                  delay: 600.ms,
                ),

                const SizedBox(height: 50),

                // Loading Indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ).animate().fadeIn(
                  duration: 500.ms,
                  delay: 800.ms,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
