# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo. El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.6.0] — 2026-04-26
### Añadido
- **Gestión Admin (CRUD)**: Implementación completa de alta, edición y borrado para Centros, Profesores y Alumnos.
- **Sistema de Tutorías**: Nueva lógica para asignar profesores como tutores de alumnos mediante relación recursiva en la base de datos.
- **UI de Administración**: 
    - Componente `NexusDataTable` mejorado con soporte para acciones por fila.
    - Formularios inteligentes con modo dual (Creación/Edición) e inyección de datos.
- **Seguridad y Consistencia**: Bloqueo de edición de email para usuarios existentes y diálogos de confirmación para borrado.

### Cambiado
- **Refresco de Datos**: Implementación de invalidación de proveedores (`ref.invalidate`) para asegurar que los cambios administrativos se reflejen inmediatamente sin recargar.

### Corregido
- **Bug de Compilación**: Eliminado parámetro duplicado en `AdminUsersNotifier` que impedía el build en Windows.

## [v0.5.0] — 2026-04-25
### Añadido
- **Identidad de Marca**: Renombrado oficial de la aplicación a **ClassNexus** en Android, iOS, Windows, Web, Linux y macOS.
- **Branding Multiplataforma**: Configuración y generación de iconos nativos para todos los sistemas operativos mediante `flutter_launcher_icons`.
- **UX de Autenticación**: Implementación de visibilidad de contraseña por presión ("Press and Hold") y navegación por teclado en Login.
- **Diseño Responsivo**: Nuevo sistema de escalado dinámico para el logo de acceso basado en el 28% de la altura de pantalla.

### Cambiado
- **UI Consistency**: Unificación de bordes de `TextField` y `NexusCard` usando Teal clarito (`primary.withOpacity(0.15)`).
- **Estabilidad**: Estandarización de todos los imports a `package:frontend/` para evitar errores en Windows.

### Corregido
- **Manejo de Sesión**: Implementación de redirección automática al Login ante errores de autenticación `401`.
- **Dashboard**: Mejora en el manejo de errores cuando el perfil de usuario no es encontrado.

## [v0.4.0] — 2026-04-02
### Añadido
- Soporte nativo para **macOS**, **Linux** y **iOS** en el frontend de Flutter.
- Configuración de `Runner` y `Entitlements` para despliegue multiplataforma.

## [v0.3.0] — 2026-03-10
### Cambiado
- **Seguridad**: Transición de JWT HS256 a validación asimétrica ES256 (JWKS).
- Ref: [ADR-002: Transición a Seguridad Asimétrica](docs/adr/ADR-002-Supabase-Asymmetric-JWT.md)

## [v0.2.1] — 2026-03-07
### Corregido
- Validación de JWT en modo síncrono para entornos locales.

## [v0.2.0] — 2026-03-03
### Añadido
- **Core Académico**: Entidades iniciales de Facultades y Departamentos en el Backend.
- Sincronización inicial con Supabase Auth.

## [v0.1.0] — 2026-02-05
### Añadido
- **Initial Commit**: Estructura base de Laravel 10 y Flutter 3.x.
- Ref: [ADR-001: Selección de Stack Tecnológico](docs/adr/ADR-001-Core-Architecture.md)

---
*Este changelog ha sido reconstruido mediante arqueología de Git para la memoria del TFG.*
