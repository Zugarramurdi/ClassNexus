<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\CenterController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::middleware('supabase.auth')->get('/test-auth', function (Request $request) {
    return response()->json([
        'message' => 'Estás autenticado correctamente con Supabase JWT.',
        'user_id' => $request->attributes->get('supabase_user_id'),
    ]);
});

Route::middleware('supabase.auth')->group(function () {
    Route::get('/me', [ProfileController::class, 'me']);
    
    Route::get('/centers', [CenterController::class, 'index']);
    Route::get('/centers/{id}', [CenterController::class, 'show']);
});
