# KAIROS — Supabase Migration + Testing + Deploy Design
**Date:** 2026-04-23
**Scope:** Paso 6.5 (Migración) + Paso 7 (Testing + CI/CD + Deploy)

---

## 1. Contexto

El proyecto KAIROS tiene un backend FastAPI (Python) con SQLite/PostgreSQL, auth JWT manual, y un proxy para Gemini AI. El frontend es Flutter con `dio` + `api_client.dart` custom. No existe CI/CD ni tests.

**Decisión:** Reemplazar el backend completo con Supabase (DB + Auth + Edge Functions). Frontend consume Supabase SDK directamente. Deploy: Edge Functions vía Supabase CLI, Flutter Web vía GitHub Pages.

---

## 2. Arquitectura Final

```
Flutter (supabase_flutter SDK)
    ├── Supabase Auth       (register, login, session)
    ├── Supabase DB         (tasks, productivity_debt via RLS)
    └── Supabase Edge Fns   (Gemini proxy: optimize-tasks, debt-reflection)
            └── Gemini API

GitHub Actions
    ├── flutter-ci.yml      (analyze + test + coverage)
    ├── supabase-ci.yml     (deno test edge functions)
    └── deploy.yml          (supabase deploy + gh-pages)
```

**Eliminado:** carpeta `backend/` completa (FastAPI, SQLAlchemy, passlib, jose, etc.)

---

## 3. Fase 1 — Migración a Supabase

### 3.1 Database Schema

```sql
-- TABLA: tasks
CREATE TABLE tasks (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title            text NOT NULL,
  priority         int  NOT NULL DEFAULT 1,
  energy           int  NOT NULL DEFAULT 3,
  estimated_minutes int NOT NULL DEFAULT 0,
  completed        boolean NOT NULL DEFAULT false,
  completed_at     timestamptz,
  abandoned        boolean NOT NULL DEFAULT false,
  abandoned_at     timestamptz,
  latitude         float8,
  longitude        float8,
  created_at       timestamptz NOT NULL DEFAULT now()
);

-- TABLA: productivity_debt
CREATE TABLE productivity_debt (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              uuid UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_debt_minutes   int NOT NULL DEFAULT 0,
  free_time_minutes    int NOT NULL DEFAULT 0,
  last_updated         timestamptz NOT NULL DEFAULT now(),
  notes                text
);
```

Archivo: `supabase/migrations/20260423000000_initial_schema.sql`

### 3.2 Row Level Security (RLS)

```sql
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE productivity_debt ENABLE ROW LEVEL SECURITY;

-- tasks: user ve/modifica solo sus rows
CREATE POLICY "tasks_user_isolation" ON tasks
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- productivity_debt: ídem
CREATE POLICY "debt_user_isolation" ON productivity_debt
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

### 3.3 Edge Functions

```
supabase/functions/
├── optimize-tasks/
│   └── index.ts      -- POST {tasks[]} → {optimized[], explanation}
└── debt-reflection/
    └── index.ts      -- POST {debt_data} → SSE stream (texto estoico)
```

**Ambas funciones:**
- Validan JWT de Supabase en `Authorization: Bearer <token>`
- Llaman Gemini API con `GEMINI_API_KEY` (secret de Supabase, no expuesto al cliente)
- Fallback idéntico al Python actual si Gemini falla
- `debt-reflection` usa `ReadableStream` para SSE

### 3.4 Flutter — Cambios de SDK

| Antes | Después |
|-------|---------|
| `dio: ^5.3.0` | `supabase_flutter: ^2.x` |
| `lib/services/api_client.dart` | `lib/services/supabase_client.dart` |
| JWT manual en SharedPreferences | Session gestionada por Supabase SDK |
| `POST /api/v1/auth/login` | `supabase.auth.signInWithPassword()` |
| `GET/POST /api/v1/tasks` | `supabase.from('tasks').select/insert/update` |
| `POST /api/v1/tasks/optimize` | `supabase.functions.invoke('optimize-tasks')` |
| `GET /api/v1/confessional/reflection` | HTTP streaming directo a Edge Function URL (paquete `http`, JWT en header) |

**Providers afectados:** `auth_provider.dart`, `task_provider.dart` — reescritos para usar Supabase client.

**Eliminado:** carpeta `backend/` completa.

---

## 4. Fase 2 — Tests + CI/CD + Deploy

### 4.1 Flutter Tests

**Estructura:**
```
frontend/test/
├── unit/
│   ├── task_provider_test.dart       -- CRUD, estados loading/error/success
│   ├── auth_provider_test.dart       -- signIn, signUp, signOut, session restore
│   └── debt_calculations_test.dart   -- severity ratio (critical/warning/healthy)
└── widget/
    ├── task_card_test.dart           -- render, tap complete, tap abandon
    ├── debt_severity_card_test.dart  -- render con datos reales, colores
    ├── stoic_input_test.dart         -- focus state, border change
    └── reflection_display_test.dart  -- texto streaming, cursor animation
