# Arquetipo de Software y Estructura del Repositorio: DentalCare App

## 1. Información General y Autoría
- **Proyecto**: DentalCare Platform (Gestión Clínica Odontológica Integral)
- **Autor / Desarrollador**: John Huerta
- **Arquitectura**: Clean Architecture / Feature-First
- **Framework Principal**: Flutter 3.x (Dart) Multiplataforma (Android, iOS, iPad/Tablet, Web)
- **Backend & Cloud**: Supabase (PostgreSQL + RLS + Auth + Edge Functions) + Cloudflare R2 (Storage RX)

---

## 2. Configuración de Repositorio Git

### 2.1 Credenciales y Configuración de Autor
Para que todos los commits queden firmados correctamente a tu nombre:
```bash
git init -b main
git config user.name "jhuertad"
git config user.email "jhuertad@gmail.com"
```
*(Si deseas configurarlo a nivel global para toda tu Mac, se añade la bandera `--global`)*.

### 2.2 Vinculación con Repositorio Remoto (GitHub / GitLab)
```bash
# Cuando tengas creada la URL remota:
git remote add origin https://github.com/jhuertad/app_odontologia.git
git branch -M main
git push -u origin main
```

### 2.3 Archivo `.gitignore` Estándar y Seguro
Debe contemplar la exclusión de artefactos de compilación móviles, archivos de entorno con claves secretas (`.env`) y configuraciones de IDE:
```gitignore
# Entorno y Secretos
.env
*.env.local
*.key
*.jks
*.keystore

# Dart & Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
build/
*.pub_cache

# Android
android/**/gradle-wrapper.jar
android/.gradle
android/captures/
android/app/build/

# iOS & macOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
*.xcworkspace
*.xcuserdatad

# IDEs & OS
.DS_Store
.idea/
.vscode/
*.swp
```

---

## 3. Estructura del Arquetipo (Feature-First + Clean Architecture)

Esta estructura modular permite que cada funcionalidad (*feature*) contenga su propia lógica de presentación, dominio (entidades) y datos (repositorios/datasources), evitando código espagueti y facilitando el mantenimiento:

```
app_odontologia/
├── .gitignore                      # Exclusiones de seguridad y compilación
├── README.md                       # Documentación técnica de inicio rápido
├── plan_app_odon.md                # Plan maestro de arquitectura cloud y módulos
├── arquetipo.md                    # Especificación del arquetipo y estructura
├── pubspec.yaml                    # Manifiesto de dependencias de Flutter
├── analysis_options.yaml           # Reglas de linting y buenas prácticas de código Dart
│
├── lib/
│   ├── main.dart                   # Inicialización de servicios (Supabase, Firebase, env)
│   ├── app.dart                    # Configuración de MaterialApp, Theme y Router
│   │
│   ├── core/                       # Módulos transversales y compartidos
│   │   ├── config/
│   │   │   ├── env.dart            # Variables de entorno y llaves públicas de Supabase
│   │   │   └── constants.dart      # Constantes de negocio y códigos FDI
│   │   ├── network/
│   │   │   ├── supabase_client.dart# Instancia singleton del cliente de Supabase
│   │   │   └── api_interceptor.dart# Manejo de errores y tokens de sesión
│   │   ├── router/
│   │   │   ├── app_router.dart     # Definición de rutas con GoRouter
│   │   │   └── route_names.dart    # Nombres tipados de cada pantalla
│   │   ├── theme/
│   │   │   ├── app_colors.dart     # Paleta clínica Stitch (Teal #00A896, Alergias #D90429)
│   │   │   ├── app_typography.dart # Tipografía Inter / Plus Jakarta Sans
│   │   │   └── app_theme.dart      # Temas Light y Dark/Quirúrgico
│   │   └── utils/
│   │       ├── date_formatter.dart # Formato de citas y horarios
│   │       ├── currency_format.dart# Formato de presupuestos y abonos
│   │       └── validators.dart     # Validación de DNI, teléfono y correo
│   │
│   └── features/                   # Módulos de negocio (Feature-First)
│       │
│       ├── auth/                   # Autenticación y Perfil
│       │   ├── data/datasources/   # Supabase Auth Data Source
│       │   ├── domain/models/      # User, Doctor, Rol
│       │   └── presentation/       # Pantallas de Login, Registro, Recuperar clave
│       │
│       ├── appointments/           # Agenda y Horarios
│       │   ├── data/datasources/   # Appointments Remote Datasource
│       │   ├── domain/models/      # Appointment, DoctorSchedule, Chair/Sillón
│       │   └── presentation/       # Calendario (Día/Semana/Mes), Modal de nueva cita
│       │
│       ├── patients/               # Directorio de Pacientes
│       │   ├── data/               # Pacientes Repository
│       │   ├── domain/models/      # Patient, MedicalAlerts
│       │   └── presentation/       # Lista de pacientes, Ficha individual, Registro rápido
│       │
│       ├── medical_history/        # Historia Clínica Electrónica
│       │   ├── domain/models/      # MedicalRecord, SOAPNote, AllergyBadge
│       │   └── presentation/       # Línea de tiempo de evoluciones, Anamnesis
│       │
│       ├── odontogram/             # Odontograma Interactivo (Canvas FDI)
│       │   ├── domain/models/      # Tooth (11-48, 51-85), ToothSurface, Diagnosis, Treatment
│       │   ├── presentation/
│       │   │   ├── controllers/    # Gestor de estado de selección de piezas
│       │   │   ├── widgets/        # ToothCanvasWidget, DentalQuadrantView, PaletteToolbar
│       │   │   └── screens/        # OdontogramaScreen (Pantalla completa / Tablet Split)
│       │
│       ├── radiology/              # Visor RX y Fotografías Clínicas
│       │   ├── domain/models/      # XRayImage, ImageFilterPreset
│       │   └── presentation/       # XRayViewerScreen (Inversión negativo, Contraste, Zoom)
│       │
│       ├── consent/                # Consentimiento Informado Digital
│       │   ├── domain/models/      # ConsentTemplate, SignedConsent
│       │   └── presentation/       # SignatureCanvasScreen (Lienzo para firma táctil)
│       │
│       └── billing_quotes/         # Presupuestos y Control de Abonos
│           ├── domain/models/      # Quote, QuotePhase, PaymentInstallment
│           └── presentation/       # Generador de presupuesto ligado a odontograma
│
├── supabase/                       # Infraestructura como Código (IaC)
│   ├── migrations/                 # Scripts SQL DDL para base de datos PostgreSQL
│   │   └── 20261018000001_initial_schema.sql
│   └── functions/                  # Supabase Edge Functions (Deno / TypeScript)
│       ├── send-whatsapp-reminder/ # Bot de recordatorios con WhatsApp Cloud API
│       └── generate-consent-pdf/   # Sellado de consentimientos con firma digital
│
└── test/                           # Pruebas Automatizadas
    ├── unit/                       # Pruebas de modelos, cálculos de presupuesto y lógica
    └── widget/                     # Pruebas de componentes visuales (Odontograma Canvas)
```

