import 'package:flutter/material.dart';

import '../utils/theme.dart';

class ReflectionDisplay extends StatefulWidget {
  final String text;
  final bool isStreaming;

  const ReflectionDisplay({
    super.key,
    required this.text,
    this.isStreaming = false,
  });

  @override
  State<ReflectionDisplay> createState() => _ReflectionDisplayState();
}

class _ReflectionDisplayState extends State<ReflectionDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursorCtrl;
  late final Animation<double> _cursorAnim;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _cursorAnim = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _cursorCtrl, curve: Curves.easeInOut),
    );
    if (widget.isStreaming) _cursorCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ReflectionDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !_cursorCtrl.isAnimating) {
      _cursorCtrl.repeat(reverse: true);
    } else if (!widget.isStreaming && _cursorCtrl.isAnimating) {
      _cursorCtrl.stop();
      _cursorCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty && !widget.isStreaming) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border:
              Border.all(color: KairosColors.neutral700, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Presiona GENERAR REFLEXIÓN\npara recibir tu valoración estoica.',
          style: KairosTheme.serif(
              size: 14,
              color: KairosColors.neutral700,
              style: FontStyle.italic),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: KairosColors.neutral700, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: KairosTheme.serif(size: 15, height: 1.65),
          ),
          if (widget.isStreaming) ...[
            const SizedBox(height: 4),
            FadeTransition(
              opacity: _cursorAnim,
              child: Text(
                '▌',
                style: KairosTheme.serif(
                    size: 18, color: KairosColors.neutral400),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
