<div align="center">

<br/>

<pre align="center">
██╗  ██╗ █████╗ ██╗██████╗  ██████╗ ███████╗
██║ ██╔╝██╔══██╗██║██╔══██╗██╔═══██╗██╔════╝
█████╔╝ ███████║██║██████╔╝██║   ██║███████╗
██╔═██╗ ██╔══██║██║██╔══██╗██║   ██║╚════██║
██║  ██╗██║  ██║██║██║  ██║╚██████╔╝███████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
</pre>

<h3><em>EL MOMENTO OPORTUNO</em></h3>

<p>
  Asistente de productividad con filosofía estoica y IA generativa.<br/>
  Gestiona tu tiempo como si cada hora fuera deuda con tu mejor versión.
</p>

<br/>

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white"/>
&nbsp;
<img src="https://img.shields.io/badge/FastAPI-0.104-009688?style=flat-square&logo=fastapi&logoColor=white"/>
&nbsp;
<img src="https://img.shields.io/badge/Gemini-AI-4285F4?style=flat-square&logo=google&logoColor=white"/>
&nbsp;
<img src="https://img.shields.io/badge/Supabase-migration-3ECF8E?style=flat-square&logo=supabase&logoColor=white"/>
&nbsp;
<img src="https://img.shields.io/badge/Python-3.14-3776AB?style=flat-square&logo=python&logoColor=white"/>

<br/><br/>

</div>

---

## 🧭 ¿Qué es KAIROS?

**KAIROS** (del griego *καιρός*, el momento oportuno) es una aplicación de productividad que combina:

- **Gestión de tareas** con priorización por IA (Google Gemini)
- **Deuda productiva** — cuando abandonas una tarea, KAIROS acumula deuda en minutos que debes saldar
- **El Confesionario** — reflexión estoica generada por IA sobre tu estado de deuda, inspirada en Marco Aurelio y Epicteto
- **Túnel de Visión** — vista de time-blocking con estados pasado / en curso / pendiente
- **Modo Foco** — sesión de trabajo profundo con contrato anti-abandono
- **Geovallado** — bloqueo de tareas por ubicación geográfica

La filosofía es simple: el tiempo no gestionado no desaparece, se convierte en deuda. KAIROS te lo recuerda sin piedad, pero también te guía de vuelta.

---

## 🏗️ Arquitectura

<div align="center">

<table>
  <thead>
    <tr>
      <th colspan="2" align="center">📱 Flutter App &nbsp;—&nbsp; Cliente</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="2" align="center">
        <code>Provider</code> &nbsp;·&nbsp; <code>GoRouter</code> &nbsp;·&nbsp; <code>Dio</code> &nbsp;·&nbsp; <code>Google Fonts</code><br/>
        Dashboard &nbsp;→&nbsp; Túnel &nbsp;→&nbsp; Foco &nbsp;→&nbsp; Confesionario &nbsp;→&nbsp; Perfil &nbsp;→&nbsp; Geovallado
      </td>
    </tr>
    <tr>
      <td colspan="2" align="center"><strong>⬇️ &nbsp; HTTP / JWT &nbsp; ⬇️</strong></td>
    </tr>
    <tr>
      <th align="center">🐍 FastAPI &nbsp;<em>(actual)</em></th>
      <th align="center">⚡ Supabase &nbsp;<em>(futuro)</em></th>
    </tr>
    <tr>
      <td align="center">
        <code>/api/v1/tasks</code><br/>
        <code>/api/v1/auth</code><br/>
        <code>/api/v1/confessional</code><br/>
        <br/>
        SQLAlchemy ORM<br/>
        PostgreSQL / SQLite<br/>
        JWT — python-jose + passlib
      </td>
      <td align="center">
        Supabase Auth<br/>
        PostgreSQL + RLS<br/>
        Edge Functions (Deno)<br/>
        <br/>
        <code>optimize-tasks</code><br/>
        <code>debt-reflection</code>
      </td>
    </tr>
    <tr>
      <td colspan="2" align="center"><strong>⬇️ &nbsp; Gemini API &nbsp; ⬇️</strong></td>
    </tr>
    <tr>
      <td align="center">
        <strong>Gemini Pro</strong><br/>
        Optimización de tareas<br/>
        (reordenación cognitiva)
      </td>
      <td align="center">
        <strong>Gemini 1.5 Flash</strong><br/>
        Reflexión estoica<br/>
        (SSE streaming)
      </td>
    </tr>
  </tbody>
</table>

</div>

---

## 📁 Estructura del proyecto

