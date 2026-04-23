# Notas para el desarrollador — KAIROS

> Todo el código de la migración a Supabase ya está escrito y en la rama
> `feat/supabase-migration`. Lo que queda son pasos de configuración que
> requieren credenciales reales: no se pueden automatizar en código.
>
> Sigue esta guía en orden. Cada paso depende del anterior.

---

## Índice

1. [Requisitos previos](#1-requisitos-previos)
2. [Crear el proyecto Supabase](#2-crear-el-proyecto-supabase)
3. [Instalar Supabase CLI y vincular el proyecto](#3-instalar-supabase-cli-y-vincular-el-proyecto)
4. [Aplicar el schema de base de datos](#4-aplicar-el-schema-de-base-de-datos)
5. [Configurar GEMINI_API_KEY en Supabase](#5-configurar-gemini_api_key-en-supabase)
6. [Desplegar las Edge Functions](#6-desplegar-las-edge-functions)
7. [Configurar el entorno Flutter](#7-configurar-el-entorno-flutter)
8. [Verificar la app en local](#8-verificar-la-app-en-local)
9. [Configurar GitHub Secrets para CI/CD](#9-configurar-github-secrets-para-cicd)
10. [Hacer el merge del PR](#10-hacer-el-merge-del-pr)
11. [Referencia rápida de variables](#11-referencia-rápida-de-variables)
12. [Qué hace cada archivo clave](#12-qué-hace-cada-archivo-clave)
13. [Problemas frecuentes](#13-problemas-frecuentes)

---

## 1. Requisitos previos

Instala estas herramientas si no las tienes:

| Herramienta | Versión mínima | Cómo instalar |
|-------------|---------------|---------------|
| Flutter SDK | 3.0.0 | https://docs.flutter.dev/get-started/install |
| Dart | incluido con Flutter | — |
| Supabase CLI | 2.x | `npm install -g supabase@latest` |
| Node.js | 18+ (para Supabase CLI) | https://nodejs.org |
| Deno | 1.x | https://deno.land |
| Git | cualquiera | — |

Verifica que todo está instalado:

```bash
flutter --version
supabase --version
deno --version
```

---

## 2. Crear el proyecto Supabase

1. Ve a **https://supabase.com** → inicia sesión o crea cuenta
2. Pulsa **"New project"**
3. Elige un nombre (ej. `kairos-prod`), región y contraseña de base de datos
4. Espera ~2 minutos a que el proyecto se aprovisione
5. Ve a **Project Settings → API** y anota estos tres valores:

```
Project URL      →  https://XXXXXXXXXX.supabase.co
anon public key  →  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Project Ref ID   →  XXXXXXXXXX  (el string corto del URL)
```

> **Guarda estos valores.** Los necesitarás en varios pasos siguientes.

---

## 3. Instalar Supabase CLI y vincular el proyecto

Desde la raíz del repositorio (`C:\Users\Ismael\Desktop\KAIROS`):

```bash
# Login — abrirá el navegador
supabase login

# Inicializa el directorio local de Supabase
# (crea supabase/config.toml si no existe)
supabase init

# Vincula con tu proyecto remoto
supabase link --project-ref TU_PROJECT_REF_ID
# Pedirá la contraseña de base de datos que pusiste al crear el proyecto
```

Después del `link`, haz commit del `config.toml` generado:

```bash
git add supabase/config.toml
git commit -m "chore: link supabase project"
```

---

## 4. Aplicar el schema de base de datos

El archivo de migración ya está escrito en:

```
supabase/migrations/20260423000000_initial_schema.sql
```

Contiene: tablas `tasks` y `productivity_debt`, índices, políticas RLS
(aislamiento por usuario) y funciones PostgreSQL auxiliares.

Aplícalo con:

```bash
supabase db push
```

Salida esperada: `Finished supabase db push.`

**Verifica en el Dashboard:**

- **Table Editor** → deben aparecer `tasks` y `productivity_debt`
- **Authentication → Policies** → cada tabla debe tener su policy activa

---

## 5. Configurar GEMINI_API_KEY en Supabase

La API Key de Gemini **nunca va en el repositorio ni en `.env` del frontend**.
Vive como secret en las Edge Functions de Supabase.

**Obtener la API Key:**

1. Ve a **https://aistudio.google.com/app/apikey**
2. Crea o copia una API Key existente

**Guardarla en Supabase:**

```bash
supabase secrets set GEMINI_API_KEY=TU_API_KEY_DE_GEMINI
```

Verifica:

```bash
supabase secrets list
# Debe aparecer: GEMINI_API_KEY
```

---

## 6. Desplegar las Edge Functions

```bash
supabase functions deploy optimize-tasks
supabase functions deploy debt-reflection
```

Salida esperada por cada función:
```
Deployed Function optimize-tasks on project XXXXXXXXXX
```

**Prueba rápida desde el Dashboard:**

Ve a **Edge Functions → optimize-tasks → Invoke** y envía:

```json
{
  "tasks": [
    {"id": "1", "title": "Test", "priority": 1, "energy": 3, "estimated_minutes": 30}
  ]
}
```

Respuesta esperada:

```json
{
  "optimized": [...],
  "explanation": "..."
}
```

Si Gemini no responde (por cuota o error de red), la función devuelve las
tareas originales sin reordenar — eso es el fallback esperado.

---

## 7. Configurar el entorno Flutter

### 7.1 Rellenar `frontend/.env`

El archivo `frontend/.env` está en `.gitignore` (nunca se sube al repo).
Édítalo con los valores reales que anotaste en el paso 2:

```
# frontend/.env

SUPABASE_URL=https://XXXXXXXXXX.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

> **No confundas** `anon public key` con `service_role key`. Usa solo la `anon`.
> La `anon key` puede estar en el frontend — está protegida por las RLS policies.

### 7.2 Instalar dependencias Flutter

```bash
cd frontend
flutter pub get
```

Debe terminar con `Got dependencies!` sin errores de resolución de versiones.

### 7.3 Verificar análisis estático

```bash
flutter analyze
```

Objetivo: `No issues found!`

Si aparecen warnings de deprecación de plugins (geolocator, google_sign_in),
son no fatales y no bloquean el build.

---

## 8. Verificar la app en local

### Tests automáticos

```bash
# Desde frontend/
flutter test --coverage
```

Objetivo: todos los tests pasan. Cobertura ≥ 80% en `lib/providers/` y `lib/widgets/`.

```bash
# Desde la raíz del repo
deno test --allow-env --allow-net supabase/functions/optimize-tasks/optimize_test.ts
deno test --allow-env --allow-net supabase/functions/debt-reflection/reflection_test.ts
```

Objetivo: 4 tests Deno en verde.

### App en emulador / dispositivo

```bash
cd frontend
flutter run                  # emulador Android/iOS activo
flutter run -d chrome        # web
```

**Flujo mínimo a probar:**

1. **Registro** → correo + username + contraseña → debe navegar a Onboarding
2. **Onboarding** → deslizar slides → llega a Dashboard
3. **Crear tarea** → FAB `+` → rellenar campos → guardar → aparece en lista
4. **Completar tarea** → checkbox → deuda se actualiza
5. **Confesionario** → GENERAR REFLEXIÓN → texto aparece en streaming
6. **Logout** → vuelve a Login

Si el paso 5 devuelve el texto de fallback estoico en lugar del de Gemini,
verifica que el `GEMINI_API_KEY` está correctamente configurado (paso 5).

### Build web (opcional antes de CI)

```bash
flutter build web --release --base-href /KAIROS/
```

El build debe completarse sin errores en `frontend/build/web/`.

---

## 9. Configurar GitHub Secrets para CI/CD

Ve a **GitHub → tu repo → Settings → Secrets and variables → Actions → New repository secret**.

Crea estos 4 secrets:

| Nombre del secret | Valor | Dónde encontrarlo |
|-------------------|-------|-------------------|
| `SUPABASE_URL` | `https://XXXXXXXXXX.supabase.co` | Supabase → Project Settings → API |
| `SUPABASE_ANON_KEY` | `eyJ...` (la clave anon) | Supabase → Project Settings → API |
| `SUPABASE_ACCESS_TOKEN` | token personal de Supabase CLI | `supabase access-token` en terminal |
| `SUPABASE_PROJECT_REF` | `XXXXXXXXXX` (el ref ID corto) | Supabase → Project Settings → General |

> `GITHUB_TOKEN` se genera automáticamente — no lo crees tú.

**Obtener el access token:**

```bash
supabase access-token
# Imprime el token — cópialo en SUPABASE_ACCESS_TOKEN
```

Una vez configurados los 4 secrets, haz un push cualquiera a la rama
`feat/supabase-migration` y verifica en GitHub → Actions que los 3 workflows
aparecen en verde:

- `Flutter CI` ✅
- `Supabase Functions CI` ✅
- `Deploy` — solo se dispara en merge a `main`

---

## 10. Hacer el merge del PR

Cuando los pasos 1-9 están completos y todos los checks del CI pasan:

1. Abre el PR en: `https://github.com/manzzaano/KAIROS/compare/main...feat/supabase-migration`
2. Revisa el diff y los comentarios de CI
3. Pulsa **"Merge pull request"**

El workflow `deploy.yml` se dispara automáticamente con el merge y:

- Despliega las Edge Functions en Supabase
- Construye Flutter Web y publica en GitHub Pages

La app quedará disponible en:

```
https://manzzaano.github.io/KAIROS/
```

> La primera vez que se activa GitHub Pages hay que ir a
> **Settings → Pages → Source** y seleccionar la rama `gh-pages`.

---

## 11. Referencia rápida de variables

### `frontend/.env` (nunca al repo)

```env
SUPABASE_URL=https://XXXXXXXXXX.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

### Supabase Edge Functions Secrets (vía CLI, nunca al repo)

```bash
supabase secrets set GEMINI_API_KEY=AIza...
```

### GitHub Actions Secrets (vía interfaz web de GitHub)

```
SUPABASE_URL          → igual que frontend/.env
SUPABASE_ANON_KEY     → igual que frontend/.env
SUPABASE_ACCESS_TOKEN → supabase access-token
SUPABASE_PROJECT_REF  → el string corto del Project URL
```

---

## 12. Qué hace cada archivo clave

```
supabase/
├── migrations/
│   └── 20260423000000_initial_schema.sql   ← schema completo: tablas, RLS, funciones PG
└── functions/
    ├── optimize-tasks/
    │   ├── index.ts          ← Edge Function: reordena tareas con Gemini
    │   └── optimize_test.ts  ← tests Deno (mockean fetch)
    └── debt-reflection/
        ├── index.ts          ← Edge Function: reflexión estoica SSE streaming
        └── reflection_test.ts

frontend/
├── .env                      ← SECRETO — rellenar con valores reales (no al repo)
├── lib/
│   ├── main.dart             ← Supabase.initialize() con .env
│   ├── services/
│   │   ├── supabase_client.dart   ← getter global del SupabaseClient
│   │   ├── auth_service.dart      ← wrapper de supabase.auth
│   │   ├── task_service.dart      ← CRUD tareas + rpc() calls a Supabase
│   │   └── reflection_service.dart ← SSE streaming via http package + JWT
│   ├── providers/
│   │   ├── auth_provider.dart     ← estado de sesión (Supabase session)
│   │   └── task_provider.dart     ← estado de tareas y deuda
│   └── utils/
│       └── debt_utils.dart        ← analyzeDebtSeverity() — lógica pura
└── test/
    ├── unit/   ← auth_provider, task_provider, debt_utils
    └── widget/ ← task_card, debt_severity_card, stoic_input, reflection_display

.github/workflows/
├── flutter-ci.yml    ← push/PR → analyze + test + coverage
├── supabase-ci.yml   ← push/PR → deno test
└── deploy.yml        ← merge a main → functions deploy + GitHub Pages
```

---

## 13. Problemas frecuentes

### `MissingPluginException` al arrancar Flutter

**Causa:** cambio de dependencias sin rebuild.

```bash
flutter clean && flutter pub get && flutter run
```

### `Bad state: No element` en fetchTasks

**Causa:** RLS activo pero el usuario no tiene sesión válida.
Verifica que `supabase.auth.currentSession` no es null antes de hacer queries.
El `TaskProvider` solo debe llamarse desde screens protegidas por auth guard.

### Edge Function devuelve siempre el fallback estoico

**Causa:** `GEMINI_API_KEY` no está configurada o es inválida.

```bash
supabase secrets list        # verificar que aparece GEMINI_API_KEY
supabase secrets set GEMINI_API_KEY=TU_KEY_NUEVA
supabase functions deploy optimize-tasks
supabase functions deploy debt-reflection
```

### `SUPABASE_URL` o `SUPABASE_ANON_KEY` null en runtime

**Causa:** `frontend/.env` no existe o las variables tienen nombre incorrecto.

```bash
cat frontend/.env
# Debe mostrar exactamente:
# SUPABASE_URL=https://...
# SUPABASE_ANON_KEY=eyJ...
```

El nombre de las variables es sensible a mayúsculas.

### CI falla con `secrets.SUPABASE_URL` vacío

**Causa:** los secrets no están creados en GitHub.
Ve a Settings → Secrets and variables → Actions y verifica que los 4 secrets existen.

### GitHub Pages muestra pantalla en blanco

**Causa:** el `--base-href` del build no coincide con el nombre del repo.
El workflow usa `/${{ github.event.repository.name }}/`.
Si renombraste el repo, el build genera el base-href correcto automáticamente.
Verifica que Settings → Pages tiene `gh-pages` como rama fuente.

### `flutter test` falla con imports `package:kairos/...`

**Causa:** el `name` en `pubspec.yaml` debe ser exactamente `kairos`.

```bash
grep "^name:" frontend/pubspec.yaml
# Debe mostrar: name: kairos
```
