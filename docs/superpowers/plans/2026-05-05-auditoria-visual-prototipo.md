# Plan de Alineación Visual KAIROS 2.0 — Prototipo → Flutter

> **Para Claude Code:** Este plan corrige discrepancias entre la app Flutter y el prototipo HTML de diseño. La fuente de verdad es `docs/design/kairos-2-0/project/`. El `theme.json` de `diseño_nuevo/` describe "Dark Glassmorphism" pero **el prototipo real NO usa glassmorphism en tarjetas** — solo la barra de tabs tiene blur. Las tarjetas del prototipo usan fondos SÓLIDOS.

**Hallazgo crítico:** Hay una discrepancia fundamental entre el theme.json y el prototipo visual real. El prototipo es la verdad. El theme.json fue una abstracción incorrecta. Este plan corrige EN CONTRA del theme.json y A FAVOR del prototipo.

---

## Estructura de archivos del prototipo (leer primero en orden)

| # | Archivo | Contenido |
|---|---------|-----------|
| 1 | `docs/design/kairos-2-0/project/styles.css` | Sistema de diseño CSS: variables de color, clases .k-card, .k-btn, .k-input, .k-tabbar, animaciones |
| 2 | `docs/design/kairos-2-0/project/kairos-store.jsx` | Datos semilla (SEED_TASKS), colores de prioridad, STATS_WEEK, HEATMAP |
| 3 | `docs/design/kairos-2-0/project/kairos-icons.jsx` | Iconos SVG inline (IconHome, IconList, IconFocus, etc.) |
| 4 | `docs/design/kairos-2-0/project/kairos-screens-auth.jsx` | Splash, Onboarding (3 slides), Login |
| 5 | `docs/design/kairos-2-0/project/kairos-screens-tasks.jsx` | TabBar, Dashboard, TaskList, CreateTask, TaskDetail, TaskRow, PriorityChip, EnergyDots |
| 6 | `docs/design/kairos-2-0/project/kairos-screens-extras.jsx` | Optimize (IA), Focus (timer), Stats, Profile, SyncSheet, ConflictSheet, OfflineBanner |
| 7 | `docs/design/kairos-2-0/project/kairos-app.jsx` | App principal: enrutamiento entre pantallas, FocusLanding |

---

## FASE 0 — EXTRACCIÓN DEL SISTEMA DE DISEÑO DEL PROTOTIPO

### 0.1 Leer styles.css y extraer TODAS las variables CSS

**Archivo:** `docs/design/kairos-2-0/project/styles.css`

Las variables CSS del prototipo (`:root`):

```css
--k-bg: #0a0a0a;           /* Fondo principal — NO es #050505 */
--k-bg-1: #0f0f0f;         /* Fondo alternativo (sheets) */
--k-bg-2: #161616;         /* Fondo de tarjetas — SÓLIDO, sin blur */
--k-bg-3: #1c1c1c;         /* Fondo hover/activo */
--k-line: rgba(255,255,255,0.06);     /* Borde sutil — 6% */
--k-line-2: rgba(255,255,255,0.10);   /* Borde destacado — 10% */
--k-text: #fafafa;          /* Texto principal */
--k-text-2: #a3a3a3;        /* Texto secundario */
--k-text-3: #525252;        /* Texto terciario/muted */
--k-text-4: #404040;        /* Texto muy sutil */
--k-accent: #fb923c;        /* Acento — NARANJA, NO azul */
--k-accent-2: #fdba74;      /* Acento claro (hover) */
--k-accent-soft: rgba(251,146,60,0.12); /* Acento translúcido */
--k-success: #4ade80;
--k-danger: #f87171;
--k-warn: #facc15;
--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
--font-mono: 'JetBrains Mono', ui-monospace, SFMono-Regular, Menlo, monospace;
```

### 0.2 Extraer clases CSS clave

**`.k-card`** (usada para tarjetas de estadísticas, KPI, perfil):
```css
.k-card {
  background: var(--k-bg-2);       /* #161616 SÓLIDO */
  border: 1px solid var(--k-line);  /* rgba(255,255,255,0.06) */
  border-radius: 14px;              /* NO 24px */
}
/* NO TIENE BACKDROP-FILTER. SIN BLUR. SIN GLASS. */
```

**`.k-btn-primary`**:
```css
.k-btn-primary {
  background: var(--k-accent);   /* #fb923c */
  color: #1a0a00;                /* texto casi negro */
  height: 52px; padding: 0 24px; font-size: 16px; font-weight: 600;
  width: 100%; border-radius: 12px;
}
```

**`.k-btn-ghost`**:
```css
.k-btn-ghost {
  background: var(--k-bg-2);     /* #161616 sólido */
  color: var(--k-text);
  border: 1px solid var(--k-line);
  height: 52px; padding: 0 24px; font-size: 15px; font-weight: 500;
  width: 100%; border-radius: 12px;
}
```

**`.k-input`**:
```css
.k-input {
  background: var(--k-bg-2);     /* #161616 sólido */
  border: 1px solid var(--k-line);
  border-radius: 12px;            /* NO pill=9999 */
  padding: 14px 16px;
  font-size: 15px; color: var(--k-text);
}
.k-input:focus { border-color: var(--k-accent); background: var(--k-bg-3); }
```

**`.k-tabbar`** (ÚNICO componente con blur):
```css
.k-tabbar {
  display: flex; align-items: stretch; justify-content: space-around;
  padding: 8px 8px 28px;
  background: rgba(10,10,10,0.92);        /* semi-transparente */
  backdrop-filter: blur(20px);             /* SÍ tiene blur */
  -webkit-backdrop-filter: blur(20px);
  border-top: 1px solid var(--k-line);    /* borde superior, no completo */
  flex-shrink: 0;
}
```

**`.k-tab`**:
```css
.k-tab {
  flex: 1; display: flex; flex-direction: column; align-items: center; gap: 3px;
  padding: 8px 4px; border-radius: 10px;
  cursor: pointer;
  color: var(--k-text-3);       /* #525252 inactivo */
  font-size: 10px; font-weight: 500; letter-spacing: 0.02em;
}
.k-tab.active { color: var(--k-text); }  /* #fafafa activo — NO usa accent para el color */
```

