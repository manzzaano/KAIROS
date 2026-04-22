import 'package:flutter/material.dart';

import '../utils/theme.dart';

class DebtSeverityCard extends StatelessWidget {
  final Map<String, dynamic> severity;

  const DebtSeverityCard({super.key, required this.severity});

  Color _levelColor(String colorKey) {
    switch (colorKey) {
      case 'error600':
        return KairosColors.error600;
      case 'neutral400':
        return KairosColors.neutral400;
      default:
        return KairosColors.neutral50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorKey = severity['color'] as String? ?? 'neutral50';
    final message = severity['message'] as String? ?? '';
    final totalDebt = severity['total_debt_minutes'] as int? ?? 0;
    final debtHours = totalDebt ~/ 60;
    final debtMinutes = totalDebt % 60;
    final color = _levelColor(colorKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.toUpperCase(),
            style: KairosTheme.mono(size: 9, color: color, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            '${debtHours}H ${debtMinutes.toString().padLeft(2, '0')}M',
            style: KairosTheme.serif(
                size: 52, weight: FontWeight.w300, color: color, height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalDebt minutos de deuda acumulada',
            style: KairosTheme.mono(
                size: 9, color: KairosColors.neutral400, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
