-- ############################################################
-- SEED SCRIPT PARA CLASSNEXUS (ENTORNO DAM/DAW) - VERSIÓN CORREGIDA
-- Proyecto: TFG ClassNexus
-- Idempotencia: Gestionada vía lógica IF NOT EXISTS
-- ############################################################

DO $$ 
DECLARE
    center_id_val BIGINT;
    role_admin_id BIGINT := 1;
    role_profe_id BIGINT := 2;
    role_alumno_id BIGINT := 3;
    
    -- IDs Reales proporcionados por el usuario
    profe_dam_uuid UUID := '6d39f8d1-6c90-42b6-ab19-9c95d98e18ea';
    profe_daw_uuid UUID := 'ad1dfce9-46a4-4b0c-b12a-82707e82dc1c';
    alumno_real_uuid UUID := '1c82f9d8-52cc-4808-b8c4-1178e4ff4a12';
    
    -- Variables auxiliares para IDs
    group_dam_1 BIGINT;
    group_dam_2 BIGINT;
    group_daw_1 BIGINT;
    group_daw_2 BIGINT;
    
    subj_prg BIGINT;
    subj_bbdd BIGINT;
    subj_dwec BIGINT;
    subj_dwes BIGINT;
    subj_si BIGINT;
    
    assign_id BIGINT;
