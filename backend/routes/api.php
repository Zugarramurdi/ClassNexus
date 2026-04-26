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

    // ENDPOINT TEMPORAL -> Sustituir por lógica de asignaturas propias del usuario post-UI
    Route::get('/subjects', [App\Http\Controllers\Api\SubjectController::class, 'index']);

    // Rutas para los Temarios (Topics) asociados a una Asignatura
    Route::get('/subjects/{subject}/topics', [App\Http\Controllers\Api\TopicController::class, 'index']);
    Route::post('/subjects/{subject}/topics', [App\Http\Controllers\Api\TopicController::class, 'store']);

    // Tareas
    Route::get('/subjects/{subject}/assignments', [\App\Http\Controllers\Api\AssignmentController::class, 'index']);
    Route::post('/subjects/{subject}/assignments', [\App\Http\Controllers\Api\AssignmentController::class, 'store']);

    // Entregas
    Route::get('/assignments/{assignment}/submissions', [\App\Http\Controllers\Api\SubmissionController::class, 'index']);
    Route::post('/assignments/{assignment}/submissions', [\App\Http\Controllers\Api\SubmissionController::class, 'store']);
    Route::patch('/submissions/{submission}/grade', [\App\Http\Controllers\Api\SubmissionController::class, 'grade']);

    // ADMINISTRACIÓN
    Route::post('/admin/users', [\App\Http\Controllers\Api\AdminController::class, 'storeUser']);
    Route::put('/admin/users/{id}', [\App\Http\Controllers\Api\AdminController::class, 'updateUser']);
    Route::delete('/admin/users/{id}', [\App\Http\Controllers\Api\AdminController::class, 'deleteUser']);
    
    Route::post('/admin/centers', [\App\Http\Controllers\Api\AdminController::class, 'storeCenter']);
    Route::put('/admin/centers/{id}', [\App\Http\Controllers\Api\AdminController::class, 'updateCenter']);
    Route::delete('/admin/centers/{id}', [\App\Http\Controllers\Api\AdminController::class, 'deleteCenter']);
});
