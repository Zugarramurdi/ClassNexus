# ADR-001: Arquitectura Base y Selección de Stack Tecnológico

## Estatus
Aceptado

## Fecha
2026-03-01

## Contexto
El proyecto **ClassNexus** surge como una solución integral para la gestión académica. Se requiere una plataforma capaz de ofrecer una experiencia nativa fluida, una API robusta y una gestión de datos escalable sin incurrir en costes prohibitivos ni tiempos de desarrollo excesivos durante la fase de Trabajo Fin de Grado (TFG).

## Decisión
Se ha seleccionado el siguiente stack tecnológico ("The Golden Triangle") para el núcleo del sistema:

1.  **Backend: Laravel 10 (PHP)**
    - Proporciona una estructura sólida, Eloquent ORM para modelado complejo y un ecosistema de seguridad maduro.
2.  **Frontend: Flutter 3.x (Dart)**
    - Permite el desarrollo multiplataforma (iOS, Android, macOS, Linux, Web) con una base de código única, garantizando visuales consistentes.
3.  **BaaS: Supabase (PostgreSQL + Auth + Storage)**
    - Actúa como el centro de datos y proveedor de identidad. Su integración nativa con PostgreSQL permite consultas complejas y gestión de eventos en tiempo real.

## Consecuencias
### Positivas
-   **Velocidad de Iteración**: El uso de Supabase elimina la necesidad de escribir manualmente todo el sistema de autenticación.
-   **Consistencia**: Flutter asegura que la lógica de negocio se mantenga idéntica en todas las plataformas cliente.
-   **Modularidad**: Laravel permite aislar la lógica de servidor para integraciones futuras con otros servicios.

### Negativas
-   **Dependencia (Vendor Lock-in)**: El sistema depende críticamente de la disponibilidad de Supabase para la autenticación de usuarios.

## ## Para Stakeholders (Contexto TFG)
> [!NOTE]
> Esta decisión establece los cimientos de ClassNexus. Elegir un stack consolidado como Laravel junto a uno innovador como Flutter asegura un producto con calidad profesional preparado para su defensa.
> - **Impacto**: Reducción del tiempo de desarrollo estimado en un 30% mediante el uso de infraestructura gestionada.
> - **Riesgo**: La dependencia del proveedor externo se mitiga mediante una arquitectura de servicios desacoplada.
