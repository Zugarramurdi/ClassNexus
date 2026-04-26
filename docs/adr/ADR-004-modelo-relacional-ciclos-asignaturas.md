# ADR-004: Modelo Relacional Ciclos-Asignaturas y RLS Académico

**Estatus:** Aceptado
**Fecha:** 2026-04-27

## Contexto
El sistema necesitaba soportar la realidad académica donde diferentes ciclos formativos (como DAM y DAW) comparten un tronco común de asignaturas en el primer año. Una relación simple 1:N obligaría a duplicar asignaturas, causando inconsistencias. Además, la aplicación Flutter no visualizaba datos debido a la falta de políticas de seguridad (RLS) en las nuevas tablas.

## Decisión
1.  **Modelo de Datos:** Implementar una relación **Muchos a Muchos (M:N)** entre `cycles` y `subjects`.
2.  **Seguridad:** Habilitar políticas de RLS de lectura para todos los usuarios autenticados en el esquema académico. La creación y edición sigue restringida exclusivamente al Backend via API con validación de rol admin.

## Consecuencias

**Trade-offs positivos (+)**
- **Eficiencia:** Una asignatura (ej. "Programación") se define una vez y se vincula a múltiples ciclos.
- **Mantenibilidad:** Cambios en una asignatura común se reflejan instantáneamente en todos los ciclos asociados.

## Notas de Implementación
- Se utiliza el método `sync()` de Eloquent en el backend para gestionar las relaciones en la tabla pivot.
- En Flutter, los modelos ignoran la tabla pivot y cargan la lista de IDs de asignaturas directamente para simplificar el estado del provider.
