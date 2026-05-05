# Entrega 2 - KAIROS 2.0

## 📦 Contenido

- `Entrega2_KAIROS_Evidencias.md` - Documento completo con todas las evidencias
- `generar_entrega2.py` - Script Python para generar las evidencias
- SQL_SETUP_SUPABASE.sql - Script para crear tabla en Supabase

## 📋 Instrucciones Entrega

### 1. Crear tabla en Supabase ⚠️ IMPORTANTE

1. Abrir: https://app.supabase.com/project/mxhyuzucjygdjmamtcjq/sql/new
2. Copiar contenido de `../kairos/SQL_SETUP_SUPABASE.sql`
3. Pegar en SQL Editor de Supabase
4. Click "Run" (▶️)

La tabla `tasks` se crea automáticamente con datos de ejemplo.

### 2. Convertir Markdown a PDF

#### Opción A: Con Pandoc (Recomendado)
```bash
# Instalar pandoc desde: https://pandoc.org/installing.html
pandoc Entrega2_KAIROS_Evidencias.md -o Entrega2_KAIROS.pdf
```

#### Opción B: Con LibreOffice
```bash
# Instalar LibreOffice si no lo tienes
libreoffice --headless --convert-to pdf Entrega2_KAIROS_Evidencias.md
```

#### Opción C: Copiar a Word y exportar
1. Abrir Entrega2_KAIROS_Evidencias.md en VSCode
2. Copiar todo el contenido
3. Pegar en Word (o Google Docs)
4. Exportar como PDF

### 3. Testing Local (Opcional)

```bash
cd ../kairos
flutter run
```

Flujo:
- Splash → Onboarding → Login (test@test.com / password123)
- Dashboard → Create Task → Focus Timer
- Perfil → Forzar Sincronización (SyncSheet real)

## ✅ Checklist Entrega 2

- [x] Backend Supabase integrado
- [x] Validaciones Login (email regex, min 6 contraseña)
- [x] Todos los callbacks funcionales
- [x] Stats dinámicas desde Realm
- [x] Contador rondas Pomodoro dinámico
- [x] Dark Glassmorphism glow up
- [x] SyncSheet con progreso real
- [x] ConflictSheet integrado
- [x] Dashboard campana tappable
- [x] Profile toggle sync con animación
- [x] Cerrar sesión funcional
- [x] Fragmentos de código incluidos
- [x] Flujo completo documentado
- [x] No hay botones sin funcionalidad
- [x] PDF lista para entregar

## 📄 Contenido PDF Requerido

El PDF incluye:

1. ✅ Identificación del alumnado
2. ✅ Descripción del proyecto
3. ✅ Flujo completo de la aplicación (8 pasos)
4. ✅ Funcionalidades implementadas (8 categorías)
5. ✅ Stack técnico
6. ✅ Fragmentos de código clave (5 ejemplos)
7. ✅ Evidencia de integración backend (Supabase)
8. ✅ Validaciones implementadas
9. ✅ Screenshots/descripción todas las pantallas
10. ✅ Estado final del proyecto

## 🔗 Links Importantes

- **Supabase Project**: https://app.supabase.com/project/mxhyuzucjygdjmamtcjq
- **GitHub Commit**: `9eea941`
- **Rama**: `feat/visual-alignment-2-0`

## 📝 Notas

- El proyecto compila sin errores críticos (`flutter analyze`)
- Todas las dependencias instaladas (`flutter pub get`)
- Base de datos Realm con schema version 1
- Sincronización mock (implementación real en Entrega 3)
- Auth mock (implementación real en Entrega 3)

---

**Generado**: 6 de Mayo de 2026  
**Alumno**: Ismael Manzano León  
**Email**: ismaelmanzanoleon@gmail.com
