<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (Schema::hasTable('competition_appeals')) {
            return;
        }

        Schema::create('competition_appeals', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('competitive_match_id')->constrained('competitive_matches')->cascadeOnDelete();
            $table->foreignId('tournament_id')->nullable()->constrained('tournaments')->nullOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('category', 40)->default('result');
            $table->text('reason');
            $table->json('evidence')->nullable();
            $table->string('status', 24)->default('pending');
            $table->foreignId('resolved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('decision_note')->nullable();
            $table->timestamp('submitted_at')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->unique(['competitive_match_id', 'user_id'], 'competition_appeal_player_match_unique');
            $table->index(['status', 'created_at'], 'competition_appeal_review_queue_idx');
            $table->index(['tournament_id', 'status'], 'competition_appeal_tournament_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('competition_appeals');
    }
};
