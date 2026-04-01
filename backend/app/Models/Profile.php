<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Profile extends Model
{
    use HasFactory;

    protected $keyType = 'string';
    public $incrementing = false;
    public $timestamps = false; // Agregado para compatibilidad con Supabase
    protected $primaryKey = 'id';

    protected $fillable = [
        'id',
        'first_name',
        'last_name',
        'avatar_url',
        'role_id',
    ];

    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function groups()
    {
        return $this->belongsToMany(Group::class);
    }

    public function teachingSubjects()
    {
        return $this->belongsToMany(Subject::class, 'profile_subject');
    }

    public function submissions()
    {
        return $this->hasMany(Submission::class, 'student_id');
    }
}
