<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Assignment;
use Illuminate\Http\Request;

class AssignmentController extends Controller
{
    /**
     * Devuelve las tareas de una asignatura especifica.
     */
    public function index(Request $request, $subject_id)
    {
        $userId = $request->input('supabase_user_id');

        $assignments = Assignment::where('subject_id', $subject_id)
            ->withCount('submissions')
            ->with(['submissions' => function ($query) use ($userId) {
                $query->where('student_id', $userId);
            }])
            ->orderBy('due_date', 'asc')
            ->get();
            
        return response()->json($assignments, 200);
    }

    /**
     * Crea una nueva tarea.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'subject_id' => 'required|exists:subjects,id',
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'due_date' => 'required|date',
            'max_score' => 'nullable|numeric|min:0',
            'file_url' => 'nullable|string'
        ]);

        $assignment = Assignment::create($validated);

        return response()->json($assignment, 201);
    }
}
