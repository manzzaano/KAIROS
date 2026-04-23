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
    this.color = KairosColors.neutral700,
    this.strokeWidth = 1.0,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: KairosColors.neutral900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KairosColors.neutral700, width: 1),
        boxShadow: glow
            ? [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 40, spreadRadius: 2)]
            : null,
      ),
    );
  }
}
