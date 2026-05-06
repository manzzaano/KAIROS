#!/usr/bin/env pwsh
# Captura final de todas las pantallas para Entrega 2

$ADB = "C:\Users\Ismael\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$SCREENS = "C:\Users\Ismael\Desktop\KAIROS\entregas\entrega2\screens"

function Cap {
    param([string]$name, [string]$desc)
    & $ADB -s emulator-5554 shell screencap -p /sdcard/screen.png | Out-Null
    & $ADB -s emulator-5554 pull /sdcard/screen.png "$SCREENS\$name" 2>&1 | Out-Null
    Write-Host "[CAP] $name - $desc"
    Start-Sleep -Milliseconds 600
}

function Tap {
    param([int]$x, [int]$y)
    & $ADB -s emulator-5554 shell input tap $x $y
    Start-Sleep -Seconds 0.5
}

function Swipe {
    & $ADB -s emulator-5554 shell input swipe 800 900 200 900 400
    Start-Sleep -Seconds 0.8
}

Write-Host "=== CAPTURANDO PANTALLAS FINALES ==="

# Ir al dashboard
& $ADB -s emulator-5554 shell am start -n com.kairos.kairos/.MainActivity 2>&1 | Out-Null
Start-Sleep -Seconds 2

# Onboarding y login primero
Write-Host "=== ONBOARDING ==="
Cap "01_splash.png" "Splash"
Start-Sleep -Seconds 2

Cap "02_onboarding_1.png" "Slide 1"
Swipe
Cap "03_onboarding_2.png" "Slide 2"
Swipe
Cap "04_onboarding_3.png" "Slide 3"
Swipe

Write-Host "=== LOGIN & DASHBOARD ==="
Cap "05_login.png" "Login"
Tap 540 1430  # Continue sin sincronizar
Cap "06_dashboard.png" "Dashboard"

# Navegar con taps en bottom nav
Write-Host "=== NAVEGANDO TABS ==="

# Tareas - tap en posición 2
Tap 75 1940
Start-Sleep -Seconds 1
Cap "07_tareas.png" "Tareas"

# Enfoque - tap en posición 3
Tap 216 1940
Start-Sleep -Seconds 1
Cap "08_enfoque.png" "Enfoque"

# Stats - tap en posición 4
Tap 348 1940
Start-Sleep -Seconds 1
Cap "09_stats.png" "Stats"

# Perfil - tap en posición 5
Tap 459 1940
Start-Sleep -Seconds 1
Cap "10_perfil.png" "Perfil"

Write-Host "=== CAPTURAS COMPLETADAS ==="
Get-ChildItem $SCREENS -Filter "*.png" | Measure-Object | Select-Object -ExpandProperty Count | ForEach-Object { Write-Host "Total: $_ archivos" }
