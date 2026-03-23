<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    /**
     * Prueba que los endpoints protegidos rechazan el acceso
     * si no se provee un token JWT de Supabase en las cabeceras.
     */
    public function test_api_me_rejects_unauthenticated_requests(): void
    {
        // Se hace una petición a /api/me sin cabecera Authorization
        $response = $this->getJson('/api/me');

        // Como usamos nuestro SupabaseJwtMiddleware, esperamos que aborte
        // con un status HTTP 401 Unauthorized
        $response->assertStatus(401);
        
        $response->assertJsonStructure(['error']);
    }

    /**
     * Prueba que el enrutamiento base de Centers también está protegido
     */
    public function test_api_centers_rejects_unauthenticated_requests(): void
    {
        $response = $this->getJson('/api/centers');
        $response->assertStatus(401);
    }
}
