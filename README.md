# ClassNexus — Ecosistema de Gestión Académica

**ClassNexus** es una plataforma integral diseñada para simplificar la administración de instituciones educativas, conectando facultades, profesores y alumnos de manera eficiente y segura.

## 🏗️ Arquitectura del Sistema
El proyecto se divide en tres componentes primordiales:
-   **`backend/`**: Servidor API basado en Laravel 10 (PHP) que centraliza la lógica de negocio y seguridad.
-   **`frontend/`**: Aplicación multiplataforma desarrollada en Flutter 3.x para iOS, Android, macOS y Linux.
-   **`database/`**: Esquema relacional gestionado via Supabase (PostgreSQL).

## 🛡️ Decisiones de Arquitectura (ADR)
Las decisiones clave del proyecto están documentadas para garantizar la trazabilidad académica:
1.  [ADR-001: Selección de Stack Tecnológico](docs/adr/ADR-001-Core-Architecture.md)
2.  [ADR-002: Transición a Seguridad Asimétrica (JWT ES256)](docs/adr/ADR-002-Supabase-Asymmetric-JWT.md)

## 📊 Hitos del Proyecto (Contexto TFG)
| Hito | Fase | Valor Aportado |
| :--- | :--- | :--- |
| **Génesis** | Cimentación | Arquitectura base y entorno de desarrollo. |
| **Core Académico** | MVP | Gestión de facultades y departamentos. |
| **Blindaje** | Seguridad | Validación JWT asimétrica (Top-tier security). |
| **Omnicanal** | Expansión | Soporte nativo en iOS, macOS y Linux. |

## ## Para Stakeholders (Contexto TFG)
> [!NOTE]
> ClassNexus no es solo una aplicación, es un sistema distribuido diseñado bajo estándares de industria actuales. La elección de Flutter y Laravel permite un escalado vertical de la solución sin comprometer la facilidad de uso del usuario final.

---
© 2026 - Proyecto de TFG ClassNexus.
