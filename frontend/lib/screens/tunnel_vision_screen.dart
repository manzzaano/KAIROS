import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';
import '../widgets/time_block.dart';

class TunnelVisionScreen extends StatelessWidget {
  const TunnelVisionScreen({super.key});

  static const _blocks = [
    _B('06:00', 'Despertar · inmersión fría', Strings.stateDischarged, TimeState.past),
    _B('07:30', 'Trabajo profundo · módulo auth', Strings.stateDischarged, TimeState.past),
    _B('09:00', 'Clasificar correspondencia', Strings.stateDischarged, TimeState.past),
    _B('10:30', 'Sincronía con el consejo', Strings.stateOngoing, TimeState.now),
    _B('12:00', 'Refactor · panel', Strings.statePending, TimeState.future),
    _B('14:00', 'Revisión · PR XLII', Strings.statePending, TimeState.future),
    _B('16:00', 'Entrenamiento · cuerpo', Strings.statePending, TimeState.future),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(),
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                      stops: [0.0, 0.15, 0.85, 1.0],
                    ).createShader(rect),
                    blendMode: BlendMode.dstIn,
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: _blocks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => TimeBlock(
                        time: _blocks[i].time,
                        title: _blocks[i].title,
                        meta: _blocks[i].meta,
                        state: _blocks[i].state,
                      ),
                    ),
                  ),
                ),
                _BottomBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _B {
  final String time, title, meta;
  final TimeState state;
  const _B(this.time, this.title, this.meta, this.state);
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Strings.tunnel, style: KairosTheme.mono(size: 11, color: KairosColors.neutral700, letterSpacing: 6)),
              GestureDetector(
                onTap: () => context.go(Routes.dashboard),
                child: Text(Strings.tunnelClose,
                    style: KairosTheme.mono(size: 10, color: KairosColors.neutral400, letterSpacing: 3)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('MARTES · 22 DE ABR, MMXXVI',
              style: KairosTheme.serif(size: 18, color: KairosColors.neutral50)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Strings.tunnelNow,
                  style: KairosTheme.mono(size: 10, color: KairosColors.neutral700, letterSpacing: 4)),
              const SizedBox(width: 12),
              Text('10:47',
                  style: KairosTheme.mono(size: 44, color: KairosColors.neutral50, letterSpacing: 2, weight: FontWeight.w300)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget btn(String label, {VoidCallback? onTap, bool primary = false}) => Expanded(
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: primary ? KairosColors.neutral700 : Colors.transparent,
                border: const Border(top: BorderSide(color: KairosColors.neutral300, width: 1)),
              ),
              child: Center(
                child: Text(
                  label,
                  style: KairosTheme.mono(
                    size: 11,
                    color: primary ? KairosColors.neutral900 : KairosColors.neutral50,
                    letterSpacing: 4,
                    weight: primary ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
    return Row(
      children: [
        btn(Strings.pause),
        btn(Strings.discharge, primary: true),
        btn(Strings.next, onTap: () => context.go(Routes.focus)),
      ],
    );
  }
}
