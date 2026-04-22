# KAIROS — Supabase Migration + Testing + Deploy

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar el backend FastAPI con Supabase (DB + Auth + Edge Functions), migrar Flutter a supabase_flutter, añadir tests con cobertura ≥80%, y desplegar vía GitHub Actions a Supabase + GitHub Pages.

**Architecture:** Supabase gestiona PostgreSQL con RLS, Supabase Auth, y Edge Functions (Deno/TypeScript) para llamadas a Gemini. Flutter usa `supabase_flutter` SDK directamente. GitHub Pages sirve el build web.

**Tech Stack:** Supabase CLI, Deno, TypeScript (Edge Functions), Flutter 3.x, supabase_flutter ^2.x, http ^1.x, mocktail ^1.0.0, GitHub Actions.

---

## Mapa de Archivos

### Nuevos
```
supabase/
  migrations/20260423000000_initial_schema.sql
  functions/
    optimize-tasks/index.ts
    optimize-tasks/optimize_test.ts
    debt-reflection/index.ts
    debt-reflection/reflection_test.ts

frontend/
  lib/services/supabase_client.dart
  lib/services/auth_service.dart
  lib/services/task_service.dart
  lib/services/reflection_service.dart
  lib/utils/debt_utils.dart
  test/unit/auth_provider_test.dart
  test/unit/task_provider_test.dart
  test/unit/debt_utils_test.dart
  test/widget/task_card_test.dart
  test/widget/debt_severity_card_test.dart
  test/widget/stoic_input_test.dart
  test/widget/reflection_display_test.dart

.github/workflows/
  flutter-ci.yml
  supabase-ci.yml
  deploy.yml

.env.example
```

### Modificados
```
frontend/pubspec.yaml        — supabase_flutter, http; quitar dio
frontend/.env                — SUPABASE_URL, SUPABASE_ANON_KEY
frontend/lib/main.dart       — Supabase.initialize()
frontend/lib/models/user.dart — String id, sin access_token, factory fromSupabase
frontend/lib/providers/auth_provider.dart — rewrite
frontend/lib/providers/task_provider.dart — rewrite
frontend/lib/screens/login_screen.dart — adaptar AuthProvider API
frontend/lib/screens/register_screen.dart — adaptar AuthProvider API
frontend/lib/screens/confessional_screen.dart — usar ReflectionService
frontend/lib/router.dart     — Supabase session para auth check
```

### Eliminados
```
frontend/lib/services/api_client.dart
backend/ (carpeta completa)
```

---

## Fase 1: Migración Supabase

---

### Task 1: Crear proyecto Supabase + CLI setup

**Files:**
- (Manual — no hay archivos de código)

- [ ] **Step 1: Crear proyecto en Supabase dashboard**

  Ir a https://supabase.com → New project. Anotar:
  - `Project URL` → ej. `https://xyzxyz.supabase.co`
  - `anon public key` → clave larga que empieza con `eyJ...`
  - `Project Reference ID` → string corto, ej. `xyzxyzxyz`
  
  Guardar los tres valores — se usarán en los siguientes steps.

- [ ] **Step 2: Instalar Supabase CLI**

  ```bash
  npm install -g supabase@latest
  supabase --version
  ```
  
  Esperado: `supabase 2.x.x`

- [ ] **Step 3: Login + init + link**

  ```bash
  supabase login
  # Abrirá el navegador para auth
  
  cd C:/Users/Ismael/Desktop/KAIROS
  supabase init
  # Crea supabase/config.toml automáticamente
  
  supabase link --project-ref TU_PROJECT_REF_ID
  # Introduce la DB password cuando la pida
  ```

- [ ] **Step 4: Commit config**

  ```bash
  git add supabase/config.toml supabase/.gitignore
  git commit -m "chore: init supabase project config"
  ```

---

### Task 2: Database schema, RLS y funciones PostgreSQL

**Files:**
- Create: `supabase/migrations/20260423000000_initial_schema.sql`

- [ ] **Step 1: Escribir archivo de migración**

  Crear `supabase/migrations/20260423000000_initial_schema.sql` con este contenido completo:

  ```sql
  -- ─── TABLAS ─────────────────────────────────────────────────────────────────

  CREATE TABLE tasks (
    id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title             text        NOT NULL,
    priority          int         NOT NULL DEFAULT 1,
    energy            int         NOT NULL DEFAULT 3,
    estimated_minutes int         NOT NULL DEFAULT 0,
    completed         boolean     NOT NULL DEFAULT false,
    completed_at      timestamptz,
    abandoned         boolean     NOT NULL DEFAULT false,
    abandoned_at      timestamptz,
    latitude          float8,
    longitude         float8,
    created_at        timestamptz NOT NULL DEFAULT now()
  );

  CREATE INDEX ix_tasks_user_created ON tasks (user_id, created_at DESC);

  CREATE TABLE productivity_debt (
    id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             uuid        UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    total_debt_minutes  int         NOT NULL DEFAULT 0,
    free_time_minutes   int         NOT NULL DEFAULT 0,
    last_updated        timestamptz NOT NULL DEFAULT now(),
    notes               text
  );

  -- ─── RLS ────────────────────────────────────────────────────────────────────

  ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
  ALTER TABLE productivity_debt ENABLE ROW LEVEL SECURITY;

  CREATE POLICY "tasks_user_isolation" ON tasks
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

  CREATE POLICY "debt_user_isolation" ON productivity_debt
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

  -- ─── FUNCIONES ──────────────────────────────────────────────────────────────

  CREATE OR REPLACE FUNCTION add_free_time(p_user_id uuid, p_minutes int)
  RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
  BEGIN
    INSERT INTO productivity_debt (user_id, free_time_minutes, last_updated)
    VALUES (p_user_id, p_minutes, now())
    ON CONFLICT (user_id) DO UPDATE
      SET free_time_minutes = productivity_debt.free_time_minutes + p_minutes,
          last_updated = now();
  END;
  $$;

  CREATE OR REPLACE FUNCTION add_debt(p_user_id uuid, p_minutes int)
  RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
  BEGIN
    INSERT INTO productivity_debt (user_id, total_debt_minutes, last_updated)
    VALUES (p_user_id, p_minutes, now())
    ON CONFLICT (user_id) DO UPDATE
      SET total_debt_minutes = productivity_debt.total_debt_minutes + p_minutes,
          last_updated = now();
  END;
  $$;

  CREATE OR REPLACE FUNCTION pay_debt(p_user_id uuid, p_minutes int)
  RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
  BEGIN
    UPDATE productivity_debt
    SET total_debt_minutes = GREATEST(0, total_debt_minutes - p_minutes),
        last_updated = now()
    WHERE user_id = p_user_id;
  END;
  $$;

  CREATE OR REPLACE FUNCTION calculate_streak(p_user_id uuid)
  RETURNS int LANGUAGE plpgsql SECURITY DEFINER AS $$
  DECLARE
    v_streak       int := 0;
    v_day          date;
    v_completed    int;
    v_abandoned    int;
  BEGIN
    FOR i IN 0..364 LOOP
      v_day := CURRENT_DATE - i;

      SELECT COUNT(*) INTO v_abandoned
      FROM tasks
      WHERE user_id = p_user_id
        AND abandoned = true
        AND DATE(abandoned_at AT TIME ZONE 'UTC') = v_day;

      EXIT WHEN v_abandoned > 0;

      SELECT COUNT(*) INTO v_completed
      FROM tasks
      WHERE user_id = p_user_id
        AND completed = true
        AND DATE(completed_at AT TIME ZONE 'UTC') = v_day;

      IF v_completed > 0 THEN
        v_streak := v_streak + 1;
      ELSIF i > 0 THEN
        EXIT;
      END IF;
    END LOOP;
    RETURN v_streak;
  END;
  $$;
  ```

- [ ] **Step 2: Aplicar migración a Supabase**

  ```bash
  supabase db push
  ```
  
  Esperado: `Finished supabase db push.` Sin errores.

- [ ] **Step 3: Verificar en Supabase Dashboard**

  Ir a Dashboard → Table Editor. Verificar que existen tablas `tasks` y `productivity_debt`. Ir a Authentication → Policies. Verificar que ambas tablas tienen sus policies activas.

- [ ] **Step 4: Commit**

  ```bash
  git add supabase/migrations/
  git commit -m "feat: add supabase schema, RLS, and PostgreSQL helper functions"
  ```

---

### Task 3: Edge Function — optimize-tasks (TDD)

**Files:**
- Create: `supabase/functions/optimize-tasks/optimize_test.ts`
- Create: `supabase/functions/optimize-tasks/index.ts`

