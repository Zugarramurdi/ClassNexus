<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Group extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'year', 'center_id'];

    public function center()
    {
        return $this->belongsTo(Center::class);
    }
}