---

## 4. Stack de Dependencias Clave (`pubspec.yaml`)

| Paquete | Versión Recomendada | Propósito en la App Odontológica |
| :--- | :--- | :--- |
| `supabase_flutter` | `^2.x` | Cliente integral: Base de datos Postgres, Auth y Realtime. |
| `go_router` | `^14.x` | Navegación declarativa moderna y URLs amigables. |
| `flutter_riverpod` | `^2.x` | Gestión de estado reactiva, segura e independiente del árbol de widgets. |
| `signature` | `^5.x` | Captura de firma táctil de pacientes para consentimientos informados. |
| `photo_view` | `^0.15.x` | Control de gestos multitáctiles (zoom/pan) para radiografías médicas de alta resolución. |
| `table_calendar` | `^3.x` | Calendario interactivo para citas y horarios de doctores. |
| `intl` | `^0.19.x` | Formateo localizado de fechas, horas y monedas. |
| `flutter_svg` | `^2.x` | Renderizado nítido de piezas dentales vectoriales e iconos clínicos. |
| `pdf` & `printing` | `^3.x` | Generación y exportación de presupuestos y recetas médicas a PDF. |

---

## 5. Diseño UI / Tokens de Stitch (`app_colors.dart`)

```dart
import 'package:flutter/material.dart';

class DentalColors {
  // Primarios Clínicos
  static const Color primaryTeal = Color(0xFF00A896);
  static const Color primaryDarkTeal = Color(0xFF028090);
  static const Color accentMint = Color(0xFF02C39A);

  // Alertas Médicas & Estados del Odontograma
  static const Color alertCritical = Color(0xFFD90429); // Alergias severas / Urgencias
  static const Color pathologyCaries = Color(0xFFE63946); // 🔴 Caries activa
  static const Color healthyRestored = Color(0xFF1D3557); // 🔵 Obturación/Tratamiento sano
  static const Color plannedTreatment = Color(0xFFF4A261); // 🟡 Tratamiento planificado
  static const Color executedToday = Color(0xFF2A9D8F); // 🟢 Tratamiento realizado hoy

  // Fondos y Superficies
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A); // Modo Quirúrgico
  static const Color surfaceDark = Color(0xFF1E293B);

  // Textos y Bordes
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
}
```

---

## 6. Siguientes Pasos de Ejecución
1. Configurar tu correo de autor en Git (`git config user.email`).
2. Crear los archivos base del arquetipo en el proyecto.
3. Generar el script de migración inicial de base de datos en `supabase/migrations/`.
4. Ejecutar el primer commit (`feat: inicializar arquetipo de arquitectura limpia DentalCare`).
