-- ==============================================================================
-- DENTALCARE CLOUD PLATFORM: ESQUEMA DE BASE DE DATOS INICIAL (POSTGRESQL / SUPABASE)
-- Autor: John Huerta (jhuertad@gmail.com)
-- ==============================================================================

-- 1. EXTENSIONES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABLA: CLÍNICAS (Soporte multi-clínica / consultorio)
CREATE TABLE IF NOT EXISTS public.clinicas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(30),
    direccion TEXT,
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. TABLA: PERFILES / DOCTORES (Vinculado a auth.users de Supabase)
CREATE TABLE IF NOT EXISTS public.doctores (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    clinica_id UUID REFERENCES public.clinicas(id) ON DELETE SET NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    colegiatura VARCHAR(50), -- Número de registro profesional (COP/médico)
    especialidad VARCHAR(100) DEFAULT 'Odontología General',
    telefono VARCHAR(30),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. TABLA: HORARIOS Y DISPONIBILIDAD DE DOCTORES
CREATE TABLE IF NOT EXISTS public.horarios_doctor (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID REFERENCES public.doctores(id) ON DELETE CASCADE NOT NULL,
    dia_semana INT NOT NULL CHECK (dia_semana BETWEEN 1 AND 7), -- 1 = Lunes, 7 = Domingo
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    duracion_turno_minutos INT DEFAULT 30,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. TABLA: PACIENTES
CREATE TABLE IF NOT EXISTS public.pacientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinica_id UUID REFERENCES public.clinicas(id) ON DELETE CASCADE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    documento_identidad VARCHAR(30) NOT NULL,
    tipo_documento VARCHAR(10) DEFAULT 'DNI',
    fecha_nacimiento DATE,
    sexo VARCHAR(10),
    telefono_whatsapp VARCHAR(30),
    email VARCHAR(100),
    direccion TEXT,
    ocupacion VARCHAR(100),
    -- Alertas médicas críticas
    alergias_criticas TEXT[], -- Ej: ['Penicilina', 'Látex', 'Ibuprofeno']
    antecedentes_medicos JSONB DEFAULT '{}'::jsonb, -- Diabetes, Hipertensión, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. TABLA: CITAS MÉDICAS
CREATE TABLE IF NOT EXISTS public.citas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinica_id UUID REFERENCES public.clinicas(id) ON DELETE CASCADE,
    paciente_id UUID REFERENCES public.pacientes(id) ON DELETE CASCADE NOT NULL,
    doctor_id UUID REFERENCES public.doctores(id) ON DELETE RESTRICT NOT NULL,
    fecha_hora_inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_hora_fin TIMESTAMP WITH TIME ZONE NOT NULL,
    motivo TEXT,
    estado VARCHAR(30) DEFAULT 'PROGRAMADA' CHECK (
        estado IN ('PROGRAMADA', 'CONFIRMADA', 'EN_SALA', 'EN_ATENCION', 'FINALIZADA', 'CANCELADA', 'NO_ASISTIO')
    ),
    numero_sillon INT DEFAULT 1,
    notas TEXT,
    recordatorio_whatsapp_enviado BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. TABLA: HISTORIAS CLÍNICAS (Notas de Evolución SOAP)
CREATE TABLE IF NOT EXISTS public.historias_clinicas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    paciente_id UUID REFERENCES public.pacientes(id) ON DELETE CASCADE NOT NULL,
    doctor_id UUID REFERENCES public.doctores(id) ON DELETE RESTRICT NOT NULL,
    cita_id UUID REFERENCES public.citas(id) ON DELETE SET NULL,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    -- Estructura SOAP
    subjetivo TEXT, -- Lo que el paciente relata (dolor, molestia)
    objetivo TEXT,   -- Hallazgos del examen clínico
    analisis TEXT,   -- Diagnóstico presuntivo o definitivo
    plan TEXT,       -- Plan de tratamiento o procedimiento realizado
    procedimiento_realizado TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. TABLA: ODONTOGRAMAS
CREATE TABLE IF NOT EXISTS public.odontogramas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    paciente_id UUID REFERENCES public.pacientes(id) ON DELETE CASCADE NOT NULL,
    doctor_id UUID REFERENCES public.doctores(id) ON DELETE RESTRICT NOT NULL,
    tipo_denticion VARCHAR(20) DEFAULT 'ADULTO' CHECK (tipo_denticion IN ('ADULTO', 'PEDIATRICO', 'MIXTO')),
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    observaciones_generales TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 9. TABLA: DETALLE DE DIENTES DEL ODONTOGRAMA (FDI ISO 3950)
CREATE TABLE IF NOT EXISTS public.detalles_dientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    odontograma_id UUID REFERENCES public.odontogramas(id) ON DELETE CASCADE NOT NULL,
    numero_fdi INT NOT NULL CHECK (
        (numero_fdi BETWEEN 11 AND 48) OR -- Dentición permanente adulta
        (numero_fdi BETWEEN 51 AND 85)    -- Dentición decidua infantil
    ),
    -- Caras afectadas: 'V' (Vestibular), 'L' (Lingual/Palatino), 'M' (Mesial), 'D' (Distal), 'O' (Oclusal/Incisal)
    caras_afectadas VARCHAR(10)[], 
    diagnostico VARCHAR(50) NOT NULL, -- 'CARIES', 'FRACTURA', 'EROSION', 'AUSENTE', 'SANO'
    tratamiento_existente VARCHAR(50), -- 'OBTURACION_RESINA', 'AMALGAMA', 'CORONA', 'ENDODONCIA'
    tratamiento_planificado VARCHAR(50),
    estado_tratamiento VARCHAR(20) DEFAULT 'PLANIFICADO' CHECK (
        estado_tratamiento IN ('PATOLOGIA_ACTIVA', 'SANO_TRATADO', 'PLANIFICADO', 'EJECUTADO_HOY')
    ),
    color_hex VARCHAR(10), -- Código de color visual para el Canvas
    notas TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 10. TABLA: RADIOGRAFÍAS E IMÁGENES CLÍNICAS (Cloudflare R2)
CREATE TABLE IF NOT EXISTS public.radiografias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    paciente_id UUID REFERENCES public.pacientes(id) ON DELETE CASCADE NOT NULL,
    doctor_id UUID REFERENCES public.doctores(id) ON DELETE RESTRICT,
    tipo_imagen VARCHAR(30) DEFAULT 'PERIAPICAL' CHECK (
        tipo_imagen IN ('PERIAPICAL', 'PANORAMICA', 'CEFALOMETRICA', 'FOTO_INTRAORAL', 'FOTO_EXTRAORAL')
    ),
    url_storage TEXT NOT NULL, -- URL firmada o pública en Cloudflare R2
    fecha_toma DATE DEFAULT CURRENT_DATE NOT NULL,
    pieza_dental_relacionada INT,
    diagnostico_radiologico TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 11. TABLA: CONSENTIMIENTOS INFORMADOS CON FIRMA DIGITAL
CREATE TABLE IF NOT EXISTS public.consentimientos_firmados (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    paciente_id UUID REFERENCES public.pacientes(id) ON DELETE CASCADE NOT NULL,
    doctor_id UUID REFERENCES public.doctores(id) ON DELETE RESTRICT NOT NULL,
    tipo_procedimiento VARCHAR(100) NOT NULL,
    contenido_terminos TEXT NOT NULL,
    firma_svg TEXT NOT NULL, -- Trazos de la firma táctil
    firma_png_storage_url TEXT,
    hash_sha256 VARCHAR(64) NOT NULL, -- Sello criptográfico inmutable
    ip_origen VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 12. TABLA: PRESUPUESTOS Y PLANES DE TRATAMIENTO
CREATE TABLE IF NOT EXISTS public.presupuestos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    paciente_id UUID REFERENCES public.pacientes(id) ON DELETE CASCADE NOT NULL,
    doctor_id UUID REFERENCES public.doctores(id) ON DELETE RESTRICT NOT NULL,
    odontograma_id UUID REFERENCES public.odontogramas(id) ON DELETE SET NULL,
    total NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    descuento NUMERIC(10, 2) DEFAULT 0.00,
    total_neto NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    saldo_pendiente NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    estado VARCHAR(20) DEFAULT 'BORRADOR' CHECK (
        estado IN ('BORRADOR', 'PRESENTADO', 'APROBADO', 'RECHAZADO', 'FINALIZADO')
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- POLÍTICAS ROW LEVEL SECURITY (RLS) PARA AISLAMIENTO MÉDICO
-- ==============================================================================
ALTER TABLE public.pacientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.citas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.historias_clinicas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.odontogramas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalles_dientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.radiografias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consentimientos_firmados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.presupuestos ENABLE ROW LEVEL SECURITY;

-- Política de lectura/escritura para usuarios autenticados
CREATE POLICY "Doctores pueden gestionar pacientes" ON public.pacientes
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Doctores pueden gestionar citas" ON public.citas
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Doctores pueden gestionar odontogramas" ON public.odontogramas
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Doctores pueden gestionar detalles de dientes" ON public.detalles_dientes
    FOR ALL TO authenticated USING (true) WITH CHECK (true);
