#!/usr/bin/env pwsh
# Captura con coordenadas correctas del botón siguiente

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
    Write-Host "  → Tap ($x, $y)"
    & $ADB -s emulator-5554 shell input tap $x $y
    Start-Sleep -Seconds 0.8
}

Write-Host "=== CAPTURA CON COORDS CORRECTAS ==="

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

# Botón siguiente (bottom right corner) - x~1020, y~2350
Tap 1020 2350
Start-Sleep -Seconds 1
Cap "03_onboarding_2.png"

# Slide 2
Tap 1020 2350
Start-Sleep -Seconds 1
Cap "04_onboarding_3.png"

# Slide 3 → Login
Tap 1020 2350
Start-Sleep -Seconds 2
Cap "05_login.png"

# Continue sin sincronizar - try different y coordinates
# Botón outlined está arriba, probablemente alrededor de y=1400-1500
Write-Host "Intentando taps en diferentes y para botón 'Continuar'..."
Tap 540 1400
Start-Sleep -Seconds 1
Cap "06_after_tap1400.png"

if ((Get-Item "$SCREENS\06_after_tap1400.png" | Select-Object -ExpandProperty Length) -lt 100000) {
    Write-Host "Login aún visible, intentando y=1500..."
    Tap 540 1500
    Start-Sleep -Seconds 1
    Cap "06_after_tap1500.png"
}

Write-Host "Capturas completadas"