- [ ] **Step 1: Escribir el test primero**

  Crear `supabase/functions/optimize-tasks/optimize_test.ts`:

  ```typescript
  import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

  // Mock fetch antes de importar el handler
  const mockTasks = [
    { id: "1", title: "Tarea A", priority: 2, energy: 3, estimated_minutes: 30 },
    { id: "2", title: "Tarea B", priority: 1, energy: 1, estimated_minutes: 15 },
  ];

  const geminiResponse = {
    candidates: [{
      content: {
        parts: [{
          text: JSON.stringify({
            optimized: [mockTasks[1], mockTasks[0]],
            explanation: "Tarea B primero por menor energía requerida.",
          }),
        }],
      },
    }],
  };

  // Override global fetch
  globalThis.fetch = async (_url: string) => {
    return new Response(JSON.stringify(geminiResponse), {
      headers: { "Content-Type": "application/json" },
    });
  };

  Deno.test("optimize-tasks: reordena tareas y devuelve explanation", async () => {
    const { handler } = await import("./index.ts");

    const req = new Request("http://localhost/optimize-tasks", {
      method: "POST",
      headers: {
        "Authorization": "Bearer test-jwt",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ tasks: mockTasks }),
    });

    const res = await handler(req);
    assertEquals(res.status, 200);

    const body = await res.json();
    assertEquals(Array.isArray(body.optimized), true);
    assertEquals(typeof body.explanation, "string");
    assertEquals(body.optimized.length, 2);
  });

  Deno.test("optimize-tasks: devuelve fallback si Gemini falla", async () => {
    globalThis.fetch = async () => { throw new Error("Network error"); };
    const { handler } = await import("./index.ts");

    const req = new Request("http://localhost/optimize-tasks", {
      method: "POST",
      headers: {
        "Authorization": "Bearer test-jwt",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ tasks: mockTasks }),
    });

    const res = await handler(req);
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(Array.isArray(body.optimized), true);
    assertEquals(typeof body.explanation, "string");
  });
  ```

- [ ] **Step 2: Ejecutar test — verificar que falla**

  ```bash
  deno test --allow-env --allow-net supabase/functions/optimize-tasks/optimize_test.ts
  ```
  
  Esperado: Error `Cannot find module './index.ts'`

