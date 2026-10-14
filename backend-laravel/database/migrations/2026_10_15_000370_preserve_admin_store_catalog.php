<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('store_catalog_overrides', function (Blueprint $table): void {
            $table->string('key')->primary();
            $table->string('operation',16);
            $table->json('attributes')->nullable();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('store_catalog_overrides'); }
};
