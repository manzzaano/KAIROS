#!/usr/bin/env pwsh
# Convertir DOCX a PDF usando LibreOffice

$DOCX_FILE = "C:\Users\Ismael\Desktop\KAIROS\entregas\entrega2\Entrega2_KAIROS.docx"
$OUTPUT_DIR = "C:\Users\Ismael\Desktop\KAIROS\entregas\entrega2"

Write-Host "[*] Buscando LibreOffice..."

# Intentar ubicar LibreOffice
$LibreOffice = @(
    "C:\Program Files\LibreOffice\program\soffice.exe",
    "C:\Program Files (x86)\LibreOffice\program\soffice.exe",
    "C:\Program Files\LibreOffice 7\program\soffice.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $LibreOffice) {
    Write-Host "[ERROR] LibreOffice no encontrado. Instala LibreOffice para convertir a PDF."
    exit 1
}

if (-not (Test-Path $DOCX_FILE)) {
    Write-Host "[ERROR] Archivo DOCX no encontrado: $DOCX_FILE"
    exit 1
}

Write-Host "[OK] LibreOffice encontrado: $LibreOffice"
Write-Host "[*] Convirtiendo a PDF..."

& $LibreOffice --headless --convert-to pdf --outdir $OUTPUT_DIR $DOCX_FILE

if ($?) {
    Write-Host "[OK] PDF generado exitosamente!"
    Get-ChildItem $OUTPUT_DIR -Filter "*.pdf"
} else {
    Write-Host "[ERROR] Conversion a PDF fallida"
    exit 1
}