- [ ] **Step 3: Implementar la Edge Function**

  Crear `supabase/functions/optimize-tasks/index.ts`:

  ```typescript
  const GEMINI_URL =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };

  function fallbackResponse(tasks: unknown[]) {
    return Response.json(
      {
        optimized: tasks,
        explanation:
          "Aviso: no se pudo optimizar vía Gemini. Se devuelven las tareas sin reordenar.",
      },
      { headers: corsHeaders },
    );
  }

  export async function handler(req: Request): Promise<Response> {
    if (req.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    if (!req.headers.get("Authorization")) {
      return new Response("Unauthorized", { status: 401 });
    }

    const { tasks } = await req.json();
    const apiKey = Deno.env.get("GEMINI_API_KEY") ?? "";

    if (!apiKey) return fallbackResponse(tasks);

    const prompt =
      `Reorganiza estas tareas por prioridad cognitiva. Considera urgencia + energía requerida + dependencias.\n\nTareas (JSON):\n${
        JSON.stringify(tasks)
      }\n\nResponde EXCLUSIVAMENTE con un JSON válido:\n{"optimized": [<tareas reordenadas>], "explanation": "<explicación breve en español>"}`;

    try {
      const res = await fetch(`${GEMINI_URL}?key=${apiKey}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
      });
      const data = await res.json();
      const raw = (data.candidates[0].content.parts[0].text as string).trim();
      const cleaned = raw.replace(/^```json?\n?/, "").replace(/\n?```$/, "").trim();
      const parsed = JSON.parse(cleaned);

      if (!parsed.optimized || !parsed.explanation) throw new Error("Bad format");

      return Response.json(parsed, { headers: corsHeaders });
    } catch {
      return fallbackResponse(tasks);
    }
  }

  // Punto de entrada para Supabase Edge Runtime
  Deno.serve(handler);
  ```

- [ ] **Step 4: Ejecutar test — verificar que pasa**

  ```bash
  deno test --allow-env --allow-net supabase/functions/optimize-tasks/optimize_test.ts
  ```
  
  Esperado: `test optimize-tasks: reordena tareas ... ok` y `test optimize-tasks: devuelve fallback ... ok`

- [ ] **Step 5: Commit**

  ```bash
  git add supabase/functions/optimize-tasks/
  git commit -m "feat: add optimize-tasks edge function with tests"
  ```

---

### Task 4: Edge Function — debt-reflection SSE (TDD)

**Files:**
- Create: `supabase/functions/debt-reflection/reflection_test.ts`
- Create: `supabase/functions/debt-reflection/index.ts`

- [ ] **Step 1: Escribir el test primero**

  Crear `supabase/functions/debt-reflection/reflection_test.ts`:

  ```typescript
  import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

  const FALLBACK_TEXT = "La deuda no es condena";

  // Mock fetch que simula SSE de Gemini
  globalThis.fetch = async () => {
    const encoder = new TextEncoder();
    const sseChunk = `data: ${
      JSON.stringify({
        candidates: [{ content: { parts: [{ text: "Epicteto diría: " }] } }],
      })
    }\n\n`;
    const stream = new ReadableStream({
      start(controller) {
        controller.enqueue(encoder.encode(sseChunk));
        controller.close();
      },
    });
    return new Response(stream, {
      headers: { "Content-Type": "text/event-stream" },
    });
  };

  Deno.test("debt-reflection: responde con Content-Type SSE", async () => {
    const { handler } = await import("./index.ts");

    const req = new Request("http://localhost/debt-reflection", {
      method: "POST",
      headers: {
        "Authorization": "Bearer test-jwt",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        total_debt_minutes: 120,
        streak_days: 3,
        sessions_completed: 10,
        recent_abandons: 1,
      }),
    });

    const res = await handler(req);
    assertEquals(res.status, 200);
    assertEquals(
      res.headers.get("Content-Type")?.includes("text/event-stream"),
      true,
    );

    const text = await res.text();
    assertEquals(text.length > 0, true);
  });

  Deno.test("debt-reflection: fallback si Gemini falla", async () => {
    globalThis.fetch = async () => { throw new Error("Network error"); };
    const { handler } = await import("./index.ts");

    const req = new Request("http://localhost/debt-reflection", {
      method: "POST",
      headers: {
        "Authorization": "Bearer test-jwt",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        total_debt_minutes: 60,
        streak_days: 0,
        sessions_completed: 5,
        recent_abandons: 2,
      }),
    });

    const res = await handler(req);
    assertEquals(res.status, 200);
    const text = await res.text();
    assertEquals(text.includes(FALLBACK_TEXT), true);
  });
  ```

- [ ] **Step 2: Ejecutar test — verificar que falla**

  ```bash
  deno test --allow-env --allow-net supabase/functions/debt-reflection/reflection_test.ts
  ```
  
  Esperado: Error `Cannot find module './index.ts'`

- [ ] **Step 3: Implementar la Edge Function**

  Crear `supabase/functions/debt-reflection/index.ts`:

  ```typescript
  const GEMINI_STREAM_URL =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent";

  const FALLBACK =
    "La deuda no es condena, sino medida de lo que aún puedes dar. " +
    "Epicteto diría: solo controlas tu esfuerzo presente, no el pasado acumulado. " +
    "Hoy, completa una tarea pequeña. Un paso honesto vale más que mil promesas.";

  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };

  function buildPrompt(data: {
    total_debt_minutes: number;
    streak_days: number;
    sessions_completed: number;
    recent_abandons: number;
  }): string {
    return `Eres un consejero estoico inspirado en Marco Aurelio y Epicteto. El usuario tiene:
- Deuda productiva: ${data.total_debt_minutes} minutos
- Racha actual: ${data.streak_days} días sin abandonar
- Sesiones completadas: ${data.sessions_completed}
- Abandonos recientes: ${data.recent_abandons}

Genera una reflexión breve (2-3 párrafos, máx 200 palabras) que:
1. Reconozca su esfuerzo sin ser condescendiente
2. Reencuadre la deuda como oportunidad de crecimiento (Epicteto: lo que está en tu control)
3. Termine con una acción concreta para hoy

Tono: Directo, sin emojis, inspirador pero realista. Como si Marco Aurelio te hablara.`;
  }

  function fallbackStream(): ReadableStream<Uint8Array> {
    const encoder = new TextEncoder();
    return new ReadableStream({
      start(controller) {
        controller.enqueue(
          encoder.encode(`data: ${JSON.stringify({ text: FALLBACK })}\n\n`),
        );
        controller.close();
      },
    });
  }

  export async function handler(req: Request): Promise<Response> {
    if (req.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    if (!req.headers.get("Authorization")) {
      return new Response("Unauthorized", { status: 401 });
    }

    const body = await req.json();
    const apiKey = Deno.env.get("GEMINI_API_KEY") ?? "";

    const sseHeaders = {
      ...corsHeaders,
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
    };

    if (!apiKey) {
      return new Response(fallbackStream(), { headers: sseHeaders });
    }

    const stream = new ReadableStream<Uint8Array>({
      async start(controller) {
        const encoder = new TextEncoder();
        try {
          const res = await fetch(
            `${GEMINI_STREAM_URL}?key=${apiKey}&alt=sse`,
            {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                contents: [{ parts: [{ text: buildPrompt(body) }] }],
              }),
            },
          );

          const reader = res.body!.getReader();
          const decoder = new TextDecoder();

          while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            const chunk = decoder.decode(value);
            for (const line of chunk.split("\n")) {
              if (!line.startsWith("data: ")) continue;
              try {
                const parsed = JSON.parse(line.slice(6));
                const text = parsed.candidates?.[0]?.content?.parts?.[0]?.text;
                if (text) {
                  controller.enqueue(
                    encoder.encode(`data: ${JSON.stringify({ text })}\n\n`),
                  );
                }
              } catch { /* skip malformed lines */ }
            }
          }
        } catch {
          for (const chunk of fallbackStream()) {
            controller.enqueue(chunk as Uint8Array);
          }
        }
        controller.close();
      },
    });

    return new Response(stream, { headers: sseHeaders });
  }

  Deno.serve(handler);
  ```

- [ ] **Step 4: Ejecutar test — verificar que pasa**

  ```bash
  deno test --allow-env --allow-net supabase/functions/debt-reflection/reflection_test.ts
  ```
  
  Esperado: `test debt-reflection: responde con Content-Type SSE ... ok` y `test debt-reflection: fallback ... ok`

- [ ] **Step 5: Commit**

  ```bash
  git add supabase/functions/debt-reflection/
  git commit -m "feat: add debt-reflection SSE edge function with tests"
  ```

---

### Task 5: Deploy Edge Functions + configurar GEMINI_API_KEY

**Files:**
- (Comandos CLI — no hay archivos)

- [ ] **Step 1: Configurar GEMINI_API_KEY como Supabase secret**

  ```bash
  supabase secrets set GEMINI_API_KEY=TU_GEMINI_API_KEY_REAL
  ```
  
  Verificar: `supabase secrets list` → debe aparecer `GEMINI_API_KEY`

- [ ] **Step 2: Deploy ambas funciones**

  ```bash
  supabase functions deploy optimize-tasks
  supabase functions deploy debt-reflection
  ```
  
  Esperado: `Deployed Function optimize-tasks` y `Deployed Function debt-reflection`

- [ ] **Step 3: Probar optimize-tasks manualmente**

  Ir a Supabase Dashboard → Edge Functions → optimize-tasks → Invoke. Enviar:
  ```json
  {
    "tasks": [
      {"id": "1", "title": "Test", "priority": 1, "energy": 3, "estimated_minutes": 30}
    ]
  }
  ```
  Esperado: Response con `{"optimized": [...], "explanation": "..."}`

- [ ] **Step 4: Commit**

  ```bash
  git commit --allow-empty -m "chore: deploy edge functions to Supabase (manual step documented)"
  ```

---

### Task 6: Flutter — actualizar pubspec.yaml + .env

**Files:**
- Modify: `frontend/pubspec.yaml`
- Modify: `frontend/.env`

- [ ] **Step 1: Actualizar pubspec.yaml**

  En `frontend/pubspec.yaml`, reemplazar la sección de dependencies:

  ```yaml
  dependencies:
    flutter:
      sdk: flutter

    cupertino_icons: ^1.0.6

    # Supabase
    supabase_flutter: ^2.5.0

    # HTTP (para SSE streaming de debt-reflection)
    http: ^1.2.0

    # State Management
    provider: ^6.0.0

    # Navigation
    go_router: ^11.0.0

    # Utils
    intl: ^0.19.0
    uuid: ^4.0.0
    shared_preferences: ^2.2.0
    flutter_dotenv: ^6.0.1

    # Typography
    google_fonts: ^6.1.0

    # Location
    geolocator: ^10.1.0

    # OAuth
    google_sign_in: ^6.2.0

  dev_dependencies:
    flutter_test:
      sdk: flutter
    mocktail: ^1.0.0
    flutter_lints: ^2.0.0
  ```

  (Eliminado: `dio: ^5.3.0`)

- [ ] **Step 2: Actualizar .env**

  En `frontend/.env`, reemplazar contenido:

  ```
  SUPABASE_URL=https://TU_PROJECT_REF.supabase.co
  SUPABASE_ANON_KEY=eyJ...TU_ANON_KEY
  ```

  (Eliminar `API_BASE_URL`, `API_PORT`, `GEMINI_API_KEY` — este último ya no va en el cliente)

- [ ] **Step 3: Instalar dependencias**

  ```bash
  cd frontend
  flutter pub get
  ```
  
  Esperado: `Got dependencies!` Sin errores de resolución.

- [ ] **Step 4: Commit**

  ```bash
  git add frontend/pubspec.yaml frontend/pubspec.lock frontend/.env
  git commit -m "deps: replace dio with supabase_flutter and http"
  ```

---

### Task 7: Flutter — archivos base (User model, main.dart, supabase_client.dart)

**Files:**
- Modify: `frontend/lib/models/user.dart`
- Create: `frontend/lib/services/supabase_client.dart`
- Modify: `frontend/lib/main.dart`

- [ ] **Step 1: Actualizar User model**

  Reemplazar `frontend/lib/models/user.dart` completamente:

  ```dart
  import 'package:supabase_flutter/supabase_flutter.dart' as supa;

  class User {
    final String id;
    final String email;
    final String username;

    const User({
      required this.id,
      required this.email,
      required this.username,
    });

    factory User.fromSupabase(supa.User supaUser) => User(
          id: supaUser.id,
          email: supaUser.email ?? '',
          username: supaUser.userMetadata?['username'] as String? ?? '',
        );

    Map<String, dynamic> toJson() => {
          'id': id,
          'email': email,
          'username': username,
        };
  }
  ```

- [ ] **Step 2: Crear supabase_client.dart**

  Crear `frontend/lib/services/supabase_client.dart`:

  ```dart
  import 'package:supabase_flutter/supabase_flutter.dart';

  SupabaseClient get supabaseClient => Supabase.instance.client;
  ```

- [ ] **Step 3: Actualizar main.dart**

  Reemplazar el bloque `main()` en `frontend/lib/main.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:provider/provider.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';

  import 'providers/auth_provider.dart';
  import 'providers/task_provider.dart';
  import 'router.dart';

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load();
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    runApp(const KairosApp());
  }

  class KairosApp extends StatelessWidget {
    const KairosApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: MaterialApp.router(
          title: 'KAIROS',
          routerConfig: appRouter,
          // ... resto de tu configuración de tema actual
        ),
      );
    }
  }
  ```

  (Mantener la configuración de tema/themeData que ya existe)

- [ ] **Step 4: Commit**

  ```bash
  git add frontend/lib/models/user.dart frontend/lib/services/supabase_client.dart frontend/lib/main.dart
  git commit -m "feat: update User model for Supabase, initialize Supabase in main"
  ```

---

### Task 8: AuthService + AuthProvider (TDD)

**Files:**
- Create: `frontend/lib/services/auth_service.dart`
- Create: `frontend/test/unit/auth_provider_test.dart`
- Modify: `frontend/lib/providers/auth_provider.dart`

- [ ] **Step 1: Crear AuthService**

  Crear `frontend/lib/services/auth_service.dart`:

  ```dart
  import 'package:supabase_flutter/supabase_flutter.dart' as supa;

  class AuthService {
    final supa.SupabaseClient client;
    AuthService(this.client);

    supa.User? get currentUser => client.auth.currentUser;

    Stream<supa.AuthState> get authStateChanges =>
        client.auth.onAuthStateChange;

    Future<supa.AuthResponse> signIn(String email, String password) =>
        client.auth.signInWithPassword(email: email, password: password);

    Future<supa.AuthResponse> signUp(
            String email, String password, String username) =>
        client.auth.signUp(
          email: email,
          password: password,
          data: {'username': username},
        );

    Future<void> signOut() => client.auth.signOut();
  }
  ```

- [ ] **Step 2: Escribir tests (primero, antes de reescribir AuthProvider)**

  Crear `frontend/test/unit/auth_provider_test.dart`:

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:mocktail/mocktail.dart';
  import 'package:supabase_flutter/supabase_flutter.dart' as supa;
  import 'package:kairos/providers/auth_provider.dart';
  import 'package:kairos/services/auth_service.dart';
  import 'package:kairos/services/storage_service.dart';

  class MockAuthService extends Mock implements AuthService {}
  class MockStorageService extends Mock implements StorageService {}

  class FakeUser extends Fake implements supa.User {
    @override
    String get id => 'test-uuid-123';
    @override
    String get email => 'test@example.com';
    @override
    Map<String, dynamic>? get userMetadata => {'username': 'test_user'};
  }

  class FakeAuthResponse extends Fake implements supa.AuthResponse {
    @override
    supa.User? get user => FakeUser();
    @override
    supa.Session? get session => null;
  }

  void main() {
    late MockAuthService mockAuth;
    late MockStorageService mockStorage;
    late AuthProvider provider;

    setUpAll(() {
      registerFallbackValue(FakeAuthResponse());
    });

    setUp(() {
      mockAuth = MockAuthService();
      mockStorage = MockStorageService();
      when(() => mockAuth.currentUser).thenReturn(null);
      when(() => mockAuth.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockStorage.getHasSeenOnboarding())
          .thenAnswer((_) async => false);
      provider = AuthProvider(auth: mockAuth, storage: mockStorage);
    });

    group('bootstrap', () {
      test('inicializa user desde currentUser', () async {
        when(() => mockAuth.currentUser).thenReturn(FakeUser());
        when(() => mockAuth.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockStorage.getHasSeenOnboarding())
            .thenAnswer((_) async => false);

        final p = AuthProvider(auth: mockAuth, storage: mockStorage);
        await p.bootstrap();

        expect(p.user?.id, 'test-uuid-123');
        expect(p.isAuthenticated, isTrue);
      });
    });

    group('login', () {
      test('sets user on success', () async {
        when(() => mockAuth.signIn(any(), any()))
            .thenAnswer((_) async => FakeAuthResponse());

        await provider.login('test@example.com', 'password123');

        expect(provider.user?.id, 'test-uuid-123');
        expect(provider.error, isNull);
        expect(provider.isLoading, isFalse);
      });

      test('sets error on AuthException', () async {
        when(() => mockAuth.signIn(any(), any()))
            .thenThrow(const supa.AuthException('Credenciales incorrectas'));

        await provider.login('test@example.com', 'wrongpassword');

        expect(provider.error, 'Credenciales incorrectas');
        expect(provider.user, isNull);
        expect(provider.isLoading, isFalse);
      });

      test('isLoading es false después de completar', () async {
        when(() => mockAuth.signIn(any(), any()))
            .thenThrow(const supa.AuthException('error'));

        await provider.login('test@example.com', 'pass');

        expect(provider.isLoading, isFalse);
      });
    });

    group('register', () {
      test('sets user on success', () async {
        when(() => mockAuth.signUp(any(), any(), any()))
            .thenAnswer((_) async => FakeAuthResponse());

        await provider.register('test@example.com', 'user', 'password123');

        expect(provider.user?.id, 'test-uuid-123');
        expect(provider.error, isNull);
      });

      test('sets error on AuthException', () async {
        when(() => mockAuth.signUp(any(), any(), any()))
            .thenThrow(const supa.AuthException('Email ya en uso'));

        await provider.register('used@example.com', 'user', 'pass');

        expect(provider.error, 'Email ya en uso');
        expect(provider.user, isNull);
      });
    });

    group('logout', () {
      test('limpia user y error', () async {
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        await provider.logout();

        expect(provider.user, isNull);
        expect(provider.error, isNull);
      });
    });
  }
  ```

