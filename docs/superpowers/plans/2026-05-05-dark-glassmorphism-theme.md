# Dark Glassmorphism Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the Dark Glassmorphism design system (`diseño_nuevo/theme.json`) to all Flutter screens, replacing solid surfaces with glass/blur effects and updating color tokens.

**Architecture:** Extend the existing `KairosColors` ThemeExtension with new glass tokens (`glowCool`, `glowWarm`) and updated values. Add two new shared widgets (`GlassCard`, `KairosBackground`) and a new shape constants file. Update all page Scaffolds and widget containers to use the new system.

**Tech Stack:** Flutter/Dart, `dart:ui` (ImageFilter.blur), BackdropFilter, ThemeExtension, BLoC

---

## File Map

| File | Action |
|---|---|
| `lib/core/constants/app_shapes.dart` | CREATE — shape radius constants |
| `lib/core/constants/app_colors.dart` | MODIFY — update static constants |
| `lib/core/theme/kairos_colors.dart` | MODIFY — add glowCool/glowWarm, update dark/light values |
| `lib/core/theme/theme_cubit.dart` | MODIFY — default accent → glowCool |
| `lib/core/theme/app_theme.dart` | MODIFY — pill input, elevatedButton theme |
| `lib/shared/widgets/glass_card.dart` | CREATE — glass surface widget |
| `lib/shared/widgets/kairos_background.dart` | CREATE — radial glow background |
| `lib/shared/widgets/task_card.dart` | MODIFY — Container → GlassCard |
| `lib/shared/widgets/priority_chip.dart` | MODIFY — borderRadius 8 → pill |
| `lib/shared/widgets/fab_kairos.dart` | MODIFY — StadiumBorder + blur |
| `lib/features/app/presentation/pages/app_shell.dart` | MODIFY — floating glass pill nav bar |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart` | MODIFY — KairosBackground + glass energy card |
| `lib/features/focus/presentation/pages/focus_page.dart` | MODIFY — KairosBackground + GlassCard task cards |
| `lib/features/focus/presentation/pages/focus_timer_page.dart` | MODIFY — KairosBackground + pill buttons |
| `lib/features/profile/presentation/pages/profile_page.dart` | MODIFY — KairosBackground + rounded containers + accent options |
| `test/core/theme/kairos_colors_test.dart` | CREATE — token value tests |
| `test/shared/widgets/glass_card_test.dart` | CREATE — widget render tests |
| `test/shared/widgets/kairos_background_test.dart` | CREATE — widget render tests |

---

## Task 1: AppShapes constants + AppColors update

**Files:**
- Create: `lib/core/constants/app_shapes.dart`
- Modify: `lib/core/constants/app_colors.dart`

- [ ] **Step 1: Create `app_shapes.dart`**

```dart
abstract class AppShapes {
  static const double pill = 9999;
  static const double rounded = 24;
  static const double roundedSm = 16;
  static const double roundedXs = 12;
}
```

- [ ] **Step 2: Update `app_colors.dart`**

Replace the entire file content with:

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  static const background = Color(0xFF050505);
  static const background1 = Color(0xFF0A0A0A);
  static const background2 = Color(0x08FFFFFF);
  static const background3 = Color(0x14FFFFFF);
  static const line = Color(0x26FFFFFF);
  static const line2 = Color(0x66FFFFFF);
  static const text = Color(0xFFFAFAFA);
  static const text2 = Color(0xFFA3A3A3);
  static const text3 = Color(0xFF525252);
  static const text4 = Color(0xFF404040);
  static const accent = Color(0xFFA0B9D2);
  static const accent2 = Color(0xFFF0E6D7);
  static const accentSoft = Color(0x1FA0B9D2);
  static const glowCool = Color(0x80A0B9D2);
  static const glowWarm = Color(0x80F0E6D7);
  static const success = Color(0xFF4ADE80);
  static const danger = Color(0xFFF87171);
  static const warning = Color(0xFFFACC15);
}
```

- [ ] **Step 3: Analyze**

```
cd kairos && flutter analyze lib/core/constants/
```

Expected: no errors.

- [ ] **Step 4: Commit**

```
git add kairos/lib/core/constants/app_shapes.dart kairos/lib/core/constants/app_colors.dart
git commit -m "feat(theme): add AppShapes constants and update AppColors to glassmorphism values"
```

---

## Task 2: KairosColors — new tokens + updated dark/light values

