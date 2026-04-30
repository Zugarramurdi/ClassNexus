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
        Schema::table('profiles', function (Blueprint $blueprint) {
            $blueprint->unsignedBigInteger('cycle_id')->nullable()->after('center_id');
            $blueprint->foreign('cycle_id')->references('id')->on('cycles')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('profiles', function (Blueprint $blueprint) {
            $blueprint->dropForeign(['cycle_id']);
            $blueprint->dropColumn('cycle_id');
        });
    }
};
