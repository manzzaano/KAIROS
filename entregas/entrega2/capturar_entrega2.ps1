# ==============================================================================
# capturar_entrega2.ps1
# KAIROS - Captura automatica de 18 screenshots + generacion de DOCX
# Emulador: Medium_Phone (1080x2400 px, portrait)
# ==============================================================================

# --- CONFIGURACION ---
$PROJECT_ROOT  = "C:\Users\Ismael\Desktop\KAIROS"
$KAIROS_DIR    = "$PROJECT_ROOT\kairos"
$SCREENS_DIR   = "$PROJECT_ROOT\entregas\entrega2\screens"
$SCRIPT_PY     = "$PROJECT_ROOT\entregas\entrega2\generar_entrega2.py"
$APK_PATH      = "$KAIROS_DIR\build\app\outputs\flutter-apk\app-debug.apk"
$EMULATOR_NAME = "Medium_Phone"
$PACKAGE       = "com.kairos.kairos"
$BOOT_TIMEOUT  = 120

# Anadir ADB al PATH si no esta disponible
$ADB_TOOLS = "$env:LOCALAPPDATA\Android\Sdk\platform-tools"
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    $env:PATH = "$ADB_TOOLS;$env:PATH"
    Write-Host "ADB anadido al PATH: $ADB_TOOLS" -ForegroundColor Cyan
}

# --- FUNCIONES HELPER ---

function Capture-Screen {
    param([string]$Name)
    $dest = "$SCREENS_DIR\$Name"
    try {
        adb shell screencap -p /sdcard/kairos_screen.png 2>$null
        adb pull /sdcard/kairos_screen.png $dest 2>$null | Out-Null
        adb shell rm /sdcard/kairos_screen.png 2>$null
        if (Test-Path $dest) {
            Write-Host "  [OK] $Name" -ForegroundColor Green
        } else {
            Write-Warning "  No se genero: $Name"
        }
    } catch {
        Write-Warning "  Error capturando $Name"
    }
}

function Tap {
    param([int]$X, [int]$Y, [int]$Wait = 1)
    adb shell input tap $X $Y 2>$null
    if ($Wait -gt 0) { Start-Sleep -Seconds $Wait }
}

function Swipe {
    param([int]$X1, [int]$Y1, [int]$X2, [int]$Y2, [int]$Duration = 400, [int]$Wait = 1)
    adb shell input swipe $X1 $Y1 $X2 $Y2 $Duration 2>$null
    if ($Wait -gt 0) { Start-Sleep -Seconds $Wait }
}

function Back {
    param([int]$Wait = 1)
    adb shell input keyevent 4 2>$null
    if ($Wait -gt 0) { Start-Sleep -Seconds $Wait }
}

function Write-Step {
    param([int]$Num, [string]$Desc)
    Write-Host ""
    Write-Host "[$Num/18] $Desc" -ForegroundColor Cyan
}

# ==============================================================================
# FASE 1: PREPARACION
# ==============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  KAIROS - Captura de screenshots Entrega 2" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

# 1.1 Crear directorio de screens
if (-not (Test-Path $SCREENS_DIR)) {
    New-Item -ItemType Directory -Path $SCREENS_DIR -Force | Out-Null
    Write-Host "[INFO] Creado directorio: $SCREENS_DIR" -ForegroundColor Gray
} else {
    Write-Host "[INFO] Directorio screens existe: $SCREENS_DIR" -ForegroundColor Gray
}

# 1.2 Comprobar emulador
Write-Host ""
Write-Host "[FASE 1] Verificando emulador..." -ForegroundColor Yellow
$devices = adb devices 2>$null | Select-String "emulator"
if ($devices) {
    Write-Host "[INFO] Emulador ya corriendo." -ForegroundColor Green
} else {
    Write-Host "[INFO] Lanzando emulador '$EMULATOR_NAME'..." -ForegroundColor Gray
    $emulatorExe = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"
    if (-not (Test-Path $emulatorExe)) { $emulatorExe = "emulator" }
    Start-Process -FilePath $emulatorExe `
        -ArgumentList "-avd", $EMULATOR_NAME, "-no-snapshot-load" `
        -WindowStyle Normal

    Write-Host "[INFO] Esperando boot (max ${BOOT_TIMEOUT}s)..." -ForegroundColor Gray
    $elapsed = 0; $booted = $false
    while ($elapsed -lt $BOOT_TIMEOUT) {
        Start-Sleep -Seconds 5; $elapsed += 5
        $prop = adb shell getprop sys.boot_completed 2>$null
        if ($prop -and $prop.Trim() -eq "1") { $booted = $true; break }
        Write-Host "  ... esperando boot ($elapsed s)" -ForegroundColor DarkGray
    }
    if (-not $booted) {
        Write-Warning "[WARN] Emulador tardo mas de ${BOOT_TIMEOUT}s."
    } else {
        Write-Host "[INFO] Boot completado en $elapsed s." -ForegroundColor Green
        Start-Sleep -Seconds 3
    }
}

