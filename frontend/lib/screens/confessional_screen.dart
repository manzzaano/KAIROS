import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../services/reflection_service.dart';
import '../utils/constants.dart';
import '../utils/debt_utils.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';
import '../widgets/debt_severity_card.dart';
import '../widgets/reflection_display.dart';

class ConfessionalScreen extends StatefulWidget {
  const ConfessionalScreen({super.key});

  @override
  State<ConfessionalScreen> createState() => _ConfessionalScreenState();
}

class _ConfessionalScreenState extends State<ConfessionalScreen> {
  final ReflectionService _reflectionService = ReflectionService();
  StreamSubscription<String>? _streamSub;

  String _reflection = '';
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchDebt();
    });
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  void _startReflection() {
    _streamSub?.cancel();
    setState(() {
      _reflection = '';
      _isStreaming = true;
    });

    final taskProvider = context.read<TaskProvider>();
    final recentAbandons =
        taskProvider.tasks.where((t) => t.abandoned).length;

    _streamSub = _reflectionService
        .streamReflection(
          totalDebtMinutes: taskProvider.debtTotalMinutes,
          streakDays: taskProvider.streakDays,
          sessionsCompleted: taskProvider.sessionsCompleted,
          recentAbandons: recentAbandons,
        )
        .listen(
          (chunk) {
            if (!mounted) return;
            setState(() => _reflection += chunk);
          },
          onError: (Object e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
            );
            setState(() => _isStreaming = false);
          },
          onDone: () {
            if (!mounted) return;
            setState(() => _isStreaming = false);
          },
        );
  }

  void _showPayDebtSheet() {
    final taskProvider = context.read<TaskProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KairosColors.neutral900,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: KairosColors.neutral700, width: 0.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _PayDebtSheet(
        debtMinutes: taskProvider.debtTotalMinutes,
        onConfirm: (minutes) async {
          Navigator.pop(context);
          final provider = context.read<TaskProvider>();
          await provider.payDebt(minutes);
          if (!mounted) return;
          if (provider.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(provider.error!)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '$minutes min pagados · Deuda restante: ${provider.debtTotalMinutes} min'),
            ));
          }
        },
      ),
    );
  }

  Map<String, String> _severity(TaskProvider provider) => analyzeDebtSeverity(
        totalDebtMinutes: provider.debtTotalMinutes,
        freeTimeMinutes: provider.freeTimeMinutes,
      );

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final severity = _severity(taskProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(Routes.dashboard),
          icon: const Icon(Icons.close, size: 20),
        ),
        title: Row(
          children: [
            Text('Ψ',
                style: KairosTheme.serif(
                    size: 18, color: KairosColors.neutral700)),
            const SizedBox(width: 12),
            Text(Strings.minos,
                style: KairosTheme.mono(
                    size: 13,
                    color: KairosColors.neutral50,
                    letterSpacing: 4)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            center: Alignment.topCenter,
            colors: [Color(0x336B1A1A), KairosColors.neutral900],
          ),
        ),
        child: Column(
          children: [
            _CaseStrip(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (taskProvider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(
                              color: KairosColors.error600, strokeWidth: 1),
                        ),
                      )
                    else
                      DebtSeverityCard(severity: {
                        ...severity,
                        'total_debt_minutes': taskProvider.debtTotalMinutes,
                      }),
                    const SizedBox(height: 20),
                    ReflectionDisplay(
                      text: _reflection,
                      isStreaming: _isStreaming,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _ActionBar(
              hasReflection: _reflection.isNotEmpty,
              isStreaming: _isStreaming,
              onGenerate: _startReflection,
              onPayDebt: _showPayDebtSheet,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _CaseStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: KairosColors.neutral900,
        border: Border(
            bottom: BorderSide(color: KairosColors.neutral300, width: 1)),
      ),
      child: Text(
        Strings.confessionalCase,
        style: KairosTheme.mono(
            size: 9, color: KairosColors.neutral700, letterSpacing: 3),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool hasReflection;
  final bool isStreaming;
  final VoidCallback onGenerate;
  final VoidCallback onPayDebt;

  const _ActionBar({
    required this.hasReflection,
    required this.isStreaming,
    required this.onGenerate,
    required this.onPayDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        border:
            Border(top: BorderSide(color: KairosColors.neutral700, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: isStreaming ? null : onGenerate,
              style: FilledButton.styleFrom(
                backgroundColor: KairosColors.neutral50,
                foregroundColor: KairosColors.neutral900,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              child: isStreaming
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: KairosColors.neutral900),
                    )
                  : Text(
                      hasReflection ? 'REGENERAR REFLEXIÓN' : 'GENERAR REFLEXIÓN',
                      style: KairosTheme.mono(
                          size: 11,
                          weight: FontWeight.w700,
                          color: KairosColors.neutral900,
                          letterSpacing: 2),
                    ),
            ),
          ),
          if (hasReflection && !isStreaming) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onPayDebt,
                style: FilledButton.styleFrom(
                  backgroundColor: KairosColors.error600,
                  foregroundColor: KairosColors.neutral50,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
                child: Text(
                  'PAGAR DEUDA',
                  style: KairosTheme.mono(
                      size: 11,
                      weight: FontWeight.w700,
                      color: KairosColors.neutral50,
                      letterSpacing: 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PayDebtSheet extends StatefulWidget {
  final int debtMinutes;
  final Future<void> Function(int minutes) onConfirm;

  const _PayDebtSheet({
    required this.debtMinutes,
    required this.onConfirm,
  });

  @override
  State<_PayDebtSheet> createState() => _PayDebtSheetState();
}

class _PayDebtSheetState extends State<_PayDebtSheet> {
  late final TextEditingController _ctrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.debtMinutes > 0 ? widget.debtMinutes.toString() : '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 28,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PAGAR DEUDA',
              style: KairosTheme.mono(size: 11, letterSpacing: 2)),
          const SizedBox(height: 6),
          Text('Deuda total: ${widget.debtMinutes} min',
              style: KairosTheme.serif(size: 14, color: KairosColors.neutral400)),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: KairosTheme.serif(size: 28),
            decoration: InputDecoration(
              hintText: 'Minutos',
              suffixText: 'MIN',
              hintStyle:
                  KairosTheme.serif(size: 28, color: KairosColors.neutral700),
              suffixStyle:
                  KairosTheme.mono(size: 9, color: KairosColors.neutral400),
              border: const UnderlineInputBorder(
                borderSide:
                    BorderSide(color: KairosColors.neutral700, width: 0.5),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide:
                    BorderSide(color: KairosColors.neutral700, width: 0.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide:
                    BorderSide(color: KairosColors.neutral400, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _loading
                  ? null
                  : () async {
                      final minutes = int.tryParse(_ctrl.text) ?? 0;
                      if (minutes <= 0) return;
                      setState(() => _loading = true);
                      try {
                        await widget.onConfirm(minutes);
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: KairosColors.error600,
                foregroundColor: KairosColors.neutral50,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: KairosColors.neutral50),
                    )
                  : Text('CONFIRMAR',
                      style: KairosTheme.mono(
                          size: 12,
                          weight: FontWeight.w700,
                          letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
