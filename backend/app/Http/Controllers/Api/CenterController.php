<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Center;
use Illuminate\Http\Request;

class CenterController extends Controller
{
    public function index()
    {
        return response()->json(Center::all());
    }

    public function show($id)
    {
        $center = Center::with(['subjects', 'groups'])->find($id);

        if (!$center) {
            return response()->json(['message' => 'Center not found'], 404);
        }

        return response()->json($center);
    }
}
