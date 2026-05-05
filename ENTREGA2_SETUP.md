# KAIROS Entrega 2 — Setup & Testing

## 1. Crear tabla en Supabase

1. Ir a https://app.supabase.com/project/mxhyuzucjygdjmamtcjq/sql/new
2. Copiar contenido de `kairos/SQL_SETUP_SUPABASE.sql`
3. Pegar en SQL Editor
4. Click "Run" (▶️)

Tabla `tasks` creada ✅

## 2. Run local

```bash
cd kairos/
flutter pub get  # (ya hecho)
flutter run
```

La app:
- Inicia en Splash → Onboarding → Login
- Login: cualquier email + contraseña de 6+ chars
- Dashboard muestra tareas
- Profile: "Forzar sincronización" → SyncSheet con progreso real
- Focus: timer Pomodoro con ronda dinámica (1/4, 2/4...)
- Todos los botones funcionales (campana, toggle sync, logout, etc)

## 3. Evidencias capturadas

Pantallas para PDF:
1. Splash
2. Onboarding (slide 1)
3. Login con validaciones
4. Dashboard con tareas
5. Task list con filtros
6. Create task
7. Focus mode
8. Focus timer (ronda dinámica)
9. Stats page
10. Profile (callbacks funcionales)
11. SyncSheet
12. ConflictSheet

## 4. Flujo completo

Splash → Onboarding → Login (validaciones) → Dashboard → 
[Crear tarea] → [Ver detalles] → [Iniciar focus] → [Timer Pomodoro] → 
[Ver stats] → [Perfil: logout]

## Commits

- `9eea941`: KAIROS Entrega 2 - Backend integrado + UI mejorada

## Estado

- ✅ Supabase integrado
- ✅ Validaciones login
- ✅ Todos los callbacks funcionales
- ✅ Stats dinámicas
- ✅ Glassmorphism dark theme
- ✅ 9/9 tasks completadas