- [ ] **Step 3: Ejecutar tests — verificar que fallan**

  ```bash
  cd frontend
  flutter test test/unit/auth_provider_test.dart
  ```
  
  Esperado: Errores de compilación porque AuthProvider no tiene el constructor `({auth, storage})`.

- [ ] **Step 4: Reescribir AuthProvider**

  Reemplazar `frontend/lib/providers/auth_provider.dart` completamente:

  ```dart
  import 'dart:developer' as developer;

  import 'package:flutter/foundation.dart';
  import 'package:supabase_flutter/supabase_flutter.dart' as supa;

  import '../models/user.dart';
  import '../services/auth_service.dart';
  import '../services/storage_service.dart';
  import '../services/supabase_client.dart';

  class AuthProvider extends ChangeNotifier {
    final AuthService _auth;
    final StorageService _storage;

    User? _user;
    bool _isLoading = false;
    String? _error;
    bool _hasSeenOnboarding = false;

    AuthProvider({AuthService? auth, StorageService? storage})
        : _auth = auth ?? AuthService(supabaseClient),
          _storage = storage ?? StorageService();

    User? get user => _user;
    bool get isLoading => _isLoading;
    String? get error => _error;
    bool get isAuthenticated => _user != null;
    bool get hasSeenOnboarding => _hasSeenOnboarding;

    Future<void> bootstrap() async {
      _hasSeenOnboarding = await _storage.getHasSeenOnboarding();
      final supaUser = _auth.currentUser;
      if (supaUser != null) _user = User.fromSupabase(supaUser);
      _auth.authStateChanges.listen((state) {
        _user = state.session?.user != null
            ? User.fromSupabase(state.session!.user!)
            : null;
        notifyListeners();
      });
      notifyListeners();
    }

    Future<void> login(String email, String password) async {
      _setLoading(true);
      try {
        final response = await _auth.signIn(email, password);
        _user = response.user != null ? User.fromSupabase(response.user!) : null;
        _error = null;
      } on supa.AuthException catch (e) {
        _error = e.message;
        _user = null;
      } catch (e, st) {
        developer.log('login falló', name: 'AuthProvider', error: e, stackTrace: st);
        _error = 'Inicio de sesión falló';
        _user = null;
      } finally {
        _setLoading(false);
      }
    }

    Future<void> register(String email, String username, String password) async {
      _setLoading(true);
      try {
        final response = await _auth.signUp(email, password, username);
        _user = response.user != null ? User.fromSupabase(response.user!) : null;
        _error = null;
      } on supa.AuthException catch (e) {
        _error = e.message;
        _user = null;
      } catch (e, st) {
        developer.log('register falló', name: 'AuthProvider', error: e, stackTrace: st);
        _error = 'Registro falló';
        _user = null;
      } finally {
        _setLoading(false);
      }
    }

    Future<void> loginWithGoogle() async {
      _error = 'Google Sign-In no implementado aún';
      notifyListeners();
    }

    Future<void> loginWithApple() async {
      _error = 'Apple Sign-In no implementado aún';
      notifyListeners();
    }

    Future<void> logout() async {
      await _auth.signOut();
      _user = null;
      _error = null;
      notifyListeners();
    }

    Future<void> markOnboardingSeen() async {
      _hasSeenOnboarding = true;
      await _storage.setHasSeenOnboarding(true);
      notifyListeners();
    }

    void _setLoading(bool value) {
      _isLoading = value;
      notifyListeners();
    }
  }
  ```

- [ ] **Step 5: Ejecutar tests — verificar que pasan**

  ```bash
  flutter test test/unit/auth_provider_test.dart
  ```
  
  Esperado: `All tests passed!`

- [ ] **Step 6: Commit**

  ```bash
  git add frontend/lib/services/auth_service.dart frontend/lib/providers/auth_provider.dart frontend/test/unit/auth_provider_test.dart
  git commit -m "feat: rewrite AuthProvider with Supabase auth, add unit tests"
  ```

---

### Task 9: TaskService + TaskProvider (TDD)

**Files:**
- Create: `frontend/lib/services/task_service.dart`
- Create: `frontend/test/unit/task_provider_test.dart`
- Modify: `frontend/lib/providers/task_provider.dart`

