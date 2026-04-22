import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/theme.dart';

enum TimeState { past, now, future }

class TimeBlock extends StatelessWidget {
  final String time;
  final String title;
  final String meta;
  final TimeState state;

  const TimeBlock({
    super.key,
    required this.time,
    required this.title,
    required this.meta,
    required this.state,
  });

  double get _blur => switch (state) {
        TimeState.past => 5.0,
        TimeState.future => 3.5,
        TimeState.now => 0.0,
      };

  double get _opacity => switch (state) {
        TimeState.past => 0.22,
        TimeState.future => 0.32,
        TimeState.now => 1.0,
      };

  @override
  Widget build(BuildContext context) {
    final isNow = state == TimeState.now;

    final content = Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      decoration: BoxDecoration(
        color: isNow ? KairosColors.ink : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isNow ? KairosColors.bronze : KairosColors.hairline,
            width: isNow ? 2 : 1,
          ),
        ),
        boxShadow: isNow
            ? [const BoxShadow(color: Color(0x409A7C4E), blurRadius: 24, spreadRadius: 2)]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(time, style: KairosTheme.mono(size: 16, color: KairosColors.bone, letterSpacing: 1)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KairosTheme.serif(size: 22, color: KairosColors.bone)),
                const SizedBox(height: 4),
                Text(meta, style: KairosTheme.mono(size: 10, color: KairosColors.bronze, letterSpacing: 2)),
              ],
            ),
          ),
        ],
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOut,
      builder: (_, t, __) {
        final op = _opacity * t;
        final blur = _blur * t;
        final faded = Opacity(opacity: op, child: content);
        if (blur < 0.1) return faded;
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: faded,
        );
      },
    );
  }
}
