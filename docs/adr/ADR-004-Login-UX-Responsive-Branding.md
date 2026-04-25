# ADR-004: Estrategia de UX en Login y Identidad Visual Responsiva

## Estado
Aceptado

## Contexto
La pantalla de Login es el primer punto de contacto del usuario con ClassNexus. Existían tres problemas identificados:
1.  **Falta de Identidad**: El logo se veía pequeño y desproporcionado en móviles, y el nombre de la app aparecía como "frontend".
2.  **Privacidad vs. UX**: El sistema de visibilidad de contraseña tradicional (clic para alternar) es propenso a errores donde el usuario deja la contraseña visible por descuido.
3.  **Inconsistencia Estética**: Los bordes de los campos de texto no coincidían con el diseño de las tarjetas del Dashboard.

## Decisiones

### 1. Mecánica de "Press and Hold" para Contraseña
Se decide utilizar eventos de puntero (`onPointerDown`/`onPointerUp`) mediante el widget `Listener`.
*   **Por qué**: Mejora la seguridad (la contraseña se oculta inmediatamente al soltar) y ofrece una experiencia más moderna y fluida en dispositivos táctiles.

### 2. Branding Basado en Proporciones de Pantalla
Se descartan los tamaños fijos (pixels) para el logo en favor de porcentajes de `MediaQuery`.
*   **Por qué**: Garantiza que el logo ocupe el 28% de la pantalla sea cual sea el dispositivo (móvil, tablet o escritorio), manteniendo la jerarquía visual deseada por diseño.

### 3. Unificación de Bordes "Teal Clarito"
Se centraliza el estilo en `AppTheme` usando `primary.withOpacity(0.15)`.
*   **Por qué**: Elimina la dureza visual de los bordes negros o grises por defecto, integrando los elementos de entrada con el lenguaje visual de "ClassNexus".

## Consecuencias

### Positivas
*   **Consistencia**: La aplicación se percibe como un producto profesional y terminado.
*   **Seguridad**: Mayor control del usuario sobre sus datos sensibles durante el acceso.
*   **Mantenibilidad**: Al usar porcentajes y temas centralizados, futuros cambios de diseño se propagan automáticamente a todos los componentes.

### Negativas / Riesgos
*   **Complejidad de Implementación**: El uso de `Listener` requiere manejar estados efímeros manualmente, lo que añade ligeras líneas de código frente a un `IconButton` estándar.
*   **Curva de Aprendizaje**: Algunos usuarios podrían esperar el comportamiento de "clic para fijar", aunque el icono del ojo es lo suficientemente intuitivo para indicar la acción.

---
*Fecha: 25 de abril de 2026*
