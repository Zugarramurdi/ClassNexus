# Changelog: Gestión Académica Administrativa
**Fecha:** 2026-04-27
**Tipo:** Feature / Infra / Fix

## Cambios en el Backend (Laravel)
- **Infraestructura Académica:** Implementación de CRUD para `Cycles` y `Subjects`.
- **Relaciones M:N:** Creada tabla pivot `cycle_subject` para permitir que múltiples ciclos compartan las mismas asignaturas (ej. DAM y DAW en 1º año).
- **Controlador Administrativo:** Añadidos métodos `storeCycle`, `updateCycle` y `deleteCycle` con sincronización de IDs de asignaturas.

## Cambios en la Base de Datos (Supabase)
- **Seguridad (RLS):** Activadas políticas de lectura (`SELECT`) para usuarios autenticados en las tablas `cycles`, `cycle_subject`, `subjects` y `centers`.
- **Poblado de Datos:** Script de inserción para ciclos reales (DAM, DAW, ASIR) y sus asignaturas curriculares oficiales.

## Cambios en el Frontend (Flutter)
- **Estabilidad de UI:** Corregido el uso de `NexusDataTable` para alinearse con la API interna.
- **Robustez de Datos:** Implementada conversión explícita de IDs en modelos `CycleData` y `SubjectData` para evitar errores de tipo dinámico.

## Impacto
- Mejora de la integridad académica al centralizar la definición de asignaturas por ciclo.
- Reducción de errores de carga en entornos de producción gracias a las nuevas políticas de RLS.