# 1.3 Compilar APK debug (theme_cubit.dart ya corregido: modeIdx ?? 2 = dark)
Write-Host ""
Write-Host "[FASE 1] Compilando APK debug..." -ForegroundColor Yellow
Push-Location $KAIROS_DIR
try {
    flutter build apk --debug 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "[WARN] flutter build apk fallo con codigo $LASTEXITCODE"
    } else {
        Write-Host "[INFO] APK compilado." -ForegroundColor Green
    }
} catch {
    Write-Warning "[WARN] Error compilando APK"
} finally {
    Pop-Location
}

# 1.4 Instalar APK
Write-Host ""
Write-Host "[FASE 1] Instalando APK..." -ForegroundColor Yellow
if (Test-Path $APK_PATH) {
    adb install -r $APK_PATH 2>&1 | Out-Null
    Write-Host "[INFO] APK instalado." -ForegroundColor Green
} else {
    Write-Warning "[WARN] APK no encontrado: $APK_PATH"
}

# 1.5 Limpiar datos de app (fuerza onboarding fresh y dark mode por defecto)
Write-Host ""
Write-Host "[FASE 1] Limpiando datos de app..." -ForegroundColor Yellow
adb shell pm clear $PACKAGE 2>$null | Out-Null
Write-Host "[INFO] Datos limpiados. Dark mode activo por defecto (modeIdx=2)." -ForegroundColor Green
Start-Sleep -Seconds 1

# ==============================================================================
# FASE 2: CAPTURA DE 18 PANTALLAS
# ==============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  FASE 2 - Captura de pantallas" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

# 01 - Splash
# Tras pm clear el cold start es ~1-2s. SplashPage se muestra 1800ms.
# Esperamos 2s (Flutter ya cargo) y capturamos durante la ventana del splash.
Write-Step 1 "Splash screen"
adb shell am start -n "$PACKAGE/.MainActivity" 2>$null | Out-Null
Start-Sleep -Seconds 2
Capture-Screen "01_splash.png"
# Esperamos otros 2s a que el splash navegue al onboarding automaticamente
Start-Sleep -Seconds 2

# 02 - Onboarding slide 1
Write-Step 2 "Onboarding - slide 1"
Start-Sleep -Seconds 1
Capture-Screen "02_onboarding_1.png"

# 03 - Onboarding slide 2
Write-Step 3 "Onboarding - slide 2"
Swipe -X1 900 -Y1 1200 -X2 200 -Y2 1200 -Duration 400 -Wait 1
Capture-Screen "03_onboarding_2.png"

# 04 - Onboarding slide 3
Write-Step 4 "Onboarding - slide 3"
Swipe -X1 900 -Y1 1200 -X2 200 -Y2 1200 -Duration 400 -Wait 1
Capture-Screen "04_onboarding_3.png"

# 05 - Login (tap Saltar en top-right, navega context.go('/login'))
# Saltar TextButton: top-right, SafeArea, aprox physical (960, 120)
Write-Step 5 "Login screen"
Tap -X 960 -Y 120 -Wait 2
Capture-Screen "05_login.png"

# 06 - Login validation (pulsar boton "Iniciar sesion" sin rellenar campos)
# Boton principal de login: centro de pantalla, aprox y=1008 physical
Write-Step 6 "Login - validacion de formulario"
Tap -X 540 -Y 1008 -Wait 2
Capture-Screen "06_login_validation.png"

# 07 - Dashboard (tap "Continuar sin sincronizar")
# Boton secundario debajo del login button, aprox y=1152 physical
Write-Step 7 "Dashboard principal"
Tap -X 540 -Y 1152 -Wait 4
Capture-Screen "07_dashboard.png"

# 08 - Optimize / IA (tap en CTA "Optimizar con IA")
# El CTA es un card/boton en la parte superior del dashboard
Write-Step 8 "Optimize / IA"
Tap -X 540 -Y 900 -Wait 7
Capture-Screen "08_optimize.png"

