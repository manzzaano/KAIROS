#!/usr/bin/env pwsh
# Captura definitiva - navega correctamente al dashboard y luego tabs

$ADB = "C:\Users\Ismael\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$SCREENS = "C:\Users\Ismael\Desktop\KAIROS\entregas\entrega2\screens"
Remove-Item "$SCREENS\*.png" -Force 2>&1 | Out-Null

function Cap {
    param([string]$name)
    & $ADB -s emulator-5554 shell screencap -p /sdcard/screen.png | Out-Null
    & $ADB -s emulator-5554 pull /sdcard/screen.png "$SCREENS\$name" 2>&1 | Out-Null
    Write-Host "[CAP] $name"
    Start-Sleep -Milliseconds 700
}

function Tap {
    param([int]$x, [int]$y)
    & $ADB -s emulator-5554 shell input tap $x $y
    Start-Sleep -Seconds 0.7
}

function Swipe {
    & $ADB -s emulator-5554 shell input swipe 800 900 200 900 400
    Start-Sleep -Seconds 0.8
}

Write-Host "=== CAPTURA DEFINITIVA ==="

# Forzar restart de app
& $ADB -s emulator-5554 shell am force-stop com.kairos.kairos
Start-Sleep -Seconds 1

# Lanzar app
& $ADB -s emulator-5554 shell am start -n com.kairos.kairos/.MainActivity 2>&1 | Out-Null
Start-Sleep -Seconds 3

# Splash
Cap "01_splash.png"
Start-Sleep -Seconds 2

# Onboarding slides - swipe para avanzar
Cap "02_onboarding_1.png"
Swipe
Cap "03_onboarding_2.png"
Swipe
Cap "04_onboarding_3.png"
Swipe

# En login después del onboarding
Start-Sleep -Seconds 1
Cap "05_login.png"

# Tap "Continuar sin sincronizar" para ir a dashboard
# Botón está abajo en el login form
Tap 540 1430
Start-Sleep -Seconds 2

# Ahora en dashboard
Cap "06_dashboard.png"

Write-Host "Dashboard capturado. Navegando tabs..."

# Ahora tap en cada tab (bottom nav)
# Posiciones basadas en 5 items distribuidos uniformemente

# Tab 1: Tareas (segundo item, x~329)
Tap 329 1950
Start-Sleep -Seconds 1
Cap "07_tareas.png"

# Tab 2: Enfoque (tercero, x~538)
Tap 538 1950
Start-Sleep -Seconds 1
Cap "08_enfoque.png"

# Tab 3: Stats (cuarto, x~747)
Tap 747 1950
Start-Sleep -Seconds 1
Cap "09_stats.png"

# Tab 4: Perfil (quinto, x~956)
Tap 956 1950
Start-Sleep -Seconds 1
Cap "10_perfil.png"

Write-Host "=== CAPTURA COMPLETADA ==="
Get-ChildItem $SCREENS -Filter "*.png" | Measure-Object | Select-Object -ExpandProperty Count | ForEach-Object { Write-Host "Total de pantallas: $_" }
