import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  static const int _total = 90 * 60;
  int _remaining = 73 * 60 + 42;
  bool _colon = true;
  Timer? _blinker;

  @override
  void initState() {
    super.initState();
    _blinker = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!mounted) return;
      setState(() => _colon = !_colon);
    });
  }

  @override
  void dispose() {
    _blinker?.cancel();
    super.dispose();
  }

  String _fmt(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    final progress = 1 - (_remaining / _total);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.focus),
        leading: IconButton(
          onPressed: () => context.go(Routes.dashboard),
          icon: const Icon(Icons.close, size: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                      size: const Size(280, 280),
                      painter: _RingPainter(progress)),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Strings.deepWork,
                          style: KairosTheme.mono(
                              size: 10,
                              color: KairosColors.neutral700,
                              letterSpacing: 5)),
                      const SizedBox(height: 14),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: _fmt(m),
                            style: KairosTheme.serif(
                                size: 72,
                                weight: FontWeight.w300,
                                color: KairosColors.neutral50),
                          ),
                          TextSpan(
                            text: _colon ? ':' : ' ',
                            style: KairosTheme.serif(
                                size: 72,
                                weight: FontWeight.w300,
                                color: KairosColors.neutral700),
                          ),
                          TextSpan(
                            text: _fmt(s),
                            style: KairosTheme.serif(
                                size: 72,
                                weight: FontWeight.w300,
                                color: KairosColors.neutral50),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 8),
                      Text(Strings.remaining,
                          style: KairosTheme.mono(
                              size: 9,
                              color: KairosColors.neutral400,
                              letterSpacing: 4)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Text(Strings.focusMotto,
                style: KairosTheme.serif(
                    size: 20,
                    color: KairosColors.neutral50,
                    style: FontStyle.italic,
                    weight: FontWeight.w300)),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(Strings.focusWarning,
                  textAlign: TextAlign.center,
                  style: KairosTheme.mono(
                      size: 9, color: KairosColors.error600, letterSpacing: 3)),
            ),
            const SizedBox(height: 14),
            _SurrenderButton(onTap: () => context.go(Routes.confessional)),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _SurrenderButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SurrenderButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: KairosColors.error600, width: 1),
            boxShadow: [
              BoxShadow(
                  color: KairosColors.error600.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 1)
            ],
          ),
          child: Center(
            child: Text(Strings.surrender,
                style: KairosTheme.mono(
                    size: 12,
                    color: KairosColors.error600,
                    letterSpacing: 6,
                    weight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 10;

    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi - math.pi / 2;
      final isMajor = i % 5 == 0;
      final inner = radius - (isMajor ? 10 : 5);
      final p1 = Offset(center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius);
      final p2 = Offset(center.dx + math.cos(angle) * inner,
          center.dy + math.sin(angle) * inner);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color =
              isMajor ? KairosColors.neutral700 : KairosColors.neutral400
          ..strokeWidth = isMajor ? 1.2 : 0.6,
      );
    }

    canvas.drawCircle(
      center,
      radius - 20,
      Paint()
        ..color = KairosColors.neutral300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 20),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      Paint()
        ..color = KairosColors.neutral700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
