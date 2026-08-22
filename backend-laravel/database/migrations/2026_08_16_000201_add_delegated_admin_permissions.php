<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasColumn('users', 'admin_role')) {
            Schema::table('users', function (Blueprint $table): void {
                $table->string('admin_role', 30)->default('player')->after('is_admin');
            });
        }
        if (!Schema::hasColumn('users', 'admin_permissions')) {
            Schema::table('users', function (Blueprint $table): void {
                $table->json('admin_permissions')->nullable()->after('admin_role');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('users', 'admin_permissions')) {
            Schema::table('users', function (Blueprint $table): void {
                $table->dropColumn('admin_permissions');
            });
        }
        if (Schema::hasColumn('users', 'admin_role')) {
            Schema::table('users', function (Blueprint $table): void {
                $table->dropColumn('admin_role');
            });
        }
    }
};