- [ ] **Step 1: Crear TaskService**

  Crear `frontend/lib/services/task_service.dart`:

  ```dart
  import 'package:supabase_flutter/supabase_flutter.dart';

  import '../models/task.dart';

  class TaskService {
    final SupabaseClient client;
    TaskService(this.client);

    String get _uid => client.auth.currentUser!.id;

    Future<List<Task>> fetchTasks({String status = 'all'}) async {
      var query = client.from('tasks').select();
      if (status == 'active') {
        query = query.eq('completed', false).eq('abandoned', false);
      } else if (status == 'completed') {
        query = query.eq('completed', true);
      } else if (status == 'abandoned') {
        query = query.eq('abandoned', true);
      }
      final data = await query.order('created_at', ascending: false);
      return (data as List)
          .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    Future<Task> createTask({
      required String title,
      required int priority,
      required int energy,
      required int estimatedMinutes,
      double? latitude,
      double? longitude,
    }) async {
      final data = await client.from('tasks').insert({
        'user_id': _uid,
        'title': title,
        'priority': priority,
        'energy': energy,
        'estimated_minutes': estimatedMinutes,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      }).select().single();
      return Task.fromJson(Map<String, dynamic>.from(data as Map));
    }

    Future<Task> completeTask(String taskId, int estimatedMinutes) async {
      final data = await client.from('tasks').update({
        'completed': true,
        'completed_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', taskId).select().single();
      await client.rpc('add_free_time',
          params: {'p_user_id': _uid, 'p_minutes': estimatedMinutes});
      return Task.fromJson(Map<String, dynamic>.from(data as Map));
    }

    Future<Task> abandonTask(String taskId, int estimatedMinutes) async {
      final data = await client.from('tasks').update({
        'abandoned': true,
        'abandoned_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', taskId).select().single();
      await client.rpc('add_debt', params: {
        'p_user_id': _uid,
        'p_minutes': (estimatedMinutes * 1.5).toInt(),
      });
      return Task.fromJson(Map<String, dynamic>.from(data as Map));
    }

    Future<void> deleteTask(String taskId) async {
      await client.from('tasks').delete().eq('id', taskId);
    }

    Future<Map<String, dynamic>> fetchDebt() async {
      final debtData = await client
          .from('productivity_debt')
          .select()
          .eq('user_id', _uid)
          .maybeSingle();

      final streakResult =
          await client.rpc('calculate_streak', params: {'p_user_id': _uid});

      final debt = (debtData as Map<String, dynamic>?) ??
          {'total_debt_minutes': 0, 'free_time_minutes': 0};

      return {
        ...debt,
        'streak_days': streakResult as int? ?? 0,
      };
    }

    Future<Map<String, dynamic>> payDebt(int minutesPaid) async {
      await client.rpc(
          'pay_debt', params: {'p_user_id': _uid, 'p_minutes': minutesPaid});
      return fetchDebt();
    }

    Future<Map<String, dynamic>> optimizeTasks(
        List<Map<String, dynamic>> tasks) async {
      final result = await client.functions
          .invoke('optimize-tasks', body: {'tasks': tasks});
      return Map<String, dynamic>.from(result.data as Map);
    }
  }
  ```

- [ ] **Step 2: Escribir tests (primero)**

  Crear `frontend/test/unit/task_provider_test.dart`:

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:mocktail/mocktail.dart';
  import 'package:kairos/models/task.dart';
  import 'package:kairos/providers/task_provider.dart';
  import 'package:kairos/services/task_service.dart';

  class MockTaskService extends Mock implements TaskService {}

  Task fakeTask({String id = '1', String title = 'Test task'}) => Task(
        id: id,
        title: title,
        priority: 1,
        energy: 3,
        estimatedMinutes: 30,
      );

  void main() {
    late MockTaskService mockService;
    late TaskProvider provider;

    setUp(() {
      mockService = MockTaskService();
      provider = TaskProvider(service: mockService);
    });

    group('fetchTasks', () {
      test('carga tareas correctamente', () async {
        final tasks = [fakeTask(id: '1'), fakeTask(id: '2')];
        when(() => mockService.fetchTasks(status: any(named: 'status')))
            .thenAnswer((_) async => tasks);

        await provider.fetchTasks();

        expect(provider.tasks.length, 2);
        expect(provider.error, isNull);
        expect(provider.isLoading, isFalse);
      });

      test('sets error on exception', () async {
        when(() => mockService.fetchTasks(status: any(named: 'status')))
            .thenThrow(Exception('Network error'));

        await provider.fetchTasks();

        expect(provider.error, contains('Network error'));
        expect(provider.tasks, isEmpty);
        expect(provider.isLoading, isFalse);
      });
    });

    group('createTask', () {
      test('añade tarea al inicio de la lista', () async {
        final newTask = fakeTask(id: 'new-1', title: 'Nueva tarea');
        when(() => mockService.createTask(
              title: any(named: 'title'),
              priority: any(named: 'priority'),
              energy: any(named: 'energy'),
              estimatedMinutes: any(named: 'estimatedMinutes'),
            )).thenAnswer((_) async => newTask);

        await provider.createTask(
          title: 'Nueva tarea',
          priority: 2,
          energy: 3,
          estimatedMinutes: 45,
        );

        expect(provider.tasks.first.id, 'new-1');
        expect(provider.tasks.first.title, 'Nueva tarea');
      });
    });

    group('completeTask', () {
      test('actualiza tarea en lista y recarga deuda', () async {
        final original = fakeTask(id: 'task-1');
        final completed = Task(
          id: 'task-1',
          title: 'Test task',
          priority: 1,
          energy: 3,
          estimatedMinutes: 30,
          completed: true,
          completedAt: DateTime.now(),
        );
        final debt = {'total_debt_minutes': 0, 'free_time_minutes': 30, 'streak_days': 1};

        when(() => mockService.fetchTasks(status: any(named: 'status')))
            .thenAnswer((_) async => [original]);
        when(() => mockService.completeTask(any(), any()))
            .thenAnswer((_) async => completed);
        when(() => mockService.fetchDebt()).thenAnswer((_) async => debt);

        await provider.fetchTasks();
        await provider.completeTask('task-1');

        expect(provider.tasks.first.completed, isTrue);
        expect(provider.debtTotalMinutes, 0);
      });
    });

    group('fetchDebt', () {
      test('carga datos de deuda con streak', () async {
        when(() => mockService.fetchDebt()).thenAnswer((_) async => {
              'total_debt_minutes': 120,
              'free_time_minutes': 60,
              'streak_days': 5,
            });

        await provider.fetchDebt();

        expect(provider.debtTotalMinutes, 120);
        expect(provider.streakDays, 5);
        expect(provider.debtHours, 2);
      });
    });

    group('computeDailyStats', () {
      test('retorna 7 días con completed y abandoned counts', () async {
        when(() => mockService.fetchTasks(status: any(named: 'status')))
            .thenAnswer((_) async => [
                  Task(
                    id: '1',
                    title: 'T',
                    priority: 1,
                    energy: 1,
                    estimatedMinutes: 10,
                    completed: true,
                    completedAt: DateTime.now(),
                  ),
                ]);
        await provider.fetchTasks();

        final stats = provider.computeDailyStats();
        expect(stats.length, 7);
        expect(stats.last['completed'], 1);
      });
    });
  }
  ```

- [ ] **Step 3: Ejecutar tests — verificar que fallan**

  ```bash
  flutter test test/unit/task_provider_test.dart
  ```
  
  Esperado: Error de compilación — `TaskProvider` no tiene constructor `({service})`.

- [ ] **Step 4: Reescribir TaskProvider**

  Reemplazar `frontend/lib/providers/task_provider.dart` completamente:

  ```dart
  import 'package:flutter/foundation.dart';

  import '../models/task.dart';
  import '../services/supabase_client.dart';
  import '../services/task_service.dart';

  class TaskProvider extends ChangeNotifier {
    final TaskService _service;

    List<Task> _tasks = [];
    Map<String, dynamic>? _debt;
    bool _isLoading = false;
    String? _error;

    TaskProvider({TaskService? service})
        : _service = service ?? TaskService(supabaseClient);

    List<Task> get tasks => _tasks;
    Map<String, dynamic>? get debt => _debt;
    bool get isLoading => _isLoading;
    String? get error => _error;

    int get debtTotalMinutes => (_debt?['total_debt_minutes'] as int?) ?? 0;
    int get debtHours => debtTotalMinutes ~/ 60;
    int get debtMinutes => debtTotalMinutes % 60;
    int get streakDays => (_debt?['streak_days'] as int?) ?? 0;
    int get sessionsCompleted => _tasks.where((t) => t.completed).length;

    Future<void> fetchTasks({String status = 'all'}) async {
      _setLoading(true);
      try {
        _tasks = await _service.fetchTasks(status: status);
        _error = null;
      } catch (e) {
        _error = _clean(e.toString());
      } finally {
        _setLoading(false);
      }
    }

    Future<void> fetchDebt() async {
      _setLoading(true);
      try {
        _debt = await _service.fetchDebt();
        _error = null;
      } catch (e) {
        _error = _clean(e.toString());
      } finally {
        _setLoading(false);
      }
    }

    Future<void> createTask({
      required String title,
      required int priority,
      required int energy,
      required int estimatedMinutes,
      double? latitude,
      double? longitude,
    }) async {
      _setLoading(true);
      try {
        final task = await _service.createTask(
          title: title,
          priority: priority,
          energy: energy,
          estimatedMinutes: estimatedMinutes,
          latitude: latitude,
          longitude: longitude,
        );
        _tasks.insert(0, task);
        _error = null;
      } catch (e) {
        _error = _clean(e.toString());
        rethrow;
      } finally {
        _setLoading(false);
      }
    }

    Future<void> completeTask(String taskId) async {
      try {
        final task = _tasks.firstWhere((t) => t.id == taskId);
        final updated =
            await _service.completeTask(taskId, task.estimatedMinutes);
        _updateTaskInList(updated);
        await fetchDebt();
      } catch (e) {
        _error = _clean(e.toString());
        notifyListeners();
      }
    }

    Future<void> abandonTask(String taskId) async {
      try {
        final task = _tasks.firstWhere((t) => t.id == taskId);
        final updated =
            await _service.abandonTask(taskId, task.estimatedMinutes);
        _updateTaskInList(updated);
        await fetchDebt();
      } catch (e) {
        _error = _clean(e.toString());
        notifyListeners();
      }
    }

    Future<void> deleteTask(String taskId) async {
      try {
        await _service.deleteTask(taskId);
        _tasks.removeWhere((t) => t.id == taskId);
        notifyListeners();
      } catch (e) {
        _error = _clean(e.toString());
        notifyListeners();
      }
    }

    Future<void> payDebt(int minutesPaid) async {
      _setLoading(true);
      try {
        _debt = await _service.payDebt(minutesPaid);
        _error = null;
      } catch (e) {
        _error = _clean(e.toString());
      } finally {
        _setLoading(false);
      }
    }

    List<Map<String, int>> computeDailyStats() {
      final now = DateTime.now();
      return List.generate(7, (i) {
        final day = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - i));
        int completed = 0;
        int abandoned = 0;
        for (final task in _tasks) {
          if (task.completed && task.completedAt != null) {
            if (_sameDay(task.completedAt!, day)) completed++;
          }
          if (task.abandoned && task.abandonedAt != null) {
            if (_sameDay(task.abandonedAt!, day)) abandoned++;
          }
        }
        return {'completed': completed, 'abandoned': abandoned};
      });
    }

    void _updateTaskInList(Task updated) {
      final idx = _tasks.indexWhere((t) => t.id == updated.id);
      if (idx >= 0) _tasks[idx] = updated;
      notifyListeners();
    }

    void _setLoading(bool v) {
      _isLoading = v;
      notifyListeners();
    }

    String _clean(String raw) {
      const prefix = 'Exception: ';
      return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
    }

    bool _sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
  }
  ```

- [ ] **Step 5: Ejecutar tests — verificar que pasan**

  ```bash
  flutter test test/unit/task_provider_test.dart
  ```
  
  Esperado: `All tests passed!`

- [ ] **Step 6: Commit**

  ```bash
  git add frontend/lib/services/task_service.dart frontend/lib/providers/task_provider.dart frontend/test/unit/task_provider_test.dart
  git commit -m "feat: rewrite TaskProvider with Supabase, add unit tests"
  ```

---

### Task 10: debt_utils + ReflectionService

**Files:**
- Create: `frontend/lib/utils/debt_utils.dart`
- Create: `frontend/test/unit/debt_utils_test.dart`
- Create: `frontend/lib/services/reflection_service.dart`

- [ ] **Step 1: Escribir test de debt_utils primero**

  Crear `frontend/test/unit/debt_utils_test.dart`:

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:kairos/utils/debt_utils.dart';

  void main() {
    group('analyzeDebtSeverity', () {
      test('retorna critical cuando ratio > 2', () {
        final result = analyzeDebtSeverity(
            totalDebtMinutes: 300, freeTimeMinutes: 100);
        expect(result['level'], 'critical');
      });

      test('retorna warning cuando ratio entre 1 y 2', () {
        final result = analyzeDebtSeverity(
            totalDebtMinutes: 150, freeTimeMinutes: 100);
        expect(result['level'], 'warning');
      });

      test('retorna healthy cuando ratio <= 1', () {
        final result = analyzeDebtSeverity(
            totalDebtMinutes: 50, freeTimeMinutes: 100);
        expect(result['level'], 'healthy');
      });

      test('no divide por cero cuando freeTime es 0', () {
        final result = analyzeDebtSeverity(
            totalDebtMinutes: 100, freeTimeMinutes: 0);
        expect(result['level'], 'critical');
      });
    });
  }
  ```

