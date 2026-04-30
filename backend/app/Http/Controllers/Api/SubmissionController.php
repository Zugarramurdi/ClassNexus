<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Submission;
use Illuminate\Http\Request;

class SubmissionController extends Controller
{
    /**
     * Devuelve las entregas de una tarea.
     */
    public function index($assignment_id)
    {
        $submissions = Submission::where('assignment_id', $assignment_id)
            ->with(['student' => function ($query) {
                $query->select('id', 'first_name', 'last_name', 'avatar_url');
            }])
            ->get();
            
        return response()->json($submissions, 200);
    }

    /**
     * El estudiante realiza una entrega.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'assignment_id' => 'required|exists:assignments,id',
            'file_url' => 'nullable|string',
            'link_url' => 'nullable|string',
            'student_comment' => 'nullable|string'
        ]);

        $userId = $request->input('supabase_user_id');
        
        if (!$userId) {
            return response()->json(['error' => 'No autorizado'], 401);
        }

        $existing = Submission::where('assignment_id', $validated['assignment_id'])
            ->where('student_id', $userId)
            ->first();

        $data = [
            'assignment_id' => $validated['assignment_id'],
            'student_id' => $userId,
            'file_url' => $validated['file_url'] ?? null,
            'link_url' => $validated['link_url'] ?? null,
            'student_comment' => $validated['student_comment'] ?? null,
        ];

        if ($existing) {
            $existing->update($data);
            return response()->json($existing, 200);
        }

        $submission = Submission::create($data);

        return response()->json($submission, 201);
    }

    /**
     * El profesor califica una entrega.
     */
    public function grade(Request $request, $id)
    {
        $validated = $request->validate([
            'score'  => 'required|numeric|min:0',
            'feedback' => 'nullable|string'
        ]);

        $submission = Submission::findOrFail($id);
        
        $submission->update([
            'score' => $validated['score'],
            'feedback' => $validated['feedback'] ?? null
        ]);

        return response()->json($submission, 200);
    }
}