```
KAIROS/
├── 🐍 backend/                  # API FastAPI (Python 3.14)
│   ├── main.py                  # Punto de entrada, CORS, lifespan
│   ├── requirements.txt
│   ├── .env.example
│   └── app/
│       ├── core/
│       │   ├── config.py        # Settings con pydantic-settings
│       │   └── database.py      # SQLAlchemy engine + sesión
│       ├── models/              # ORM: User, Task, Debt
│       ├── schemas/             # Pydantic schemas (I/O)
│       ├── routes/
│       │   ├── auth.py          # Login, registro, JWT
│       │   ├── tasks.py         # CRUD + optimización IA
│       │   └── confessional.py  # Reflexión SSE + severidad deuda
│       └── services/
│           ├── auth_service.py  # Hash, verificación, tokens
│           ├── task_service.py  # Deuda, racha, cálculos
│           └── gemini_service.py# Gemini Pro/Flash wrapper
│
├── 📱 frontend/                 # App Flutter (Dart)
│   └── lib/
│       ├── main.dart
│       ├── router.dart          # GoRouter con guards de auth
│       ├── models/              # Task, User (DTOs)
│       ├── providers/           # AuthProvider, TaskProvider
│       ├── services/
│       │   ├── api_client.dart  # Capa HTTP con Dio
│       │   ├── location_service.dart
│       │   └── storage_service.dart
│       ├── screens/             # 11 pantallas
│       ├── widgets/             # Componentes reutilizables
│       └── utils/
│           ├── theme.dart       # KairosTheme + KairosColors
│           ├── strings.dart     # Constantes de texto
│           ├── constants.dart   # Rutas, timings
│           └── animations.dart
│
└── 📄 docs/                     # Especificaciones y planes
    └── superpowers/
        ├── specs/               # Diseño arquitectónico
        └── plans/               # Plan de implementación
```

---

## ✨ Características principales

### 📋 Gestión de Tareas

- Crear tareas con **título**, **prioridad** (1-5) y **energía requerida** (1-5)
- Estimación de tiempo en minutos
- Completar o **abandonar** (con penalización en deuda)
- **Optimización IA**: Gemini reordena tus tareas por prioridad cognitiva (urgencia + energía + dependencias)
- Geolocalización opcional por tarea

### 💀 Deuda Productiva

El sistema de deuda es el corazón de KAIROS:

| Estado | Descripción |
|--------|-------------|
| 🟢 **Saludable** | Ratio deuda/tiempo libre < 1 |
| 🟡 **Considerable** | Ratio deuda/tiempo libre entre 1 y 2 |
| 🔴 **Crítica** | Ratio deuda/tiempo libre > 2 |

Cada vez que abandonas una tarea, se añaden minutos a tu deuda. La racha de días consecutivos sin abandonar reduce la presión.

### 🏛️ El Confesionario

Endpoint SSE que envía en **streaming** una reflexión estoica personalizada generada por Gemini 1.5 Flash:

```
POST /api/v1/confessional/reflect
→ text/event-stream

data: "La deuda no es condena..."
data: "Epicteto diría: solo controlas..."
data: "[DONE]"
```

La reflexión considera: deuda acumulada, racha actual, sesiones completadas y abandonos recientes. Si Gemini falla, hay un *fallback* estoico hardcodeado.

### ⏱️ Modo Foco

Sesión de trabajo profundo con contrato: abandonar añade **42 minutos** a la deuda. Sin escapatoria fácil.

### 🔭 Túnel de Visión

Time-blocking visual con tres estados por bloque horario:
- `DESPACHADO` — completado
- `EN CURSO` — el momento presente
- `PENDIENTE` — lo que viene

### 📍 Geovallado

Vincula tareas a coordenadas GPS. La app puede bloquear o priorizar tareas según dónde estés.

---

## 🎨 Sistema de diseño

KAIROS usa un sistema visual **brutalista oscuro** con tipografía editorial:

<table>
<tr>
<th>Token</th>
<th>Color</th>
<th>Uso</th>
</tr>
<tr>
<td><code>neutral900</code></td>
<td><img src="https://placehold.co/16x16/18181B/18181B.png"/> <code>#18181B</code></td>
<td>Fondo principal, texto sobre blanco</td>
</tr>
<tr>
<td><code>neutral700</code></td>
<td><img src="https://placehold.co/16x16/3F3F46/3F3F46.png"/> <code>#3F3F46</code></td>
<td>Bordes, divisores, metadatos</td>
</tr>
<tr>
<td><code>neutral400</code></td>
<td><img src="https://placehold.co/16x16/A1A1AA/A1A1AA.png"/> <code>#A1A1AA</code></td>
<td>Texto secundario, labels</td>
</tr>
<tr>
<td><code>neutral50</code></td>
<td><img src="https://placehold.co/16x16/FAFAFA/FAFAFA.png"/> <code>#FAFAFA</code></td>
<td>Texto primario, botones principales</td>
</tr>
<tr>
<td><code>error600</code></td>
<td><img src="https://placehold.co/16x16/EF4444/EF4444.png"/> <code>#EF4444</code></td>
<td>Deuda crítica, advertencias, sangre</td>
</tr>
</table>

