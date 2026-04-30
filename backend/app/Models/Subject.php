<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'description', 'center_id'];

    public function center()
    {
        return $this->belongsTo(Center::class);
    }

    public function groups()
    {
        return $this->belongsToMany(Group::class);
    }

    public function teachers()
    {
        return $this->belongsToMany(Profile::class, 'profile_subject')
                    ->whereIn('role_id', [1, 2]);
    }

    public function students()
    {
        return $this->belongsToMany(Profile::class, 'profile_subject')
                    ->where('role_id', 3);
    }

    public function cycles()
    {
        return $this->belongsToMany(Cycle::class, 'cycle_subject');
    }

    public function topics()
    {
        return $this->hasMany(Topic::class);
    }

    public function assignments()
    {
        return $this->hasMany(Assignment::class);
    }
}
