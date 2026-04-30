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
        'email',
        'role_id',
        'center_id',
        'tutor_id',
        'cycle_id',
    ];

    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function cycle()
    {
        return $this->belongsTo(Cycle::class);
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

    public function tutor()
    {
        return $this->belongsTo(Profile::class, 'tutor_id');
    }

    public function students()
    {
        return $this->hasMany(Profile::class, 'tutor_id');
    }
}
