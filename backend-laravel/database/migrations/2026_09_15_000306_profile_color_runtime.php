<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('profiles')) return;
        Schema::table('profiles', function (Blueprint $table) {
            if (!Schema::hasColumn('profiles','active_profile_color')) {
                $table->string('active_profile_color', 160)->nullable()->after('active_profile_cover');
            }
            if (!Schema::hasColumn('profiles','profile_color_expires_at')) {
                $table->timestamp('profile_color_expires_at')->nullable()->after('active_profile_color');
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('profiles')) return;
        Schema::table('profiles', function (Blueprint $table) {
            foreach (['profile_color_expires_at','active_profile_color'] as $column) {
                if (Schema::hasColumn('profiles',$column)) $table->dropColumn($column);
            }
        });
    }
};
