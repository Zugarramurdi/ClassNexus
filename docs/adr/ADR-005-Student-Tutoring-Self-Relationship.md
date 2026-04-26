# ADR-005: Relación Recursiva para Tutorías en Profiles

## Estado
Aceptado ✅

## Fecha
2026-04-26

## Contexto
En el sistema ClassNexus, los alumnos necesitan tener asignado un profesor como tutor académico. Esta relación es fundamental para el seguimiento del progreso y la comunicación. Técnicamente, tanto profesores como alumnos son registros en la tabla `profiles`, diferenciados por su `role_id`.

## Alternativas Consideradas
1.  **Tabla Intermedia (`tutor_student`)**: Una tabla pivot para gestionar la relación.
    *   *Pros*: Permite múltiples tutores por alumno en el futuro.
    *   *Contras*: Añade complejidad a las consultas y a la lógica del backend para una relación que, por ahora, es estrictamente 1:N (un alumno, un tutor).
2.  **Relación Recursiva en `profiles`**: Añadir un campo `tutor_id` que apunte a la misma tabla.
    *   *Pros*: Máxima simplicidad, consultas directas vía JOIN, fácil de implementar en Eloquent (Laravel) y Supabase.
    *   *Contras*: Limita a un solo tutor por alumno (aceptable según requerimientos).

## Decisión
Se ha optado por la **Opción 2: Relación Recursiva**. Se ha añadido el campo `tutor_id` (UUID, nullable) a la tabla `profiles` con una clave foránea apuntando a `profiles.id`.

## Consecuencias
*   **Backend**: En Laravel, se han definido las relaciones `tutor()` y `students()` en el modelo `Profile`.
*   **Seguridad**: Las políticas de RLS en Supabase deben permitir que el usuario con `tutor_id` correspondiente pueda leer ciertos datos de sus alumnos (pendiente de refinamiento fino).
*   **Integridad**: El administrador es el encargado de asegurar que solo usuarios con rol 'PROFESOR' sean asignados como tutores mediante la validación en el formulario frontend y el controlador backend.

## Referencias
- Plan de Gestión Admin: `docs/plans/2026-04-26-admin-management-crud.md`
- Migración: `backend/database/migrations/2026_04_26_143100_add_tutor_id_to_profiles_table.php`
