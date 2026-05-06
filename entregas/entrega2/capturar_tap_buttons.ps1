#!/usr/bin/env pwsh
# Captura usando tap en botones en lugar de swipe

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

Write-Host "=== CAPTURA CON TAPS EN BOTONES ==="

# Restart
& $ADB -s emulator-5554 shell am force-stop com.kairos.kairos
Start-Sleep -Seconds 1

# Launch
& $ADB -s emulator-5554 shell am start -n com.kairos.kairos/.MainActivity 2>&1 | Out-Null
Start-Sleep -Seconds 3

# Splash
Cap "01_splash.png"
Start-Sleep -Seconds 2

# Onboarding slide 1
Cap "02_onboarding_1.png"

# Tap en botón siguiente (el botón verde arrow está en bottom right, ~600, 1380)
Tap 600 1380
Start-Sleep -Seconds 1
Cap "03_onboarding_2.png"

# Slide 2, siguiente button
Tap 600 1380
Start-Sleep -Seconds 1
Cap "04_onboarding_3.png"

# Slide 3, siguiente button (debería ir a login)
Tap 600 1380
Start-Sleep -Seconds 2
Cap "05_login.png"

# Tap "Continuar sin sincronizar"
# El botón outlined está abajo, deberíaes estar alrededor de y=900-1000 (más arriba que el botón principal de login)
Tap 540 960
Start-Sleep -Seconds 2
Cap "06_dashboard.png"

Write-Host "Primeras capturas completadas"
