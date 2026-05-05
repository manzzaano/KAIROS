# KAIROS — Dark Glassmorphism Design System

**Date:** 2026-05-05  
**Scope:** Apply `diseño_nuevo/theme.json` design system to all Flutter screens  
**Approach:** Extend `KairosColors` ThemeExtension (no breaking changes)

---

## 1. Design System Source

`diseño_nuevo/theme.json` — "Dark Glassmorphism":
- Background: `#050505`
- Glass surfaces: `rgba(255,255,255,0.03)` + `blur(16px)`
- Borders: `rgba(255,255,255,0.15)` base, `rgba(255,255,255,0.40)` highlight
- Shapes: pill (`9999px`) for buttons/inputs/tags, `24px` for cards
- Glows: cool `rgba(160,185,210,0.5)`, warm `rgba(240,230,215,0.5)`
- Accent: glowCool base `#A0B9D2`, accent2: glowWarm base `#F0E6D7`
- Effects: `blur(16px)`, `shadowDrop` 0 8px 32px rgba(0,0,0,0.4), `shadowInner` inset 0 1px 1px rgba(255,255,255,0.10)

---

## 2. Token Changes — `KairosColors`

### Dark mode

| Token | Before | After |
|---|---|---|
| `bg` | `#0A0A0A` | `#050505` |
| `bg2` | `#161616` solid | `Color(0x08FFFFFF)` = rgba(255,255,255,0.03) |
| `bg3` | `#1C1C1C` solid | `Color(0x14FFFFFF)` = rgba(255,255,255,0.08) |
| `line` | `Color(0x0FFFFFFF)` ~6% | `Color(0x26FFFFFF)` = 15% |
| `line2` | `Color(0x1AFFFFFF)` ~10% | `Color(0x66FFFFFF)` = 40% |
| `accent` | `#FB923C` orange | `#A0B9D2` (glowCool solid) |
| `accent2` | lerp orange+white | `#F0E6D7` (glowWarm solid) |
| `accentSoft` | orange 12% | `#A0B9D2` at 12% |

New tokens added:
- `glowCool`: `Color(0x80A0B9D2)` — ambient radial glow, cool blue-grey
- `glowWarm`: `Color(0x80F0E6D7)` — ambient radial glow, warm cream

### Light mode

| Token | Value |
|---|---|
| `bg` | `#FAFAFA` |
| `bg2` | `rgba(255,255,255,0.70)` = `Color(0xB3FFFFFF)` frosted |
| `bg3` | `rgba(255,255,255,0.50)` = `Color(0x80FFFFFF)` |
| `line` | `Color(0x14000000)` = 8% black |
| `line2` | `Color(0x40000000)` = 25% black |
| `accent` | `#5A7A9A` (dark glowCool for contrast) |
| `accent2` | `#8A7060` (dark glowWarm for contrast) |
| `accentSoft` | `#5A7A9A` at 12% |
| `glowCool` | `Color(0x40A0B9D2)` 25% |
| `glowWarm` | `Color(0x40F0C080)` 25% |

---

## 3. New Constants — `AppShapes`

New file `lib/core/constants/app_shapes.dart`:
```dart
abstract class AppShapes {
  static const double pill = 9999;
  static const double rounded = 24;
  static const double roundedSm = 16;
  static const double roundedXs = 12;
}
```

---

## 4. New Shared Widgets

### `GlassCard` (`lib/shared/widgets/glass_card.dart`)
- `ClipRRect` + `BackdropFilter(ImageFilter.blur(16,16))` + `Container`
- Uses `kc.bg2` fill, `kc.line` border, `AppShapes.rounded` radius
- `shadowDrop`: `BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 32, offset: Offset(0,8))`
- `shadowInner` via gradient overlay trick (1px top border highlight)
- Props: `child`, `padding`, `borderRadius`, `margin`

### `KairosBackground` (`lib/shared/widgets/kairos_background.dart`)
- Stack: solid `kc.bg` base + optional dual radial glows
- `withGlows: bool` prop (default false)
- Cool glow: top-left, `RadialGradient([kc.glowCool, transparent])`, 400x400 circle
- Warm glow: bottom-right, `RadialGradient([kc.glowWarm, transparent])`, 400x400 circle
- Used as `Scaffold.backgroundColor = Colors.transparent` + body wrapped in this

---

## 5. Updated Widgets

### `TaskCard`
- Replace `Container` with `GlassCard`
- `borderRadius` stays 24 (AppShapes.rounded)

### `FABKairos`
- `shape`: `StadiumBorder()` (pill)
- Background: `kc.accent`
- Add `BackdropFilter` wrap

### `AppShell` — Floating Glass Nav Bar
- Remove `BottomNavigationBar`
- Use `Scaffold(body: Stack([navigationShell, Positioned(bottom:24,left:24,right:24, child: _GlassNavBar())]))` 
- `_GlassNavBar`: `ClipRRect(radius: pill)` + `BackdropFilter` + `Container(kc.bg2, border: kc.line)`
- 5 icon+label items as `GestureDetector` row, active = `kc.accent`, inactive = `kc.text3`
- Height ~64, padding horizontal 8

### `AppTheme`
- `inputDecorationTheme.border`: radius → `AppShapes.pill`
- `inputDecorationTheme.fillColor`: `kc.bg2`
- `navigationBarTheme.backgroundColor`: transparent (nav bar replaced)

---

## 6. Pages with Radial Glow Background

Dashboard, Focus (both pages), Profile — use `KairosBackground(withGlows: true)`:
- `Scaffold(backgroundColor: Colors.transparent)`
- Body: `KairosBackground(withGlows: true, child: ...)`

All other pages: `KairosBackground(withGlows: false)` or just `Scaffold(backgroundColor: kc.bg)`

---

## 7. Files Changed

| File | Change |
|---|---|
| `lib/core/theme/kairos_colors.dart` | Add `glowCool`/`glowWarm`, update values |
| `lib/core/constants/app_colors.dart` | Update static constants |
| `lib/core/constants/app_shapes.dart` | NEW — shape constants |
| `lib/core/theme/app_theme.dart` | Input radius → pill, update ColorScheme |
| `lib/shared/widgets/glass_card.dart` | NEW — GlassCard widget |
| `lib/shared/widgets/kairos_background.dart` | NEW — background with optional glows |
| `lib/shared/widgets/task_card.dart` | Container → GlassCard |
| `lib/shared/widgets/fab_kairos.dart` | Pill shape + blur |
| `lib/features/app/presentation/pages/app_shell.dart` | Floating glass nav bar |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart` | KairosBackground + GlassCard energy |
| `lib/features/focus/presentation/pages/focus_page.dart` | KairosBackground glows |
| `lib/features/focus/presentation/pages/focus_timer_page.dart` | KairosBackground glows |
| `lib/features/profile/presentation/pages/profile_page.dart` | KairosBackground glows |

---

## 8. Out of Scope

- Stats page: no glow background (plain dark)
- Tasks pages: no glow background (plain dark)
- Auth screens: not in current build
- Animations/transitions between screens
