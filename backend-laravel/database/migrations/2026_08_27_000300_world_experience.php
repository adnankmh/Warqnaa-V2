<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('parties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->string('code', 12)->unique();
            $table->string('status', 24)->default('open')->index();
            $table->unsignedTinyInteger('max_members')->default(4);
            $table->string('game_key', 80)->nullable()->index();
            $table->foreignId('room_id')->nullable()->constrained('rooms')->nullOnDelete();
            $table->json('settings')->nullable();
            $table->timestamps();
        });

        Schema::create('party_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('party_id')->constrained('parties')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('role', 20)->default('member');
            $table->string('status', 20)->default('joined');
            $table->timestamp('joined_at')->nullable();
            $table->timestamp('last_seen_at')->nullable();
            $table->timestamps();
            $table->unique(['party_id', 'user_id']);
            $table->index(['user_id', 'status']);
        });

        Schema::create('game_session_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('room_id')->constrained('rooms')->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('type', 48)->index();
            $table->unsignedTinyInteger('severity')->default(0);
            $table->json('payload')->nullable();
            $table->timestamps();
            $table->index(['room_id', 'created_at']);
        });

        Schema::create('economy_audit_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_transaction_id')->nullable()->constrained('wallet_transactions')->nullOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('type', 48)->index();
            $table->unsignedTinyInteger('risk_score')->default(0)->index();
            $table->string('status', 24)->default('open')->index();
            $table->json('payload')->nullable();
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();
            $table->index(['status', 'risk_score', 'created_at']);
        });

        Schema::table('room_players', function (Blueprint $table) {
            $table->timestamp('last_heartbeat_at')->nullable()->after('missed_turns');
            $table->timestamp('disconnected_at')->nullable()->after('last_heartbeat_at');
            $table->timestamp('afk_since')->nullable()->after('disconnected_at');
            $table->string('bot_difficulty', 16)->nullable()->after('afk_since');
        });
    }

    public function down(): void
    {
        Schema::table('room_players', function (Blueprint $table) {
            $table->dropColumn(['last_heartbeat_at', 'disconnected_at', 'afk_since', 'bot_difficulty']);
        });
        Schema::dropIfExists('economy_audit_events');
        Schema::dropIfExists('game_session_events');
        Schema::dropIfExists('party_members');
        Schema::dropIfExists('parties');
    }
};
