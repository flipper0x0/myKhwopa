import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fastController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fast sub-second entrance animation (500ms)
    _fastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _fastController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fastController,
      curve: Curves.easeIn,
    );

    _startFastSequence();
  }

  Future<void> _startFastSequence() async {
    FlutterNativeSplash.remove();
    _fastController.forward();

    // Pre-check authentication in parallel while animation runs
    final prefsFuture = SharedPreferences.getInstance();

    // Fast sub-second delay (700ms total splash screen display time)
    await Future.delayed(const Duration(milliseconds: 700));

    final prefs = await prefsFuture;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isLoggedIn ? const HomeScreen() : const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  void dispose() {
    _fastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF090C15), // Sleek deep dark navy
      body: Stack(
        children: [
          // Subtle Glowing Ambient Orbs
          Positioned(
            top: size.height * 0.2,
            left: size.width * 0.1,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withOpacity(0.08),
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            right: size.width * 0.1,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7928CA).withOpacity(0.1),
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              ),
            ),
          ),

          // Main Center Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Modern Glowing Crest Graphic
                      const ModernKhwopaEmblem(),
                      const SizedBox(height: 32),

                      // Main Brand Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF00E5FF),
                            Color(0xFF7928CA),
                            Color(0xFFFF0080),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'KHWOPA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'COLLEGE OF ENGINEERING',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 5,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Department Badges
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DeptBadge(label: 'COMP', color: Color(0xFF00E5FF)),
                          SizedBox(width: 8),
                          _DeptBadge(label: 'CIVIL', color: Color(0xFFFF6600)),
                          SizedBox(width: 8),
                          _DeptBadge(label: 'ELEC', color: Color(0xFFFFAA00)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Footer
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'EST. 2056 BS • BHAKTAPUR NEPAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernKhwopaEmblem extends StatelessWidget {
  const ModernKhwopaEmblem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF161B2E), Color(0xFF0D111D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.25),
            blurRadius: 25,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF7928CA).withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(80, 80),
          painter: _EmblemPainter(),
        ),
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paintGlow = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF7928CA), Color(0xFFFF0080)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Outer Tech Ring Teeth
    for (int i = 0; i < 8; i++) {
      double angle = (i * math.pi / 4);
      double x1 = center.dx + math.cos(angle) * 32;
      double y1 = center.dy + math.sin(angle) * 32;
      double x2 = center.dx + math.cos(angle) * 37;
      double y2 = center.dy + math.sin(angle) * 37;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paintGlow);
    }

    // Stylized K logo mark
    final kPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFFFFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Vertical stem of K
    path.moveTo(center.dx - 12, center.dy - 20);
    path.lineTo(center.dx - 12, center.dy + 20);

    // Upper arm
    path.moveTo(center.dx - 10, center.dy);
    path.lineTo(center.dx + 14, center.dy - 20);

    // Lower arm
    path.moveTo(center.dx - 4, center.dy - 5);
    path.lineTo(center.dx + 14, center.dy + 20);

    canvas.drawPath(path, kPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DeptBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _DeptBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}