# 09 - Dashboard con tareas (volver del optimize)
Write-Step 9 "Dashboard con tareas"
Back -Wait 2
Capture-Screen "09_dashboard_tasks.png"

# 10 - Crear tarea (FAB + en esquina inferior-derecha)
# FAB: aprox physical (950, 2100)
Write-Step 10 "Crear tarea - formulario"
Tap -X 950 -Y 2100 -Wait 2
Capture-Screen "10_create_task.png"

# 11 - Lista de tareas (back + tab Tareas)
# Tab Tareas: 2/5 de 1080 = x=324, barra de tabs y=2320 physical
Write-Step 11 "Lista de tareas"
Back -Wait 1
Tap -X 324 -Y 2320 -Wait 2
Capture-Screen "11_task_list.png"

# 12 - Detalle de tarea (tap primera tarea en la lista)
Write-Step 12 "Detalle de tarea"
Tap -X 540 -Y 600 -Wait 2
Capture-Screen "12_task_detail.png"

# 13 - Focus / Enfoque (back + tab Enfoque)
# Tab Enfoque: 3/5 de 1080 = x=540, y=2320
Write-Step 13 "Focus / Enfoque - landing"
Back -Wait 1
Tap -X 540 -Y 2320 -Wait 2
Capture-Screen "13_focus_page.png"

# 14 - Focus timer (tap en boton de iniciar sesion de enfoque)
Write-Step 14 "Focus - timer en marcha"
Tap -X 540 -Y 800 -Wait 3
Capture-Screen "14_focus_timer.png"

# 15 - Estadisticas (back + tab Stats)
# Tab Stats: 4/5 de 1080 = x=756, y=2320
Write-Step 15 "Estadisticas"
Back -Wait 1
Tap -X 756 -Y 2320 -Wait 2
Capture-Screen "15_stats_page.png"

# 16 - Perfil tema oscuro (tab Perfil)
# Tab Perfil: 5/5 = x=972, y=2320
Write-Step 16 "Perfil (tema oscuro)"
Tap -X 972 -Y 2320 -Wait 2
Capture-Screen "16_profile_dark.png"

# 17 - Sheet de sincronizacion
# "Forzar sincronizacion" en seccion SINCRONIZACION del perfil
# Seccion aparece despues del user card. Aprox y=750 desde top de pagina
Write-Step 17 "Sheet de sincronizacion"
Tap -X 540 -Y 750 -Wait 3
Capture-Screen "17_sync_sheet.png"

# 18 - Selector de color acento
# Cerrar sheet (tap zona superior oscura fuera del sheet)
Write-Step 18 "Selector de color acento"
Tap -X 540 -Y 300 -Wait 1
# Scroll para ver la seccion de acentos
adb shell input swipe 540 1400 540 600 600 2>$null
Start-Sleep -Seconds 1
# Tap en el selector de color (aprox centro de la seccion de colores)
Tap -X 540 -Y 1100 -Wait 2
Capture-Screen "18_accent_change.png"

# ==============================================================================
# FASE 3: GENERACION DEL DOCX
# ==============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  FASE 3 - Generando documento DOCX" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

if (Test-Path $SCRIPT_PY) {
    python $SCRIPT_PY
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "[WARN] generar_entrega2.py fallo con codigo $LASTEXITCODE"
    }
} else {
    Write-Warning "[WARN] Script Python no encontrado: $SCRIPT_PY"
}

# ==============================================================================
# FASE 4: RESULTADO
# ==============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  FASE 4 - Resultado" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$docxFiles = Get-ChildItem -Path "$PROJECT_ROOT\entregas\entrega2" -Filter "*.docx" -ErrorAction SilentlyContinue
if ($docxFiles) {
    foreach ($f in $docxFiles) {
        Write-Host "[OK] DOCX: $($f.FullName)" -ForegroundColor Green
    }
    $latest = $docxFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Invoke-Item $latest.FullName
} else {
    Write-Warning "[WARN] No se encontro archivo .docx en entregas\entrega2"
}

$captured = (Get-ChildItem -Path $SCREENS_DIR -Filter "*.png" -ErrorAction SilentlyContinue).Count
Write-Host ""
if ($captured -eq 18) {
    Write-Host "Screenshots: $captured / 18" -ForegroundColor Green
} else {
    Write-Host "Screenshots: $captured / 18" -ForegroundColor Yellow
}
Write-Host "Directorio: $SCREENS_DIR" -ForegroundColor Gray
Write-Host ""
Write-Host "Script finalizado." -ForegroundColor Yellow