**Tipografía:** Inter (serif editorial) + monoespaciado para métricas y marcas de tiempo.

**Solo modo oscuro.** No hay modo claro. KAIROS es serio.

---

## 🚀 Puesta en marcha

### Requisitos previos

- Python 3.12+
- Flutter 3.x SDK
- Cuenta Google con API Key de Gemini

### 🐍 Backend

```bash
cd backend

# Crear entorno virtual
python -m venv venv
source venv/bin/activate        # Linux / macOS
venv\Scripts\activate           # Windows

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus valores (ver sección siguiente)

# Arrancar servidor
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

La API estará disponible en `http://localhost:8000`.
Documentación interactiva: `http://localhost:8000/docs`

### 📱 Frontend

```bash
cd frontend

# Instalar dependencias
flutter pub get

# Configurar variables de entorno
# Editar frontend/.env con la URL del backend

# Ejecutar en emulador / dispositivo / chrome
flutter run
flutter run -d chrome        # Web
flutter run -d android       # Android
```

---

## 🔑 Variables de entorno

### Backend — `backend/.env`

```env
# Base de datos
DATABASE_URL=sqlite:///./kairos.db
# Para producción: postgresql://user:password@host:5432/kairos_db

# IA
GEMINI_API_KEY=tu_api_key_de_google_ai_studio

# Seguridad JWT
JWT_SECRET=cambia-esto-en-produccion-usa-una-clave-larga

# Servidor
API_HOST=0.0.0.0
API_PORT=8000
ENV_NAME=development
```

> ⚠️ **Nunca** subas `.env` al repositorio. Ya está en `.gitignore`.

### Frontend — `frontend/.env`

```env
API_BASE_URL=http://localhost:8000/api/v1
```

---

## 📡 API Reference

### Autenticación

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/v1/auth/register` | Registro de usuario |
| `POST` | `/api/v1/auth/login` | Login → devuelve JWT |

### Tareas

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/v1/tasks/` | Listar tareas del usuario |
| `POST` | `/api/v1/tasks/` | Crear tarea |
| `PATCH` | `/api/v1/tasks/{id}/complete` | Completar tarea |
| `PATCH` | `/api/v1/tasks/{id}/abandon` | Abandonar tarea (+deuda) |
| `POST` | `/api/v1/tasks/optimize` | Optimizar orden vía Gemini |

### Confesionario

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/v1/confessional/reflect` | Reflexión estoica SSE streaming |
| `GET` | `/api/v1/confessional/debt-severity` | Nivel de deuda: healthy / warning / critical |

### Health

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/health` | Estado del servidor |

---

## 🗺️ Roadmap

```
✅ Paso 1-6   Backend FastAPI + Flutter pre-Supabase
               Auth JWT, CRUD tareas, Gemini AI, Confesionario SSE
               Dashboard, Foco, Túnel, Onboarding, Geovallado

🔄 En curso   Migración a Supabase (rama feat/supabase-migration)
               ├── Supabase Auth (reemplaza JWT manual)
               ├── PostgreSQL + RLS (reemplaza SQLAlchemy)
               └── Edge Functions Deno (reemplaza FastAPI)

📋 Pendiente  Testing + CI/CD + Deploy
               ├── flutter test + coverage
               ├── deno test (edge functions)
               ├── GitHub Actions (flutter-ci, supabase-ci, deploy)
               ├── Flutter Web → GitHub Pages
               └── Edge Functions → Supabase CLI
```

---

## 🤝 Contribuir

Este es un proyecto personal en desarrollo activo. Si quieres contribuir:

1. Haz fork del repositorio
2. Crea una rama: `git checkout -b feat/tu-mejora`
3. Haz tus cambios y commitea: `git commit -m "feat: descripción"`
4. Abre un Pull Request hacia `main`

---

## 📜 Filosofía

> *"Organiza tus tareas como si fueras a vivir para siempre; ejecuta como si fueras a morir mañana."*

KAIROS no es un gestor de tareas amable. No te felicita por cada tarea completada ni te pone confetis. Te dice cuánto tiempo debes, te da una reflexión estoica y te manda de vuelta a trabajar.

La deuda productiva es una metáfora honesta: el tiempo que prometiste y no entregaste no desaparece, vive en tu balance. Saldarla es la única salida.

---

<div align="center">

<br/>

**KAIROS** · *El momento oportuno*

<sub>© Ismael Manzano León · 2026</sub>

<br/>

<sub>Construido con FastAPI · Flutter · Google Gemini · y demasiado café</sub>

</div>
