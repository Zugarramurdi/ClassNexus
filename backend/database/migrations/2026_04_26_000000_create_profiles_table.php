<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasTable('profiles')) {
            Schema::create('profiles', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('first_name')->nullable();
                $table->string('last_name')->nullable();
                $table->string('avatar_url')->nullable();
                $table->string('email')->nullable();
                $table->integer('role_id')->nullable();
                $table->unsignedBigInteger('center_id')->nullable();
                $table->timestamps();

                $table->foreign('role_id')->references('id')->on('roles');
                $table->foreign('center_id')->references('id')->on('centers');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('profiles');
    }
};
