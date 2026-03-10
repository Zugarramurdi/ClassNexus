# ADR-002: Transición a Validación JWT Asimétrica (ES256) con Supabase

## Estatus
Aceptado

## Fecha
2026-03-10

## Contexto
Durante la integración de la autenticación de Supabase en el Backend (Laravel) y Frontend (Flutter), se descubrió que las nuevas implementaciones de Supabase (por defecto a partir de mayo de 2025) firman los tokens JWT de manera asimétrica utilizando el algoritmo ES256, proporcionando mayor seguridad y escalabilidad frente a los tokens simétricos (HS256). Nuestro middleware inicial (`SupabaseJwtMiddleware`) validaba usando HS256 mediante un secreto inyectado en `.env`.

Esta validación síncrona provocaba excepciones `Incorrect key for this algorithm` dado que la firma enviada por la API no correspondía, bloqueando el acceso de usuarios legítimos, además de depender de que cada microservicio almacenara el secreto del JWT explícitamente.

## Decisión
Se ha decidido implementar un Middleware Dinámico (`SupabaseJwtMiddleware.php`) en Laravel capaz de procesar firmas ES256 y soportar el flujo JWKS asimétrico de Supabase.

1.  **Obtención JWKS**: El middleware visita el endpoint público `/auth/v1/.well-known/jwks.json` expuesto por Supabase.
2.  **Caché**: Se almacena la lista de claves públicas devueltas en caché estática de Laravel (`Illuminate\Support\Facades\Cache`) por el plazo de 1 hora.
3.  **Procesamiento**: Se utiliza `firebase/php-jwt` y `Firebase\JWT\JWK::parseKeySet()` para mapear los endpoints en formato objeto Key y se validan con la clave privada de ES256 extraída.
4.  **Local-Dev**: Se excluye temporalmente la validación estricta SSL con `->withoutVerifying()` usando `Http` Facade de Laravel para los entornos locales Windows (cURL error 60).

## Consecuencias
### Positivas
-   **Seguridad y Escalabilidad Mejorada**: Los microservicios ahora solo necesitan conocer la URL pública del proyecto; no requiere enrutar secretos sensibles vía `.env` (`SUPABASE_JWT_SECRET`).
-   **Compatibilidad Próxima Generación**: La plataforma está inmediatamente preparada para cualquier API pública que use Oauth2/OIDC con un endpoint JWKS.

### Negativas
-   **Dependencia Externa y Latencia**: Añade latencia en la resolución HTTP inicial (absorbida y mitigada drásticamente por la caché de 1h).
-   **Tolerancia a Fallos SSL local**: La desconexión temporal del chequeo SSL (->withoutVerifying()) asume un riesgo temporal en desarrollo ante ataques *Man in the middle*, justificado para iterar eficientemente en local (se recomienda restringir esto mediante `app()->isLocal()` de cara a producción).

## Notas de Implementación
- Se ha actualizado `api_client.dart` en Flutter para inyectar automáticamente el Bearer proporcionado por `supabase_flutter`.
- La solución aprovecha `firebase/php-jwt` v6+, preinstalado anteriormente en la aplicación.
