#!/usr/bin/env python3
"""
Generador de PDF para Entrega 2 - KAIROS
Evidencias de funcionalidades, código y flujo
"""

from datetime import datetime
import json

# Datos del proyecto
PROJECT = {
    "titulo": "KAIROS 2.0",
    "subtitulo": "Aplicación de Productivity con Offline-First & Deep Work",
    "alumno": "Ismael Manzano León",
    "email": "ismaelmanzanoleon@gmail.com",
    "fecha": datetime.now().strftime("%d de %B de %Y"),
    "version": "2.0.0",
}

FUNCIONALIDADES = {
    "Backend": [
        "✅ Supabase integrado (PostgreSQL remoto)",
        "✅ SupabaseSyncService con push() para sincronización",
        "✅ Realm offline-first (Realm local como fuente de verdad)",
        "✅ Tabla 'tasks' con schema completo",
        "✅ isSynced flag para rastrear estado",
    ],
    "Autenticación": [
        "✅ Login page con validaciones (email regex, min 6 chars)",
        "✅ Form con GlobalKey<FormState>",
        "✅ Callbacks: ¿Olvidaste contraseña?, Crear cuenta",
        "✅ Navegación logout → /login",
        "✅ Mock auth (real en Entrega 3)",
    ],
    "Tareas (CRUD)": [
        "✅ Crear tarea con campos: título, prioridad, energía, proyecto, fecha",
        "✅ Lista con filtros: Todas, Pendientes, Completadas, Alta prioridad",
        "✅ Swipe derecha para completar (toggle)",
        "✅ Swipe izquierda para eliminar",
        "✅ Detalle de tarea con opción iniciar Focus",
        "✅ Agrupación por proyecto",
    ],
    "Focus (Deep Work)": [
        "✅ Selector de tarea para enfocar (FocusLanding)",
        "✅ Timer Pomodoro 25min con pausa/resume/reset",
        "✅ Contador de rondas dinámico (POMODORO n/4)",
        "✅ Arc animado mostrando progreso en tiempo real",
        "✅ Sesión libre (sin tarea asociada)",
        "✅ Stats: sesiones, tiempo total, completadas (datos reales)",
    ],
    "Estadísticas": [
        "✅ KPIs: total completadas, tiempo estimado, racha de días",
        "✅ Bar chart último 7 días (tareas/día)",
        "✅ Heatmap 4 semanas (actividad visual)",
        "✅ Media tareas por día",
        "✅ Insights condicionales",
    ],
    "Perfil & Sincronización": [
        "✅ Toggle tema oscuro/claro (persistente)",
        "✅ Selector de color acento (8 opciones)",
        "✅ Forzar sincronización → SyncSheet con progreso (4 pasos)",
        "✅ Resolver conflictos de versión (ConflictSheet)",
        "✅ Toggle sync online/offline con animación",
        "✅ Cerrar sesión funcional",
        "✅ Callbacks para Notificaciones, Privacidad, Ajustes",
    ],
    "UI/UX": [
        "✅ Dark Glassmorphism (accent warm ivory #F0E6D7)",
        "✅ GlassCard con blur(16) + borders glassmórficos",
        "✅ Nav bar flotante pill con glassmorphism",
        "✅ FAB glassmórfico",
        "✅ Glow ambient (cool top-left, warm bottom-right)",
        "✅ Energy bar con gradiente bicolor",
        "✅ Colores semánticos desaturados (mint/rose/yellow)",
    ],
}

STACK_TECNICO = {
    "Frontend": "Flutter 3.3+, Dart",
    "UI": "Material Design, Custom Painters, Animations",
    "State Management": "flutter_bloc + Cubit",
    "Routing": "go_router 14.0",
    "Local Database": "Realm 3.0",
    "Remote Backend": "Supabase PostgreSQL",
    "HTTP Client": "Dio 5.4",
    "DI Container": "get_it 7.7",
    "Persistence": "SharedPreferences 2.3",
    "UI Toolkit": "Google Fonts, Custom Widgets",
}

