import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';
import '../widgets/doric_column.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _fade;
  late final AnimationController _loader;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _loader = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    Future.delayed(Timings.splashDelay, () {
      if (!mounted) return;
      context.go(Routes.login);
    });
  }

  @override
  void dispose() {
    _fade.dispose();
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: KairosColors.neutral900,
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DoricColumn(width: 120, height: 280),
                const SizedBox(height: 44),
                Text(Strings.appName,
                    style: KairosTheme.serif(size: 46, weight: FontWeight.w300, color: KairosColors.neutral50)),
                const SizedBox(height: 10),
                Text(Strings.appTagline,
                    style: KairosTheme.mono(size: 10, color: KairosColors.neutral400, letterSpacing: 2)),
                const SizedBox(height: 72),
                SizedBox(
                  width: 96,
                  height: 1,
                  child: AnimatedBuilder(
                    animation: _loader,
                    builder: (_, __) => CustomPaint(
                      painter: _HairlinePainter(_loader.value),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(Strings.copyright,
                    style: KairosTheme.mono(size: 9, color: KairosColors.neutral400, letterSpacing: 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HairlinePainter extends CustomPainter {
  final double t;
  _HairlinePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = KairosColors.neutral700
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), bg);
    final fg = Paint()
      ..color = KairosColors.neutral50
      ..strokeWidth = 1;
    final segW = size.width * 0.35;
    final x = (size.width + segW) * t - segW;
    canvas.drawLine(Offset(x, size.height / 2), Offset(x + segW, size.height / 2), fg);
  }

  @override
  bool shouldRepaint(covariant _HairlinePainter old) => old.t != t;
}
