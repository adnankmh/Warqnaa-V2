<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('profiles') && !Schema::hasColumn('profiles', 'locale')) {
            Schema::table('profiles', function (Blueprint $table) {
                $table->string('locale', 10)->default('ar')->after('country_name');
            });
        }
        if (Schema::hasTable('profiles') && Schema::hasColumn('profiles', 'locale')) {
            DB::table('profiles')->whereNull('locale')->orWhere('locale', '')->update(['locale' => 'ar']);
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('profiles') && Schema::hasColumn('profiles', 'locale')) {
            Schema::table('profiles', fn (Blueprint $table) => $table->dropColumn('locale'));
        }
    }
};