BEGIN

    -- 1. CONFIGURACIÓN DEL CENTRO
    IF NOT EXISTS (SELECT 1 FROM public.centers WHERE code = 'ITX-2026') THEN
        INSERT INTO public.centers (name, code, address, created_at, updated_at)
        VALUES ('IES Tecnológico ClassNexus', 'ITX-2026', 'Calle de la Tecnología, 101, Madrid', NOW(), NOW())
        RETURNING id INTO center_id_val;
    ELSE
        SELECT id INTO center_id_val FROM public.centers WHERE code = 'ITX-2026';
    END IF;

    -- 2. ROLES
    INSERT INTO public.roles (id, name, created_at, updated_at) 
    SELECT role_admin_id, 'Admin', NOW(), NOW() WHERE NOT EXISTS (SELECT 1 FROM public.roles WHERE id = role_admin_id);
    INSERT INTO public.roles (id, name, created_at, updated_at) 
    SELECT role_profe_id, 'Profesor', NOW(), NOW() WHERE NOT EXISTS (SELECT 1 FROM public.roles WHERE id = role_profe_id);
    INSERT INTO public.roles (id, name, created_at, updated_at) 
    SELECT role_alumno_id, 'Alumno', NOW(), NOW() WHERE NOT EXISTS (SELECT 1 FROM public.roles WHERE id = role_alumno_id);

    -- 3. PERFILES REALES
    -- Usamos UPDATE o INSERT manual para perfiles (id es UUID único de auth)
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = profe_dam_uuid) THEN
        UPDATE public.profiles SET first_name = 'Julián', last_name = 'Programador Pérez', role_id = role_profe_id WHERE id = profe_dam_uuid;
    ELSE
        INSERT INTO public.profiles (id, first_name, last_name, role_id, created_at) VALUES (profe_dam_uuid, 'Julián', 'Programador Pérez', role_profe_id, NOW());
    END IF;

    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = profe_daw_uuid) THEN
        UPDATE public.profiles SET first_name = 'Marta', last_name = 'Frontender García', role_id = role_profe_id WHERE id = profe_daw_uuid;
    ELSE
        INSERT INTO public.profiles (id, first_name, last_name, role_id, created_at) VALUES (profe_daw_uuid, 'Marta', 'Frontender García', role_profe_id, NOW());
    END IF;

    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = alumno_real_uuid) THEN
        UPDATE public.profiles SET first_name = 'Alex', last_name = 'Estudiante Pro', role_id = role_alumno_id WHERE id = alumno_real_uuid;
    ELSE
        INSERT INTO public.profiles (id, first_name, last_name, role_id, created_at) VALUES (alumno_real_uuid, 'Alex', 'Estudiante Pro', role_alumno_id, NOW());
    END IF;

    -- 4. GRUPOS
    IF NOT EXISTS (SELECT 1 FROM public.groups WHERE name = '1º DAM' AND center_id = center_id_val) THEN
        INSERT INTO public.groups (name, year, center_id, created_at, updated_at) VALUES ('1º DAM', '2025/2026', center_id_val, NOW(), NOW()) RETURNING id INTO group_dam_1;
    ELSE
        SELECT id INTO group_dam_1 FROM public.groups WHERE name = '1º DAM' AND center_id = center_id_val;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.groups WHERE name = '2º DAM' AND center_id = center_id_val) THEN
        INSERT INTO public.groups (name, year, center_id, created_at, updated_at) VALUES ('2º DAM', '2025/2026', center_id_val, NOW(), NOW()) RETURNING id INTO group_dam_2;
    ELSE
        SELECT id INTO group_dam_2 FROM public.groups WHERE name = '2º DAM' AND center_id = center_id_val;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.groups WHERE name = '1º DAW' AND center_id = center_id_val) THEN
        INSERT INTO public.groups (name, year, center_id, created_at, updated_at) VALUES ('1º DAW', '2025/2026', center_id_val, NOW(), NOW()) RETURNING id INTO group_daw_1;
    ELSE
        SELECT id INTO group_daw_1 FROM public.groups WHERE name = '1º DAW' AND center_id = center_id_val;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.groups WHERE name = '2º DAW' AND center_id = center_id_val) THEN
        INSERT INTO public.groups (name, year, center_id, created_at, updated_at) VALUES ('2º DAW', '2025/2026', center_id_val, NOW(), NOW()) RETURNING id INTO group_daw_2;
    ELSE
        SELECT id INTO group_daw_2 FROM public.groups WHERE name = '2º DAW' AND center_id = center_id_val;
    END IF;

    -- 5. ASIGNATURAS
    IF NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'Programación' AND center_id = center_id_val) THEN
        INSERT INTO public.subjects (name, description, center_id, created_at, updated_at) VALUES ('Programación', 'Java y Kotlin', center_id_val, NOW(), NOW()) RETURNING id INTO subj_prg;
    ELSE
        SELECT id INTO subj_prg FROM public.subjects WHERE name = 'Programación' AND center_id = center_id_val;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'Bases de Datos' AND center_id = center_id_val) THEN
        INSERT INTO public.subjects (name, description, center_id, created_at, updated_at) VALUES ('Bases de Datos', 'PostgreSQL', center_id_val, NOW(), NOW()) RETURNING id INTO subj_bbdd;
    ELSE
        SELECT id INTO subj_bbdd FROM public.subjects WHERE name = 'Bases de Datos' AND center_id = center_id_val;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'DWEC' AND center_id = center_id_val) THEN
        INSERT INTO public.subjects (name, description, center_id, created_at, updated_at) VALUES ('DWEC', 'Desarrollo Frontend', center_id_val, NOW(), NOW()) RETURNING id INTO subj_dwec;
    ELSE
        SELECT id INTO subj_dwec FROM public.subjects WHERE name = 'DWEC' AND center_id = center_id_val;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'DWES' AND center_id = center_id_val) THEN
        INSERT INTO public.subjects (name, description, center_id, created_at, updated_at) VALUES ('DWES', 'Desarrollo Backend', center_id_val, NOW(), NOW()) RETURNING id INTO subj_dwes;
    ELSE
        SELECT id INTO subj_dwes FROM public.subjects WHERE name = 'DWES' AND center_id = center_id_val;
    END IF;

    -- 6. ASOCIACIONES PROFESOR-ASIGNATURA
    IF NOT EXISTS (SELECT 1 FROM public.profile_subject WHERE profile_id = profe_dam_uuid AND subject_id = subj_prg) THEN
        INSERT INTO public.profile_subject (profile_id, subject_id, created_at) VALUES (profe_dam_uuid, subj_prg, NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.profile_subject WHERE profile_id = profe_dam_uuid AND subject_id = subj_bbdd) THEN
        INSERT INTO public.profile_subject (profile_id, subject_id, created_at) VALUES (profe_dam_uuid, subj_bbdd, NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.profile_subject WHERE profile_id = profe_daw_uuid AND subject_id = subj_dwec) THEN
        INSERT INTO public.profile_subject (profile_id, subject_id, created_at) VALUES (profe_daw_uuid, subj_dwec, NOW());
    END IF;

    -- 7. TEMARIO
    IF NOT EXISTS (SELECT 1 FROM public.topics WHERE subject_id = subj_prg AND title = 'UD1: Introducción') THEN
        INSERT INTO public.topics (subject_id, title, description, "order", created_at) VALUES (subj_prg, 'UD1: Introducción', 'Fundamentos.', 1, NOW());
    END IF;

    -- 8. TAREAS Y ENTREGAS
    IF NOT EXISTS (SELECT 1 FROM public.assignments WHERE subject_id = subj_prg AND title = 'Práctica 1') THEN
        INSERT INTO public.assignments (subject_id, title, description, due_date, max_score, created_at) 
        VALUES (subj_prg, 'Práctica 1', 'Calculadora en Java.', '2026-03-15 23:59:59', 10, NOW()) RETURNING id INTO assign_id;
        
        IF assign_id IS NOT NULL THEN
            INSERT INTO public.submissions (assignment_id, student_id, score, feedback, created_at) 
            VALUES (assign_id, alumno_real_uuid, 9.50, 'Buen trabajo.', NOW());
        END IF;
    END IF;

    -- 9. ASOCIACIÓN ALUMNO-GRUPO
    IF NOT EXISTS (SELECT 1 FROM public.group_profile WHERE group_id = group_dam_1 AND profile_id = alumno_real_uuid) THEN
        INSERT INTO public.group_profile (group_id, profile_id, created_at) VALUES (group_dam_1, alumno_real_uuid, NOW());
    END IF;

END $$;

-- 11. FANTASMAS (Fuera del bloque para simplicidad, con WHERE NOT EXISTS)
INSERT INTO public.profiles (id, first_name, last_name, role_id) 
SELECT 'a1111111-1111-1111-a111-111111111111', 'Sergio', 'Sistemas Ruiz', 2
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = 'a1111111-1111-1111-a111-111111111111');

INSERT INTO public.profiles (id, first_name, last_name, role_id) 
SELECT 'f1111111-1111-1111-f111-111111111111', 'Lucas', 'López Lira', 3
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = 'f1111111-1111-1111-f111-111111111111');