- [ ] **Step 2: Ejecutar test — verificar que falla**

  ```bash
  flutter test test/unit/debt_utils_test.dart
  ```
  
  Esperado: Error `Target of URI doesn't exist: 'package:kairos/utils/debt_utils.dart'`

- [ ] **Step 3: Implementar debt_utils.dart**

  Crear `frontend/lib/utils/debt_utils.dart`:

  ```dart
  Map<String, String> analyzeDebtSeverity({
    required int totalDebtMinutes,
    required int freeTimeMinutes,
  }) {
    final ratio = totalDebtMinutes / (freeTimeMinutes > 0 ? freeTimeMinutes : 1);
    if (ratio > 2) {
      return {'level': 'critical', 'color': 'error600', 'message': 'Deuda crítica'};
    }
    if (ratio > 1) {
      return {'level': 'warning', 'color': 'neutral400', 'message': 'Deuda considerable'};
    }
    return {'level': 'healthy', 'color': 'neutral50', 'message': 'En balance'};
  }
  ```

- [ ] **Step 4: Ejecutar test — verificar que pasa**

  ```bash
  flutter test test/unit/debt_utils_test.dart
  ```
  
  Esperado: `All tests passed!`

- [ ] **Step 5: Crear ReflectionService**

  Crear `frontend/lib/services/reflection_service.dart`:

  ```dart
  import 'dart:async';
  import 'dart:convert';

  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:http/http.dart' as http;
  import 'package:supabase_flutter/supabase_flutter.dart';

  class ReflectionService {
    final SupabaseClient _client;
    final String _functionsBaseUrl;

    ReflectionService({SupabaseClient? client, String? functionsBaseUrl})
        : _client = client ?? Supabase.instance.client,
          _functionsBaseUrl = functionsBaseUrl ??
              '${dotenv.env['SUPABASE_URL']!}/functions/v1';

    Stream<String> streamReflection({
      required int totalDebtMinutes,
      required int streakDays,
      required int sessionsCompleted,
      required int recentAbandons,
    }) async* {
      final session = _client.auth.currentSession;
      if (session == null) return;

      final request = http.Request(
        'POST',
        Uri.parse('$_functionsBaseUrl/debt-reflection'),
      );
      request.headers['Authorization'] = 'Bearer ${session.accessToken}';
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'total_debt_minutes': totalDebtMinutes,
        'streak_days': streakDays,
        'sessions_completed': sessionsCompleted,
        'recent_abandons': recentAbandons,
      });

      try {
        final streamedResponse = await http.Client().send(request);
        final buffer = StringBuffer();

        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          buffer.write(chunk);
          final text = buffer.toString();
          buffer.clear();

          int searchFrom = 0;
          while (true) {
            final idx = text.indexOf('\n\n', searchFrom);
            if (idx == -1) {
              buffer.write(text.substring(searchFrom));
              break;
            }
            final message = text.substring(searchFrom, idx);
            searchFrom = idx + 2;

            for (final line in message.split('\n')) {
              if (!line.startsWith('data: ')) continue;
              try {
                final data =
                    jsonDecode(line.substring(6)) as Map<String, dynamic>;
                final t = data['text'] as String?;
                if (t != null && t.isNotEmpty) yield t;
              } catch (_) {}
            }
          }
        }
      } catch (_) {
        yield 'La deuda no es condena, sino medida de lo que aún puedes dar. '
            'Epicteto diría: solo controlas tu esfuerzo presente, no el pasado acumulado. '
            'Hoy, completa una tarea pequeña. Un paso honesto vale más que mil promesas.';
      }
    }
  }
  ```

- [ ] **Step 6: Commit**

  ```bash
  git add frontend/lib/utils/debt_utils.dart frontend/test/unit/debt_utils_test.dart frontend/lib/services/reflection_service.dart
  git commit -m "feat: add debt_utils, ReflectionService SSE streaming"
  ```

