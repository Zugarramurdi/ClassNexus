# ADR-003: Estrategia de Despliegue — Dokploy en VPS con Nixpacks

## Estatus
Aceptado

## Fecha
2026-04-19

## Contexto
Con el backend de ClassNexus funcional al 85% del hito académico, se requiere un entorno de producción estable para validar el sistema en condiciones reales, facilitar las pruebas de integración con el cliente Flutter y disponer de una URL pública para la defensa del TFG.

Las alternativas consideradas fueron:

| Opción | Pros | Contras |
|--------|------|---------|
| **Railway / Render (PaaS)** | Sin configuración de servidor | Coste elevado en producción, vendor lock-in |
| **VPS bare-metal + configuración manual** | Control total | Alta complejidad operacional (nginx, SSL, etc.) |
| **Dokploy en VPS propio** | Control total + UI de gestión + Traefik automático | Requiere VPS ya aprovisionado |

## Decisión

Se despliega el backend de Laravel en un **VPS propio gestionado con Dokploy**, utilizando **Nixpacks** como sistema de build. El frontend Flutter no se despliega en esta fase — al ser una app nativa, su distribución es independiente (APK / TestFlight / builds de escritorio).

### Componentes de la solución

- **Dokploy**: Plataforma de auto-hosting que orquesta contenedores Docker, gestiona el reverse proxy (Traefik) y automatiza la renovación de certificados SSL (Let's Encrypt).
- **Nixpacks**: Sistema de build que detecta automáticamente el stack (PHP + Composer + Node) y genera un Dockerfile optimizado sin configuración manual.
- **Traefik**: Reverse proxy integrado en Dokploy. Escucha en los puertos 80/443 del host y enruta por subdominio a cada contenedor de forma aislada.
- **Subdominio**: `api.juanmasegura.com` (registro A en Porkbun apuntando a la IP del VPS).

### Archivos añadidos al repositorio

**`backend/Procfile`**
```
web: php artisan serve --host=0.0.0.0 --port=${PORT:-8080}
```
Indica a Nixpacks el comando de arranque. La variable `$PORT` es inyectada por Dokploy en tiempo de ejecución.

**`backend/nixpacks.toml`**
```toml
[phases.setup]
nixPkgs = ["php83", "php83Packages.composer", "php83Extensions.pdo",
           "php83Extensions.pdo_pgsql", "php83Extensions.mbstring",
           "php83Extensions.tokenizer", "php83Extensions.xml",
           "php83Extensions.ctype", "php83Extensions.bcmath",
           "php83Extensions.fileinfo", "php83Extensions.openssl", "nodejs_20"]

[start]
cmd = "php artisan serve --host=0.0.0.0 --port=${PORT:-8080}"
```
Fija PHP 8.3 e incluye las extensiones necesarias para Laravel + PostgreSQL + Vite.

## Problemas encontrados y soluciones

### 1. `Class "Pdo\Mysql" not found` (Build)
**Causa**: PHP 8.4 introdujo la clase `Pdo\Mysql` como alias del driver MySQL. El archivo `config/database.php` de Laravel referenciaba `Pdo\Mysql::ATTR_SSL_CA` directamente. Al no tener la extensión `pdo_mysql` instalada en el contenedor, PHP fallaba al parsear el archivo incluso aunque `DB_CONNECTION=pgsql`.

**Solución**: Se eliminó la referencia a `Pdo\Mysql::ATTR_SSL_CA` en `config/database.php`, sustituyendo el bloque de opciones MySQL por un array vacío, dado que el proyecto no utiliza MySQL.

```php
// Antes (incompatible con entornos sin pdo_mysql)
'options' => extension_loaded('pdo_mysql') ? array_filter([
    Pdo\Mysql::ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
]) : [],

// Después
'options' => [],
```

### 2. `npm: command not found` (Build)
**Causa**: Nixpacks detectó el `package.json` de Vite en el backend y añadió un paso `npm i` al Dockerfile generado, pero el entorno base no incluía Node.js.

**Solución**: Se añadió `nodejs_20` al array `nixPkgs` del `nixpacks.toml`.

### 3. Bad Gateway 502 (Runtime)
**Causa**: El dominio en Dokploy estaba configurado con puerto `8080`, pero Dokploy inyecta la variable de entorno `PORT=80` en el contenedor. El servidor de Laravel arrancó en el puerto `80` (recogido de `$PORT`), generando un desajuste con la configuración del dominio.

**Solución**: Se cambió el puerto del dominio en Dokploy de `8080` a `80`. Sin redeploy — cambio en caliente en Traefik.

### 4. `Tenant or user not found` (Supabase)
**Causa**: El proyecto de Supabase estaba en estado **standby** por inactividad (limitación del plan gratuito).

**Solución**: Restauración manual del proyecto desde el panel de Supabase. Una vez activo, la conexión PostgreSQL funcionó correctamente.

## Variables de entorno de producción

Las siguientes variables se configuran en Dokploy (nunca en el repositorio):

```
APP_NAME, APP_ENV=production, APP_DEBUG=false, APP_URL, APP_KEY
DB_CONNECTION=pgsql, DB_HOST, DB_PORT=5432, DB_DATABASE, DB_USERNAME, DB_PASSWORD
SUPABASE_URL, SUPABASE_KEY, SUPABASE_JWT_SECRET
CACHE_DRIVER=file, SESSION_DRIVER=file, FILESYSTEM_DISK=local
```

## Consecuencias

### Positivas
- **Aislamiento de contenedores**: Cada servicio del VPS corre en su propia red Docker. No hay conflictos de puertos entre el backend de ClassNexus y otros servicios (ej. PHPMyAdmin) ya desplegados en el mismo VPS.
- **SSL automático**: Traefik gestiona Let's Encrypt sin intervención manual.
- **Integración con GitHub**: Dokploy despliega automáticamente en cada `git push` a `main`.
- **Monorepo compatible**: El campo `Root Directory: backend` en Dokploy permite desplegar solo el subdirectorio del backend sin afectar al frontend Flutter.

### Negativas
- **`php artisan serve` no es producción**: El servidor de desarrollo de Laravel no está diseñado para carga real. Para un TFG es suficiente; en producción real se sustituiría por nginx + php-fpm.
- **Supabase free tier**: El proyecto de base de datos entra en standby por inactividad prolongada. Requiere restauración manual antes de cada sesión de uso.

## Para Stakeholders (Contexto TFG)
> [!NOTE]
> El despliegue en VPS propio con Dokploy demuestra competencia en DevOps aplicada: gestión de contenedores, reverse proxy, SSL automatizado e integración continua con GitHub. La solución es equivalente funcional a plataformas PaaS de pago (Heroku, Railway) pero con control total de la infraestructura y coste cero adicional al VPS ya existente.
