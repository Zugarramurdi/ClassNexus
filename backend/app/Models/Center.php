<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Center extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'code', 'address'];

    public function subjects()
    {
        return $this->hasMany(Subject::class);
    }

    public function groups()
    {
        return $this->hasMany(Group::class);
    }
}
