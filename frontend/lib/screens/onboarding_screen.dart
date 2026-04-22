import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/onboarding_steps.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<AuthProvider>().markOnboardingSeen();
    if (!mounted) return;
    context.go(Routes.dashboard);
  }

  void _next() {
    if (_index >= onboardingSteps.length - 1) {
      _finish();
      return;
    }
    _pc.nextPage(duration: Timings.pageTransition, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final username =
        context.watch<AuthProvider>().user?.username ?? Strings.aspirant;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Strings.appName,
                      style: KairosTheme.mono(
                          size: 11,
                          color: KairosColors.neutral700,
                          letterSpacing: 6)),
                  GestureDetector(
                    onTap: _finish,
                    child: Text(Strings.skip,
                        style: KairosTheme.mono(
                            size: 10,
                            color: KairosColors.neutral400,
                            letterSpacing: 4)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: onboardingSteps.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) =>
                    _Step(step: onboardingSteps[i], username: username),
              ),
            ),
            _Dots(count: onboardingSteps.length, index: _index),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _index >= onboardingSteps.length - 1
                          ? Strings.start
                          : Strings.nextStep,
                      style: KairosTheme.mono(
                        size: 12,
                        color: KairosColors.neutral900,
                        letterSpacing: 4,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final OnboardingStep step;
  final String username;
  const _Step({required this.step, required this.username});

  @override
  Widget build(BuildContext context) {
    final desc = step.description.replaceAll('{username}', username);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              border: Border.all(color: KairosColors.neutral700, width: 1),
              boxShadow: [
                BoxShadow(
                    color: KairosColors.neutral700.withValues(alpha: 0.18),
                    blurRadius: 40,
                    spreadRadius: 2)
              ],
            ),
            child:
                Icon(step.icon, color: KairosColors.neutral700, size: 34),
          ),
          const SizedBox(height: 44),
          Text(
              Strings.stepOf.replaceAll(
                  '{n}', step.step.toString().padLeft(2, '0')),
              style: KairosTheme.mono(
                  size: 10, color: KairosColors.neutral400, letterSpacing: 4)),
          const SizedBox(height: 14),
          Text(step.title,
              style: KairosTheme.serif(
                  size: 38,
                  weight: FontWeight.w300,
                  color: KairosColors.neutral50,
                  height: 1.1)),
          const SizedBox(height: 18),
          Text(desc,
              style: KairosTheme.serif(
                  size: 20,
                  weight: FontWeight.w300,
                  color: KairosColors.neutral50,
                  style: FontStyle.italic,
                  height: 1.4)),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: Timings.pageTransition,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 6,
          height: 2,
          color: active ? KairosColors.neutral700 : KairosColors.neutral300,
        );
      }),
    );
  }
}
