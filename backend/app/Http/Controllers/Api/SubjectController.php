<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    /**
     * Devuelve las asignaturas asociadas al usuario autenticado
     * dependiendo de si es estudiante (vía grupo) o docente (vía asignación directa).
     */
    public function index(Request $request)
    {
        try {
            $userId = $request->input('supabase_user_id');
            
            if (!$userId) {
                return response()->json(['error' => 'No autorizado'], 401);
            }

            $profile = \App\Models\Profile::with('role')->find($userId);

            if (!$profile || !$profile->role) {
                return response()->json([], 200); 
            }

            $roleName = strtolower($profile->role->name);

            if ($roleName === 'teacher') {
                $subjects = $profile->teachingSubjects()->with(['center', 'teachers'])->get();
            } elseif ($roleName === 'student') {
                $subjects = $profile->subjects()->with(['center', 'teachers'])->get();
            } else {
                $subjects = Subject::with(['center', 'teachers'])->get();
            }

            return response()->json($subjects, 200);

        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Error en SubjectController@index: ' . $e->getMessage());
            return response()->json([
                'message' => 'Error interno del servidor'
            ], 500);
        }
    }
}
