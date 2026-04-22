import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/theme.dart';

const _romans = ['', 'I', 'II', 'III', 'IV', 'V'];

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<Task> onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  Color _priorityColor() {
    switch (task.priority) {
      case 3:
        return KairosColors.blood;
      case 2:
        return KairosColors.bronze;
      default:
        return KairosColors.muted;
    }
  }

  void _toggle() => onToggle(task.copyWith(completed: !task.completed));

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor();
    final energy = _romans[task.energy.clamp(0, 5)];
    final done = task.completed;

    return InkWell(
      onTap: _toggle,
      splashColor: KairosColors.bronze.withOpacity(0.12),
      highlightColor: KairosColors.hairline.withOpacity(0.4),
      hoverColor: KairosColors.ink,
      child: Container(
        decoration: BoxDecoration(
          color: KairosColors.charcoal,
          border: Border(
            left: BorderSide(color: color, width: 3),
            bottom: const BorderSide(color: KairosColors.hairline, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: done,
                onChanged: (_) => _toggle(),
                activeColor: KairosColors.bronze,
                checkColor: KairosColors.black,
                side: const BorderSide(color: KairosColors.muted, width: 1),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                task.title,
                style: KairosTheme.serif(
                  size: 20,
                  color: done ? KairosColors.muted : KairosColors.bone,
                  style: done ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('P${task.priority}', style: KairosTheme.mono(size: 10, color: color, letterSpacing: 1)),
            const SizedBox(width: 12),
            Text(energy, style: KairosTheme.mono(size: 11, color: KairosColors.bronze, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
