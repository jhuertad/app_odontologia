# Especificación de Diseño y Prompt para Google Stitch: DentalCare Platform 🦷✨

> **Instrucciones de uso**: Copia y pega el contenido de este documento en **Google Stitch** para generar los prototipos visuales, componentes de interfaz y tokens de diseño. Al obtener la respuesta o código exportado (Flutter, SVG, CSS o Tokens JSON), impórtalos aquí para integrarlos directamente en la aplicación.

---

## 1. Visión y Brief del Producto

- **Nombre de la Aplicación**: DentalCare Cloud Platform
- **Propósito**: Suite clínica y operativa inteligente para odontólogos y clínicas dentales de vanguardia.
- **Dispositivos Objetivo**:
  - **Tablets / iPads (Prioridad Alta)**: Uso interactivo en el sillón dental frente al paciente (formato apaisado / horizontal con vista en dos paneles).
  - **Smartphones (Android e iOS)**: Agenda rápida, visualización de fichas y movilidad del doctor.
- **Estilo Visual Requerido (Google Stitch)**:
  - **Estética**: *Clean Soft-Tech Medical*, hipermoderno, minimalista pero con profundidad visual.
  - **Texturas**: Glassmorphism sutil (`backdrop-filter: blur(16px)`), bordes translúcidos (`rgba(255, 255, 255, 0.6)`), sombras volumétricas suaves (`box-shadow: 0 8px 24px rgba(15, 23, 42, 0.06)`).
  - **Sensación**: Confianza clínica, pulcritud, tecnología de grado médico y facilidad táctil (ergonomía para uso con guantes o lápiz óptico).

---

## 2. Sistema de Diseño (Design Tokens para Stitch)

### 2.1 Paleta Cromática

```json
{
  "colors": {
    "primary": {
      "teal_main": "#00A896",
      "teal_dark": "#028090",
      "mint_glow": "#02C39A",
      "gradient_hero": ["#00A896", "#028090"]
    },
    "neutrals": {
      "background_light": "#F8FAFC",
      "surface_white": "#FFFFFF",
      "surface_frosted": "rgba(255, 255, 255, 0.85)",
      "border_subtle": "#E2E8F0",
      "slate_dark": "#0F172A",
      "slate_card": "#1E293B",
      "text_primary": "#0F172A",
      "text_secondary": "#64748B",
      "text_muted": "#94A3B8"
    },
    "clinical_status": {
      "pathology_caries": {
        "solid": "#E63946",
        "gradient": ["#FF4D6D", "#C9184A"],
        "description": "Caries activa o patología aguda"
      },
      "healthy_restored": {
        "solid": "#0077B6",
        "gradient": ["#00B4D8", "#0077B6"],
        "description": "Obturación en resina o amalgama en buen estado"
      },
      "planned_treatment": {
        "solid": "#FB8500",
        "gradient": ["#FFB703", "#FB8500"],
        "description": "Tratamiento presupuestado o por ejecutar"
      },
      "executed_today": {
        "solid": "#10B981",
        "gradient": ["#34D399", "#059669"],
        "description": "Procedimiento realizado en la sesión actual"
      },
      "crown_prosthesis": {
        "solid": "#D4AF37",
        "gradient": ["#FFD700", "#FFA500"],
        "description": "Corona o prótesis dental dorada/cerámica"
      },
      "endodontic_canal": {
        "solid": "#4F46E5",
        "gradient": ["#6366F1", "#4338CA"],
        "description": "Tratamiento de conductos radiculares"
      },
      "missing_tooth": {
        "solid": "#E63946",
        "description": "Diente extraído o ausente (cruz ergonómica)"
      }
    },
    "medical_alerts": {
      "allergy_critical": "#FF4D6D",
      "allergy_bg": "rgba(255, 77, 109, 0.12)",
      "allergy_border": "rgba(255, 77, 109, 0.3)"
    }
  }
}
```

### 2.2 Tipografía
- **Familia Primaria**: `Plus Jakarta Sans` (o `Inter` en su defecto).
- **Escala**:
  - `Display Large`: 28px, Bold (800), tracking -0.5px.
  - `Title Medium`: 18px, Bold (700).
  - `Body Regular`: 14px, Regular (400), line-height 1.5.
  - `Badge / Label`: 11px, ExtraBold (800), uppercase, tracking 0.5px.

---

## 3. Pantallas Requeridas para Generación

### Pantalla 1: Odontograma Digital Interactivo FDI (Pantalla Principal de Sillón)
- **Cabecera de Paciente (Stitch Patient Banner)**:
  - Avatar circular con iniciales con gradiente Teal.
  - Nombre: *"Camila Ramos Vega"*, edad: *"28 años"*, historia: *"#HC-2049"*.
  - **Badge de Alerta Médica**: Píldora coral pulsante `⚠️ Alergia Crítica: Penicilina`.
  - Métrica de presupuesto dinámico en tiempo real (ej. `$320.00 USD`).
