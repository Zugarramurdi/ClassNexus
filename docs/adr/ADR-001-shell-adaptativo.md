# ADR-001: Arquitectura Shell Adaptativa y Navegación

**Estatus:** Aceptado
**Fecha:** 2026-04-26

## Contexto
La aplicación ClassNexus requiere un módulo administrativo que sea funcional tanto en plataformas de escritorio (Windows, Mac, Linux) como en dispositivos móviles (iOS, Android). El desafío principal era mantener una estructura de navegación coherente y eficiente que se adaptara al tamaño de la pantalla sin perder el estado de la aplicación ni forzar recargas innecesarias de la interfaz.

## Decisión
Se decidió implementar un `ShellRoute` utilizando `go_router` que envuelve todas las vistas administrativas dentro de un widget `AdminShell`. Este widget utiliza un layout adaptativo que alterna dinámicamente entre un `Sidebar` lateral para pantallas grandes (>= 900px) y un `BottomNavigationBar` para dispositivos móviles.

## Consecuencias

**Trade-offs positivos (+)**
- **Persistencia de Estado**: El Shell permite que la Sidebar o el menú inferior se mantengan estáticos mientras solo cambia el contenido central, mejorando la fluidez percibida.
- **Responsividad Nativa**: Se garantiza que la aplicación sea usable en cualquier dispositivo con un solo código base.
- **Trazabilidad de Navegación**: El uso de rutas anidadas permite que el historial de navegación funcione correctamente ("Back button" en Android y navegadores).

**Trade-offs negativos (−)**
- **Complejidad en Tests**: Requiere la inyección de una configuración real de `GoRouter` en los tests de widgets para validar el estado de la ruta.
- **Curva de Aprendizaje**: El equipo debe estar familiarizado con la gestión de rutas anidadas en Flutter.

## Notas de Implementación
- Se utiliza `context.go()` en lugar de `context.push()` para la navegación entre secciones principales (`centers`, `teachers`, `students`) para evitar el apilamiento infinito de rutas y mantener los breadcrumbs limpios.
- La detección de la ruta activa para el resaltado de iconos se realiza mediante `GoRouterState.of(context).uri.path`.

## Para Stakeholders
**Impacto en el Negocio**: Esta arquitectura permite que ClassNexus sea una herramienta versátil. Los administradores pueden gestionar centros cómodamente desde un PC en la oficina o realizar ajustes rápidos desde su teléfono móvil mientras se desplazan.
**Riesgo**: Bajo. Se utiliza el estándar oficial de navegación recomendado por el equipo de Flutter.
