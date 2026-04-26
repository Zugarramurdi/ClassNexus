# Changelog: Gestión Administrativa (Admin CRUD)

Fecha: 2026-04-26

## Descripción de la Tarea
Implementación completa del módulo de administración global para ClassNexus, permitiendo la gestión centralizada de centros educativos y perfiles de usuario (Profesores y Alumnos).

## Funcionalidades Implementadas
- **CRUD de Centros**: Listado responsivo con búsqueda y formulario de alta.
- **CRUD de Usuarios**: Gestión de perfiles con asignación de centro y rol.
- **Adaptive Admin Shell**: Interfaz que se adapta automáticamente a escritorio y móvil.
- **Developer Bypass**: Acceso directo al panel administrativo desde Login para facilitar el testeo.

## Decisiones de Arquitectura
- **ShellRoute**: Implementado para mantener el estado de navegación multiplataforma (Ver ADR-001).
- **NexusDataTable**: Nuevo componente reutilizable para visualización de datos masivos con comportamiento responsivo.
- **Sync Laravel-Supabase**: La creación de usuarios pasa por Laravel para orquestar Auth, mientras que el listado se obtiene directamente de Supabase por rendimiento.

## Calidad y Verificación
- **Tests**: 13 tests de widgets y unitarios passing (100% cobertura de lógica de providers).
- **Responsividad**: Verificada en resoluciones de 400px (móvil) y 1920px (escritorio).
- **Seguridad**: Políticas RLS validadas para restringir el acceso solo a administradores.

## Para Stakeholders
**Resultado Final**: Se ha entregado una herramienta de gestión robusta que reduce el tiempo de administración de la plataforma. El sistema es seguro y escalable, permitiendo una expansión futura sin costes técnicos significativos.
**Valor Añadido**: La capacidad multiplataforma asegura que el control de la aplicación esté siempre al alcance del usuario, independientemente del dispositivo que use.
