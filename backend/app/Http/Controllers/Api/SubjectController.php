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
        $userId = $request->attributes->get('supabase_user_id');
        
        if (!$userId) {
            return response()->json(['error' => 'No autorizado'], 401);
        }

        $profile = \App\Models\Profile::with('role')->find($userId);

        if (!$profile || !$profile->role) {
            return response()->json([], 200); // Si no tiene rol, no devolvemos datos
        }

        $roleName = strtolower($profile->role->name);

        if ($roleName === 'teacher') {
            // Los docentes obtienen las asignaturas en las que están explícitamente asignados
            $subjects = $profile->teachingSubjects()->with(['center', 'teachers'])->get();
        } elseif ($roleName === 'student') {
            // Los estudiantes obtienen asignaturas derivadas de los grupos a los que pertenecen
            $groupIds = $profile->groups()->pluck('groups.id');
            
            $subjects = Subject::whereHas('groups', function($q) use ($groupIds) {
                $q->whereIn('groups.id', $groupIds);
            })->with(['center', 'teachers'])->distinct()->get();
        } else {
            // Administradores y otros roles ven todo el catálogo
            $subjects = Subject::with(['center', 'teachers'])->get();
        }

        return response()->json($subjects, 200);
    }
}
