<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    /**
     * Display a listing of the resource.
     * 
     * TODO: Esta lógica es un ENDPOINT GENÉRICO TEMPORAL.
     * En el futuro, debe ser reemplazada por `$request->user()->subjects()` 
     * una vez implementadas las tablas pivot (group_profile, profile_subject).
     */
    public function index(Request $request)
    {
        // Por ahora, para desbloquear la UI del Frontend, devolvemos TODAS las asignaturas
        // incluyendo el centro educativo al que pertenecen.
        $subjects = Subject::with('center')->get();

        return response()->json($subjects, 200);
    }
}