- **Selector de Dentición**:
  - Control deslizante tipo cápsula: `Adulto (32 piezas)` vs. `Pediátrico (20 piezas)`.
- **Lienzo de las Arcadas Dentales (FDI ISO 3950)**:
  - **Arcada Superior**: Cuadrante 1 (18 al 11) y Cuadrante 2 (21 al 28).
  - **Arcada Inferior**: Cuadrante 4 (48 al 41) y Cuadrante 3 (31 al 38).
  - **Línea Media Dental**: Separador vertical con gradiente aguamarina resplandeciente.
  - **Renderizado Anatómico de Cada Diente**:
    - Pieza rectangular/capsular de 44x44px con esquinas redondeadas (`RRect` 10px).
    - 5 facetas táctiles independientes: *Vestibular, Lingual/Palatina, Mesial, Distal y Oclusal*.
    - Relieve con gradientes cerámicos suaves y micro-sombra al pasar el cursor (`hover: scale(1.08)`).
    - Capacidad de mostrar corona dorada, cruz de diente ausente o conducto radicular.
- **Dock Flotante Glassmórfico de Tratamientos (Stitch Tool Dock)**:
  - Barra flotante en la parte inferior con desenfoque de cristal (`backdrop-filter`).
  - Chips con iconos y micro-gradientes: *Caries (Rojo)*, *Restaurado (Azul)*, *Planificado (Ámbar)*, *Hoy (Verde)*, *Ausente (Cruz)*, *Corona (Oro)*, *Endodoncia (Púrpura)*, *Borrador*.
- **Panel Inferior / Drawer de Presupuesto**:
  - Desglose de piezas afectadas, caras tratadas, costo unitario por procedimiento y total acumulado.

---

### Pantalla 2: Dashboard Clínico Inteligente (Panel del Doctor)
- **Barra Superior**:
  - Identidad de la clínica, Dr. John Huerta, fecha actual y campana con badge de notificaciones no leídas.
- **Hero Card: Paciente en Atención (Sillón 1)**:
  - Tarjeta de alto contraste en slate oscuro (`#0F172A`) con efecto glow esmeralda.
  - Indicador en vivo: `🟢 EN ATENCIÓN • SILLÓN 1 • 10:30 AM`.
  - Nombre del paciente, procedimiento en curso y botón de acción directa: `Abrir Odontograma`.
- **Tarjetas de Métricas Rápidas (KPIs)**:
  - *Citas Hoy*: 8 pacientes (2 en sala de espera).
  - *Presupuestos del Mes*: $14,250 (Tasa de aceptación: 94%).
  - *Ocupación de Gabinetes*: 85%.
- **Módulos Clínicos en Grid de Tarjetas**:
  - *Odontograma Digital* (Canvas FDI 32/20 con paleta interactiva).
  - *Agenda & Horarios* (Citas, turnos y confirmaciones automáticas por WhatsApp).
  - *Visor Radiográfico* (Periapicales, panorámicas, zoom de alta resolución y filtros).
  - *Consentimiento Digital* (Lienzo para firma táctil biométrica y sellado PDF).

---

### Pantalla 3: Visor de Radiografías RX & Fotografía Clínica
- **Área de Visualización Central**:
  - Lienzo negro puro médico (`#000000` / `#050505`) con radiografía periapical u ortopantomografía de alta resolución.
  - Herramienta de zoom multitáctil y paneo libre.
- **Barra de Filtros Diagnósticos (Stitch Filter Controls)**:
  - *Inversión de Color*: Botón para alternar a vista en negativo.
  - *Deslizador de Contraste*: Control suave para realce óseo.
  - *Deslizador de Brillo*: Control fino para evaluar ápices y conductos.
  - *Modo Split (Antes vs. Después)*: Línea deslizadora para mostrar progreso estético al paciente.

---

### Pantalla 4: Consentimiento Informado con Firma Biométrica
- **Documento Clínico**:
  - Título del procedimiento (ej. *Cirugía de Tercera Molar #38*).
  - Resumen de riesgos y beneficios en tipografía clara y descansada.
- **Lienzo de Firma Táctil (Signature Canvas)**:
  - Área limpia con fondo blanco y línea de guía para firma con el dedo o lápiz óptico.
  - Botones `Limpiar Trazo` y `Confirmar y Sellar`.
  - Badge de seguridad: `🔒 Sellado Criptográfico SHA-256 + Marca de Tiempo Inmutable`.

---

## 4. Formato de Salida Esperado desde Stitch

Por favor, genera y exporta en cualquiera de estos formatos para integrarlo en Antigravity:
1. **Código Flutter (Dart)**: Widgets reutilizables (`StatelessWidget` / `StatefulWidget`) organizados con Clean Architecture.
2. **Tokens de Diseño**: Archivo JSON o mapa de Dart con colores, tipografías y dimensiones.
3. **Componentes SVG / Canvas**: Definiciones vectoriales de las piezas dentales y sus 5 caras.
4. **Pantallas Maquetadas**: Código responsivo con soporte para modo Claro y Oscuro Quirúrgico.
