import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/focus_bloc.dart';
import '../bloc/focus_event.dart';
import '../bloc/focus_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Modo enfoque', style: AppTypography.heading18),
        centerTitle: false,
      ),
      body: BlocBuilder<FocusBloc, FocusState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular timer
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(300, 300),
                        painter: TimerArcPainter(
                          progress: _getProgress(state),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(state),
                            style: AppTypography.mono64,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _getLabel(state),
                            style: AppTypography.mono11.copyWith(color: AppColors.text3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      context,
                      icon: state is FocusRunning ? Icons.pause : Icons.play_arrow,
                      onPressed: () => context.read<FocusBloc>().add(const FocusTogglePause()),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _buildControlButton(
                      context,
                      icon: Icons.restart_alt,
                      onPressed: () => context.read<FocusBloc>().add(const FocusReset()),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(FocusState state) {
    int seconds = 0;
    if (state is FocusRunning) seconds = state.secondsLeft;
    if (state is FocusPaused) seconds = state.secondsLeft;

    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getLabel(FocusState state) {
    if (state is FocusIdle) return 'LISTO · POMODORO';
    if (state is FocusRunning) return 'ENFOQUE · ACTIVO';
    if (state is FocusPaused) return 'PAUSA · REANUDAR';
    if (state is FocusCompleted) return 'COMPLETADO · ¡BRAVO!';
    return '';
  }

  double _getProgress(FocusState state) {
    const totalSeconds = FocusBloc.pomodoroSeconds;
    int remaining = 0;

    if (state is FocusRunning) remaining = state.secondsLeft;
    if (state is FocusPaused) remaining = state.secondsLeft;
    if (state is FocusCompleted) remaining = 0;

    return 1.0 - (remaining.toDouble() / totalSeconds.toDouble());
  }

  Widget _buildControlButton(BuildContext context,
      {required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent,
        ),
        child: Icon(icon, color: AppColors.background, size: 28),
      ),
    );
  }
}

// CustomPainter for circular arc timer
class TimerArcPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  TimerArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.background3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      progress * 2 * 3.14159, // Sweep angle (full circle = 2π)
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
