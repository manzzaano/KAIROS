# KAIROS Flutter — Spec Completo de Implementación
**Fecha**: 2026-04-26  
**Scope**: UI 100% fiel al diseño + Realm (offline-first, sin backend)

---

## 1. Contexto y objetivo

Implementar todas las pantallas de KAIROS 2.0 identicas al diseño en `design_extracted/kairos-2-0/`. El estado actual es ~25% completo. Se mantiene la arquitectura Clean Architecture + BLoC existente.

**Fuente de verdad del diseño**: `design_extracted/kairos-2-0/project/`  
**Backend**: ninguno. Realm = única fuente de datos. Auth siempre en modo invitado.

---

## 2. Pantallas a implementar (15 total)

### 2.1 Splash Screen
- Logo KAIROS centrado con spinner animado (círculos concéntricos rotando)
- Texto "INICIANDO" en mono, versión "v2.0.1"
- Footer: "realm · syncing local store…"
- Auto-navega a Onboarding tras 1.8 segundos

### 2.2 Onboarding (3 slides)
- Slide 1: OFFLINE-FIRST — ilustración DB local + texto
- Slide 2: SMART SCHEDULING — ilustración algoritmo
- Slide 3: DEEP WORK — timer Pomodoro ilustrativo
- Controles: botón "Continuar"/"Empezar", botón "Saltar" (top-right)
- Indicadores de progreso (barras horizontales, no puntos)
- Navega a Login al terminar o saltar

### 2.3 Login (fix + polish)
- UI existente ya coincide con diseño
- Fix: añadir `context.go('/dashboard')` tras AuthGuestSuccess y AuthSuccess (ya hecho)
- Fix: badge ONLINE/OFFLINE según conectividad real
- Guest mode siempre funcional

### 2.4 AppShell — 5 tabs
Rediseñar de 3 a 5 tabs:
| # | Tab | Icono | Ruta |
|---|-----|-------|------|
| 0 | Hoy | home_outlined | /dashboard |
| 1 | Tareas | list_outlined | /tasks |
| 2 | Enfoque | timer_outlined | /focus |
| 3 | Stats | bar_chart | /stats |
| 4 | Perfil | person_outlined | /profile |

Bottom nav sin labels visibles en estado inactivo, naranja en activo.

### 2.5 Dashboard (reescribir)
**Header**:
- Fecha: "SÁBADO, 26 DE ABRIL" (mono12, text3)
- Greeting: "Buenos días, Ismael" (heading28)
- Botón campana (icon, top-right)

**Energy Bar Card**:
- Card con fondo background2
- Título "Energía requerida hoy" (caption12, text2)
- Barra progresiva (naranja sobre background3, esquinas redondeadas)
- Contador "X/18" en mono
- Subtítulo "X pendientes · Y completadas"

**AI Optimize CTA**:
- Card con border accent (0.06 opacity)
- Icono ✦ (sparkle), título, subtítulo
- Botón "Optimizar ahora" → navega a /optimize
- Deshabilitado en offline (sin función de togglear offline por ahora)

**Sección PENDIENTES**:
- Header: "PENDIENTES" (mono11, text3) + contador + "Ver todas" link → /tasks
- Máximo 4 TaskCards
- Si no hay tareas: empty state "No hay tareas pendientes"

**Sección COMPLETADAS** (solo si hay):
- Header: "COMPLETADAS" (mono11, text3) + contador
- Máximo 2 TaskCards (atenuadas)

**FAB**: naranja, icono +, navega a /tasks/create

### 2.6 Task List Page (crear)
**Header**:
- Título "Todas las tareas" (heading18)
- Subtítulo "X en total · desliza para acción rápida" (body13, text2)

**Filter Row** (scroll horizontal):
- Botones: Todas | Pendientes | Completadas | Alta prioridad
- Activo: fondo accent, texto background
- Inactivo: fondo background2, texto text2

