import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class ProfileStatsScreen extends StatefulWidget {
  const ProfileStatsScreen({super.key});

  @override
  State<ProfileStatsScreen> createState() => _ProfileStatsScreenState();
}

class _ProfileStatsScreenState extends State<ProfileStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<TaskProvider>();
      p.fetchDebt();
      p.fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();

    final debtHours = p.debtHours;
    final debtMinutes = p.debtMinutes;
    final streakDays = p.streakDays;
    final sessionsCompleted = p.sessionsCompleted;
    final debtColor =
        debtHours > 10 ? KairosColors.error600 : KairosColors.neutral50;
    final dailyStats =
        p.debt != null ? p.computeDailyStats() : _kFallbackStats;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ESTADÍSTICAS',
          style: KairosTheme.mono(size: 11, letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: p.isLoading && p.debt == null
            ? const Center(
                child: CircularProgressIndicator(
                    color: KairosColors.neutral700, strokeWidth: 1))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _StatCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${debtHours}H ${debtMinutes.toString().padLeft(2, '0')}M',
                            style: KairosTheme.serif(
                                size: 64,
                                weight: FontWeight.w300,
                                color: debtColor,
                                height: 1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'DEUDA ACUMULADA',
                            style: KairosTheme.mono(
                                size: 9,
                                color: KairosColors.neutral400,
                                letterSpacing: 2),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                '$sessionsCompleted',
                                style: KairosTheme.serif(
                                    size: 20, weight: FontWeight.w300),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SESIONES COMPLETADAS',
                                style: KairosTheme.mono(
                                    size: 9,
                                    color: KairosColors.neutral400,
                                    letterSpacing: 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_fire_department_outlined,
                              color: KairosColors.error600, size: 28),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$streakDays días sin rendirse',
                                style: KairosTheme.serif(
                                    size: 24, weight: FontWeight.w300),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'RACHA ACTIVA',
                                style: KairosTheme.mono(
                                    size: 9,
                                    color: KairosColors.neutral400,
                                    letterSpacing: 2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ÚLTIMOS 7 DÍAS',
                      style: KairosTheme.mono(
                          size: 9,
                          color: KairosColors.neutral400,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 12),
                    _DailyChart(stats: dailyStats),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        _ChartLegend(
                            color: KairosColors.neutral400,
                            label: 'COMPLETADAS'),
                        SizedBox(width: 16),
                        _ChartLegend(
                            color: KairosColors.error600,
                            label: 'ABANDONADAS'),
                      ],
                    ),
                    if (p.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          p.error!,
                          style: KairosTheme.mono(
                              size: 9,
                              color: KairosColors.error600,
                              letterSpacing: 1),
                        ),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed:
                            p.isLoading ? null : () => context.go(Routes.confessional),
                        style: FilledButton.styleFrom(
                          backgroundColor: KairosColors.error600,
                          foregroundColor: KairosColors.neutral50,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          'PAGAR DEUDA',
                          style: KairosTheme.mono(
                              size: 12,
                              weight: FontWeight.w700,
                              color: KairosColors.neutral50,
                              letterSpacing: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }
}

const _kFallbackStats = [
  {'completed': 0, 'abandoned': 0},
  {'completed': 0, 'abandoned': 0},
  {'completed': 0, 'abandoned': 0},
  {'completed': 0, 'abandoned': 0},
  {'completed': 0, 'abandoned': 0},
  {'completed': 0, 'abandoned': 0},
  {'completed': 0, 'abandoned': 0},
];

class _StatCard extends StatelessWidget {
  const _StatCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: KairosColors.neutral700, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: KairosTheme.mono(
              size: 8, color: KairosColors.neutral400, letterSpacing: 1),
        ),
      ],
    );
  }
}

class _DailyChart extends StatelessWidget {
  const _DailyChart({required this.stats});
  final List<Map<String, int>> stats;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: CustomPaint(painter: _BarChartPainter(stats: stats)),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({required this.stats});
  final List<Map<String, int>> stats;

  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _maxTasks = 5;
  static const _labelHeight = 24.0;
  static const _barGap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;
    final chartH = size.height - _labelHeight;
    final barW = (size.width / stats.length) - _barGap;

    final completedPaint = Paint()
      ..color = KairosColors.neutral400
      ..style = PaintingStyle.fill;
    final abandonedPaint = Paint()
      ..color = KairosColors.error600
      ..style = PaintingStyle.fill;
    final axisPaint = Paint()
      ..color = KairosColors.neutral700
      ..strokeWidth = 0.5;

    canvas.drawLine(Offset(0, chartH), Offset(size.width, chartH), axisPaint);

    for (var i = 0; i < stats.length; i++) {
      final x = i * (barW + _barGap);
      final completed = stats[i]['completed'] ?? 0;
      final abandoned = stats[i]['abandoned'] ?? 0;

      final completedH =
          (completed / _maxTasks).clamp(0.0, 1.0) * chartH;
      final abandonedH =
          (abandoned / _maxTasks).clamp(0.0, 1.0) * chartH;

      if (completedH > 0) {
        canvas.drawRect(
          Rect.fromLTWH(x, chartH - completedH, barW, completedH),
          completedPaint,
        );
      }
      if (abandonedH > 0) {
        canvas.drawRect(
          Rect.fromLTWH(
              x + barW / 2, chartH - abandonedH, barW / 2, abandonedH),
          abandonedPaint,
        );
      }

      final tp = TextPainter(
        text: TextSpan(
          text: i < _labels.length ? _labels[i] : '',
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 9,
            color: KairosColors.neutral400,
            letterSpacing: 0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + barW / 2 - tp.width / 2, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => old.stats != stats;
}
