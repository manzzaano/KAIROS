import 'package:flutter/material.dart';

import '../utils/theme.dart';

class DoricColumn extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;
  final bool glow;

  const DoricColumn({
    super.key,
    required this.width,
    required this.height,
    this.color = KairosColors.bronze,
    this.strokeWidth = 1.0,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      size: Size(width, height),
      painter: _ColumnPainter(color: color, strokeWidth: strokeWidth),
    );
    if (!glow) return painter;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.10), blurRadius: 60, spreadRadius: 6),
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 120, spreadRadius: 12),
        ],
      ),
      child: painter,
    );
  }
}

class _ColumnPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ColumnPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final w = size.width;
    final h = size.height;
    final capH = h * 0.07;
    final baseH = h * 0.05;
    final shaftTop = capH;
    final shaftBottom = h - baseH;

    final botW = w * 0.70;
    final topW = botW * 0.88;
    final botX = (w - botW) / 2;
    final topX = (w - topW) / 2;

    // Abacus (top slab)
    canvas.drawRect(Rect.fromLTWH(0, 0, w, capH * 0.45), paint);
    // Echinus (rounded molding under abacus)
    final echinus = Rect.fromLTWH(w * 0.06, capH * 0.45, w * 0.88, capH * 0.55);
    canvas.drawRect(echinus, paint);

    // Shaft outline with entasis
    final shaftPath = Path()
      ..moveTo(topX, shaftTop)
      ..lineTo(topX + topW, shaftTop)
      ..lineTo(botX + botW, shaftBottom)
      ..lineTo(botX, shaftBottom)
      ..close();
    canvas.drawPath(shaftPath, paint);

    // Flutes (14 vertical grooves)
    const flutes = 14;
    for (int i = 1; i < flutes; i++) {
      final t = i / flutes;
      canvas.drawLine(
        Offset(topX + topW * t, shaftTop),
        Offset(botX + botW * t, shaftBottom),
        paint,
      );
    }

    // Base (torus + plinth)
    canvas.drawRect(Rect.fromLTWH(w * 0.04, shaftBottom, w * 0.92, baseH * 0.55), paint);
    canvas.drawRect(Rect.fromLTWH(0, shaftBottom + baseH * 0.55, w, baseH * 0.45), paint);
  }

  @override
  bool shouldRepaint(covariant _ColumnPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
