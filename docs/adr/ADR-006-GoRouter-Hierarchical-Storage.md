# ADR-006: GoRouter & Storage Jerárquico para el Módulo de Tareas

**Estatus:** Aceptado
**Fecha:** 2026-04-30

## Contexto
Durante el desarrollo del módulo de tareas y evaluación de ClassNexus, el uso de `LayoutBuilder` provocaba conflictos de renderizado al anidar la navegación interna, dificultando la estabilidad de la UI. Adicionalmente, el requerimiento de permitir entregas de archivos (PDF, ZIP, imágenes) necesitaba una estrategia clara para organizar los recursos en la nube, evitando la sobrescritura y colisión de nombres de archivo cuando distintos alumnos entregan sus prácticas.

## Decisión
1. **Navegación**: Migrar el enrutamiento del módulo de tareas hacia **GoRouter**, gestionando la pila de navegación de manera imperativa y declarativa sin conflictos de constraints.
2. **Storage**: Implementar un modelo de "Storage Jerárquico". Las rutas en los buckets (Supabase) incluirán los IDs únicos (UUIDs) de la tarea y de la entrega para garantizar el aislamiento absoluto de los ficheros.
3. **Optimización de Estado**: Actualizar la visualización de calificaciones y feedback en la app mediante la "invalidación selectiva de providers" (Riverpod). Esto actualiza únicamente el fragmento de datos afectado por una modificación (ej. al recibir una nota) en lugar de recargar la página entera o requerir WebSockets.

## Consecuencias

**Trade-offs positivos (+)**
- Eliminación de errores de renderizado y transiciones seguras.
- Integridad asegurada en los recursos adjuntos por aislamiento estricto de carpetas.
- Refresco de UI asíncrono y liviano, minimizando la carga en la red.

**Trade-offs negativos (−)**
- Incremento de la verbosidad (boilerplate) al definir las rutas anidadas en la configuración principal de GoRouter.

## Notas de Implementación
*Nota sobre el flujo de actualización:* Tras realizar mutaciones (ej: subir un feedback o calificar una tarea), es imperativo emplear `ref.invalidate(providerName)` sobre el provider que lista/provee la tarea, para forzar el re-fetch de estado subyacente. Nunca forzar un `setState` tradicional en estas vistas complejas.

## Para Stakeholders (Contexto TFG)
Esta sección expone el impacto de las decisiones técnicas para evaluadores y miembros del tribunal del Trabajo de Fin de Grado, sin utilizar jerga técnica de la implementación:

- **Impacto y Valor Añadido**: El concepto de "Storage Jerárquico" asegura que los documentos subidos por los alumnos (prácticas, memorias) o profesores (feedback, archivos adjuntos) queden aislados. Es virtualmente imposible que la entrega de un estudiante sobrescriba el archivo de otro, logrando un sistema fiable a nivel de producción.
- **Fiabilidad y Experiencia de Usuario**: El cambio en la navegación interna erradica el problema de parpadeos o "pantallas en blanco" que sucedía al alternar entre la lista de tareas y el detalle de evaluación, proporcionando una usabilidad robusta.
- **Riesgos Mitigados y Viabilidad Económica**: La técnica de sincronizar las notas y el feedback (invalidación selectiva) proporciona a profesores y estudiantes una percepción de "tiempo real". Técnicamente, esto se logra sin mantener conexiones permanentes abiertas (WebSockets), lo cual reduce de forma drástica el consumo de CPU del servidor. Esto garantiza que la plataforma mantenga unos costes de infraestructura contenidos (Tier gratuito o muy básico), cumpliendo con los objetivos de viabilidad económica del TFG.
