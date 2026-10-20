<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('rewarded_ad_sessions',function(Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('status',24)->default('pending');
            $table->string('provider_transaction_id',128)->nullable()->unique();
            $table->timestamp('expires_at');$table->timestamp('rewarded_at')->nullable();
            $table->unsignedInteger('reward_tokens')->default(0);
            $table->unsignedInteger('reward_xp')->default(0);
            $table->timestamps();$table->index(['user_id','status']);
        });
    }
    public function down(): void {Schema::dropIfExists('rewarded_ad_sessions');}
};