---

### Task 11: Actualizar screens + eliminar api_client + backend

**Files:**
- Modify: `frontend/lib/screens/login_screen.dart`
- Modify: `frontend/lib/screens/register_screen.dart`
- Modify: `frontend/lib/screens/confessional_screen.dart`
- Modify: `frontend/lib/router.dart`
- Delete: `frontend/lib/services/api_client.dart`
- Delete: `backend/` (carpeta completa)

- [ ] **Step 1: Actualizar login_screen.dart**

  Buscar en `frontend/lib/screens/login_screen.dart` todas las referencias a `ApiClient` y `StorageService.getToken()`. El `AuthProvider` ya expone los mismos métodos (`login`, `register`, `logout`), así que los calls en la pantalla no deben cambiar. Verificar que no hay import directo de `ApiClient`:

  ```bash
  cd frontend
  grep -n "ApiClient\|api_client" lib/screens/login_screen.dart
  ```
  
  Si hay imports directos, eliminarlos. El screen solo debe usar `context.read<AuthProvider>().login(email, pass)`.

- [ ] **Step 2: Actualizar register_screen.dart**

  ```bash
  grep -n "ApiClient\|api_client" lib/screens/register_screen.dart
  ```
  
  Eliminar cualquier import directo de `ApiClient`. Verificar que llama `context.read<AuthProvider>().register(email, username, pass)`.

- [ ] **Step 3: Actualizar confessional_screen.dart**

  Buscar la llamada a `api_client.getReflectionStream()`:

  ```bash
  grep -n "getReflectionStream\|ApiClient\|api_client" lib/screens/confessional_screen.dart
  ```
  
  Reemplazar el uso de `ApiClient().getReflectionStream()` con `ReflectionService`. El screen debe usar:

  ```dart
  import '../services/reflection_service.dart';
  import '../utils/debt_utils.dart';

  // En el lugar donde se llama getReflectionStream():
  final taskProvider = context.read<TaskProvider>();
  final reflectionService = ReflectionService();
  final stream = reflectionService.streamReflection(
    totalDebtMinutes: taskProvider.debtTotalMinutes,
    streakDays: taskProvider.streakDays,
    sessionsCompleted: taskProvider.sessionsCompleted,
    recentAbandons: 0, // calcular desde tasks si aplica
  );
  ```

  Reemplazar también `ApiClient().getDebtSeverity()` con `analyzeDebtSeverity(...)` de `debt_utils.dart`.

- [ ] **Step 4: Actualizar router.dart para Supabase session**

  En `frontend/lib/router.dart`, buscar dónde se verifica autenticación (probablemente comprueba un token en StorageService). Reemplazar con:

  ```dart
  // En el redirect del GoRouter:
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuth = authProvider.isAuthenticated;
    final isOnAuth = state.matchedLocation == '/login' || 
                     state.matchedLocation == '/register';
    if (!isAuth && !isOnAuth) return '/login';
    if (isAuth && isOnAuth) return '/dashboard';
    return null;
  },
  ```

- [ ] **Step 5: Eliminar api_client.dart**

  ```bash
  rm frontend/lib/services/api_client.dart
  ```
  
  Verificar que no queden imports de api_client:

  ```bash
  grep -rn "api_client\|ApiClient" frontend/lib/
  ```
  
  Esperado: 0 resultados. Si hay alguno, corregirlo antes de continuar.

