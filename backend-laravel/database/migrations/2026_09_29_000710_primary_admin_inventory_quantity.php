<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (Schema::hasTable('inventory_items') && !Schema::hasColumn('inventory_items', 'quantity')) {
            Schema::table('inventory_items', function (Blueprint $table): void {
                $table->unsignedInteger('quantity')->default(1)->after('store_item_id');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('inventory_items') && Schema::hasColumn('inventory_items', 'quantity')) {
            Schema::table('inventory_items', function (Blueprint $table): void {
                $table->dropColumn('quantity');
            });
        }
    }
};
