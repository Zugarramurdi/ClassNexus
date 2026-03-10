<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Exception;

class SupabaseJwtMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(['error' => 'Token not provided.'], 401);
        }

        try {
            $jwksUrl = env('SUPABASE_URL') . '/auth/v1/.well-known/jwks.json';

            // Cacheamos el JWKS de Supabase por 1 hora para no frenar la API
            $jwks = \Illuminate\Support\Facades\Cache::remember('supabase_jwks', 3600, function () use ($jwksUrl) {
                // Deshabilitamos verificación SSL estricta (útil para entornos de desarrollo en Windows con PHP curl) -> `cURL error 60`
                $response = \Illuminate\Support\Facades\Http::withoutVerifying()->get($jwksUrl);
                if ($response->successful()) {
                    return $response->json();
                }
                return null;
            });

            if (!$jwks) {
                return response()->json(['error' => 'Could not fetch JWKS from Supabase.'], 500);
            }

            // Transformamos el JWKS en el formato que `firebase/php-jwt` entiende
            $keys = \Firebase\JWT\JWK::parseKeySet($jwks);

            // Decode token (Automáticamente comprobará la firma ES256 o RS256 contra la clave pública)
            $decoded = JWT::decode($token, $keys);

            // Store the authenticated user's ID in the request
            // Supabase stores user ID in the 'sub' claim
            $request->attributes->add(['supabase_user_id' => $decoded->sub]);

        } catch (Exception $e) {
            return response()->json(['error' => 'Invalid token.', 'message' => $e->getMessage()], 401);
        }

        return $next($request);
    }
}