**Files:**
- Modify: `lib/core/theme/kairos_colors.dart`
- Create: `test/core/theme/kairos_colors_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/core/theme/kairos_colors_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/core/theme/kairos_colors.dart';

void main() {
  group('KairosColors.dark', () {
    late KairosColors kc;
    setUp(() => kc = KairosColors.dark(const Color(0xFFA0B9D2)));

    test('bg is #050505', () => expect(kc.bg, const Color(0xFF050505)));
    test('bg2 is glass surface 3%', () => expect(kc.bg2, const Color(0x08FFFFFF)));
    test('bg3 is glass hover 8%', () => expect(kc.bg3, const Color(0x14FFFFFF)));
    test('line is borderLight 15%', () => expect(kc.line, const Color(0x26FFFFFF)));
    test('line2 is borderHighlight 40%', () => expect(kc.line2, const Color(0x66FFFFFF)));
    test('glowCool is cool ambient', () => expect(kc.glowCool, const Color(0x80A0B9D2)));
    test('glowWarm is warm ambient', () => expect(kc.glowWarm, const Color(0x80F0E6D7)));
  });

  group('KairosColors.light', () {
    late KairosColors kc;
    setUp(() => kc = KairosColors.light(const Color(0xFF5A7A9A)));

    test('bg is #FAFAFA', () => expect(kc.bg, const Color(0xFFFAFAFA)));
    test('bg2 is frosted 70%', () => expect(kc.bg2, const Color(0xB3FFFFFF)));
    test('glowCool light is 25%', () => expect(kc.glowCool, const Color(0x40A0B9D2)));
    test('glowWarm light is 25%', () => expect(kc.glowWarm, const Color(0x40F0E6D7)));
  });

  group('KairosColors copyWith preserves glowCool/glowWarm', () {
    test('copyWith returns updated glowCool', () {
      final kc = KairosColors.dark(const Color(0xFFA0B9D2));
      final updated = kc.copyWith(glowCool: Colors.red);
      expect(updated.glowCool, Colors.red);
      expect(updated.bg, kc.bg);
    });
  });
}
```

- [ ] **Step 2: Run test — expect failure**

```
cd kairos && flutter test test/core/theme/kairos_colors_test.dart
```

Expected: FAIL — `glowCool` does not exist on `KairosColors`.

- [ ] **Step 3: Update `kairos_colors.dart`**

Replace entire file with:

```dart
import 'package:flutter/material.dart';

@immutable
class KairosColors extends ThemeExtension<KairosColors> {
  final Color accent;
  final Color accent2;
  final Color accentSoft;
  final Color bg;
  final Color bg2;
  final Color bg3;
  final Color line;
  final Color line2;
  final Color text;
  final Color text2;
  final Color text3;
  final Color text4;
  final Color glowCool;
  final Color glowWarm;
  final Color success;
  final Color danger;
  final Color warning;

  const KairosColors({
    required this.accent,
    required this.accent2,
    required this.accentSoft,
    required this.bg,
    required this.bg2,
    required this.bg3,
    required this.line,
    required this.line2,
    required this.text,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.glowCool,
    required this.glowWarm,
    required this.success,
    required this.danger,
    required this.warning,
  });

  factory KairosColors.dark(Color accent) => KairosColors(
        accent: accent,
        accent2: const Color(0xFFF0E6D7),
        accentSoft: accent.withValues(alpha: 0.12),
        bg: const Color(0xFF050505),
        bg2: const Color(0x08FFFFFF),
        bg3: const Color(0x14FFFFFF),
        line: const Color(0x26FFFFFF),
        line2: const Color(0x66FFFFFF),
        text: const Color(0xFFFAFAFA),
        text2: const Color(0xFFA3A3A3),
        text3: const Color(0xFF525252),
        text4: const Color(0xFF404040),
        glowCool: const Color(0x80A0B9D2),
        glowWarm: const Color(0x80F0E6D7),
        success: const Color(0xFF4ADE80),
        danger: const Color(0xFFF87171),
        warning: const Color(0xFFFACC15),
      );

  factory KairosColors.light(Color accent) => KairosColors(
        accent: accent,
        accent2: const Color(0xFF8A7060),
        accentSoft: accent.withValues(alpha: 0.12),
        bg: const Color(0xFFFAFAFA),
        bg2: const Color(0xB3FFFFFF),
        bg3: const Color(0x80FFFFFF),
        line: const Color(0x14000000),
        line2: const Color(0x40000000),
        text: const Color(0xFF0A0A0A),
        text2: const Color(0xFF525252),
        text3: const Color(0xFF909090),
        text4: const Color(0xFFBBBBBB),
        glowCool: const Color(0x40A0B9D2),
        glowWarm: const Color(0x40F0E6D7),
        success: const Color(0xFF16A34A),
        danger: const Color(0xFFDC2626),
        warning: const Color(0xFFD97706),
      );

  static KairosColors of(BuildContext context) =>
      Theme.of(context).extension<KairosColors>()!;

  @override
  KairosColors copyWith({
    Color? accent,
    Color? accent2,
    Color? accentSoft,
    Color? bg,
    Color? bg2,
    Color? bg3,
    Color? line,
    Color? line2,
    Color? text,
    Color? text2,
    Color? text3,
    Color? text4,
    Color? glowCool,
    Color? glowWarm,
    Color? success,
    Color? danger,
    Color? warning,
  }) =>
      KairosColors(
        accent: accent ?? this.accent,
        accent2: accent2 ?? this.accent2,
        accentSoft: accentSoft ?? this.accentSoft,
        bg: bg ?? this.bg,
        bg2: bg2 ?? this.bg2,
        bg3: bg3 ?? this.bg3,
        line: line ?? this.line,
        line2: line2 ?? this.line2,
        text: text ?? this.text,
        text2: text2 ?? this.text2,
        text3: text3 ?? this.text3,
        text4: text4 ?? this.text4,
        glowCool: glowCool ?? this.glowCool,
        glowWarm: glowWarm ?? this.glowWarm,
        success: success ?? this.success,
        danger: danger ?? this.danger,
        warning: warning ?? this.warning,
      );

  @override
  KairosColors lerp(KairosColors? other, double t) {
    if (other is! KairosColors) return this;
    return KairosColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accent2: Color.lerp(accent2, other.accent2, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      bg3: Color.lerp(bg3, other.bg3, t)!,
      line: Color.lerp(line, other.line, t)!,
      line2: Color.lerp(line2, other.line2, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      text4: Color.lerp(text4, other.text4, t)!,
      glowCool: Color.lerp(glowCool, other.glowCool, t)!,
      glowWarm: Color.lerp(glowWarm, other.glowWarm, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension KairosThemeX on BuildContext {
  KairosColors get kc => KairosColors.of(this);
}
```

