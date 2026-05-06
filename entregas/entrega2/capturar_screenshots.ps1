#!/usr/bin/env pwsh
# Script para capturar screenshots de la app KAIROS en emulador
# Requiere: adb, emulador ejecutando, app en foreground

$SCREENS_DIR = "C:\Users\Ismael\Desktop\KAIROS\entregas\entrega2\screens"
$DEVICE = "emulator-5554"
$ADB = "C:\Users\Ismael\AppData\Local\Android\Sdk\platform-tools\adb.exe"

function Capture-Screenshot {
    param(
        [string]$Filename,
        [string]$Description,
        [int]$DelaySeconds = 0
    )

    if ($DelaySeconds -gt 0) {
        Write-Host "[*] Esperando $DelaySeconds segundos..."
        Start-Sleep -Seconds $DelaySeconds
    }

    $FullPath = Join-Path $SCREENS_DIR $Filename
    Write-Host "[CAPTURA] $Filename - $Description"

    # Capturar usando adb
    $TempPath = "/sdcard/screenshot.png"
    & $ADB -s $DEVICE shell screencap -p $TempPath
    & $ADB -s $DEVICE pull $TempPath $FullPath
    & $ADB -s $DEVICE shell rm $TempPath

    if (Test-Path $FullPath) {
        $Size = [math]::Round((Get-Item $FullPath).Length / 1024, 1)
        Write-Host "[OK] Guardado: $Filename ($Size KB)"
    } else {
        Write-Host "[ERROR] Capturando: $Filename"
    }
}

# ────────────────────────────────────────
# CAPTURAS
# ────────────────────────────────────────

Write-Host "[START] Iniciando captura de screenshots..."
Write-Host "Device: $DEVICE"
Write-Host "Directorio: $SCREENS_DIR"
Write-Host ""

# Splash (ya debería estar pasando)
Capture-Screenshot "01_splash.png" "Splash screen"

# Onboarding
Write-Host ""
Write-Host "[SECTION] Capturando Onboarding..."
Capture-Screenshot "02_onboarding_1.png" "Slide 1: Offline-First" 2
& $ADB -s $DEVICE shell input tap 500 700
Start-Sleep -Seconds 1
Capture-Screenshot "03_onboarding_2.png" "Slide 2: Smart Scheduling"
& $ADB -s $DEVICE shell input tap 500 700
Start-Sleep -Seconds 1
Capture-Screenshot "04_onboarding_3.png" "Slide 3: Deep Work"
& $ADB -s $DEVICE shell input tap 500 700

Write-Host ""
Write-Host "[SECTION] Capturando Login..."
Start-Sleep -Seconds 1
Capture-Screenshot "05_login.png" "Pagina de login"

Write-Host "[*] Llenando formulario login..."
& $ADB -s $DEVICE shell input text "test@example.com"
Start-Sleep -Seconds 0.5
& $ADB -s $DEVICE shell input tap 200 450
Start-Sleep -Seconds 0.5
& $ADB -s $DEVICE shell input text "password123"
Start-Sleep -Seconds 0.5
Capture-Screenshot "05b_login_filled.png" "Login completado"
& $ADB -s $DEVICE shell input tap 200 550
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "[SECTION] Capturando Dashboard..."
Capture-Screenshot "06_dashboard.png" "Dashboard vacio"

Write-Host ""
Write-Host "[SECTION] Capturando Task Management..."
& $ADB -s $DEVICE shell input tap 200 600
Start-Sleep -Seconds 1
Capture-Screenshot "07_task_list_empty.png" "Lista vacia"

& $ADB -s $DEVICE shell input tap 500 700
Start-Sleep -Seconds 1
Capture-Screenshot "10_create_task.png" "Formulario crear tarea"

Write-Host "[*] Creando tarea de prueba..."
& $ADB -s $DEVICE shell input text "Terminar proyecto Flutter"
& $ADB -s $DEVICE shell input tap 200 300
Start-Sleep -Seconds 0.5
& $ADB -s $DEVICE shell input tap 300 350
Start-Sleep -Seconds 0.5
& $ADB -s $DEVICE shell input tap 500 600
Start-Sleep -Seconds 1

Capture-Screenshot "08_task_list.png" "Lista con tareas"

Write-Host ""
Write-Host "[SECTION] Capturando Detalle de Tarea..."
& $ADB -s $DEVICE shell input tap 200 200
Start-Sleep -Seconds 1
Capture-Screenshot "11_task_detail.png" "Detalle de tarea"

Write-Host ""
Write-Host "[SECTION] Capturando Focus Mode..."
& $ADB -s $DEVICE shell input tap 300 600
Start-Sleep -Seconds 1
Capture-Screenshot "12_focus_landing.png" "Selector de tarea"
& $ADB -s $DEVICE shell input tap 200 400
Start-Sleep -Seconds 1
Capture-Screenshot "13_focus_timer_start.png" "Timer 25:00"

& $ADB -s $DEVICE shell input tap 200 400
Start-Sleep -Seconds 2
Capture-Screenshot "14_focus_timer_running.png" "Timer en ejecucion"

& $ADB -s $DEVICE shell input tap 200 400
Start-Sleep -Seconds 1
Capture-Screenshot "15_focus_timer_pause.png" "Timer en pausa"

Write-Host ""
Write-Host "[*] Volviendo a Dashboard..."
& $ADB -s $DEVICE shell input keyevent 4
Start-Sleep -Seconds 1
& $ADB -s $DEVICE shell input keyevent 4
Start-Sleep -Seconds 1

Write-Host ""
Write-Host "[SECTION] Capturando Estadisticas..."
& $ADB -s $DEVICE shell input tap 400 600
Start-Sleep -Seconds 1
Capture-Screenshot "17_stats_overview.png" "KPIs"
& $ADB -s $DEVICE shell input swipe 100 400 100 100
Start-Sleep -Seconds 1
Capture-Screenshot "18_stats_chart.png" "Grafico 7 dias"
& $ADB -s $DEVICE shell input swipe 100 400 100 100
Start-Sleep -Seconds 1
Capture-Screenshot "19_stats_heatmap.png" "Heatmap 4 semanas"

Write-Host ""
Write-Host "[SECTION] Capturando Perfil..."
& $ADB -s $DEVICE shell input tap 500 600
Start-Sleep -Seconds 1
Capture-Screenshot "20_profile.png" "Perfil modo oscuro"

& $ADB -s $DEVICE shell input tap 200 200
Start-Sleep -Seconds 1
Capture-Screenshot "21_profile_light.png" "Perfil modo claro"

Write-Host ""
Write-Host "[SECTION] Capturando Sincronizacion..."
& $ADB -s $DEVICE shell input tap 200 300
Start-Sleep -Seconds 1
Capture-Screenshot "22_sync_sheet.png" "SyncSheet en progreso"

Write-Host ""
Write-Host "[COMPLETE] Captura completada!"
Write-Host "Screenshots guardados en: $SCREENS_DIR"
Get-ChildItem $SCREENS_DIR -Filter "*.png"