**Lista** (grouped por proyecto):
- Header de grupo: nombre proyecto (mono11, text3) + contador
- **TaskCard con Swipe**:
  - Deslizar derecha >70px: fondo verde, icono check → toggle completar
  - Deslizar izquierda >70px: fondo rojo, icono delete → eliminar con confirmación
  - Tap: navega a /tasks/:id

**FAB**: igual al dashboard

### 2.7 Task Detail (crear)
Modal/página de detalle:
- Header: botón X (close), botones editar + eliminar
- Proyecto label uppercase (mono11, text3)
- Título (heading22)
- Descripción si existe (body14, text2)
- Row de propiedades:
  - PriorityChip
  - EnergyDots
  - Estimación (icono clock + X min)
  - Fecha (icono calendar + label)
  - Badge sync: "✓ SINCRONIZADO" (verde) | "◐ LOCAL" (text3)
- Botón primario: "Marcar como completada" / "Marcar como pendiente"
- Botón ghost: "Iniciar Modo Enfoque" → navega a /focus con taskId

### 2.8 Create Task (fix + completar)
- Validación visual: si título vacío y toca Guardar → error message con icon alert debajo del campo
- Botón Guardar deshabilitado si título vacío (visual: opacity 0.5)
- Energy slider: 1-5, labels "Mínima | Ligera | Media | Alta | Extrema"
- Date buttons: Hoy / Mañana / Esta semana / Sin fecha (exclusivos, uno activo)
- Info box: "Se guarda primero en local (Realm)…" (mono11, background2, rounded)
- Al guardar: crea en Realm, navega back

### 2.9 Focus Landing (crear)
- Header: label "DEEP WORK" (mono11), título "Modo enfoque" (heading28)
- Descripción breve
- Botón primario "Empezar sesión libre" → /focus/timer (sin tarea)
- Divider "O ENFÓCATE EN UNA TAREA"
- Lista de hasta 4 tareas pendientes (TaskCards clickables) → /focus/timer?taskId=X
- Stats card inferior: "X sesiones · Xh Xm tiempo enfocado"

### 2.10 Focus Timer (reescribir UI)
- Fondo #080808 (más oscuro que background)
- Header: botón "Salir" (text, top-left), label "POMODORO X/4" (mono11, top-center)
- Centro:
  - Label "ENFOCADO EN" (mono11, text3)
  - Nombre de tarea o "Sesión libre" (heading18)
  - **Arc SVG** (CustomPainter): círculo de progreso naranja sobre background3
  - Timer MM:SS (mono64, 64px)
  - Estado: "EN PROGRESO" | "EN PAUSA" | "COMPLETADO"
- Controles (row centrada):
  - Reset (36x36, icon sync, background2)
  - Play/Pause (72x72, naranja, icon play/pause)
  - Cerrar (36x36, icon close, background2)
- Footer: "NOTIFS PAUSADAS · +12 PUNTOS" (mono11, text3)
- Timer: countdown desde 25:00, 1 tick/segundo, auto-completa a 0:00

### 2.11 Optimize AI (crear)
- Fondo background1
- Animación: 3 círculos orbitales concéntricos (rotation AnimationController)
- Centro: icono ✦ con glow
- Steps list (5 pasos):
  1. "Serializando tareas locales" 
  2. "Enviando al servidor"
  3. "Procesando con algoritmo heurístico"
  4. "Recibiendo agenda optimizada"
  5. "Aplicando cambios"
- Cada step: icon check (done) | spinner (active) | circle-outline (pending)
- Secuencia auto: cada step ~920ms
- Al completar paso 5: navega back al Dashboard (reordena tareas simulado)

### 2.12 Stats Page (crear)
- Header: "Tu productividad · ÚLTIMOS 7 DÍAS" (heading18)
- Grid 2x2 KPI Cards:
  - Tareas completadas: número grande + Δ%
  - Tiempo enfocado: Xh Xm + X sesiones
  - Racha actual: X días + mejor X días
  - Tareas/día: media con 1 decimal