FRAGMENTOS_CODIGO = {
    "FocusBloc con rondas": '''
class FocusBloc extends Bloc<FocusEvent, FocusState> {
  int _currentRound = 1;

  void _onTick(FocusTick event, Emitter<FocusState> emit) {
    if (state is FocusRunning) {
      final current = state as FocusRunning;
      if (current.secondsLeft <= 1) {
        _timer?.cancel();
        _currentRound++;  // Incrementa ronda
        emit(FocusCompleted(round: current.round));
      } else {
        emit(FocusRunning(
          secondsLeft: current.secondsLeft - 1,
          task: current.task,
          round: current.round
        ));
      }
    }
  }
}
    ''',

    "Login con validaciones": '''
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'El correo es obligatorio';
  }
  final emailRegex = RegExp(r'^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$');
  if (!emailRegex.hasMatch(value)) {
    return 'Correo inválido';
  }
  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'La contraseña es obligatoria';
  }
  if (value.length < 6) {
    return 'Mínimo 6 caracteres';
  }
  return null;
}
    ''',

    "SupabaseSyncService": '''
class SupabaseSyncService {
  Future<int> pushTasks(List<TaskObject> tasks) async {
    int syncedCount = 0;
    for (final task in tasks) {
      if (!task.isSynced) {
        await supabase.from('tasks').upsert({
          'id': task.id.toString(),
          'title': task.title,
          'priority': task.priority,
          'energy': task.energyLevel,
          'project': task.project,
          'is_completed': task.isDone,
          'completed_at': task.completedAt?.toIso8601String(),
          'is_synced': true,
        });
        syncedCount++;
      }
    }
    return syncedCount;
  }
}
    ''',
}