- [ ] **Step 4: Run test — expect pass**

```
cd kairos && flutter test test/core/theme/kairos_colors_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Full analyze**

```
cd kairos && flutter analyze
```

Expected: No errors. If `KairosColors` had `text4` removed — check it's referenced nowhere; it's in the `copyWith` and `lerp` still. If any widget uses a removed field, fix the reference.

Note: `KairosColors` no longer has `text4` field! Add it back:

Actually — `text4` IS removed from the new design. But `dashboard_page.dart` uses `kc.text4` on line 223 of focus_timer_page:
```dart
Text('NOTIFS PAUSADAS · +12 PUNTOS', style: AppTypography.mono11.copyWith(color: kc.text4)),
```

Keep `text4` in the new `KairosColors` (it's already included in the spec above at `Color(0xFF404040)` dark, `Color(0xFFBBBBBB)` light). ✓

- [ ] **Step 6: Commit**

```
git add kairos/lib/core/theme/kairos_colors.dart kairos/test/core/theme/kairos_colors_test.dart
git commit -m "feat(theme): add glowCool/glowWarm tokens and update KairosColors to glassmorphism values"
```

---

## Task 3: ThemeCubit default accent + AppTheme pill updates

**Files:**
- Modify: `lib/core/theme/theme_cubit.dart`
- Modify: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Update ThemeCubit default accent**

In `theme_cubit.dart`, change:
```dart
// line 20: ThemeCubit() : super(const ThemeState(mode: ThemeMode.dark, accent: Color(0xFFFB923C)));
// line 25: final accentVal = prefs.getInt(_accentKey) ?? 0xFFFB923C;
```
To:
```dart
ThemeCubit()
    : super(const ThemeState(
          mode: ThemeMode.dark, accent: Color(0xFFA0B9D2)));

// in load():
final accentVal = prefs.getInt(_accentKey) ?? 0xFFA0B9D2;
```

- [ ] **Step 2: Update AppTheme**

Replace `app_theme.dart` with:

```dart
import 'package:flutter/material.dart';
import 'kairos_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_shapes.dart';

class AppTheme {
  static ThemeData dark(Color accent) =>
      _build(Brightness.dark, KairosColors.dark(accent));

  static ThemeData light(Color accent) =>
      _build(Brightness.light, KairosColors.light(accent));

  static ThemeData _build(Brightness brightness, KairosColors kc) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: kc.bg,
        extensions: [kc],
        colorScheme: ColorScheme(
          brightness: brightness,
          primary: kc.accent,
          onPrimary: brightness == Brightness.dark
              ? const Color(0xFF050505)
              : Colors.white,
          secondary: kc.accent2,
          onSecondary:
              brightness == Brightness.dark ? Colors.black : Colors.white,
          surface: kc.bg2,
          onSurface: kc.text,
          error: kc.danger,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: kc.text),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kc.bg2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppShapes.pill),
            borderSide: BorderSide(color: kc.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppShapes.pill),
            borderSide: BorderSide(color: kc.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppShapes.pill),
            borderSide: BorderSide(color: kc.accent, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          hintStyle: AppTypography.body13.copyWith(color: kc.text3),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(kc.accent),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: kc.accent,
          inactiveTrackColor: kc.bg3,
          thumbColor: kc.accent,
          overlayColor: kc.accent.withValues(alpha: 0.12),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? kc.accent : kc.text3),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? kc.accentSoft : kc.bg3),
        ),
        dividerColor: kc.line,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          indicatorColor: kc.bg3,
          labelTextStyle: WidgetStateProperty.all(
            AppTypography.caption12.copyWith(color: kc.text),
          ),
        ),
      );
}
```

- [ ] **Step 3: Analyze**

```
cd kairos && flutter analyze lib/core/theme/
```

Expected: No errors.

- [ ] **Step 4: Commit**

```
git add kairos/lib/core/theme/theme_cubit.dart kairos/lib/core/theme/app_theme.dart
git commit -m "feat(theme): update default accent to glowCool and apply pill shape to inputs/buttons"
```

---

## Task 4: GlassCard widget

**Files:**
- Create: `lib/shared/widgets/glass_card.dart`
- Create: `test/shared/widgets/glass_card_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/shared/widgets/glass_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/core/theme/app_theme.dart';
import 'package:kairos/shared/widgets/glass_card.dart';