- Bar Chart (7 días):
  - Barras proporcionales al máximo
  - Día actual: naranja. Resto: background3
  - Labels: L M X J V S D
- Heatmap (4 semanas × 7 días):
  - 5 intensidades de naranja (0-5)
  - Leyenda: "MENOS ←→ MÁS"
- Insights (3 cards, icono lightbulb):
  - Datos calculados de Realm (día con más completadas, etc.)

### 2.13 Profile Page (crear)
- Avatar card: gradiente naranja, iniciales "IM", nombre, email
- Sync Section:
  - Toggle online/offline (simula desconexión)
  - Estado "Conectado" / "Sin conexión"
  - Botón "Forzar sincronización" → abre SyncSheet
  - Botón "Conflictos de versión" + badge "1 PENDIENTE" → abre ConflictSheet
- Preferences Section:
  - Notificaciones, Apariencia, Privacidad (navegación placeholder)
- Logout: button ghost rojo → navega a /login
- Footer: "KAIROS 2.0.1 · BUILD 2026.04.26 · ©IML"

### 2.14 Sync Sheet (modal bottom sheet)
- Título "Sincronizando datos", subtítulo "Realm ↔ PostgreSQL · API REST"
- 4 pasos en secuencia automática (~700ms cada uno)
- Icono check al completar
- Auto-dismiss al terminar

### 2.15 Conflict Sheet (modal bottom sheet)
- Título "Conflicto de versión"
- 2 cards: LOCAL vs REMOTO
- Botones: "Más tarde" (ghost) | "Mantener local" (primary)
- Al resolver: dismiss

### 2.16 Offline Banner
- Widget overlay (top del scaffold)
- Aparece cuando network cambia a offline
- Icono wifi-off, "Sin conexión", "Se sincronizará al recuperar red"
- Auto-dismiss a 2.8s, o cuando vuelve red

---

## 3. Modelo de datos

### Task (sin cambios de schema Realm)
```dart
class Task {
  String id;          // ObjectId hex string
  String title;
  String? description;
  String priority;    // 'high' | 'medium' | 'low'
  int energyLevel;    // 1-5
  int estimateMinutes;
  bool isDone;
  bool isSynced;
  String project;
  String? dueLabel;   // 'Hoy' | 'Mañana' | 'Esta semana' | null
  DateTime createdAt;
}
```

### Seed data (10 tareas del diseño)
Insertar al primer arranque si Realm está vacío.

### FocusSession (nuevo - para stats)
```dart
class FocusSession {
  String id;
  String? taskId;
  int durationSeconds;
  DateTime completedAt;
}
```

---

## 4. Navegación completa

```
/splash           → auto a /onboarding (1.8s)
/onboarding       → /login (skip o completar)
/login            → /dashboard (guest o login)

Shell (5 tabs):
  /dashboard        Tab 0
  /tasks            Tab 1
  /focus            Tab 2 (Focus Landing)
  /stats            Tab 3
  /profile          Tab 4

Subrutas (push sobre shell):
  /tasks/create     FAB desde dashboard o tasks
  /tasks/:id        Task Detail
  /focus/timer      Focus Timer (query: taskId? opcional)
  /optimize         Optimize AI
```

---

## 5. Arquitectura (sin cambios)

Clean Architecture + BLoC existente. Se agregan:
- `FocusBloc` (ya existe, expandir)
- `StatsBloc` (nuevo, lee de Realm)
- `ProfileBloc` (nuevo, maneja sync toggle)
- Shared state: `NetworkBloc` (simula online/offline)

---

## 6. Criterios de completitud

- [ ] Todas las pantallas renderizan igual al diseño (colores, tipografía, spacing)
- [ ] Navegación completa sin dead-ends
- [ ] CRUD de tareas funcional via Realm
- [ ] Focus timer cuenta atrás correctamente
- [ ] Stats calculadas de datos reales de Realm
- [ ] App arranca con seed data si Realm vacío
- [ ] Sin errores en consola de Flutter
