#!/usr/bin/env python3
"""
Generador de PDF para Entrega 2 - KAIROS
Usando reportlab para PDF profesional con screenshots
"""

from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch, cm
from reportlab.lib.colors import HexColor, black, white
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image, PageBreak, KeepTogether
from pathlib import Path
from datetime import datetime

PDF_OUTPUT = Path(r"C:\Users\Ismael\Desktop\KAIROS\entregas\entrega2\Entrega2_KAIROS.pdf")
SCREENS_DIR = Path(r"C:\Users\Ismael\Desktop\KAIROS\entregas\entrega2\screens")

# Colores
COLOR_DARK = HexColor("#050505")
COLOR_ACCENT = HexColor("#F0E6D7")
COLOR_GRAY = HexColor("#CCCCCC")

def create_pdf():
    doc = SimpleDocTemplate(str(PDF_OUTPUT), pagesize=letter,
                           topMargin=0.5*inch, bottomMargin=0.5*inch,
                           leftMargin=0.75*inch, rightMargin=0.75*inch)

    styles = getSampleStyleSheet()

    # Crear estilos personalizados
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=28,
        textColor=COLOR_ACCENT,
        spaceAfter=12,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )

    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=COLOR_ACCENT,
        spaceAfter=8,
        spaceBefore=8,
        fontName='Helvetica-Bold'
    )

    normal_style = ParagraphStyle(
        'CustomNormal',
        parent=styles['Normal'],
        fontSize=10,
        alignment=TA_LEFT,
        spaceAfter=6
    )

    center_style = ParagraphStyle(
        'CustomCenter',
        parent=styles['Normal'],
        fontSize=9,
        alignment=TA_CENTER,
        spaceAfter=12,
        textColor=COLOR_GRAY,
        italic=True
    )

    story = []

    # ─── COVER PAGE ───
    story.append(Spacer(1, 1.5*inch))
    story.append(Paragraph("KAIROS 2.0", title_style))
    story.append(Spacer(1, 0.2*inch))
    story.append(Paragraph("Aplicación de Productivity con<br/>Offline-First & Deep Work",
                          ParagraphStyle('subtitle', parent=styles['Normal'],
                                       fontSize=14, alignment=TA_CENTER,
                                       textColor=COLOR_GRAY)))
    story.append(Spacer(1, 0.8*inch))
    story.append(Paragraph("Entrega 2 - Aplicación Funcional",
                          ParagraphStyle('sub2', parent=styles['Normal'],
                                       fontSize=12, alignment=TA_CENTER,
                                       textColor=COLOR_GRAY, italic=True)))
    story.append(Spacer(1, 0.8*inch))
    story.append(Paragraph("Ismael Manzano León<br/>ismaelmanzanoleon@gmail.com",
                          ParagraphStyle('author', parent=styles['Normal'],
                                       fontSize=11, alignment=TA_CENTER)))
    story.append(Spacer(1, 0.5*inch))
    story.append(Paragraph(f"Mayo 2026 - Versión 2.0.0",
                          ParagraphStyle('date', parent=styles['Normal'],
                                       fontSize=9, alignment=TA_CENTER,
                                       textColor=COLOR_GRAY)))
    story.append(PageBreak())

    # ─── CONTENIDO ───
    story.append(Paragraph("KAIROS 2.0", heading_style))
    story.append(Spacer(1, 0.1*inch))

    story.append(Paragraph("<b>Identificación del Alumnado</b>", heading_style))
    story.append(Paragraph("Nombre: Ismael Manzano León", normal_style))
    story.append(Paragraph("Email: ismaelmanzanoleon@gmail.com", normal_style))
    story.append(Paragraph("Fecha: Mayo 2026", normal_style))
    story.append(Paragraph("Versión: 2.0.0", normal_style))
    story.append(Paragraph("Entrega: 2 (Aplicación Funcional)", normal_style))
    story.append(Spacer(1, 0.2*inch))

    story.append(Paragraph("<b>Descripción del Proyecto</b>", heading_style))
    story.append(Paragraph(
        "KAIROS es una aplicación Flutter de productivity basada en:<br/>" +
        "&bull; <b>Offline-First</b>: Realm como fuente de verdad local, Supabase como remoto<br/>" +
        "&bull; <b>Deep Work</b>: Pomodoro timer con tracking de sesiones dinámicas<br/>" +
        "&bull; <b>Smart Scheduling</b>: Algoritmo heurístico para optimizar orden de tareas<br/>" +
        "&bull; <b>Visual</b>: Dark Glassmorphism theme con warm ivory accents",
        normal_style))
    story.append(Spacer(1, 0.2*inch))

    story.append(Paragraph("<b>Flujo Completo de la Aplicación</b>", heading_style))
    story.append(Paragraph(
        "1. <b>Splash</b> → Animación de carga (1.8s)<br/>" +
        "2. <b>Onboarding</b> → 3 slides: Offline-First, Smart Scheduling, Deep Work<br/>" +
        "3. <b>Login</b> → Email + contraseña con validaciones<br/>" +
        "4. <b>Dashboard</b> → Resumen de tareas hoy + energy bar<br/>" +
        "5. <b>Task Management</b> → CRUD completo con filtros y swipe actions<br/>" +
        "6. <b>Focus Mode</b> → Timer Pomodoro 25min con progreso visual<br/>" +
        "7. <b>Estadísticas</b> → KPIs, gráficos 7 días y heatmap 4 semanas<br/>" +
        "8. <b>Perfil</b> → Sincronización, temas y configuración",
        normal_style))
    story.append(PageBreak())

    # ─── SCREENSHOTS ───
    story.append(Paragraph("<b>Evidencia Visual - Flujo Principal</b>", heading_style))
    story.append(Spacer(1, 0.1*inch))

    # Helper para agregar screenshots
    def add_screenshot(filename, caption):
        path = SCREENS_DIR / filename
        if path.exists():
            try:
                img = Image(str(path), width=3*inch, height=6*inch)
                story.append(img)
                story.append(Paragraph(caption, center_style))
                story.append(Spacer(1, 0.2*inch))
            except:
                story.append(Paragraph(f"[Captura no disponible: {filename}]", normal_style))
        else:
            story.append(Paragraph(f"[Captura no encontrada: {filename}]", normal_style))

    # Splash
    story.append(Paragraph("Splash Screen", ParagraphStyle('h3', parent=styles['Normal'],
                                                           fontSize=11, fontName='Helvetica-Bold')))
    add_screenshot("01_splash.png", "Animación de carga inicial")

    # Onboarding
    story.append(Paragraph("Onboarding", ParagraphStyle('h3', parent=styles['Normal'],
                                                        fontSize=11, fontName='Helvetica-Bold')))
    add_screenshot("02_onboarding_1.png", "Slide 1: Offline-First")
    add_screenshot("03_onboarding_2.png", "Slide 2: Smart Scheduling")
    add_screenshot("04_onboarding_3.png", "Slide 3: Deep Work")

    story.append(PageBreak())

    # Login
    story.append(Paragraph("Login", ParagraphStyle('h3', parent=styles['Normal'],
                                                   fontSize=11, fontName='Helvetica-Bold')))
    add_screenshot("05_login.png", "Página de login")
    add_screenshot("05b_login_filled.png", "Login completado")

    # Dashboard
    story.append(Paragraph("Dashboard", ParagraphStyle('h3', parent=styles['Normal'],
                                                       fontSize=11, fontName='Helvetica-Bold')))
    add_screenshot("06_dashboard.png", "Resumen de tareas y energy bar")

    story.append(PageBreak())

    # Task Management
    story.append(Paragraph("Gestión de Tareas (CRUD)", heading_style))
    add_screenshot("07_task_list_empty.png", "Lista vacía")
    add_screenshot("08_task_list.png", "Con tareas creadas")
    add_screenshot("10_create_task.png", "Formulario de creación")
    add_screenshot("11_task_detail.png", "Vista de detalle")

    story.append(PageBreak())

    # Focus Mode
    story.append(Paragraph("Focus Mode - Deep Work", heading_style))
    add_screenshot("12_focus_landing.png", "Seleccionar tarea")
    add_screenshot("13_focus_timer_start.png", "Timer en inicio")
    add_screenshot("14_focus_timer_running.png", "Timer en ejecución")
    add_screenshot("15_focus_timer_pause.png", "Timer en pausa")

    story.append(PageBreak())

    # Stats
    story.append(Paragraph("Estadísticas y Análisis", heading_style))
    add_screenshot("17_stats_overview.png", "KPIs y métricas")
    add_screenshot("18_stats_chart.png", "Gráfico 7 días")
    add_screenshot("19_stats_heatmap.png", "Heatmap 4 semanas")

    story.append(PageBreak())

    # Profile
    story.append(Paragraph("Perfil y Sincronización", heading_style))
    add_screenshot("20_profile.png", "Perfil modo oscuro")
    add_screenshot("21_profile_light.png", "Perfil modo claro")
    add_screenshot("22_sync_sheet.png", "Sincronización")

    story.append(PageBreak())

    # ─── BACKEND & INTEGRACIÓN ───
    story.append(Paragraph("<b>Evidencia de Integración Backend</b>", heading_style))
    story.append(Spacer(1, 0.1*inch))

    story.append(Paragraph("<b>Supabase Setup</b>",
                          ParagraphStyle('h3', parent=styles['Normal'],
                                       fontSize=11, fontName='Helvetica-Bold')))
    story.append(Paragraph("URL: https://mxhyuzucjygdjmamtcjq.supabase.co", normal_style))
    story.append(Paragraph("Tabla: tasks (id, title, priority, energy, project, is_completed, is_synced)", normal_style))
    story.append(Paragraph("Sincronización: SupabaseSyncService.pushTasks() → upsert en Supabase", normal_style))
    story.append(Spacer(1, 0.1*inch))

    story.append(Paragraph("<b>Operaciones Reales</b>",
                          ParagraphStyle('h3', parent=styles['Normal'],
                                       fontSize=11, fontName='Helvetica-Bold')))
    story.append(Paragraph(
        "&bullet; Crear tarea en Realm (local)<br/>" +
        "&bullet; Modificar tarea local<br/>" +
        "&bullet; Marcar completada (local + sync)<br/>" +
        "&bullet; Perfil: 'Forzar sincronización' con 4 pasos reales<br/>" +
        "&bullet; Datos persistentes en Realm<br/>" +
        "&bullet; Estadísticas calculadas en tiempo real",
        normal_style))

    story.append(PageBreak())

    # ─── STACK TÉCNICO ───
    story.append(Paragraph("<b>Stack Técnico</b>", heading_style))

    tech_data = [
        ["Componente", "Tecnología"],
        ["Frontend", "Flutter 3.3+, Dart"],
        ["UI Framework", "Material Design 3"],
        ["State Management", "flutter_bloc + Cubit"],
        ["Routing", "go_router 14.0"],
        ["Local Database", "Realm 3.0"],
        ["Remote Backend", "Supabase PostgreSQL"],
        ["HTTP Client", "Dio 5.4"],
        ["DI Container", "get_it 7.7"],
        ["Persistence", "SharedPreferences 2.3"],
    ]

    tech_table = Table(tech_data, colWidths=[2*inch, 4*inch])
    tech_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), HexColor("#333333")),
        ('TEXTCOLOR', (0, 0), (-1, 0), white),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 8),
        ('BACKGROUND', (0, 1), (-1, -1), HexColor("#F5F5F5")),
        ('GRID', (0, 0), (-1, -1), 1, black),
        ('FONTSIZE', (0, 1), (-1, -1), 9),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [HexColor("#FFFFFF"), HexColor("#F9F9F9")]),
    ]))
    story.append(tech_table)
    story.append(Spacer(1, 0.2*inch))

    # ─── VALIDACIONES ───
    story.append(Paragraph("<b>Validaciones Implementadas</b>", heading_style))

    story.append(Paragraph("<b>Login</b>",
                          ParagraphStyle('h3', parent=styles['Normal'],
                                       fontSize=11, fontName='Helvetica-Bold')))
    story.append(Paragraph(
        "&bullet; Email: formato válido (regex validation)<br/>" +
        "&bullet; Contraseña: mínimo 6 caracteres<br/>" +
        "&bullet; Campos obligatorios",
        normal_style))
    story.append(Spacer(1, 0.1*inch))

    story.append(Paragraph("<b>Create Task</b>",
                          ParagraphStyle('h3', parent=styles['Normal'],
                                       fontSize=11, fontName='Helvetica-Bold')))
    story.append(Paragraph(
        "&bullet; Título: obligatorio<br/>" +
        "&bullet; Prioridad: seleccionar de opciones<br/>" +
        "&bullet; Energía: slider 1-5<br/>" +
        "&bullet; Proyecto: opcional<br/>" +
        "&bullet; Fecha: date picker",
        normal_style))

    story.append(PageBreak())

    # ─── ESTADO ───
    story.append(Paragraph("<b>Estado del Proyecto - Entrega 2</b>", heading_style))

    story.append(Paragraph("<b>Completado</b>",
                          ParagraphStyle('h3', parent=styles['Normal'],
                                       fontSize=11, fontName='Helvetica-Bold')))
    story.append(Paragraph(
        "&checkmark; Backend Supabase integrado (PostgreSQL remoto)<br/>" +
        "&checkmark; Realm offline-first (fuente de verdad local)<br/>" +
        "&checkmark; SupabaseSyncService con push() operativo<br/>" +
        "&checkmark; CRUD completo: Crear, Leer, Actualizar, Eliminar<br/>" +
        "&checkmark; Filtros: Todas, Pendientes, Completadas, Alta prioridad<br/>" +
        "&checkmark; Swipe actions operativas<br/>" +
        "&checkmark; Focus Mode: Selector de tarea + Timer Pomodoro<br/>" +
        "&checkmark; Contador de rondas dinámico (n/4)<br/>" +
        "&checkmark; Estadísticas: KPIs, gráficos, heatmap<br/>" +
        "&checkmark; Perfil: toggle tema, selector color acento<br/>" +
        "&checkmark; Sincronización: SyncSheet con 4 pasos<br/>" +
        "&checkmark; Resolución de conflictos<br/>" +
        "&checkmark; Dark Glassmorphism con glow ambient<br/>" +
        "&checkmark; Todos los 9 requisitos implementados",
        normal_style))
    story.append(Spacer(1, 0.1*inch))

    story.append(Paragraph("<b>Conclusión</b>", heading_style))
    story.append(Paragraph(
        "KAIROS 2.0 es una aplicación de productivity completamente funcional con arquitectura " +
        "offline-first. Implementa sincronización bidireccional con Supabase, validaciones robustas, " +
        "UI modern con glassmorphism, y funcionalidad completa de Focus Mode con Pomodoro timer dinámico. " +
        "Todas las funcionalidades requeridas para Entrega 2 están implementadas y operativas.",
        normal_style))

    # ─── BUILD ───
    doc.build(story)
    print(f"PDF generado: {PDF_OUTPUT}")
    print(f"Tamaño: {PDF_OUTPUT.stat().st_size / (1024*1024):.1f} MB")

if __name__ == "__main__":
    print("Generando PDF Entrega 2...")
    create_pdf()
    print("Completado!")
