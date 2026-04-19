# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo. El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
