# Integración Fullstack Autenticación (Supabase + Laravel + Flutter)

**Fecha:** 2026-03-10

Esta actualización marca la finalización del Sprint 2 ("Iteración 2"), implementando un flujo de autenticación JWT híbrido de punto a punto desde Supabase directo a la capa de API backend de Laravel, y consumiendo los datos mediante Flutter Web con arquitectura Riverpod.

## 🚀 Funcionalidades y Cambios Técnicos

### Backend (Laravel 10 API)
- **Base de Datos:**
  - Migración al driver `pgsql` conectando directamente al Auth Pool de Supabase.
  - Creación y volcado de las primeras tablas de negocio completando el esquema Entidad-Relación: `roles`, `centers`, `subjects`, `groups` y extendiendo `profiles` ligado a `auth.users` vía UUID en string.
- **Autenticación (API Middleware):**
  - Implementado `SupabaseJwtMiddleware` protegiendo los nuevos endpoints bajo el alias `supabase.auth`.
  - **Refactorización Asimétrica:** Integración exitosa de JWT Asimétrico (ES256) interceptando y absorbiendo la API remota `/auth/v1/.well-known/jwks.json` con caché integrada de 1 hora.
- **Endpoints Expuestos:**
  - `GET /api/me`: Extracción autoejecutada desde el JWT payload (`sub`) sin pasar ID. Devuelve Perfil y su Rol (`role` Model embebido).

### Frontend (Flutter Web)
- **Capa de Red (Networking):**
  - Integrado `dioProvider` con un Interceptor automático instanciando el header `Authorization: Bearer <token>` extraído dinámicamente de Supabase Auth.
- **Gestión de Estado (Riverpod):**
  - Implementación de `FutureProvider` tipado `ProfileData` apuntando a Laravel (`/api/me`).
  - Adaptabilidad de parseos nativos (JSON Stringify safety parsing para los UUIDs).
- **Interfaz (DashboardScreen):**
  - Renderizado síncrono que detecta el status HTTP:
    - Autenticado & Con Perfil (`200 OK`): Expone nombre completo real y el string del Rol del backend. Muestra grid general.
    - Autenticado & Perfil Incompleto (`404`/Válido pero ausente en BD): Fallback nativo mostrando el componente `WarningCard` interrumpiendo navegación.

## 🛠 Cómo probar (Steps to Verify)
1. Abrir la URL de Flutter en el ecosistema actual (vía localhost / Brave Web).
2. Proceder a Iniciar Sesión introduciendo Email de test y Password.
3. Acceder al dashboard; si en este punto la tabla pública `profiles` (Superbase DB) no contiene ese ID, la app deberá bloquearse suavemente mostrando el aviso amarillo "*Tu perfil está incompleto*".
4. Acudir a manual:
   - Añadir una nueva línea en la tabla postgres `profiles`.
   - Incluir un `role_id` válido del 1 al 3 (preasignados en Laravel para Admin, Teacher, Student correspondientemente).
5. Forzar el refresco de pantalla. La aplicación pintará "Bienvenido de vuelta, {Nombre_En_BD}" y cargará la etiqueta "{ROLE_NAME_ASIGNADO}".
