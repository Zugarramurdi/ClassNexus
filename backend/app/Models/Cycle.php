<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Cycle extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'description', 'center_id'];

    public function center()
    {
        return $this->belongsTo(Center::class);
    }

    public function subjects()
    {
        return $this->belongsToMany(Subject::class, 'cycle_subject');
    }

    public function groups()
    {
        return $this->hasMany(Group::class);
    }
}
