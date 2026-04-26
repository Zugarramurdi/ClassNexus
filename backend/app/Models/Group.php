<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Group extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'year', 'center_id', 'cycle_id'];

    public function center()
    {
        return $this->belongsTo(Center::class);
    }

    public function cycle()
    {
        return $this->belongsTo(Cycle::class);
    }

    public function profiles()
    {
        return $this->belongsToMany(Profile::class);
    }

    public function subjects()
    {
        return $this->belongsToMany(Subject::class);
    }
}
