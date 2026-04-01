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
        Schema::table('submissions', function (Blueprint $table) {
            $table->string('file_url')->nullable()->change();
            $table->string('link_url')->nullable()->after('file_url');
            $table->text('student_comment')->nullable()->after('link_url');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('submissions', function (Blueprint $table) {
            $table->string('file_url')->nullable(false)->change();
            $table->dropColumn(['link_url', 'student_comment']);
        });
    }
};
