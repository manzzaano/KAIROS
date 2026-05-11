# Plan: Generación automática del documento Entrega 2 — KAIROS

## Objetivo

Generar `entregas/entrega2/Entrega2_KAIROS.docx` de forma **totalmente automática**, sin intervención manual, replicando la estructura y diseño de la Entrega 1 pero con el contenido actualizado.

---

## Arquitectura de la solución

```
entregas/entrega2/
├── capturar_entrega2.ps1    ← Script maestro (lo hace TODO)
├── generar_entrega2.py       ← Genera el DOCX con python-docx
├── screens/                  ← PNGs capturados automáticamente (18)
└── Entrega2_KAIROS.docx     ← Documento final listo para entregar
```

---

## Fase 1: Captura automática de pantallas

### Herramientas

| Herramienta | Uso |
|---|---|
| `adb shell input tap x y` | Tocar botones, tabs, FAB |
| `adb shell input swipe x1 y1 x2 y2 duration` | Pasar slides del onboarding |
| `adb exec-out screencap -p > archivo.png` | Capturar screenshot PNG |
| `Start-Sleep -Seconds N` | Esperar transiciones y animaciones |

### Resolución base

**1080 × 2400 px** (AVD Medium Phone API 35, portrait).

### Coordenadas clave

| Elemento | Coordenadas | Notas |
|---|---|---|
| Tab 1 (Dashboard) | x=108, y=2320 | 5 tabs ÷ 1080px = 216px c/u |
| Tab 2 (Tareas) | x=324, y=2320 | |
| Tab 3 (Enfoque) | x=540, y=2320 | |
| Tab 4 (Stats) | x=756, y=2320 | |
| Tab 5 (Perfil) | x=972, y=2320 | |
| FAB (+) | x=950, y=2100 | Floating action button |
| Centro pantalla | x=540, y=1100 | Para taps genéricos |
| Swipe izquierda | 900,1200 → 200,1200 | Onboarding slides |
| Botón atrás | x=60, y=100 | Top-left corner |
| Primera tarea | x=540, y=600 | Aproximado en lista |

### Flujo de captura (18 screenshots)

| # | Archivo | Acción ADB | Espera |
|---|---|---|---|
| 1 | `01_splash.png` | Ninguna (app inicia sola) | 4s |
| 2 | `02_onboarding_1.png` | Ninguna (slide 1 visible) | 2s |
| 3 | `03_onboarding_2.png` | `swipe 900 1200 200 1200 500` | 2s |
| 4 | `04_onboarding_3.png` | `swipe 900 1200 200 1200 500` | 2s |
| 5 | `05_login.png` | `tap 900 1200` (swipe al login o botón Comenzar) | 2s |
| 6 | `06_login_validation.png` | `tap 540 1200` (botón Iniciar sesión) | 2s |
| 7 | `07_dashboard.png` | `tap 540 1550` (Continuar sin sincronizar) | 3s |
| 8 | `08_optimize.png` | `tap 540 900` (CTA Optimizar con IA) | 8s |
| 9 | `09_dashboard_tasks.png` | Esperar pop del optimize → captura dashboard con tasks | 3s |
| 10 | `10_create_task.png` | `tap 950 2100` (FAB +) | 2s |
| 11 | `11_task_list.png` | `tap 60 100` (back) → `tap 324 2320` (tab Tareas) | 3s |
| 12 | `12_task_detail.png` | `tap 540 600` (primera tarea) | 2s |
| 13 | `13_focus_page.png` | `tap 60 100` (back) → `tap 540 2320` (tab Enfoque) | 2s |
| 14 | `14_focus_timer.png` | `tap 540 800` (Sesión libre / iniciar) | 3s |
| 15 | `15_stats_page.png` | `tap 60 100` (back) → `tap 756 2320` (tab Stats) | 2s |
| 16 | `16_profile_dark.png` | `tap 972 2320` (tab Perfil) | 2s |
| 17 | `17_sync_sheet.png` | `tap 540 750` (Forzar sincronización) | 3s |
| 18 | `18_accent_change.png` | Cerrar sheet (tap fuera) → scroll → `tap azul` | 3s |

---

## Fase 2: Generación del DOCX

### Script: `generar_entrega2.py`