```

**Nota sobre streaming:** `supabase.functions.invoke()` bufferiza — no soporta SSE. `debt-reflection` se consume vía `http` package con streaming manual + JWT de `supabase.auth.currentSession?.accessToken` en el header `Authorization`.

**Dependencies de test:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  flutter_lints: ^2.0.0
```

**Mock strategy:** `MockSupabaseClient` con `mocktail`. Unit tests mockean Supabase client. Widget tests usan `ProviderScope` con providers sobreescritos.

**Coverage objetivo:** ≥80% en `lib/providers/` y `lib/widgets/`.

### 4.2 Edge Function Tests (Deno)

```
supabase/functions/
├── optimize-tasks/
│   ├── index.ts
│   └── optimize_test.ts    -- mock fetch a Gemini, verifica JSON {optimized, explanation}
└── debt-reflection/
    ├── index.ts
    └── reflection_test.ts  -- mock stream, verifica chunks SSE no vacíos
```

Comando: `deno test --allow-net supabase/functions/`

### 4.3 GitHub Actions Workflows

**`flutter-ci.yml`** — trigger: push/PR → main
```
setup Flutter → flutter pub get → flutter analyze (0 errors) →
flutter test --coverage → upload Codecov
```

**`supabase-ci.yml`** — trigger: push/PR → main
```
setup Deno → deno test supabase/functions/
```

**`deploy.yml`** — trigger: push → main (needs flutter-ci + supabase-ci pass)
```
job 1: supabase functions deploy (usa SUPABASE_ACCESS_TOKEN)
job 2: flutter build web --base-href /<repo>/ →
        peaceiris/actions-gh-pages → branch gh-pages
```

### 4.4 GitHub Secrets (4 total)

| Secret | Uso |
|--------|-----|
| `SUPABASE_URL` | Flutter build + deploy workflow |
| `SUPABASE_ANON_KEY` | Flutter build (público, pero no en repo) |
| `SUPABASE_ACCESS_TOKEN` | `supabase functions deploy` en CI |
| `GEMINI_API_KEY` | Secret en Supabase (no en GitHub) |

> `GEMINI_API_KEY` se configura en Supabase Dashboard → Edge Functions → Secrets. No va a GitHub Secrets.

### 4.5 GitHub Pages

- Branch: `gh-pages` (auto-creado por `peaceiris/actions-gh-pages`)
- Base href: `/<nombre-repo>/` en el build
- URL final: `https://ismaelmanzanoleon.github.io/<repo>/`

---

## 5. Archivos que se crean/modifican

### Nuevos
```
supabase/
├── config.toml
├── migrations/
│   └── 20260423000000_initial_schema.sql
└── functions/
    ├── optimize-tasks/
    │   ├── index.ts
    │   └── optimize_test.ts
    └── debt-reflection/
        ├── index.ts
        └── reflection_test.ts

.github/workflows/
├── flutter-ci.yml
├── supabase-ci.yml
└── deploy.yml

frontend/test/
├── unit/ (3 archivos)
└── widget/ (4 archivos)

.env.example (actualizado)
```

### Modificados
```
frontend/pubspec.yaml          -- supabase_flutter, http (streaming); mocktail dev; quitar dio
frontend/lib/main.dart         -- Supabase.initialize()
frontend/lib/services/         -- supabase_client.dart (reemplaza api_client.dart)
frontend/lib/providers/        -- auth_provider, task_provider reescritos
frontend/lib/screens/          -- login, register, confessional (adaptar auth calls)
```

### Eliminados
```
backend/                       -- completo
```

---

## 6. Validación

- `flutter test` → ≥80% coverage en providers + widgets
- `deno test` → edge functions pasan sin errores
- GitHub Actions → los 3 workflows pasan en verde
- `https://ismaelmanzanoleon.github.io/<repo>/` → app carga
- Supabase Dashboard → Edge Functions activas
- Auth funcional end-to-end en web deploy