def generate_markdown():
    """Genera markdown con todas las evidencias"""

    lines = []

    # Header
    lines.append(f"# {PROJECT['titulo']}")
    lines.append(f"## {PROJECT['subtitulo']}\n")

    # Alumno
    lines.append("## Identificación del Alumnado")
    lines.append(f"**Nombre:** {PROJECT['alumno']}")
    lines.append(f"**Email:** {PROJECT['email']}")
    lines.append(f"**Fecha:** {PROJECT['fecha']}")
    lines.append(f"**Versión:** {PROJECT['version']}\n")

    # Descripción
    lines.append("## Descripción del Proyecto")
    lines.append("""
KAIROS es una aplicación Flutter de productivity basada en:
- **Offline-First**: Realm como fuente de verdad local, Supabase como remoto
- **Deep Work**: Pomodoro timer con tracking de sesiones
- **Smart Scheduling**: Algoritmo heurístico para optimizar orden de tareas
- **Visual**: Dark Glassmorphism theme con warm ivory accents
    """)

    # Flujo completo
    lines.append("## Flujo Completo de la Aplicación")
    lines.append("""
1. **Splash** → Animación de carga (1.8s)
2. **Onboarding** → 3 slides: Offline-First, Smart Scheduling, Deep Work
3. **Login** → Email + contraseña (validaciones)
4. **Dashboard** → Resumen de tareas hoy + energy bar + botón "Optimizar con IA"
5. **Task Management**:
   - Lista con filtros (Todas/Pendientes/Completadas/Alta prioridad)
   - Crear tarea (título, prioridad, energía, proyecto, fecha)
   - Detalle de tarea (marcar completada, iniciar Focus)
   - Swipe actions (completar derecha, eliminar izquierda)
6. **Focus Mode**:
   - Selector de tarea (o sesión libre)
   - Timer Pomodoro 25min con pausa/resume/reset
   - Contador de rondas dinámico (1/4, 2/4, 3/4, 4/4)
   - Arc animado mostrando progreso
7. **Estadísticas**:
   - KPIs (completadas, tiempo, racha)
   - Bar chart 7 días
   - Heatmap 4 semanas
8. **Perfil**:
   - Toggle tema oscuro/claro
   - Selector de color acento
   - Forzar sincronización (SyncSheet con 4 pasos)
   - Resolver conflictos
   - Toggle sync online/offline
   - Cerrar sesión
    """)

    # Funcionalidades
    for categoria, items in FUNCIONALIDADES.items():
        lines.append(f"\n## {categoria}")
        for item in items:
            lines.append(f"- {item}")

    # Stack técnico
    lines.append("\n## Stack Técnico")
    for area, tech in STACK_TECNICO.items():
        lines.append(f"- **{area}**: {tech}")

    # Fragmentos de código
    lines.append("\n## Fragmentos de Código Clave")
    for titulo, codigo in FRAGMENTOS_CODIGO.items():
        lines.append(f"\n### {titulo}")
        lines.append(f"```dart\n{codigo}\n```")

    # Evidencia de integración
    lines.append("\n## Evidencia de Integración Backend")
    lines.append("""
### Supabase Setup
- **URL**: https://mxhyuzucjygdjmamtcjq.supabase.co
- **Tabla**: `tasks` (id, title, priority, energy, project, is_completed, is_synced)
- **Sync**: SupabaseSyncService.pushTasks() → upsert en Supabase
- **Flujo**: Realm local → Detectar cambios (isSynced=false) → Push a Supabase → Marcar sincronizado

### Operaciones Reales
- Crear tarea en Realm (local)
- Perfil: "Forzar sincronización" → SyncSheet con 4 pasos reales
- Paso 1: Detectando cambios locales
- Paso 2: Preparando datos (JSON serialization)
- Paso 3: Sincronizando con servidor (push real)
- Paso 4: Completado
    """)

    # Validaciones
    lines.append("\n## Validaciones Implementadas")
    lines.append("""
### Login
- Email: formato válido (regex)
- Contraseña: mínimo 6 caracteres

### Create Task
- Título: obligatorio

### Focus
- Timer: 25 minutos (Pomodoro)
- Rondas: contador 1/4 → 2/4 → 3/4 → 4/4
    """)

    # Mejoras visuales
    lines.append("\n## Mejoras Visuales (Glassmorphism)")
    lines.append("""
### Colores
- **Fondo**: #050505 (negro profundo)
- **Accent**: #F0E6D7 (warm ivory, diseño_nuevo)
- **Glass surfaces**: rgba(255,255,255,0.03) con blur(16)
- **Borders**: rgba(255,255,255,0.15)
- **Glows**: Cool (azul) top-left + Warm (marfil) bottom-right

### Componentes
- GlassCard: backdrop-filter blur + inner shadow
- Nav bar: pill flotante con glassmorphism
- FAB: glassmórfico con glow cálido
- Energy bar: gradiente bicolor (cool→warm)
- Cards: semi-transparent con borders sutil
    """)

    # Estado del proyecto
    lines.append("\n## Estado del Proyecto")
    lines.append("""
### Completado en Entrega 2
- ✅ Backend Supabase integrado
- ✅ Validaciones en formularios
- ✅ Todos los botones funcionales (6 callbacks Profile)
- ✅ Stats dinámicas desde datos reales
- ✅ Contador de rondas Pomodoro dinámico
- ✅ Dark Glassmorphism glow up
- ✅ 9/9 tareas implementadas
- ✅ Commit: 9eea941

### Pendiente para Entregas Futuras
- [ ] Autenticación real (Entrega 3)
- [ ] Algoritmo IA para optimización
- [ ] Notificaciones push
- [ ] Sistema de puntos/gamificación
    """)

    return "\n".join(lines)

if __name__ == "__main__":
    md = generate_markdown()

    # Guardar markdown
    with open("Entrega2_KAIROS_Evidencias.md", "w", encoding="utf-8") as f:
        f.write(md)

    print("✅ Evidencias generadas: Entrega2_KAIROS_Evidencias.md")
    print(f"📄 Para convertir a PDF: pandoc Entrega2_KAIROS_Evidencias.md -o Entrega2_KAIROS.pdf")