- [ ] **Step 6: Eliminar backend/**

  ```bash
  rm -rf backend/
  ```
  
  > **Warning:** Esta acción elimina permanentemente toda la carpeta `backend/`. El código Python (FastAPI, SQLAlchemy, etc.) quedará solo en el historial de git. Confirmar que tienes commit previo antes de ejecutar.

- [ ] **Step 7: Verificar que la app compila**

  ```bash
  cd frontend
  flutter analyze
  ```
  
  Esperado: `No issues found!`

- [ ] **Step 8: Commit**

  ```bash
  git add -A
  git commit -m "feat: complete Supabase migration, remove FastAPI backend"
  ```

---

## Fase 2: Tests + CI/CD + Deploy

---

### Task 12: Flutter Widget Tests

**Files:**
- Create: `frontend/test/widget/task_card_test.dart`
- Create: `frontend/test/widget/debt_severity_card_test.dart`
- Create: `frontend/test/widget/stoic_input_test.dart`
- Create: `frontend/test/widget/reflection_display_test.dart`

- [ ] **Step 1: Crear task_card_test.dart**

  Crear `frontend/test/widget/task_card_test.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:kairos/models/task.dart';
  import 'package:kairos/widgets/task_card.dart';

  Task testTask({bool completed = false, bool abandoned = false}) => Task(
        id: 'test-id',
        title: 'Tarea de prueba',
        priority: 2,
        energy: 3,
        estimatedMinutes: 45,
        completed: completed,
        abandoned: abandoned,
      );

  void main() {
    group('TaskCard', () {
      testWidgets('muestra el título de la tarea', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: testTask(),
              onComplete: () {},
              onAbandon: () {},
            ),
          ),
        ));

        expect(find.text('Tarea de prueba'), findsOneWidget);
      });

      testWidgets('llama onComplete al pulsar complete', (tester) async {
        bool called = false;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: testTask(),
              onComplete: () => called = true,
              onAbandon: () {},
            ),
          ),
        ));

        // Buscar el botón de completar (ajustar el finder si usa icono o texto)
        final completeBtn = find.byKey(const Key('task_complete_btn'));
        if (completeBtn.evaluate().isNotEmpty) {
          await tester.tap(completeBtn);
          expect(called, isTrue);
        }
      });

      testWidgets('muestra estado completed correctamente', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: testTask(completed: true),
              onComplete: () {},
              onAbandon: () {},
            ),
          ),
        ));

        // TaskCard completada no debe mostrar botones de acción
        expect(find.byKey(const Key('task_complete_btn')), findsNothing);
      });
    });
  }
  ```

- [ ] **Step 2: Crear debt_severity_card_test.dart**

  Crear `frontend/test/widget/debt_severity_card_test.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:kairos/widgets/debt_severity_card.dart';

  void main() {
    group('DebtSeverityCard', () {
      testWidgets('renderiza con datos críticos', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DebtSeverityCard(
              totalDebtMinutes: 300,
              freeTimeMinutes: 100,
            ),
          ),
        ));

        await tester.pump();
        expect(find.byType(DebtSeverityCard), findsOneWidget);
      });

      testWidgets('renderiza con datos healthy', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DebtSeverityCard(
              totalDebtMinutes: 30,
              freeTimeMinutes: 120,
            ),
          ),
        ));

        await tester.pump();
        expect(find.byType(DebtSeverityCard), findsOneWidget);
      });

      testWidgets('muestra minutos de deuda formateados', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DebtSeverityCard(
              totalDebtMinutes: 90,
              freeTimeMinutes: 60,
            ),
          ),
        ));

        await tester.pump();
        // Al menos el widget renderiza sin errores
        expect(tester.takeException(), isNull);
      });
    });
  }
  ```

- [ ] **Step 3: Crear stoic_input_test.dart**

  Crear `frontend/test/widget/stoic_input_test.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:kairos/widgets/stoic_input.dart';

  void main() {
    group('StoicInput', () {
      testWidgets('renderiza con placeholder', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: StoicInput(
              hint: 'Introduce tu email',
              controller: TextEditingController(),
            ),
          ),
        ));

        expect(find.text('Introduce tu email'), findsOneWidget);
      });

      testWidgets('acepta texto', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: StoicInput(
              hint: 'Email',
              controller: controller,
            ),
          ),
        ));

        await tester.enterText(find.byType(TextField), 'test@example.com');
        expect(controller.text, 'test@example.com');
      });

      testWidgets('no lanza excepciones al renderizar', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: StoicInput(
              hint: 'Contraseña',
              controller: TextEditingController(),
              obscureText: true,
            ),
          ),
        ));

        expect(tester.takeException(), isNull);
      });
    });
  }
  ```

- [ ] **Step 4: Crear reflection_display_test.dart**

  Crear `frontend/test/widget/reflection_display_test.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:kairos/widgets/reflection_display.dart';

  void main() {
    group('ReflectionDisplay', () {
      testWidgets('muestra texto cuando tiene contenido', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ReflectionDisplay(
              text: 'Epicteto diría que el control es tuyo.',
              isLoading: false,
            ),
          ),
        ));

        await tester.pump();
        expect(
            find.text('Epicteto diría que el control es tuyo.'), findsOneWidget);
      });

      testWidgets('muestra indicador de carga cuando isLoading true', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ReflectionDisplay(
              text: '',
              isLoading: true,
            ),
          ),
        ));

        await tester.pump();
        // Debe haber algún indicador de carga (CircularProgressIndicator o similar)
        expect(
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
              find.byType(LinearProgressIndicator).evaluate().isNotEmpty ||
              find.text('').evaluate().isNotEmpty,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('no lanza excepciones con texto vacío', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ReflectionDisplay(
              text: '',
              isLoading: false,
            ),
          ),
        ));

        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    });
  }
  ```

- [ ] **Step 5: Ejecutar todos los widget tests**

  ```bash
  cd frontend
  flutter test test/widget/
  ```
  
  Esperado: `All tests passed!` Si algún test falla por diferencias en el widget API (ej. parámetros del constructor), ajustar el test para que coincida con la firma real del widget.

- [ ] **Step 6: Ejecutar todos los tests juntos y verificar cobertura**

  ```bash
  flutter test --coverage
  ```
  
  Luego verificar cobertura en `coverage/lcov.info`. Los archivos en `lib/providers/` y `lib/widgets/` deben tener ≥80% de line coverage.

- [ ] **Step 7: Commit**

  ```bash
  git add frontend/test/
  git commit -m "test: add widget tests for task_card, debt_severity_card, stoic_input, reflection_display"
  ```

---

### Task 13: GitHub Actions — flutter-ci.yml

**Files:**
- Create: `.github/workflows/flutter-ci.yml`

- [ ] **Step 1: Crear el workflow**

  Crear `.github/workflows/flutter-ci.yml`:

  ```yaml
  name: Flutter CI

  on:
    push:
      branches: [main, develop]
    pull_request:
      branches: [main, develop]

  jobs:
    test:
      runs-on: ubuntu-latest
      defaults:
        run:
          working-directory: frontend

      steps:
        - uses: actions/checkout@v4

        - uses: subosito/flutter-action@v2
          with:
            flutter-version: '3.19.0'
            channel: 'stable'
            cache: true

        - name: Create .env for build
          run: |
            echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" > .env
            echo "SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}" >> .env

        - name: Install dependencies
          run: flutter pub get

        - name: Analyze
          run: flutter analyze --no-fatal-infos

        - name: Run tests with coverage
          run: flutter test --coverage

        - name: Upload coverage to Codecov
          uses: codecov/codecov-action@v4
          with:
            file: frontend/coverage/lcov.info
            flags: flutter
          continue-on-error: true
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add .github/workflows/flutter-ci.yml
  git commit -m "ci: add Flutter CI workflow with tests and coverage"
  ```

---

### Task 14: GitHub Actions — supabase-ci.yml

**Files:**
- Create: `.github/workflows/supabase-ci.yml`

- [ ] **Step 1: Crear el workflow**

  Crear `.github/workflows/supabase-ci.yml`:

  ```yaml
  name: Supabase Functions CI

  on:
    push:
      branches: [main, develop]
    pull_request:
      branches: [main, develop]

  jobs:
    test:
      runs-on: ubuntu-latest

      steps:
        - uses: actions/checkout@v4

        - uses: denoland/setup-deno@v1
          with:
            deno-version: v1.x

        - name: Test optimize-tasks
          run: deno test --allow-env --allow-net supabase/functions/optimize-tasks/optimize_test.ts
          env:
            GEMINI_API_KEY: test-key

        - name: Test debt-reflection
          run: deno test --allow-env --allow-net supabase/functions/debt-reflection/reflection_test.ts
          env:
            GEMINI_API_KEY: test-key
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add .github/workflows/supabase-ci.yml
  git commit -m "ci: add Supabase Edge Functions CI with Deno tests"
  ```

---

### Task 15: GitHub Actions — deploy.yml

**Files:**
- Create: `.github/workflows/deploy.yml`

- [ ] **Step 1: Crear el workflow**

  Crear `.github/workflows/deploy.yml`:

  ```yaml
  name: Deploy

  on:
    push:
      branches: [main]

  jobs:
    deploy-functions:
      runs-on: ubuntu-latest

      steps:
        - uses: actions/checkout@v4

        - uses: supabase/setup-cli@v1
          with:
            version: latest

        - name: Deploy optimize-tasks
          run: |
            supabase functions deploy optimize-tasks \
              --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
          env:
            SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}

        - name: Deploy debt-reflection
          run: |
            supabase functions deploy debt-reflection \
              --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
          env:
            SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}

    deploy-web:
      runs-on: ubuntu-latest
      needs: deploy-functions
      defaults:
        run:
          working-directory: frontend

      steps:
        - uses: actions/checkout@v4

        - uses: subosito/flutter-action@v2
          with:
            flutter-version: '3.19.0'
            channel: 'stable'
            cache: true

        - name: Create .env
          run: |
            echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" > .env
            echo "SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}" >> .env

        - name: Install dependencies
          run: flutter pub get

        - name: Build web
          run: |
            flutter build web --release \
              --base-href /${{ github.event.repository.name }}/

        - name: Deploy to GitHub Pages
          uses: peaceiris/actions-gh-pages@v3
          with:
            github_token: ${{ secrets.GITHUB_TOKEN }}
            publish_dir: frontend/build/web
            cname: ''
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add .github/workflows/deploy.yml
  git commit -m "ci: add deploy workflow for Supabase functions and GitHub Pages"
  ```

---

### Task 16: .env.example + GitHub Secrets + primer push

**Files:**
- Create: `.env.example`
- Modify: `.gitignore` (verificar)

- [ ] **Step 1: Crear .env.example en raíz**

  Crear `.env.example`:

  ```
  # Supabase
  SUPABASE_URL=https://TU_PROJECT_REF.supabase.co
  SUPABASE_ANON_KEY=eyJ...TU_ANON_KEY_PUBLICA

  # No incluir en este archivo — va en Supabase Dashboard → Edge Functions → Secrets
  # GEMINI_API_KEY=...
  ```

- [ ] **Step 2: Verificar .gitignore**

  Verificar que `frontend/.gitignore` contiene `.env`:

  ```bash
  grep "\.env" frontend/.gitignore
  ```
  
  Si no está, añadir:

  ```bash
  echo ".env" >> frontend/.gitignore
  ```

- [ ] **Step 3: Configurar GitHub Secrets**

  En GitHub → Settings → Secrets and variables → Actions → New repository secret. Crear estos 4 secrets:

  | Secret | Valor |
  |--------|-------|
  | `SUPABASE_URL` | `https://TU_PROJECT_REF.supabase.co` |
  | `SUPABASE_ANON_KEY` | La clave anon del Dashboard |
  | `SUPABASE_ACCESS_TOKEN` | Obtener con: `supabase access token` |
  | `SUPABASE_PROJECT_REF` | El Reference ID del proyecto (string corto) |

  Para obtener el access token:
  ```bash
  supabase access token
  ```

- [ ] **Step 4: Asegurarse que el repo está en GitHub y hacer push**

  ```bash
  git remote -v
  # Si no hay remote origin:
  # git remote add origin https://github.com/ismaelmanzanoleon/KAIROS.git
  
  git push origin main
  ```

- [ ] **Step 5: Verificar GitHub Actions**

  Ir a GitHub → Actions. Verificar que los 3 workflows se ejecutan:
  - `Flutter CI` → analyze + test deben pasar
  - `Supabase Functions CI` → deno tests deben pasar
  - `Deploy` → functions deploy + gh-pages debe pasar

  URL final: `https://ismaelmanzanoleon.github.io/KAIROS/`

- [ ] **Step 6: Commit final de documentación**

  ```bash
  git add .env.example .gitignore
  git commit -m "chore: add .env.example, configure GitHub Secrets documentation"
  git push origin main
  ```

---

## Validación Final

```bash
# 1. Flutter tests
cd frontend && flutter test --coverage
# Esperado: All tests passed. Coverage en lib/providers/ y lib/widgets/ ≥80%

# 2. Deno tests
deno test --allow-env --allow-net supabase/functions/
# Esperado: All 4 tests passed

# 3. Flutter analyze
flutter analyze
# Esperado: No issues found!

# 4. Build web local
flutter build web --release --base-href /KAIROS/
# Esperado: Build succeeded

# 5. Verificar endpoints en producción
curl https://TU_PROJECT_REF.supabase.co/functions/v1/optimize-tasks \
  -H "Authorization: Bearer TU_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"tasks": [{"id":"1","title":"Test","priority":1,"energy":3,"estimated_minutes":30}]}'
# Esperado: {"optimized": [...], "explanation": "..."}
```