Réplica exacta de `generar_entrega1.py` (mismo diseño, mismas helpers, misma portada) con contenido actualizado.

### Secciones del documento

| # | Sección | Contenido |
|---|---|---|
| Portada | **ENTREGA 2 · Aplicación funcional · 40%**, fecha mayo 2026, datos alumno |
| Índice | TOC de Word (Ctrl+A → F9) |
| 1 | **Descripción del proyecto** | + Supabase, glassmorphism, onboarding |
| 2 | **Arquitectura** | + Capa Supabase, módulo sync, onboarding flow |
| 3 | **Funcionalidades implementadas** | Todas E1 + 8 nuevas de E2 |
| 4 | **Fragmentos de código relevantes** | SupabaseSyncService, login_page (validación), sync_sheet, optimize_page, kairos_colors, app_router (auth flow) |
| 5 | **Capturas de pantalla** | 18 capturas en pares (2 por fila) |
| 6 | **Evidencias de navegación** | Flujo completo: splash → onboarding → login → dashboard → tabs → detalle |
| 7 | **Evidencias de backend (Supabase)** | SQL schema, upsert, sync flow, inyección de dependencias |
| 8 | **Validaciones y flujo de uso** | Email regex, login flow, swipe actions, filtros |
| 9 | **Conclusiones y trabajo futuro** | Planes para E3 (auth real, IA real, notificaciones push) |

### Contenido de la portada

```
ENTREGA 2
Aplicación funcional · 40%

Alumno:               Ismael Manzano León
Ciclo Formativo:      [Nombre Ciclo Formativo]
Centro:               [Nombre del Centro Educativo]
Módulo / Asignatura:  [Nombre del Módulo]
Profesor/a:           [Nombre del Profesor/a]
Fecha de entrega:     11 de mayo de 2026
Versión:              2.0.0
```

### Cabeceras y pies de página

- **Cabecera**: `KAIROS · Entrega 2 – Aplicación funcional` | `Ismael Manzano León`
- **Pie**: `— [PAGE] —`

Los headers/footers se integran directamente en `generar_entrega2.py` (sin script separado, a diferencia de E1).

---

## Fase 3: Ejecución

### Pre-requisitos

```powershell
# Verificar que todo está listo
flutter doctor          # Android toolchain OK
flutter emulators       # Medium_Phone disponible
pip install python-docx # Si no está instalado
```

### Comando único

```powershell
.\entregas\entrega2\capturar_entrega2.ps1
```

### Lo que hace el script

1. Lanza el emulador Android (`Medium_Phone`)
2. Espera a que el emulador termine de bootear
3. Compila la app en modo debug: `flutter build apk --debug`
4. Instala el APK en el emulador: `adb install`
5. Lanza la app: `adb shell am start`
6. Recorre las 18 pantallas automáticamente con `adb input tap/swipe`
7. Captura cada pantalla con `adb exec-out screencap`
8. Cierra la app
9. Ejecuta `generar_entrega2.py` para crear el DOCX
10. Abre el documento final

### Resultado final

```
entregas/entrega2/Entrega2_KAIROS.docx   ← Listo para convertir a PDF y entregar
```

---

## Diferencias clave con Entrega 1

| Aspecto | Entrega 1 | Entrega 2 |
|---|---|---|
| Capturas | Manuales (11 PNGs) | Automáticas vía ADB (18 PNGs) |
| Backend | Solo Realm (local) | Realm + Supabase (cloud) |
| Auth | No tenía | Login con validación (mock) |
| Tema | Dark/Light básico | Dark Glassmorphism + 8 acentos |
| Sync | No tenía | Sync sheet + conflict sheet |
| IA | No tenía | Optimize page animada |
| Header/footer | Script separado | Integrado en el generador |

---

## Archivos a crear/modificar

| Archivo | Acción |
|---|---|
| `entregas/entrega2/capturar_entrega2.ps1` | **Crear** — Script maestro PowerShell |
| `entregas/entrega2/generar_entrega2.py` | **Crear** — Basado en `generar_entrega1.py` |
| `entregas/entrega2/screens/` | **Crear** — Directorio para PNGs |
| `entregas/entrega2/Entrega2_KAIROS.docx` | **Generado** — Documento final |
