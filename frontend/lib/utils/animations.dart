import 'package:flutter/material.dart';

abstract final class AnimationUtils {
  static Widget fadeScale({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (_, t, w) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.96 + 0.04 * t, child: w),
      ),
      child: child,
    );
  }

  static Widget slideFromBottom({
    required Widget child,
    Duration duration = const Duration(milliseconds: 360),
    Curve curve = Curves.easeOut,
    double offsetY = 24.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (_, t, w) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, offsetY * (1 - t)), child: w),
      ),
      child: child,
    );
  }

  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 900),
  }) {
    return _PulseWidget(duration: duration, child: child);
  }
}

class _PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const _PulseWidget({required this.child, required this.duration});

  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _anim, child: widget.child);
  }
}
