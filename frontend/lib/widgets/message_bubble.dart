import 'package:flutter/material.dart';

import '../utils/strings.dart';
import '../utils/theme.dart';

enum Speaker { minos, aspirant }

class MessageBubble extends StatelessWidget {
  final String text;
  final String timestamp;
  final Speaker speaker;

  const MessageBubble({
    super.key,
    required this.text,
    required this.timestamp,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    final isMinos = speaker == Speaker.minos;
    return Align(
      alignment: isMinos ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.fromLTRB(isMinos ? 16 : 12, 12, 12, 12),
          decoration: BoxDecoration(
            color: isMinos ? KairosColors.ink : Colors.transparent,
            border: isMinos
                ? const Border(left: BorderSide(color: KairosColors.bronze, width: 2))
                : Border.all(color: KairosColors.hairline, width: 1),
          ),
          child: Column(
            crossAxisAlignment: isMinos ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (isMinos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(Strings.minos, style: KairosTheme.mono(size: 9, color: KairosColors.bronze, letterSpacing: 3)),
                ),
              Text(
                text,
                textAlign: isMinos ? TextAlign.left : TextAlign.right,
                style: KairosTheme.serif(
                  size: 18,
                  color: KairosColors.bone,
                  style: isMinos ? FontStyle.normal : FontStyle.italic,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: 0.6,
                child: Text(
                  timestamp,
                  style: KairosTheme.mono(size: 9, color: KairosColors.muted, letterSpacing: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 18, top: 8, bottom: 8),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = ((_c.value + i * 0.22) % 1.0);
                final alpha = (0.2 + 0.8 * (1 - (phase - 0.5).abs() * 2)).clamp(0.2, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: KairosColors.bronze.withOpacity(alpha)),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
