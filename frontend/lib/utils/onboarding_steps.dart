import 'package:flutter/material.dart';

import 'strings.dart';

class OnboardingStep {
  final int step;
  final String title;
  final String description;
  final IconData icon;

  const OnboardingStep(this.step, this.title, this.description, this.icon);
}

const onboardingSteps = <OnboardingStep>[
  OnboardingStep(1, Strings.onboardingStep1Title, Strings.onboardingStep1Desc, Icons.person_outline),
  OnboardingStep(2, Strings.onboardingStep2Title, Strings.onboardingStep2Desc, Icons.list_alt),
  OnboardingStep(3, Strings.onboardingStep3Title, Strings.onboardingStep3Desc, Icons.visibility_outlined),
  OnboardingStep(4, Strings.onboardingStep4Title, Strings.onboardingStep4Desc, Icons.timer_outlined),
  OnboardingStep(5, Strings.onboardingStep5Title, Strings.onboardingStep5Desc, Icons.gavel_outlined),
];