**`.k-chip`** (priority chip):
```css
.k-chip {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 4px 8px; border-radius: 6px;   /* NO pill=9999 */
  font-size: 11px; font-weight: 500; letter-spacing: 0.02em;
  text-transform: uppercase;
}
```

### 0.3 Extraer propiedades de componentes específicos del JSX

**TaskRow (tarjeta de tarea):**
- `background: var(--k-bg-2)` (#161616 sólido)
- `border: 1px solid var(--k-line)`
- `border-radius: 12px`
- `padding: 14px 14px`
- `display: flex; align-items: flex-start; gap: 12px`
- Checkbox: `width: 20px, height: 20px, border-radius: 6px`, `border: 1.5px solid var(--k-line-2)`, cuando checked: `background: var(--k-accent)`, borde accent
- Título: `font-size: 14px, font-weight: 500`, cuando done: `color: var(--k-text-3)`, `text-decoration: line-through`
- Meta-row: `gap: 10px`, con PriorityChip, EnergyDots (dots 4x4, gap 2px), tiempo estimado (`mono`, `font-size: 11px`)
- Swipe actions: `COMPLETAR` (verde) derecha, `ELIMINAR` (rojo) izquierda

**Dashboard:**
- Header padding: `64px 20px 16px`
- Fecha: `mono 11px, color: var(--k-text-3), letter-spacing: 0.08em`, formato `SÁBADO, 25 DE ABRIL`
- Saludo: `font-size: 28px, font-weight: 600, letter-spacing: -0.025em`
- Bell icon: `36x36, border-radius: 50%, bg: var(--k-bg-2), border: 1px solid var(--k-line)`
- Energy card: `margin-top: 20px, padding: 16px, bg: var(--k-bg-2), border: 1px solid var(--k-line), border-radius: 14px`
  - Barra: `height: 6px, background: rgba(255,255,255,0.06), border-radius: 99px`, fill: `var(--k-accent)`
- AI CTA: `margin-top: 12px, border-radius: 14px`, gradient `linear-gradient(135deg, rgba(251,146,60,0.14), rgba(251,146,60,0.04))`, border `rgba(251,146,60,0.25)`
- Sección pendientes: `padding: 12px 20px 8px`, label `mono 11px, color: var(--k-text-3)`, "Ver todas" button `k-btn-text`
- Lista pendientes: `padding: 0 20px, gap: 8px`, TaskRow components
- Completadas: `padding: 24px 20px 8px`, al 50% de opacidad
- FAB: `position: absolute, bottom: 100px, right: 20px, width: 56px, height: 56px, border-radius: 18px`, `background: var(--k-accent)`, `boxShadow: 0 10px 30px rgba(251,146,60,0.35), 0 0 0 1px rgba(251,146,60,0.5)`

**TabBar:**
- 5 tabs: Hoy (IconHome), Tareas (IconList), Enfoque (IconFocus), Stats (IconChart), Perfil (IconUser)
- Icons: size 20, strokeWidth 1.8 (active) / 1.5 (inactive)
- NO usa accent para el color activo — texto e icono activos son `var(--k-text)` (blanco)
- Inactivos: `var(--k-text-3)` (#525252)

**FocusTimer (pomodoro activo):**
- Fondo: `#080808` (diferente del bg principal `#0a0a0a`)
- Header: padding `12px 20px`, botón "Salir" + "POMODORO 1/4" + spacer
- Label: `mono 11px, color: var(--k-accent)`, "ENFOCADO EN"
- Título tarea: `font-size: 18px, font-weight: 500, text-align: center`
- Timer circle: 280x280, stroke `rgba(255,255,255,0.05)` 1.5px, progress `var(--k-accent)` 2px
- Timer text: `mono tnum 64px, font-weight: 300, letter-spacing: -0.04em`
- Status: `mono 11px, color: var(--k-text-3)`, "EN PROGRESO" / "EN PAUSA" / "COMPLETADO"
- Botones: reset 52x52 border-radius 16px, play/pause 72x72 border-radius 24px con shadow accent, close 52x52
- Footer: `mono 11px, color: var(--k-text-3)`, "NOTIFS PAUSADAS · +12 PUNTOS"

**Stats:**
- Header: `padding: 64px 20px 12px`, "ÚLTIMOS 7 DÍAS" mono, "Tu productividad" 28px
- KPIs: grid 2 cols, gap 10px, `.k-card` (bg #161616, border-radius 14px), padding 14px
- Bar chart: dentro de `.k-card`, padding 18px
- Heatmap: dentro de `.k-card`, padding 18px, grid 7 cols, cells aspect-ratio 1, border-radius 3px
- Insights: cards sueltas con dot indicador, `padding: 12px 14px`

**Profile:**
- Header: `padding: 64px 20px 12px`, "Perfil" 28px
- User card: `.k-card`, border-radius 14px, padding 18px, avatar 56x56 border-radius 18px, gradient `linear-gradient(135deg, #fb923c, #c2410c)`
- Secciones: "SINCRONIZACIÓN", "PREFERENCIAS" (mono labels)
- Settings items: dentro de `.k-card`, padding 14px, dividers, icon 18px
- Toggle sync: custom switch 38x22, pill
- Logout: `k-btn-ghost` con color danger
- Footer: `mono 10px, color: var(--k-text-4)`, "KAIROS 2.0.1 · BUILD 2026.04.25 · ©IML"

**CreateTask:**
- Header: altura 60px spacer, "Cancelar" | "Nueva tarea" | "Guardar" (accent si título no vacío)
- Título input: `background: transparent, border: 0, padding: 8px 0, font-size: 22px, font-weight: 500`
- Descripción textarea: `.k-input`, rows 3
- Prioridad: 3 botones (Alta/Media/Baja) con dot de color, flex 1, border-radius 12px
- Energía: slider range 1-5 con label `mono tnum 18px`, etiquetas "Mínima" a "Extrema"
- Fecha: 4 chips (Hoy, Mañana, Esta semana, Sin fecha), border-radius 10px
- Footer: info card sobre almacenamiento local Realm

**Optimize (IA):**
- Centered layout, orbit animation con 3 círculos concéntricos
- "OPTIMIZANDO" mono label, "Reorganizando tu día" 22px
- 5 pasos con indicadores circulares (done=accent check, active=pulse dot, pending=empty)
- Cada paso: `padding: 10px 12px, background: var(--k-bg-2)` (solo active), borde solo active

**FocusLanding:**
- Header: padding `64px 20px 12px`, "DEEP WORK" mono 11px, "Modo enfoque" 28px, descripción 14px
- Botón primario: "Empezar sesión libre" con IconPlay, height 56px
- "O ENFÓCATE EN UNA TAREA" mono label
- Task cards: botones con icono focus 36x36 border-radius 10px, título 13px weight 500, meta mono 10px
- Stats card: `.k-card`, padding 16px, "HOY" mono, 3 sesiones / 1h 15m

---

## FASE 1 — CORRECCIÓN DE COLORES (TOKENS)

### 1.1 Modificar `kairos_colors.dart` — Valores dark

**Archivo:** `kairos/lib/core/theme/kairos_colors.dart`

Cambiar el factory `KairosColors.dark` para que coincida con el prototipo:

```dart
factory KairosColors.dark(Color accent) => KairosColors(
      accent: const Color(0xFFFB923C),     // #fb923c — NARANJA (era #A0B9D2 azul)
      accent2: const Color(0xFFFDBA74),    // #fdba74 (era #F0E6D7)
      accentSoft: const Color(0x1FFB923C),  // rgba(251,146,60,0.12)
      bg: const Color(0xFF0A0A0A),         // #0a0a0a (era #050505)
      bg2: const Color(0xFF161616),        // #161616 SÓLIDO (era Color(0x08FFFFFF) glass)
      bg3: const Color(0xFF1C1C1C),        // #1c1c1c SÓLIDO (era Color(0x14FFFFFF) glass)
      line: const Color(0x0FFFFFFF),        // rgba(255,255,255,0.06) (era 0x26FFFFFF = 15%)
      line2: const Color(0x1AFFFFFF),       // rgba(255,255,255,0.10) (era 0x66FFFFFF = 40%)
      text: const Color(0xFFFAFAFA),        // #fafafa (igual)
      text2: const Color(0xFFA3A3A3),       // #a3a3a3 (igual)
      text3: const Color(0xFF525252),       // #525252 (igual)
      text4: const Color(0xFF404040),       // #404040 (igual)
      glowCool: const Color(0x80A0B9D2),    // sin cambios
      glowWarm: const Color(0x80F0E6D7),    // sin cambios
      success: const Color(0xFF4ADE80),
      danger: const Color(0xFFF87171),
      warning: const Color(0xFFFACC15),
    );
```

**IMPORTANTE:** El parámetro `accent` DEBE ser ignorado y forzado a `#FB923C` en dark mode, porque el prototipo usa naranja fijo. Mantener el parámetro para light mode o para el selector de acento del perfil.

### 1.2 Modificar `theme_cubit.dart` — Acento por defecto

**Archivo:** `kairos/lib/core/theme/theme_cubit.dart`

Cambiar el acento por defecto de `Color(0xFFA0B9D2)` a `Color(0xFFFB923C)`.

### 1.3 Modificar `app_colors.dart`

**Archivo:** `kairos/lib/core/constants/app_colors.dart`

Actualizar constantes estáticas para reflejar los nuevos valores del prototipo:
```dart
static const background = Color(0xFF0A0A0A);       // era 0xFF050505
static const background2 = Color(0xFF161616);      // era 0x08FFFFFF
static const background3 = Color(0xFF1C1C1C);      // era 0x14FFFFFF
static const line = Color(0x0FFFFFFF);              // era 0x26FFFFFF
static const line2 = Color(0x1AFFFFFF);             // era 0x66FFFFFF
static const accent = Color(0xFFFB923C);            // era 0xFFA0B9D2
static const accent2 = Color(0xFFFDBA74);           // era 0xFFF0E6D7
static const accentSoft = Color(0x1FFB923C);        // era 0x1FA0B9D2
```

### 1.4 Actualizar `app_shapes.dart`

**Archivo:** `kairos/lib/core/constants/app_shapes.dart`

El prototipo usa radios más pequeños:
```dart
abstract class AppShapes {
  static const double pill = 9999;       // para chips/tags y toggle
  static const double rounded = 14;      // era 24 — para tarjetas k-card
  static const double roundedSm = 12;    // era 16 — para task cards
  static const double roundedXs = 10;    // era 12 — para botones pequeños
  static const double btnRadius = 12;    // radio de botones
  static const double inputRadius = 12;  // radio de inputs
  static const double fabRadius = 18;    // radio del FAB
}
```

---

## FASE 2 — ELIMINAR GLASSMORPHISM DE TARJETAS (SOLO TAB BAR TIENE BLUR)

Este es el cambio más importante. El prototipo usa fondos SÓLIDOS (`#161616`) para TODAS las tarjetas. Solo la barra de navegación inferior tiene backdrop-filter.

### 2.1 Reescribir `GlassCard` → `SolidCard` (sin blur)

**Archivo:** `kairos/lib/shared/widgets/glass_card.dart`

Sustituir completamente. La tarjeta del prototipo es:
- Fondo sólido `#161616`
- Borde `1px solid rgba(255,255,255,0.06)`
- Sin backdrop-filter, sin blur, sin sombra de glass
- Sin sombra exterior (solo el FAB y algunos elementos tienen shadow)

```dart
import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_shapes.dart';

class SolidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? border;

  const SolidCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.margin,
    this.backgroundColor,
    this.border,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final radius = borderRadius ?? BorderRadius.circular(AppShapes.roundedSm);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? kc.bg2,
        borderRadius: radius,
        border: border ?? Border.all(color: kc.line),
      ),
      child: child,
    );
  }
}
```

**IMPORTANTE:** Renombrar todas las referencias a `GlassCard` por `SolidCard` en todo el proyecto. Si se prefiere mantener el nombre, simplemente reescribir el contenido del archivo.

### 2.2 Actualizar `kairos_background.dart`

**Archivo:** `kairos/lib/shared/widgets/kairos_background.dart`

Mantener los glows radiales pero cambiar el fondo base de `kc.bg` (#050505 → #0a0a0a al actualizar kairos_colors). Sin cambios adicionales necesarios.

---

## FASE 3 — RECONSTRUIR LA BARRA DE NAVEGACIÓN (TAB BAR)

El prototipo tiene una barra COMPLETA (ancho total) con blur, NO una pastilla flotante.

### 3.1 Reescribir `app_shell.dart`

**Archivo:** `kairos/lib/features/app/presentation/pages/app_shell.dart`

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';

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
      bottomNavigationBar: _KairosTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _KairosTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _KairosTabBar({required this.currentIndex, required this.onTap});

  static const _tabs = [
    ('Hoy', Icons.home_outlined, Icons.home),
    ('Tareas', Icons.list_outlined, Icons.list),
    ('Enfoque', Icons.timer_outlined, Icons.timer),
    ('Stats', Icons.bar_chart_outlined, Icons.bar_chart),
    ('Perfil', Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
          decoration: BoxDecoration(
            color: const Color(0xEB0A0A0A), // rgba(10,10,10,0.92)
            border: Border(top: BorderSide(color: kc.line)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final (label, icon, activeIcon) = _tabs[i];
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? activeIcon : icon,
                        color: active ? kc.text : kc.text3,
                        size: 20,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: AppTypography.caption12.copyWith(
                          fontSize: 10,
                          color: active ? kc.text : kc.text3,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
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
    );
  }
}
```

**Cambios clave respecto al actual:**
- Barra de ancho completo (no pastilla flotante con padding 24)
- `border-top` en vez de borde completo
- Padding `8px 8px 28px` (espacio para safe area inferior)
- Fondo `rgba(10,10,10,0.92)` semi-transparente + blur 20px
- Tab activo: color `kc.text` (blanco), NO `kc.accent`
- Tab inactivo: `kc.text3` (#525252)
- Sin `border-radius` (barra rectangular)
- Gap de 3px entre icono y label

---

## FASE 4 — CORRECCIÓN DE PANTALLAS (PÁGINA POR PÁGINA)

### 4.1 Dashboard (`dashboard_page.dart`)

**Archivo:** `kairos/lib/features/dashboard/presentation/pages/dashboard_page.dart`

**Cambios necesarios:**

1. **Header:** Reemplazar `AppSpacing.lg` (20px) por padding explícito `EdgeInsets.fromLTRB(20, 64, 20, 16)` para igualar el prototipo. Quitar `SafeArea` (el prototipo no usa safe area dentro del frame del teléfono).

2. **Fecha:** La etiqueta mono debe ir PRIMERO (arriba), luego el saludo. El prototipo muestra:
   ```
   SÁBADO, 25 DE ABRIL    [icono campana]
   Buenos días, Ismael
   ```
   Actualmente en Flutter la fecha está a la izquierda y la campana a la derecha sin el formato de fecha correcto del prototipo.

3. **Bell icon:** Debe ser un contenedor circular `36x36` con `bg: kc.bg2` y `border: 1px solid kc.line`. Actualmente es solo un `Icon`.

4. **Energy card:** 
   - Radio: 14px (no 24px)
   - Padding: 16px (no 20px)
   - Título: `font-size: 13px, weight: 500, color: kc.text` (no caption 12px en text2)
   - Valor `totalEnergy/maxEnergy`: `mono 12px, color: kc.text2` a la derecha del título
   - Barra: `height: 6px, background: Color(0x0FFFFFFF)` (6% white), `border-radius: 99`
   - Footer: `pendientes · completadas` en una línea, mono 11px text3

5. **AI Optimize CTA:** AÑADIR este botón que falta completamente. Debe tener:
   - `margin-top: 12px, border-radius: 14px`
   - Fondo: gradiente lineal `linear-gradient(135deg, rgba(251,146,60,0.14), rgba(251,146,60,0.04))`
   - Borde: `rgba(251,146,60,0.25)`
   - Icono sparkle 32x32 dentro de caja 32x32 border-radius 10px bg accent soft
   - Texto: "Optimizar mi día con IA" + subtítulo "Reordena por prioridad y energía"
   - Chevron a la derecha
   - Deshabilitado si offline (opacidad 0.5)

6. **Pendientes header:** `padding: 12px 20px 8px`, label `mono 11px`, botón "Ver todas" con estilo `k-btn-text` (sin fondo, height 24px, font-size 12px, color accent). No uses divider.

7. **Lista de tareas pendientes:** `padding: 0 20px, gap: 8px`. Usar `SolidCard` con padding `14px` (no lg=20px). Layout horizontal con checkbox a la izquierda (ver sección TaskCard abajo).

8. **Completadas:** Sección con opacidad 0.5. `padding: 24px 20px 8px`, label `mono 11px`.

9. **FAB:** Quitar el `FloatingActionButton` del scaffold y usar un `Stack` + `Positioned`:
   - `bottom: 100, right: 20`
   - `56x56, border-radius: 18px`
   - `background: kc.accent`
   - `boxShadow: 0 10px 30px rgba accent 0.35, 0 0 0 1px rgba accent 0.5`
   - Icono Plus, blanco/negro, size 26
   - SIN BackdropFilter (el FAB del prototipo no tiene blur)

10. **Estructura general:** `Stack` con:
    - `Positioned.fill`: contenido scrolleable
    - `Positioned(bottom: 100, right: 20)`: FAB

### 4.2 TaskCard — Rediseño completo

**Archivo:** `kairos/lib/shared/widgets/task_card.dart`

La tarjeta de tarea actual usa `GlassCard` con layout vertical (título arriba, checkbox derecha, chips abajo). El prototipo es MUY diferente:

**Layout horizontal:**
```
[checkbox 20x20] [título + metadata row]
```

```dart
import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_shapes.dart';
import '../../features/tasks/domain/entities/task.dart';
import 'priority_chip.dart';
import 'energy_dots.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskCard({
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kc.bg2,                         // #161616 sólido
          borderRadius: BorderRadius.circular(AppShapes.roundedSm), // 12px
          border: Border.all(color: kc.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox custom — 20x20, border-radius 6
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: task.isDone ? kc.accent : kc.line2,
                    width: 1.5,
                  ),
                  color: task.isDone ? kc.accent : Colors.transparent,
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 12, color: Color(0xFF1A0A00))
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTypography.body14.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      color: task.isDone ? kc.text3 : kc.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Metadata row
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      PriorityChip(priority: task.priority),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 11, color: kc.text3),
                          const SizedBox(width: 4),
                          EnergyDots(level: task.energyLevel),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 11, color: kc.text3),
                          const SizedBox(width: 4),
                          Text(
                            '${task.estimateMinutes}m',
                            style: AppTypography.mono11.copyWith(color: kc.text3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.3 PriorityChip — Ajustar al prototipo

**Archivo:** `kairos/lib/shared/widgets/priority_chip.dart`

El prototipo tiene chips con:
- `padding: 4px 8px`
- `border-radius: 6px` (NO pill=9999)
- `font-size: 11px, weight: 500, letter-spacing: 0.02em, uppercase`
- Un dot de color (5x5, border-radius 50%) ANTES del texto
- Colores del prototipo:
  - Alta: `bg: rgba(248,113,113,0.12), fg: #fca5a5, dot: #f87171`
  - Media: `bg: rgba(251,146,60,0.12), fg: #fdba74, dot: #fb923c`
  - Baja: `bg: rgba(115,115,115,0.18), fg: #a3a3a3, dot: #737373`

```dart
// Reemplazar completamente:
@override
Widget build(BuildContext context) {
  final config = _chipColors[priority]!;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: config['bg'] as Color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: config['dot'] as Color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          config['label'] as String,
          style: AppTypography.caption12.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.22,
            color: config['fg'] as Color,
          ),
        ),
      ],
    ),
  );
}
```

### 4.4 EnergyDots — Ajustar al prototipo

**Archivo:** `kairos/lib/shared/widgets/energy_dots.dart`

Prototipo: dots 4x4, gap 2px, color activo `var(--k-accent)`, inactivo `rgba(255,255,255,0.10)`.

```dart
children: List.generate(5, (i) => Container(
  width: 4,
  height: 4,
  margin: const EdgeInsets.only(right: 2),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: i < level ? kc.accent : const Color(0x1AFFFFFF),
  ),
)),
```

### 4.5 TaskListPage

**Archivo:** `kairos/lib/features/tasks/presentation/pages/task_list_page.dart`

**Cambios:**
1. Header padding: `EdgeInsets.fromLTRB(20, 64, 20, 12)`
2. Título: `font-size: 28px, weight: 600` (no 18px)
3. Subtítulo: `font-size: 13px, color: kc.text2`
4. Filter chips: `padding: 8px 14px, border-radius: 99px`, activo: `bg: kc.text, color: kc.bg` (invertido), inactivo: `bg: kc.bg2, color: kc.text2`
5. Eliminar `_FilterChip` actual (usa accent para activo, el prototipo usa texto blanco/negro)
6. Las task rows usan `_SwipeableTaskRow` que ya implementa Dismissible — mantener pero ajustar estilos
7. Añadir `margin: EdgeInsets.symmetric(vertical: 4)` entre tasks (gap 8px total)
8. Agrupar por proyecto con header `mono 10px color text3`: "PROYECTO · N"
9. FAB: mismo cambio que en Dashboard (Stack + Positioned, sin blur)

### 4.6 CreateTaskPage y TaskDetailPage

**Archivos:**
- `kairos/lib/features/tasks/presentation/pages/create_task_page.dart`
- `kairos/lib/features/tasks/presentation/pages/task_detail_page.dart`

**CreateTask — cambios:**
1. Sin SafeArea: usar padding top 60px
2. Header: Cancelar (izq, k-btn-text) | "Nueva tarea" (centro, 16px weight 600) | Guardar (derecha, accent si título, bg3 si vacío)
3. Título: input sin fondo, sin borde, font-size 22px weight 500, padding 8px 0
4. Descripción: textarea con estilo .k-input (bg kc.bg2, border-radius 12px, padding 14px 16px)
5. Prioridad: 3 botones no outline, con dot centrado + label, border-radius 12px, padding 14px 12px. Activo usa el color de prioridad, inactivo bg2
6. Energía: Slider con label "Nivel de energía", valor grande `mono 18px accent` a la derecha, etiquetas "Mínima" a "Extrema" abajo
7. Fecha: chips "Hoy", "Mañana", "Esta semana", "Sin fecha", border-radius 10px, padding 10px 14px
8. Info footer: card con icono cloud + texto sobre Realm

**TaskDetail — cambios:**
1. Header: botón close (40x40, border-radius 12px) a la izquierda, botones edit/delete a la derecha
2. Proyecto: mono 11px text3, letter-spacing 0.1em, uppercase
3. Título: 26px weight 600
4. Descripción: 14px text2
5. Info card (.k-card): padding 4px, rows con padding 14px, dividers, label 13px text3 + value a la derecha
6. Botones: "Marcar como completada" (primary), "Iniciar Modo Enfoque" (ghost)

### 4.7 FocusPage (FocusLanding del prototipo)

**Archivo:** `kairos/lib/features/focus/presentation/pages/focus_page.dart`

**Cambios:**
1. Padding header: `EdgeInsets.fromLTRB(20, 64, 20, 12)`
2. "DEEP WORK" mono 11px accent (no text3)
3. "Modo enfoque" 28px weight 600
4. Descripción: 14px text2, line-height 1.5
5. Botón "Empezar sesión libre": height 56px, con icono play. Usar SolidCard-like botón (no ElevatedButton de Material). `background: kc.accent, color: Color(0xFF1A0A00), border-radius: 12px`
6. Sección "O ENFÓCATE EN UNA TAREA": mono 11px text3, padding 8px 0
7. Task cards: estilo botón con icono focus 36x36 bg kc.bg3 border-radius 10px, título 13px weight 500, meta mono 10px, chevron derecha
8. Stats card al final: "HOY" mono 11px text3, 3 sesiones / 1h 15m, dentro de SolidCard padding 16px
9. Sin glows radiales en esta pantalla (el prototipo no tiene glows)

### 4.8 FocusTimerPage

**Archivo:** `kairos/lib/features/focus/presentation/pages/focus_timer_page.dart`

**Cambios:**
1. Fondo: `#080808` (Container negro sólido, NO `kc.bg`). Añadir `Color(0xFF080808)` como constante o usar directamente.
2. Quitar `KairosBackground` — esta pantalla tiene fondo plano `#080808`
3. Header: botón "Salir" con icono close + texto (k-btn-text style), centro "POMODORO 1/4" mono 11px text3
4. "ENFOCADO EN" mono 11px accent (no text3)
5. Título: 18px weight 500, textAlign center, maxLines 2
6. Timer circle: 280x280 en vez de 260x260
   - Track: `rgba(255,255,255,0.05)` (no kc.bg2), strokeWidth 1.5
   - Progress: `kc.accent`, strokeWidth 2
7. Timer text: `mono 64px, fontWeight: 300, letterSpacing: -0.04em`, con ":" en text3
8. Status: `mono 11px`, "EN PROGRESO" (text3) / "COMPLETADO" (success)
9. Botones de control:
   - Reset (izq): 52x52, border-radius 16px, bg kc.bg2, border kc.line
   - Play/Pause (centro): 72x72, border-radius 24px, bg kc.accent, boxShadow `0 10px 30px rgba(251,146,60,0.35)`
   - Close (der): 52x52, border-radius 16px, bg kc.bg2, border kc.line
   - Usar `BoxShape.rectangle` + borderRadius, NO `BoxShape.circle`
10. Footer: `mono 11px text4`, "NOTIFS PAUSADAS · +12 PUNTOS"

### 4.9 StatsPage

**Archivo:** `kairos/lib/features/stats/presentation/pages/stats_page.dart`

**Cambios:**
1. Header: `padding: EdgeInsets.fromLTRB(20, 64, 20, 12)`
2. "ÚLTIMOS 7 DÍAS" mono 11px text3 PRIMERO, luego "Tu productividad" 28px (orden invertido)
3. KPIs: grid 2 cols, gap 10px. Cada KPI usa `SolidCard` (bg kc.bg2, border kc.line, border-radius 14px, padding 14px)
4. Label: 11px text3, icono 12px text3 a la derecha
5. Valor: mono 22px weight 500
6. Sub: 10px text3
7. Bar chart: ENVOLVER en SolidCard con padding 18px
8. Heatmap: ENVOLVER en SolidCard con padding 18px. Cells `aspectRatio: 1`, `border-radius: 3px`, colores basados en opacidad del acento como el prototipo: `rgba(251,146,60,0.20)`, `0.40`, `0.65`, `0.95` para niveles 1-4, `rgba(255,255,255,0.04)` para 0
9. Heatmap legend: "MENOS" / "MÁS" mono 10px text4
10. Insights: cards con dot circular 6x6 + texto, bg kc.bg2, border-radius 12px, padding 12px 14px

### 4.10 ProfilePage

**Archivo:** `kairos/lib/features/profile/presentation/pages/profile_page.dart`

**Cambios:**
1. Header: `padding: EdgeInsets.fromLTRB(20, 64, 20, 12)`
2. Título "Perfil" 28px weight 600 (no 18px)
3. User card: `SolidCard` con padding 18px, border-radius 14px
4. Avatar: 56x56, border-radius 18px (NO circular), gradiente `linear-gradient(135deg, #fb923c, #c2410c)`, iniciales "IM" 22px weight 600 color `#1a0a00`
5. Nombre: 16px weight 600, email: 12px text3
6. Sección "SINCRONIZACIÓN": mono 11px text3 header
7. Sync status card: SolidCard, overflow hidden
   - Online status: icono cloud + texto + toggle switch custom (38x22, pill, bg accent/grey)
   - "Forzar sincronización": row con icono sync + chevron
   - "Conflictos de versión": row con icono alert + "1 PENDIENTE" en warning
8. Sección "PREFERENCIAS": mono 11px text3 header
9. Settings rows: icono 18px text2, label 13px, valor 12px text3, chevron 14px text3. Dentro de SolidCard con dividers.
10. Apariencia (dark/light toggle): mantener el Switch actual
11. Color de acento: círculos 36x36, 8 opciones incluyendo `#FB923C` (naranja) como opción. El borde de selección debe ser `kc.text` (blanco).
12. Logout: k-btn-ghost style, color danger, icono logout
13. Footer: `mono 10px text4`, "KAIROS 2.0.1 · BUILD 2026.04.27 · ©IML"

---

## FASE 5 — PANTALLAS FALTANTES (NO IMPLEMENTADAS)

Estas pantallas existen en el prototipo pero no en Flutter. Crearlas nuevas.

### 5.1 SplashScreen

**Archivo nuevo:** `kairos/lib/features/onboarding/presentation/pages/splash_page.dart`

**Ruta:** `/splash` (redirige a `/onboarding` o `/dashboard`)

**Diseño exacto (del prototipo `kairos-screens-auth.jsx`):**
- Fondo: `kc.bg` (#0a0a0a)
- Centrado vertical y horizontal
- Círculo exterior: 80x80, borde `1px solid rgba(255,255,255,0.08)`, border-radius 50%
- Arco animado (spinner): mismo tamaño, `border-top: 1.5px solid kc.accent`, animación de rotación 1.4s linear infinite
- Icono central: logo KAIROS, 36px, color `#fafafa`
- Texto: "KAIROS" 22px weight 600
- Subtítulo: `mono 11px text3`, "v2.0.1 · INICIANDO"
- Footer: `mono 12px text4`, "realm · syncing local store…"
- Auto-navega a onboarding después de 1.8s

### 5.2 OnboardingScreen

**Archivo nuevo:** `kairos/lib/features/onboarding/presentation/pages/onboarding_page.dart`

**Ruta:** `/onboarding`

**Diseño:**
- 3 slides con indicador de progreso (barras horizontales)
- Slide 1: "01 / OFFLINE-FIRST", "Tu agenda, siempre disponible", ilustración de círculos concéntricos + Realm
- Slide 2: "02 / SMART SCHEDULING", "Optimiza tu día con un toque", ilustración de lista de tareas ordenadas
- Slide 3: "03 / DEEP WORK", "Modo enfoque sin distracciones", ilustración de cronómetro circular
- Navegación: botón "Saltar" arriba derecha, botón "Continuar"/"Empezar" abajo
- Indicador: 3 barras horizontales (6x3px inactivo, 18x3px activo), color accent
- Animación fade-up entre slides

### 5.3 LoginScreen

**Archivo nuevo:** `kairos/lib/features/onboarding/presentation/pages/login_page.dart`

**Ruta:** `/login`

**Diseño:**
- Header: logo KAIROS 26px + "KAIROS" 18px + badge "ONLINE" (verde, pill)
- "Bienvenido de vuelta" 28px weight 600
- "Sincroniza tus tareas con la nube" 15px text2
- Inputs: Correo + Contraseña con labels mono 11px
- Link "¿Olvidaste tu contraseña?" accent, derecha
- Botón "Iniciar sesión y sincronizar" (primary, con loading spinner)
- Botón "Continuar sin sincronizar" (ghost)
- "¿Aún no tienes cuenta? Crear una"

### 5.4 OptimizeScreen (IA)

**Archivo nuevo:** `kairos/lib/features/optimize/presentation/pages/optimize_page.dart`

**Ruta:** `/optimize`

**Diseño:**
- Overlay/pantalla completa centrada
- Botón close arriba derecha (36x36, border-radius 12px)
- Animación de órbita: 3 círculos concéntricos (dashed, solid, bg2), planetas orbitando
- Icono sparkle central 32px
- "OPTIMIZANDO" mono 11px accent
- "Reorganizando tu día" 22px weight 600
- 5 pasos con indicadores (done=accent check, active=pulse, pending=empty)
- Auto-avanza por fases y cierra al completar

### 5.5 SyncSheet y ConflictSheet

**Archivos nuevos:**
- `kairos/lib/features/sync/presentation/widgets/sync_sheet.dart`
- `kairos/lib/features/sync/presentation/widgets/conflict_sheet.dart`

**SyncSheet:** Bottom sheet modal con:
- Handle bar (36x4, bg line2, border-radius 99)
- "Sincronizando datos" 18px weight 600
- 4 pasos de sincronización con indicadores
- Botón "Cerrar"

**ConflictSheet:** Bottom sheet modal con:
- Handle bar
- Icono alert + "Conflicto de versión" 18px
- 2 versiones: LOCAL · iPhone y REMOTO · MacBook
- Botones "Más tarde" (ghost) y "Mantener local" (primary)

### 5.6 OfflineBanner

**Archivo nuevo:** `kairos/lib/shared/widgets/offline_banner.dart`

Widget animado que aparece/desaparece en la parte superior:
- `background: rgba(250,204,21,0.12)`, borde `rgba(250,204,21,0.25)`
- `border-radius: 12px, padding: 10px 14px`
- Icono wifi-off + "Sin conexión" + "Se sincronizará al recuperar red"
- Animación slide-down/fade

---

## FASE 6 — CORRECCIÓN DE TEMAS DE MATERIAL

### 6.1 Actualizar `app_theme.dart`

**Archivo:** `kairos/lib/core/theme/app_theme.dart`

```dart
// Inputs: border-radius 12px (no pill)
border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(AppShapes.inputRadius), // 12
  borderSide: BorderSide(color: kc.line),
),
// Padding de input: 14px 16px (no 24px horizontal)
contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

// Botones elevados: border-radius 12px, altura 52px
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.btnRadius)),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    minimumSize: const Size(double.infinity, 52),
  ),
),

// Checkbox: quitar tema global (usamos checkbox custom en TaskCard)
// Slider: mantener tema actual (accent)
```

---

## FASE 7 — VERIFICACIÓN Y PRUEBAS

### 7.1 Comandos de verificación

```bash
cd kairos && flutter analyze
cd kairos && flutter test
cd kairos && flutter build apk --debug
```

### 7.2 Checklist visual por pantalla

Para cada pantalla, verificar contra el prototipo:

- [ ] **Splash**: Círculo animado, texto KAIROS, subtítulo, footer realm
- [ ] **Onboarding**: 3 slides, indicador de barras, botones Saltar/Continuar
- [ ] **Login**: Logo, inputs, botones primary y ghost, loading state
- [ ] **Dashboard**: Fecha mono, saludo, campana circular, energy card (14px radio), AI CTA gradiente, task rows con checkbox custom, FAB naranja
- [ ] **TaskList**: Filtros pill invertidos, agrupación por proyecto, swipe actions
- [ ] **CreateTask**: Input título sin bordes, prioridad 3 botones con dots, slider energía, chips fecha
- [ ] **TaskDetail**: Header con close/edit/delete, info rows, botones primary/ghost
- [ ] **FocusLanding**: Botón sesión libre 56px, task cards con icono focus, stats card HOY
- [ ] **FocusTimer**: Fondo #080808, timer 280x280, controles con border-radius (no circulares)
- [ ] **Stats**: KPI cards 14px radio, bar chart y heatmap envueltos en cards, insights con dots
- [ ] **Profile**: Avatar 56x56 radius 18px gradiente, sync toggle pill, settings rows con dividers
- [ ] **TabBar**: Ancho completo, blur 20px, border-top, tabs activos en blanco (no accent)
- [ ] **Optimize**: Órbita animada, 5 pasos, auto-cierre
- [ ] **SyncSheet**: Bottom sheet con pasos de sync
- [ ] **ConflictSheet**: Bottom sheet con versiones local/remoto

### 7.3 Propiedades clave a verificar en TODAS las pantallas

| Propiedad | Valor correcto (prototipo) | Valor actual (erróneo) |
|-----------|---------------------------|------------------------|
| Fondo app | `#0a0a0a` | `#050505` |
| Fondo tarjetas | `#161616` SÓLIDO | `Color(0x08FFFFFF)` glass |
| Borde tarjetas | `rgba(255,255,255,0.06)` = 6% | `rgba(255,255,255,0.15)` = 15% |
| Radio tarjetas | `12px` (tasks), `14px` (cards) | `24px` |
| Acento | `#fb923c` NARANJA | `#A0B9D2` AZUL |
| Texto activo tab | `#fafafa` BLANCO | `kc.accent` (naranja/azul) |
| Texto inactivo tab | `#525252` | `kc.text3` (#525252) ✓ |
| Blur en tarjetas | NO | SÍ (BackdropFilter) |
| Blur en tab bar | SÍ (20px) | SÍ (16px) — ajustar a 20px |
| Tab bar forma | Rectangular, ancho completo | Pastilla flotante |
| Radio inputs | `12px` | `9999px` (pill) |
| Radio botones | `12px` | `9999px` (pill) |
| Radio FAB | `18px` | Circular/StadiumBorder |
| FAB shadow | `0 10px 30px rgba(accent,0.35), 0 0 0 1px rgba(accent,0.50)` | Sin shadow |
| Header padding | `64px 20px 16px` | `SafeArea + 20px` |

---

## Resumen de archivos a modificar

| # | Archivo | Acción |
|---|---------|--------|
| 1 | `lib/core/theme/kairos_colors.dart` | MODIFICAR: todos los colores dark al prototipo |
| 2 | `lib/core/constants/app_colors.dart` | MODIFICAR: constantes estáticas |
| 3 | `lib/core/constants/app_shapes.dart` | MODIFICAR: radios a 14/12/10/12/12/18 |
| 4 | `lib/core/theme/theme_cubit.dart` | MODIFICAR: default accent a #FB923C |
| 5 | `lib/core/theme/app_theme.dart` | MODIFICAR: input radius 12, button radius 12 |
| 6 | `lib/shared/widgets/glass_card.dart` | REESCRIBIR: SolidCard sin blur |
| 7 | `lib/shared/widgets/task_card.dart` | REESCRIBIR: layout horizontal, checkbox custom |
| 8 | `lib/shared/widgets/priority_chip.dart` | MODIFICAR: dot + radius 6 + padding 4x8 |
| 9 | `lib/shared/widgets/energy_dots.dart` | MODIFICAR: dots 4x4, gap 2px, inactivo 10% |
| 10 | `lib/shared/widgets/fab_kairos.dart` | REESCRIBIR: sin blur, border-radius 18, shadow accent |
| 11 | `lib/shared/widgets/kairos_background.dart` | Sin cambios (bg se actualiza vía tokens) |
| 12 | `lib/features/app/presentation/pages/app_shell.dart` | REESCRIBIR: tab bar ancho completo |
| 13 | `lib/features/dashboard/presentation/pages/dashboard_page.dart` | REESCRIBIR: padding, AI CTA, FAB, task layout |
| 14 | `lib/features/tasks/presentation/pages/task_list_page.dart` | MODIFICAR: header, filtros, task rows |
| 15 | `lib/features/tasks/presentation/pages/create_task_page.dart` | MODIFICAR: layout prototipo |
| 16 | `lib/features/tasks/presentation/pages/task_detail_page.dart` | MODIFICAR: layout prototipo |
| 17 | `lib/features/focus/presentation/pages/focus_page.dart` | MODIFICAR: layout FocusLanding |
| 18 | `lib/features/focus/presentation/pages/focus_timer_page.dart` | REESCRIBIR: fondo, timer, controles |
| 19 | `lib/features/stats/presentation/pages/stats_page.dart` | MODIFICAR: cards, orden header, wrappers |
| 20 | `lib/features/profile/presentation/pages/profile_page.dart` | REESCRIBIR: layout prototipo |
| 21 | `lib/features/onboarding/presentation/pages/splash_page.dart` | NUEVO |
| 22 | `lib/features/onboarding/presentation/pages/onboarding_page.dart` | NUEVO |
| 23 | `lib/features/onboarding/presentation/pages/login_page.dart` | NUEVO |
| 24 | `lib/features/optimize/presentation/pages/optimize_page.dart` | NUEVO |
| 25 | `lib/features/sync/presentation/widgets/sync_sheet.dart` | NUEVO |
| 26 | `lib/features/sync/presentation/widgets/conflict_sheet.dart` | NUEVO |
| 27 | `lib/shared/widgets/offline_banner.dart` | NUEVO |
| 28 | `lib/core/router/app_router.dart` | MODIFICAR: añadir rutas nuevas |

---

## Orden de ejecución recomendado

1. **Primero los tokens** (Fase 1): `kairos_colors.dart`, `app_colors.dart`, `app_shapes.dart`, `theme_cubit.dart`, `app_theme.dart`
2. **Luego widgets compartidos** (Fases 2-3): `glass_card.dart` → `task_card.dart` → `priority_chip.dart` → `energy_dots.dart` → `fab_kairos.dart` → `app_shell.dart`
3. **Luego páginas existentes** (Fase 4): Dashboard → TaskList → CreateTask → TaskDetail → FocusPage → FocusTimer → Stats → Profile
4. **Pantallas nuevas** (Fase 5): Splash → Onboarding → Login → Optimize → Sync sheets
5. **Verificación final** (Fase 7): `flutter analyze && flutter test`
