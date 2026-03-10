<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class SupabaseAuthTest extends TestCase
{
    public function test_should_deny_access_without_token()
    {
        $response = $this->getJson('/api/test-auth');
        $response->assertStatus(401);
        $response->assertJson(['error' => 'Token not provided.']);
    }

    public function test_should_deny_access_with_invalid_token()
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer INVALID.TOKEN.DATA'
        ])->getJson('/api/test-auth');
        
        $response->assertStatus(401);
        $response->assertJsonStructure(['error', 'message']);
    }
}
