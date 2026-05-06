#!/usr/bin/env pwsh
# Captura secuencial navegando por la app

$ADB = "C:\Users\Ismael\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$DEVICE = "emulator-5554"
$SCREENS = "C:\Users\Ismael\Desktop\KAIROS\entregas\entrega2\screens"

function Cap {
    param([string]$name)
    & $ADB -s $DEVICE shell screencap -p /sdcard/screen.png
    & $ADB -s $DEVICE pull /sdcard/screen.png "$SCREENS\$name" 2>&1 | Out-Null
    Write-Host "[CAPTURA] $name"
}

function Swipe {
    param([int]$repeat = 1)
    for ($i = 0; $i -lt $repeat; $i++) {
        & $ADB -s $DEVICE shell input swipe 800 800 200 800
        Start-Sleep -Seconds 0.8
    }
}

function Tap {
    param([int]$x, [int]$y)
    & $ADB -s $DEVICE shell input tap $x $y
    Start-Sleep -Seconds 0.5
}

Write-Host "[START] Capturando flujo KAIROS completo..."

# Onboarding - slides 1,2,3
Write-Host ""
Write-Host "[SECTION] Onboarding"
Cap "01_splash.png"
Start-Sleep -Seconds 2

Swipe 1
Cap "02_onboarding_slide1.png"

Swipe 1
Cap "03_onboarding_slide2.png"

Swipe 1
Cap "04_onboarding_slide3.png"

# Skip onboarding
Write-Host ""
Write-Host "[ACTION] Skip onboarding"
Tap 540 1200  # Tap en area general para avanzar
Start-Sleep -Seconds 1

# Debería estar en login o dashboard
Cap "05_login_or_dashboard.png"

# Si es login, rellenar
Write-Host ""
Write-Host "[SECTION] Login"
Tap 540 400  # Email field
Start-Sleep -Seconds 0.5
& $ADB -s $DEVICE shell input text "test@example.com"
Start-Sleep -Seconds 0.5

Tap 540 500  # Password field
Start-Sleep -Seconds 0.5
& $ADB -s $DEVICE shell input text "password123"
Start-Sleep -Seconds 0.5

Cap "05_login_filled.png"

# Login button
Tap 540 600
Start-Sleep -Seconds 2

# Dashboard
Write-Host ""
Write-Host "[SECTION] Dashboard"
Cap "06_dashboard.png"

# Tasks tab
Write-Host ""
Write-Host "[SECTION] Tasks"
Tap 200 1900  # Tasks icon in nav bar
Start-Sleep -Seconds 1
Cap "07_task_list.png"

# Create task (FAB)
Tap 540 2100  # FAB button
Start-Sleep -Seconds 1
Cap "08_create_task_form.png"

# Fill task
& $ADB -s $DEVICE shell input text "Tarea importante"
Start-Sleep -Seconds 0.5
Cap "08b_create_task_filled.png"

# Save (button at bottom)
Tap 540 2000
Start-Sleep -Seconds 1

# Tasks list with item
Cap "09_task_list_with_item.png"

# Tap task to see detail
Tap 400 300
Start-Sleep -Seconds 1
Cap "10_task_detail.png"

# Focus Mode
Write-Host ""
Write-Host "[SECTION] Focus Mode"
Tap 540 1800  # "Iniciar Focus" button
Start-Sleep -Seconds 1
Cap "11_focus_landing.png"

# Select task
Tap 400 400
Start-Sleep -Seconds 1
Cap "12_focus_timer.png"

# Stats
Write-Host ""
Write-Host "[SECTION] Stats"
Tap 400 1900  # Stats icon
Start-Sleep -Seconds 1
Cap "13_stats.png"

# Profile
Write-Host ""
Write-Host "[SECTION] Profile"
Tap 800 1900  # Profile icon
Start-Sleep -Seconds 1
Cap "14_profile.png"

# Toggle theme
Tap 540 300
Start-Sleep -Seconds 1
Cap "15_profile_light.png"

Write-Host ""
Write-Host "[COMPLETE] Captura terminada!"
Write-Host "Total archivos: $(Get-ChildItem $SCREENS -Filter *.png | Measure-Object | Select-Object -ExpandProperty Count)"
