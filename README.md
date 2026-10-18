# DentalCare Cloud Platform 🦷☁️

Plataforma inteligente de gestión clínica odontológica desarrollada en **Flutter** con arquitectura limpia (**Feature-First / Clean Architecture**) y servicios cloud-native en **Supabase** y **Cloudflare R2**.

---

## 🚀 Características Principales

- **Multiplataforma Unificada**: Android, iOS, iPad/Tablet (Modo Sillón Dental) y Web.
- **Odontograma Interactivo Digital (Canvas)**:
  - Sistema internacional **FDI (ISO 3950)**: Dentición adulta (32 piezas) y pediátrica (20 piezas).
  - Selección táctil por caras dentales: *Vestibular, Lingual/Palatino, Mesial, Distal y Oclusal*.
  - Código estandarizado de colores: 🔴 Patología/Caries, 🔵 Tratamiento sano, 🟡 Planificado, 🟢 Realizado hoy.
- **Visor de Radiografías y Registro Clínico**:
  - Soporte de periapicales, panorámicas y fotos intraorales.
  - Ajuste de brillo, contraste, inversión de color (negativo) y zoom sin pérdida.
- **Historia Clínica Electrónica (SOAP)**:
  - Badges de alerta médica en rojo para alergias severas (Penicilina, Látex, Anestésicos).
- **Consentimiento Informado Digital**:
  - Lienzo de firma biométrica/táctil en pantalla del dispositivo.
- **Presupuestos Inteligentes**:
  - Cotización automática por fases generada a partir del odontograma.
- **Recordatorios por WhatsApp**:
  - Integración cloud para confirmación de citas y reducción de ausentismos (*No-Shows*).

---

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                   # Inicialización y bootstrap de servicios
├── app.dart                    # Configuración de MaterialApp y temas
├── core/                       # Núcleo transversal compartido
│   ├── config/                 # Variables de entorno y constantes
│   ├── constants/              # Colores Stitch, códigos FDI
│   ├── network/                # Cliente Supabase & R2
│   ├── router/                 # GoRouter declarativo
│   └── theme/                  # Design System Clean Medical (Light/Dark)
└── features/                   # Módulos de negocio (Feature-First)
    ├── appointments/           # Agenda y horarios
    ├── auth/                   # Autenticación y control de accesos
    ├── billing_quotes/         # Presupuestos dinámicos
    ├── consent/                # Firma de consentimientos
    ├── medical_history/        # Historia clínica y alergias
    ├── odontogram/             # Odontograma interactivo FDI
    ├── patients/               # Directorio y ficha de pacientes
    └── radiology/              # Visor RX y fotografía clínica
```

---

## 🛠️ Requisitos Previos

- **Flutter SDK**: 3.22.0 o superior
- **Dart SDK**: 3.4.0 o superior
- **Cuenta en Supabase**: Proyecto activo con PostgreSQL y Auth habilitado.
- **Git**: Configurado con `jhuertad` / `jhuertad@gmail.com`.

---

## ⚙️ Configuración y Arranque Rápido

1. **Clonar e instalar dependencias:**
   ```bash
   git clone https://github.com/jhuertad/app_odontologia.git
   cd app_odontologia
   flutter pub get
   ```

2. **Configurar variables de entorno:**
   Copiar `.env.example` a `.env` y completar con las credenciales de Supabase:
   ```bash
   cp .env.example .env
   ```

3. **Ejecutar migraciones en Supabase:**
   Aplicar el archivo `supabase/migrations/20261018000001_initial_schema.sql` en el SQL Editor de tu dashboard de Supabase.

4. **Lanzar la aplicación:**
   ```bash
   # En dispositivo móvil o emulador Android
   flutter run -d android

   # En simulador iOS
   flutter run -d ios

   # En navegador Web
   flutter run -d chrome
   ```

---

## 📄 Licencia y Autoría
- **Autor**: John Huerta (`jhuertad@gmail.com`)
- **Repositorio**: [https://github.com/jhuertad/app_odontologia](https://github.com/jhuertad/app_odontologia)