void main() {
  testWidgets('GlassCard renders child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(const Color(0xFFA0B9D2)),
        home: const Scaffold(
          body: GlassCard(child: Text('hello')),
        ),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);
  });

  testWidgets('GlassCard uses custom padding', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(const Color(0xFFA0B9D2)),
        home: const Scaffold(
          body: GlassCard(
            padding: EdgeInsets.all(8),
            child: Text('padded'),
          ),
        ),
      ),
    );
    expect(find.text('padded'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test — expect failure**

```
cd kairos && flutter test test/shared/widgets/glass_card_test.dart
```

Expected: FAIL — `GlassCard` does not exist.

- [ ] **Step 3: Create `glass_card.dart`**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_shapes.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final radius =
        borderRadius ?? BorderRadius.circular(AppShapes.rounded);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: kc.bg2,
              borderRadius: radius,
              border: Border.all(color: kc.line),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test — expect pass**

```
cd kairos && flutter test test/shared/widgets/glass_card_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```
git add kairos/lib/shared/widgets/glass_card.dart kairos/test/shared/widgets/glass_card_test.dart
git commit -m "feat(widgets): add GlassCard glassmorphism surface widget"
```

---

## Task 5: KairosBackground widget

**Files:**
- Create: `lib/shared/widgets/kairos_background.dart`
- Create: `test/shared/widgets/kairos_background_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/shared/widgets/kairos_background_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/core/theme/app_theme.dart';
import 'package:kairos/shared/widgets/kairos_background.dart';

void main() {
  testWidgets('KairosBackground renders child without glows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(const Color(0xFFA0B9D2)),
        home: KairosBackground(child: const Text('content')),
      ),
    );
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('KairosBackground renders child with glows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(const Color(0xFFA0B9D2)),
        home: KairosBackground(
          withGlows: true,
          child: const Text('glow content'),
        ),
      ),
    );
    expect(find.text('glow content'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test — expect failure**

```
cd kairos && flutter test test/shared/widgets/kairos_background_test.dart
```

Expected: FAIL — `KairosBackground` does not exist.

- [ ] **Step 3: Create `kairos_background.dart`**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';

class KairosBackground extends StatelessWidget {
  final Widget child;
  final bool withGlows;

  const KairosBackground({
    required this.child,
    this.withGlows = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: kc.bg)),
        if (withGlows) ...[
          Positioned(
            top: -120,
            left: -120,
            child: SizedBox(
              width: 500,
              height: 500,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [kc.glowCool, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: SizedBox(
              width: 500,
              height: 500,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [kc.glowWarm, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
        ],
        child,
      ],
    );
  }
}
```

- [ ] **Step 4: Run test — expect pass**

```
cd kairos && flutter test test/shared/widgets/kairos_background_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```
git add kairos/lib/shared/widgets/kairos_background.dart kairos/test/shared/widgets/kairos_background_test.dart
git commit -m "feat(widgets): add KairosBackground with optional dual radial glows"
```

---

## Task 6: TaskCard + PriorityChip glass updates

**Files:**
- Modify: `lib/shared/widgets/task_card.dart`
- Modify: `lib/shared/widgets/priority_chip.dart`

- [ ] **Step 1: Update TaskCard — Container → GlassCard**

Replace `task_card.dart` with:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/tasks/domain/entities/task.dart';
import 'glass_card.dart';
import 'priority_chip.dart';
import 'energy_dots.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const TaskCard({
    required this.task,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTypography.body15.copyWith(
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? kc.text3 : kc.text,
                        ),
                      ),
                      if (task.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            task.description!,
                            style: AppTypography.caption12
                                .copyWith(color: kc.text3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                Checkbox(
                  value: task.isDone,
                  onChanged: (_) => onToggle?.call(),
                  fillColor: WidgetStateProperty.all(kc.accent),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriorityChip(priority: task.priority),
                EnergyDots(level: task.energyLevel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update PriorityChip — pill border radius + use AppShapes**

Replace `priority_chip.dart` with:

```dart
import 'package:flutter/material.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_shapes.dart';
import '../../features/tasks/domain/entities/task.dart';

class PriorityChip extends StatelessWidget {
  final Priority priority;
  const PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final colors = {
      Priority.high: {
        'bg': const Color(0x1FF87171),
        'fg': const Color(0xFFF87171),
        'label': 'Alta'
      },
      Priority.medium: {
        'bg': const Color(0x1FFACC15),
        'fg': const Color(0xFFFACC15),
        'label': 'Media'
      },
      Priority.low: {
        'bg': const Color(0x14525252),
        'fg': const Color(0xFF525252),
        'label': 'Baja'
      },
    };

    final config = colors[priority]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(AppShapes.pill),
      ),
      child: Text(
        config['label'] as String,
        style: AppTypography.caption12.copyWith(color: config['fg'] as Color),
      ),
    );
  }
}
```

- [ ] **Step 3: Analyze**

```
cd kairos && flutter analyze lib/shared/widgets/
```

Expected: No errors.

- [ ] **Step 4: Commit**

```
git add kairos/lib/shared/widgets/task_card.dart kairos/lib/shared/widgets/priority_chip.dart
git commit -m "feat(widgets): apply GlassCard to TaskCard and pill shape to PriorityChip"
```

---

## Task 7: FABKairos — pill + blur

**Files:**
- Modify: `lib/shared/widgets/fab_kairos.dart`

- [ ] **Step 1: Update FABKairos**

Replace `fab_kairos.dart` with:

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';

class FABKairos extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const FABKairos({required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: kc.accent.withValues(alpha: 0.9),
          elevation: 0,
          shape: const StadiumBorder(),
          child: Icon(icon, color: kc.bg),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
cd kairos && flutter analyze lib/shared/widgets/fab_kairos.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```
git add kairos/lib/shared/widgets/fab_kairos.dart
git commit -m "feat(widgets): apply pill shape and backdrop blur to FABKairos"
```

---

## Task 8: AppShell — floating glass pill nav bar

**Files:**
- Modify: `lib/features/app/presentation/pages/app_shell.dart`

- [ ] **Step 1: Replace AppShell**

Replace `app_shell.dart` with:

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_shapes.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      extendBody: true,
      backgroundColor: kc.bg,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: _GlassNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home, 'Hoy'),
    _NavItem(Icons.list_outlined, Icons.list, 'Tareas'),
    _NavItem(Icons.timer_outlined, Icons.timer, 'Enfoque'),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Stats'),
    _NavItem(Icons.person_outline, Icons.person, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppShapes.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppShapes.pill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: kc.bg2,
              borderRadius: BorderRadius.circular(AppShapes.pill),
              border: Border.all(color: kc.line),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final active = i == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 56,
                    height: 64,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          active ? item.activeIcon : item.icon,
                          color: active ? kc.accent : kc.text3,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: active ? kc.accent : kc.text3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
```

- [ ] **Step 2: Analyze**

```
cd kairos && flutter analyze lib/features/app/
```

Expected: No errors.

- [ ] **Step 3: Commit**

```
git add kairos/lib/features/app/presentation/pages/app_shell.dart
git commit -m "feat(shell): replace BottomNavigationBar with floating glass pill nav bar"
```

---

## Task 9: DashboardPage — KairosBackground + glass energy card

**Files:**
- Modify: `lib/features/dashboard/presentation/pages/dashboard_page.dart`

- [ ] **Step 1: Update DashboardPage**

Make these changes to `dashboard_page.dart`:

1. Add import at top:
```dart
import '../../../../shared/widgets/kairos_background.dart';
import '../../../../shared/widgets/glass_card.dart';
```

2. In `build()`, change Scaffold:
```dart
// Before:
return Scaffold(
  backgroundColor: kc.bg,
  body: BlocBuilder<TaskBloc, TaskState>(
    builder: (context, state) {
      ...
      return SafeArea(
        child: CustomScrollView(
```

// After:
```dart
return Scaffold(
  backgroundColor: Colors.transparent,
  body: KairosBackground(
    withGlows: true,
    child: BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        ...
        return SafeArea(
          child: CustomScrollView(
```

Close the extra `KairosBackground` child properly — add `)` before the `floatingActionButton:` parameter.

3. Replace the energy card Container (lines 96-139 of original) with a `GlassCard`:
```dart
// Replace:
Container(
  padding: const EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    color: kc.bg2,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: kc.line),
  ),
  child: Column(...),
)

// With:
GlassCard(
  padding: const EdgeInsets.all(AppSpacing.lg),
  child: Column(...),
)
```

Full updated `dashboard_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/task_card.dart';
import '../../../../shared/widgets/fab_kairos.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/kairos_background.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasksRequested());
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 13) return 'Buenos días, Ismael';
    if (h < 20) return 'Buenas tardes, Ismael';
    return 'Buenas noches, Ismael';
  }

  String _dateLabel() {
    const days = [
      'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO', 'DOMINGO'
    ];
    const months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} DE ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KairosBackground(
        withGlows: true,
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return Center(
                  child: CircularProgressIndicator(color: kc.accent));
            }
            if (state is TaskError) {
              return Center(
                  child: Text(state.message,
                      style: TextStyle(color: kc.danger)));
            }

            final tasks =
                state is TaskLoaded ? state.tasks : <Task>[];
            final pending = tasks.where((t) => !t.isDone).toList();
            final done = tasks.where((t) => t.isDone).toList();
            final totalEnergy =
                pending.fold<int>(0, (s, t) => s + t.energyLevel);
            const maxEnergy = 18;

            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(_dateLabel(),
                                  style: AppTypography.mono11
                                      .copyWith(color: kc.text3)),
                              const Spacer(),
                              Icon(Icons.notifications_outlined,
                                  color: kc.text3, size: 20),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(_greeting(), style: AppTypography.heading28),
                          const SizedBox(height: AppSpacing.xxl),

                          GlassCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Energía requerida hoy',
                                    style: AppTypography.caption12
                                        .copyWith(color: kc.text2)),
                                const SizedBox(height: AppSpacing.md),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: maxEnergy > 0
                                        ? (totalEnergy / maxEnergy)
                                            .clamp(0.0, 1.0)
                                        : 0,
                                    backgroundColor: kc.bg3,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(kc.accent),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$totalEnergy/$maxEnergy',
                                        style: AppTypography.mono11
                                            .copyWith(color: kc.accent)),
                                    Text(
                                        '${pending.length} pendientes · ${done.length} completadas',
                                        style: AppTypography.mono11
                                            .copyWith(color: kc.text3)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),

                          Row(
                            children: [
                              Text('PENDIENTES',
                                  style: AppTypography.mono11
                                      .copyWith(color: kc.text3)),
                              const SizedBox(width: AppSpacing.sm),
                              Text('${pending.length}',
                                  style: AppTypography.mono11
                                      .copyWith(color: kc.text3)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => context.go('/tasks'),
                                child: Text('Ver todas',
                                    style: AppTypography.caption12
                                        .copyWith(color: kc.accent)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                  if (pending.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxxl),
                        child: Center(
                          child: Text('No hay tareas pendientes',
                              style: AppTypography.body13
                                  .copyWith(color: kc.text3)),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          if (i >= pending.length.clamp(0, 4)) return null;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg),
                            child: TaskCard(
                              task: pending[i],
                              onTap: () =>
                                  context.push('/task/${pending[i].id}'),
                              onToggle: () => context.read<TaskBloc>().add(
                                  ToggleTaskRequested(id: pending[i].id)),
                            ),
                          );
                        },
                        childCount: pending.length.clamp(0, 4),
                      ),
                    ),
                  if (done.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                            AppSpacing.xxl, AppSpacing.lg, AppSpacing.md),
                        child: Row(
                          children: [
                            Text('COMPLETADAS',
                                style: AppTypography.mono11
                                    .copyWith(color: kc.text3)),
                            const SizedBox(width: AppSpacing.sm),
                            Text('${done.length}',
                                style: AppTypography.mono11
                                    .copyWith(color: kc.text3)),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg),
                          child: Opacity(
                            opacity: 0.5,
                            child: TaskCard(
                              task: done[i],
                              onTap: () =>
                                  context.push('/task/${done[i].id}'),
                              onToggle: () => context.read<TaskBloc>().add(
                                  ToggleTaskRequested(id: done[i].id)),
                            ),
                          ),
                        ),
                        childCount: done.length.clamp(0, 2),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FABKairos(
          onPressed: () => context.push('/create-task'), icon: Icons.add),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
cd kairos && flutter analyze lib/features/dashboard/
```

Expected: No errors.

- [ ] **Step 3: Commit**

```
git add kairos/lib/features/dashboard/presentation/pages/dashboard_page.dart
git commit -m "feat(dashboard): apply KairosBackground with glows and GlassCard energy widget"
```

---

## Task 10: FocusPage — KairosBackground + GlassCard task cards

**Files:**
- Modify: `lib/features/focus/presentation/pages/focus_page.dart`

- [ ] **Step 1: Update FocusPage**

Replace `focus_page.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_shapes.dart';
import '../../../../shared/widgets/priority_chip.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/kairos_background.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});
  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasksRequested());
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KairosBackground(
        withGlows: true,
        child: SafeArea(
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              final pending = state is TaskLoaded
                  ? state.tasks.where((t) => !t.isDone).take(4).toList()
                  : <Task>[];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DEEP WORK',
                        style: AppTypography.mono11
                            .copyWith(color: kc.accent)),
                    const SizedBox(height: AppSpacing.md),
                    Text('Modo enfoque', style: AppTypography.heading28),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                        'Una tarea. Un cronómetro. Sin distracciones.',
                        style: AppTypography.body14
                            .copyWith(color: kc.text2)),
                    const SizedBox(height: AppSpacing.xxl),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/focus/timer'),
                        icon: Icon(Icons.play_arrow, color: kc.bg),
                        label: Text('Empezar sesión libre',
                            style: AppTypography.body15
                                .copyWith(color: kc.bg)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kc.accent,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    if (pending.isNotEmpty) ...[
                      Row(children: [
                        Expanded(child: Divider(color: kc.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          child: Text('O ENFÓCATE EN UNA TAREA',
                              style: AppTypography.mono11
                                  .copyWith(color: kc.text3)),
                        ),
                        Expanded(child: Divider(color: kc.line)),
                      ]),
                      const SizedBox(height: AppSpacing.lg),
                      for (final task in pending)
                        _FocusTaskCard(task: task),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FocusTaskCard extends StatelessWidget {
  final Task task;
  const _FocusTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return GestureDetector(
      onTap: () => context.push('/focus/timer?taskId=${task.id}'),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: AppTypography.body14),
                  const SizedBox(height: 4),
                  Row(children: [
                    PriorityChip(priority: task.priority),
                    const SizedBox(width: 8),
                    Text('E${task.energyLevel}',
                        style: AppTypography.mono11
                            .copyWith(color: kc.text3)),
                    const SizedBox(width: 8),
                    Text('${task.estimateMinutes}min',
                        style: AppTypography.mono11
                            .copyWith(color: kc.text3)),
                  ]),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: kc.text3, size: 14),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
cd kairos && flutter analyze lib/features/focus/presentation/pages/focus_page.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```
git add kairos/lib/features/focus/presentation/pages/focus_page.dart
git commit -m "feat(focus): apply KairosBackground with glows and GlassCard to FocusPage"
```

---

## Task 11: FocusTimerPage — KairosBackground + pill button

**Files:**
- Modify: `lib/features/focus/presentation/pages/focus_timer_page.dart`

- [ ] **Step 1: Update FocusTimerPage**

Two changes needed:
1. Replace `backgroundColor: const Color(0xFF080808)` with `Colors.transparent` and wrap body in `KairosBackground(withGlows: true)`
2. The "¡Sesión completada!" ElevatedButton already uses `StadiumBorder` via the theme — remove explicit `shape:` param from its style.

Add import at top:
```dart
import '../../../../shared/widgets/kairos_background.dart';
```

Change Scaffold:
```dart
// Before:
return Scaffold(
  backgroundColor: const Color(0xFF080808),
  body: BlocBuilder<FocusBloc, FocusState>(
    builder: (context, state) {
      ...
      return SafeArea(
        child: Column(

// After:
return Scaffold(
  backgroundColor: Colors.transparent,
  body: KairosBackground(
    withGlows: true,
    child: BlocBuilder<FocusBloc, FocusState>(
      builder: (context, state) {
        ...
        return SafeArea(
          child: Column(
```

Close `KairosBackground` child — add `)` after the last `),` of BlocBuilder.

Update the completed button style (remove explicit shape and radius):
```dart
// Before:
style: ElevatedButton.styleFrom(
  backgroundColor: kc.accent,
  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),

// After:
style: ElevatedButton.styleFrom(
  backgroundColor: kc.accent,
),
```

Full updated file — replace with:

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/focus_bloc.dart';
import '../bloc/focus_event.dart';
import '../bloc/focus_state.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/kairos_background.dart';

class FocusTimerPage extends StatefulWidget {
  final String? taskId;
  const FocusTimerPage({this.taskId, super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  Task? _task;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      final s = context.read<TaskBloc>().state;
      if (s is TaskLoaded) {
        _task = s.tasks.where((t) => t.id == widget.taskId).firstOrNull;
      }
    }
    context.read<FocusBloc>().add(FocusStart(task: _task));
  }

  @override
  void dispose() {
    context.read<FocusBloc>().add(const FocusStop());
    super.dispose();
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KairosBackground(
        withGlows: true,
        child: BlocBuilder<FocusBloc, FocusState>(
          builder: (context, state) {
            final secondsLeft = state is FocusRunning
                ? state.secondsLeft
                : state is FocusPaused
                    ? state.secondsLeft
                    : state is FocusCompleted
                        ? 0
                        : FocusBloc.pomodoroSeconds;

            final progress =
                1.0 - (secondsLeft / FocusBloc.pomodoroSeconds);
            final isRunning = state is FocusRunning;
            final isCompleted = state is FocusCompleted;
            final task = state is FocusRunning
                ? state.task
                : state is FocusPaused
                    ? state.task
                    : _task;

            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Row(children: [
                            Icon(Icons.close,
                                color: kc.text3, size: 18),
                            const SizedBox(width: 4),
                            Text('Salir',
                                style: AppTypography.body13
                                    .copyWith(color: kc.text3)),
                          ]),
                        ),
                        const Spacer(),
                        Text('POMODORO 1/4',
                            style: AppTypography.mono11
                                .copyWith(color: kc.text3)),
                        const Spacer(),
                        const SizedBox(width: 60),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Column(
                      children: [
                        Text('ENFOCADO EN',
                            style: AppTypography.mono11
                                .copyWith(color: kc.text3)),
                        const SizedBox(height: 6),
                        Text(
                          task?.title ?? 'Sesión libre',
                          style: AppTypography.heading18,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(260, 260),
                          painter: _ArcPainter(
                            progress: progress,
                            accent: kc.accent,
                            track: kc.bg2,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_fmt(secondsLeft),
                                style: AppTypography.mono64
                                    .copyWith(color: kc.text)),
                            const SizedBox(height: 8),
                            Text(
                              isCompleted
                                  ? 'COMPLETADO'
                                  : isRunning
                                      ? 'EN PROGRESO'
                                      : 'EN PAUSA',
                              style: AppTypography.mono11.copyWith(
                                  color: isCompleted
                                      ? kc.success
                                      : kc.text3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  if (!isCompleted) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlBtn(
                          size: 48,
                          icon: Icons.sync,
                          bg: kc.bg2,
                          fg: kc.text,
                          border: kc.line2,
                          onTap: () => context
                              .read<FocusBloc>()
                              .add(const FocusReset()),
                        ),
                        const SizedBox(width: AppSpacing.xxl),
                        _ControlBtn(
                          size: 72,
                          icon: isRunning
                              ? Icons.pause
                              : Icons.play_arrow,
                          bg: kc.accent,
                          fg: kc.bg,
                          onTap: () => context
                              .read<FocusBloc>()
                              .add(const FocusTogglePause()),
                        ),
                        const SizedBox(width: AppSpacing.xxl),
                        _ControlBtn(
                          size: 48,
                          icon: Icons.close,
                          bg: kc.bg2,
                          fg: kc.text,
                          border: kc.line2,
                          onTap: () => context.pop(),
                        ),
                      ],
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kc.accent,
                      ),
                      child: Text('¡Sesión completada!',
                          style: AppTypography.body15
                              .copyWith(color: kc.bg)),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xxl),
                  Text('NOTIFS PAUSADAS · +12 PUNTOS',
                      style: AppTypography.mono11
                          .copyWith(color: kc.text4)),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color? border;
  final VoidCallback onTap;
  const _ControlBtn(
      {required this.size,
      required this.icon,
      required this.bg,
      required this.fg,
      this.border,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border != null ? Border.all(color: border!) : null,
        ),
        child: Icon(icon, color: fg, size: size > 50 ? 32 : 20),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color accent;
  final Color track;
  const _ArcPainter(
      {required this.progress,
      required this.accent,
      required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        progress * 2 * pi,
        false,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress ||
      old.accent != accent ||
      old.track != track;
}
```

- [ ] **Step 2: Analyze**

```
cd kairos && flutter analyze lib/features/focus/presentation/pages/focus_timer_page.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```
git add kairos/lib/features/focus/presentation/pages/focus_timer_page.dart
git commit -m "feat(focus): apply KairosBackground and pill button to FocusTimerPage"
```

---

## Task 12: ProfilePage — KairosBackground + glass containers + accent options

**Files:**
- Modify: `lib/features/profile/presentation/pages/profile_page.dart`

- [ ] **Step 1: Update ProfilePage**

Three changes:
1. Update `_accentOptions` — first two colors = glowCool/glowWarm, keep rest for variety.
2. Scaffold: `backgroundColor: Colors.transparent` + `KairosBackground(withGlows: true)`
3. All `Container(decoration: BoxDecoration(color: kc.bg2, borderRadius: BorderRadius.circular(12), border: ...))` → `GlassCard` with `borderRadius: BorderRadius.circular(AppShapes.rounded)`, or inline using 24px radius.

Replace `profile_page.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_shapes.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/kairos_background.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _accentOptions = [
    Color(0xFFA0B9D2), // glowCool (default)
    Color(0xFFF0E6D7), // glowWarm
    Color(0xFF3B82F6), // Azul
    Color(0xFF10B981), // Verde
    Color(0xFFA855F7), // Violeta
    Color(0xFFEC4899), // Rosa
    Color(0xFF06B6D4), // Cian
    Color(0xFFFB923C), // Naranja
  ];

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = themeState.mode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KairosBackground(
        withGlows: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Perfil', style: AppTypography.heading18),
                const SizedBox(height: AppSpacing.xxl),

                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kc.accent, kc.accent2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                            child: Text('IM',
                                style: AppTypography.body15.copyWith(
                                    color: kc.bg,
                                    fontWeight: FontWeight.w700))),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ismael Manzano',
                              style: AppTypography.body15.copyWith(
                                  fontWeight: FontWeight.w500)),
                          Text('Almacenamiento local · Realm',
                              style: AppTypography.caption12
                                  .copyWith(color: kc.text2)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                _SectionHeader('APARIENCIA'),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(
                              isDark
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                              color: kc.text2,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      isDark
                                          ? 'Modo oscuro'
                                          : 'Modo claro',
                                      style: AppTypography.body13),
                                  Text(
                                      isDark
                                          ? 'Toca para cambiar a claro'
                                          : 'Toca para cambiar a oscuro',
                                      style: AppTypography.caption12
                                          .copyWith(color: kc.text3)),
                                ],
                              ),
                            ),
                            Switch(
                              value: isDark,
                              onChanged: (_) => context
                                  .read<ThemeCubit>()
                                  .toggleMode(),
                              activeColor: kc.accent,
                            ),
                          ],
                        ),
                      ),
                      Divider(color: kc.line, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Color de acento',
                                style: AppTypography.body13),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _accentOptions.map((color) {
                                final selected =
                                    themeState.accent == color;
                                return GestureDetector(
                                  onTap: () => context
                                      .read<ThemeCubit>()
                                      .setAccent(color),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: selected
                                          ? Border.all(
                                              color: kc.text,
                                              width: 2.5)
                                          : Border.all(
                                              color: Colors.transparent,
                                              width: 2.5),
                                      boxShadow: selected
                                          ? [
                                              BoxShadow(
                                                color: color.withValues(
                                                    alpha: 0.5),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: selected
                                        ? const Icon(Icons.check,
                                            color: Colors.white,
                                            size: 18)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                _SectionHeader('PREFERENCIAS'),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ActionRow(
                          icon: Icons.notifications_outlined,
                          label: 'Notificaciones',
                          sub: 'Activadas',
                          onTap: () {}),
                      Divider(color: kc.line, height: 1),
                      _ActionRow(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacidad y datos',
                          onTap: () {}),
                      Divider(color: kc.line, height: 1),
                      _ActionRow(
                          icon: Icons.settings_outlined,
                          label: 'Ajustes avanzados',
                          onTap: () {}),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                Center(
                    child: Text(
                        'KAIROS 2.0.1 · BUILD 2026.04.27 · ©IML',
                        style: AppTypography.mono11
                            .copyWith(color: kc.text4))),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text,
          style: AppTypography.mono11
              .copyWith(color: context.kc.text3)),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final VoidCallback onTap;
  const _ActionRow(
      {required this.icon,
      required this.label,
      this.sub,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: kc.text2, size: 18),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.body13),
                if (sub != null)
                  Text(sub!,
                      style: AppTypography.caption12
                          .copyWith(color: kc.text3)),
              ],
            )),
            Icon(Icons.chevron_right, color: kc.text3, size: 16),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
cd kairos && flutter analyze lib/features/profile/
```

Expected: No errors.

- [ ] **Step 3: Commit**

```
git add kairos/lib/features/profile/presentation/pages/profile_page.dart
git commit -m "feat(profile): apply KairosBackground, GlassCard and update accent color options"
```

---

## Task 13: Full test run + final analyze

- [ ] **Step 1: Run all tests**

```
cd kairos && flutter test
```

Expected: All tests PASS (existing bloc tests + new theme/widget tests).

- [ ] **Step 2: Full analyze**

```
cd kairos && flutter analyze
```

Expected: No errors or warnings related to the changed files.

- [ ] **Step 3: Verify build compiles**

```
cd kairos && flutter build apk --debug 2>&1 | tail -20
```

Expected: `Built build/app/outputs/flutter-apk/app-debug.apk` with no errors.

- [ ] **Step 4: Final commit**

```
git add -A
git commit -m "chore: complete dark glassmorphism design system migration"
```
