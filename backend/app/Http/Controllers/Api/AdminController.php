<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Profile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AdminController extends Controller
{
    /**
     * Crea un usuario en Supabase Auth y su perfil correspondiente.
     */
    public function storeUser(Request $request)
    {
        Log::info('Datos recibidos para creación de usuario:', $request->all());

        // 1. Verificar que quien llama es Admin
        $callerId = $request->attributes->get('supabase_user_id');
        $admin = Profile::find($callerId);

        if (!$admin || $admin->role_id !== 1) {
            return response()->json(['message' => 'No tienes permisos de administrador'], 403);
        }

        $request->validate([
            'email' => 'required|email',
            'first_name' => 'required|string',
            'last_name' => 'required|string',
            'role_id' => 'required|integer',
            'password' => 'required|string|min:6',
            'center_id' => 'nullable|integer',
            'tutor_id' => 'nullable|uuid',
            'cycle_id' => 'nullable|integer',
            'subject_ids' => 'nullable|array',
            'subject_ids.*' => 'integer',
        ]);

        $supabaseUrl = env('SUPABASE_URL');
        $serviceRoleKey = env('SUPABASE_SERVICE_ROLE_KEY');

        if (!$serviceRoleKey) {
            // Si no hay service role key, intentamos una creación básica de perfil 
            // pero esto fallará si el usuario no existe en Auth.
            // Para el TFG, lo ideal es configurar la key.
            return response()->json([
                'message' => 'Configuración incompleta: falta SUPABASE_SERVICE_ROLE_KEY en el servidor.'
            ], 500);
        }

        // 2. Crear usuario en Supabase Auth (vía Admin API)
        // Usamos una contraseña temporal por defecto para simplificar el flujo inicial
        try {
            $response = Http::withoutVerifying()->withHeaders([
                'Authorization' => 'Bearer ' . $serviceRoleKey,
                'apikey' => $serviceRoleKey,
            ])->post($supabaseUrl . '/auth/v1/admin/users', [
                'email' => $request->email,
                'password' => $request->password,
                'email_confirm' => true,
                'user_metadata' => [
                    'first_name' => $request->first_name,
                    'last_name' => $request->last_name,
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Excepción llamando a Supabase Auth API: ' . $e->getMessage());
            return response()->json([
                'message' => 'Error de conexión con el servicio de autenticación',
                'error' => $e->getMessage()
            ], 500);
        }

        if ($response->failed()) {
            Log::error('Error creando usuario en Supabase Auth', [
                'status' => $response->status(),
                'body' => $response->json()
            ]);
            return response()->json([
                'message' => 'Supabase Auth denegó la creación del usuario',
                'details' => $response->json()
            ], $response->status());
        }

        $userData = $response->json();
        $newUserId = $userData['id'];

        // 3. Crear o actualizar el perfil en la tabla pública
        try {
            $profile = Profile::updateOrCreate(
                ['id' => $newUserId],
                [
                    'first_name' => $request->first_name,
                    'last_name' => $request->last_name,
                    'email' => $request->email,
                    'role_id' => $request->role_id,
                    'center_id' => $request->center_id,
                    'tutor_id' => $request->tutor_id,
                    'cycle_id' => $request->cycle_id,
                ]
            );
            // 4. Sincronizar asignaturas si es profesor
            if ($request->has('subject_ids')) {
                $profile->teachingSubjects()->sync($request->subject_ids);
            }
        } catch (\Exception $e) {
            Log::error('Error creando perfil en DB tras crear usuario en Auth', [
                'user_id' => $newUserId,
                'error' => $e->getMessage()
            ]);
            // Nota: El usuario ya está creado en Auth. En producción se debería hacer rollback manual si no hay transacciones distribuidas.
            return response()->json([
                'message' => 'Usuario creado en Auth pero falló la creación del perfil en la base de datos',
                'error' => $e->getMessage()
            ], 500);
        }

        return response()->json([
            'message' => 'Usuario creado correctamente',
            'profile' => $profile
        ], 201);
    }

    /**
     * Actualiza un usuario.
     */
    public function updateUser(Request $request, $id)
    {
        $callerId = $request->attributes->get('supabase_user_id');
        $admin = Profile::find($callerId);

        if (!$admin || $admin->role_id !== 1) {
            return response()->json(['message' => 'No tienes permisos de administrador'], 403);
        }

        $request->validate([
            'first_name' => 'required|string',
            'last_name' => 'required|string',
            'center_id' => 'nullable|integer',
            'tutor_id' => 'nullable|uuid',
            'cycle_id' => 'nullable|integer',
            'subject_ids' => 'nullable|array',
            'subject_ids.*' => 'integer',
        ]);

        try {
            $profile = Profile::findOrFail($id);
            $profile->update([
                'first_name' => $request->first_name,
                'last_name' => $request->last_name,
                'center_id' => $request->center_id,
                'tutor_id' => $request->tutor_id,
                'cycle_id' => $request->cycle_id,
            ]);
            
            // Sincronizar asignaturas si se envían
            if ($request->has('subject_ids')) {
                $profile->teachingSubjects()->sync($request->subject_ids);
            }

            return response()->json([
                'message' => 'Usuario actualizado correctamente',
                'profile' => $profile
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al actualizar el usuario',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Elimina un usuario de Auth y su perfil.
     */
    public function deleteUser($id)
    {
        $callerId = request()->attributes->get('supabase_user_id');
        $admin = Profile::find($callerId);

        if (!$admin || $admin->role_id !== 1) {
            return response()->json(['message' => 'No tienes permisos de administrador'], 403);
        }

        $supabaseUrl = env('SUPABASE_URL');
        $serviceRoleKey = env('SUPABASE_SERVICE_ROLE_KEY');

        // Eliminar de Auth primero
        if ($serviceRoleKey) {
            try {
                Http::withoutVerifying()->withHeaders([
                    'Authorization' => 'Bearer ' . $serviceRoleKey,
                    'apikey' => $serviceRoleKey,
                ])->delete($supabaseUrl . '/auth/v1/admin/users/' . $id);
            } catch (\Exception $e) {
                Log::warning('No se pudo eliminar de Auth (posiblemente ya no existe): ' . $e->getMessage());
            }
        }

        // Eliminar perfil (la cascada de la DB debería encargarse de lo demás)
        Profile::destroy($id);

        return response()->json(['message' => 'Usuario eliminado correctamente']);
    }

    /**
     * Crea un centro educativo.
     */
    public function storeCenter(Request $request)
    {
        Log::info('Datos recibidos para creación de centro:', $request->all());

        $callerId = $request->attributes->get('supabase_user_id');
        $admin = Profile::find($callerId);

        if (!$admin || $admin->role_id !== 1) {
            return response()->json(['message' => 'No tienes permisos de administrador'], 403);
        }

        $request->validate([
            'name' => 'required|string',
            'code' => 'required|string|unique:centers',
            'address' => 'nullable|string',
        ]);

        try {
            $center = \App\Models\Center::create($request->all());
            return response()->json($center, 201);
        } catch (\Exception $e) {
            Log::error('Error creando centro en DB: ' . $e->getMessage());
            return response()->json([
                'message' => 'Error al crear el centro en la base de datos',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Elimina un centro educativo.
     */
    public function deleteCenter($id)
    {
        $callerId = request()->attributes->get('supabase_user_id');
        $admin = Profile::find($callerId);

        if (!$admin || $admin->role_id !== 1) {
            return response()->json(['message' => 'No tienes permisos de administrador'], 403);
        }

        try {
            \App\Models\Center::destroy($id);
            return response()->json(['message' => 'Centro eliminado correctamente']);
        } catch (\Exception $e) {
            Log::error('Error eliminando centro en DB: ' . $e->getMessage());
            return response()->json([
                'message' => 'Error al eliminar el centro',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Actualiza un centro educativo.
     */
    public function updateCenter(Request $request, $id)
    {
        $callerId = $request->attributes->get('supabase_user_id');
        $admin = Profile::find($callerId);

        if (!$admin || $admin->role_id !== 1) {
            return response()->json(['message' => 'No tienes permisos de administrador'], 403);
        }

        $request->validate([
            'name' => 'required|string',
            'code' => 'required|string|unique:centers,code,' . $id,
            'address' => 'nullable|string',
        ]);

        try {
            $center = \App\Models\Center::findOrFail($id);
            $center->update($request->all());
            return response()->json($center);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al actualizar el centro',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Gestión de Ciclos Formativos
     */
    public function storeCycle(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'center_id' => 'required|integer',
            'description' => 'nullable|string',
            'subject_ids' => 'nullable|array',
            'subject_ids.*' => 'integer',
        ]);

        try {
            $cycle = \App\Models\Cycle::create($request->only(['name', 'center_id', 'description']));
            if ($request->has('subject_ids')) {
                $cycle->subjects()->sync($request->subject_ids);
            }
            return response()->json($cycle, 201);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al crear el ciclo', 'error' => $e->getMessage()], 500);
        }
    }

    public function updateCycle(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string',
            'description' => 'nullable|string',
            'subject_ids' => 'nullable|array',
            'subject_ids.*' => 'integer',
        ]);

        try {
            $cycle = \App\Models\Cycle::findOrFail($id);
            $cycle->update($request->only(['name', 'description']));
            if ($request->has('subject_ids')) {
                $cycle->subjects()->sync($request->subject_ids);
            }
            return response()->json($cycle);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al actualizar el ciclo', 'error' => $e->getMessage()], 500);
        }
    }

    public function deleteCycle($id)
    {
        try {
            \App\Models\Cycle::destroy($id);
            return response()->json(['message' => 'Ciclo eliminado correctamente']);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al eliminar el ciclo', 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * Gestión de Asignaturas
     */
    public function storeSubject(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'center_id' => 'required|integer',
            'description' => 'nullable|string',
        ]);

        try {
            $subject = \App\Models\Subject::create($request->all());
            return response()->json($subject, 201);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al crear la asignatura', 'error' => $e->getMessage()], 500);
        }
    }

    public function updateSubject(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string',
            'description' => 'nullable|string',
        ]);

        try {
            $subject = \App\Models\Subject::findOrFail($id);
            $subject->update($request->all());
            return response()->json($subject);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al actualizar la asignatura', 'error' => $e->getMessage()], 500);
        }
    }

    public function deleteSubject($id)
    {
        try {
            \App\Models\Subject::destroy($id);
            return response()->json(['message' => 'Asignatura eliminada correctamente']);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al eliminar la asignatura', 'error' => $e->getMessage()], 500);
        }
    }
}
