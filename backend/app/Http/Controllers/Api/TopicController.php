<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use App\Models\Topic;
use Illuminate\Http\Request;

class TopicController extends Controller
{
    /**
     * Recupera la lista de temas para una asignatura concreta ordenados cronológicamente
     */
    public function index($subjectId)
    {
        $subject = Subject::find($subjectId);

        if (!$subject) {
            return response()->json(['error' => 'Asignatura no encontrada'], 404);
        }

        // Devolver temas ordenados
        $topics = $subject->topics()->orderBy('order', 'asc')->get();

        return response()->json($topics, 200);
    }

    /**
     * Guarda un nuevo tema creado por el docente.
     * En la arquitectura API-First, Laravel sólo recibe el path del fichero (file_url) 
     * ya subido a Supabase Storage desde el Frontend, aliviando al servidor PHP.
     */
    public function store(Request $request, $subjectId)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'file_url' => 'nullable|string', // URL o path devuelto por el SDK de Supabase
            'order' => 'integer'
        ]);

        $subject = Subject::find($subjectId);

        if (!$subject) {
            return response()->json(['error' => 'Asignatura no encontrada'], 404);
        }

        // Opcional: Validar que el auth_user_id sea un docente de ESTA asignatura.

        $topic = new Topic();
        $topic->subject_id = $subject->id;
        $topic->title = $request->input('title');
        $topic->description = $request->input('description');
        $topic->file_url = $request->input('file_url');
        
        // Asignar el último orden si no se pasa de forma manual
        if ($request->has('order')) {
            $topic->order = $request->input('order');
        } else {
            $maxOrder = $subject->topics()->max('order') ?? 0;
            $topic->order = $maxOrder + 1;
        }

        $topic->save();

        return response()->json($topic, 201);
    }
}
