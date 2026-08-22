<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('competitive_seasons')) {
            Schema::create('competitive_seasons', function (Blueprint $table) {
                $table->id();
                $table->string('key', 80)->unique();
                $table->json('name');
                $table->json('description')->nullable();
                $table->string('status', 20)->default('scheduled');
                $table->timestamp('starts_at');
                $table->timestamp('ends_at');
                $table->decimal('rating_soft_reset_factor', 4, 3)->default(0.750);
                $table->unsignedTinyInteger('placement_games')->default(10);
                $table->json('rules')->nullable();
                $table->json('reward_tiers')->nullable();
                $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
                $table->timestamp('finalized_at')->nullable();
                $table->timestamps();
                $table->index(['status', 'starts_at', 'ends_at'], 'competitive_seasons_lifecycle_idx');
            });
        }

        if (!Schema::hasTable('competitive_ratings')) {
            Schema::create('competitive_ratings', function (Blueprint $table) {
                $table->id();
                $table->foreignId('season_id')->constrained('competitive_seasons')->cascadeOnDelete();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->foreignId('game_id')->nullable()->constrained()->nullOnDelete();
                $table->string('scope_key', 100);
                $table->integer('rating')->default(1000);
                $table->integer('peak_rating')->default(1000);
                $table->unsignedInteger('games_played')->default(0);
                $table->unsignedInteger('wins')->default(0);
                $table->unsignedInteger('losses')->default(0);
                $table->unsignedInteger('draws')->default(0);
                $table->integer('streak')->default(0);
                $table->unsignedInteger('best_streak')->default(0);
                $table->unsignedTinyInteger('provisional_games')->default(0);
                $table->boolean('placement_complete')->default(false);
                $table->unsignedInteger('abandons')->default(0);
                $table->unsignedInteger('clean_games')->default(0);
                $table->timestamp('last_match_at')->nullable();
                $table->json('meta')->nullable();
                $table->timestamps();
                $table->unique(['season_id', 'user_id', 'scope_key'], 'competitive_rating_scope_unique');
                $table->index(['season_id', 'scope_key', 'rating'], 'competitive_leaderboard_idx');
            });
        }

        if (!Schema::hasTable('ranked_queue_entries')) {
            Schema::create('ranked_queue_entries', function (Blueprint $table) {
                $table->id();
                $table->uuid('queue_token')->unique();
                $table->foreignId('season_id')->constrained('competitive_seasons')->cascadeOnDelete();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->foreignId('game_id')->constrained()->cascadeOnDelete();
                $table->foreignId('room_id')->nullable()->constrained()->nullOnDelete();
                $table->string('queue_mode', 20)->default('ranked');
                $table->unsignedTinyInteger('preferred_seats')->default(4);
                $table->string('region', 24)->default('global');
                $table->string('country_code', 2)->nullable();
                $table->integer('rating_snapshot')->default(1000);
                $table->unsignedInteger('search_window')->default(100);
                $table->string('status', 20)->default('waiting');
                $table->timestamp('joined_at');
                $table->timestamp('last_heartbeat_at')->nullable();
                $table->timestamp('matched_at')->nullable();
                $table->timestamp('expires_at')->nullable();
                $table->json('meta')->nullable();
                $table->timestamps();
                $table->index(['status', 'game_id', 'region', 'joined_at'], 'ranked_queue_match_idx');
                $table->index(['user_id', 'status'], 'ranked_queue_user_idx');
            });
        }

        if (!Schema::hasTable('competitive_matches')) {
            Schema::create('competitive_matches', function (Blueprint $table) {
                $table->id();
                $table->uuid('match_key')->unique();
                $table->foreignId('season_id')->constrained('competitive_seasons')->cascadeOnDelete();
                $table->foreignId('tournament_id')->nullable()->constrained()->nullOnDelete();
                $table->foreignId('room_id')->nullable()->unique()->constrained()->nullOnDelete();
                $table->foreignId('game_id')->constrained()->cascadeOnDelete();
                $table->string('mode', 24)->default('ranked');
                $table->string('status', 20)->default('forming');
                $table->string('region', 24)->default('global');
                $table->unsignedTinyInteger('team_size')->default(1);
                $table->json('participant_ids');
                $table->json('team_map')->nullable();
                $table->json('rating_snapshot')->nullable();
                $table->json('result')->nullable();
                $table->boolean('rating_processed')->default(false);
                $table->boolean('reward_processed')->default(false);
                $table->string('anti_cheat_status', 20)->default('pending');
                $table->timestamp('started_at')->nullable();
                $table->timestamp('finished_at')->nullable();
                $table->timestamp('processed_at')->nullable();
                $table->json('meta')->nullable();
                $table->timestamps();
                $table->index(['season_id', 'mode', 'status'], 'competitive_matches_status_idx');
                $table->index(['game_id', 'finished_at'], 'competitive_matches_game_idx');
            });
        }

        if (!Schema::hasTable('competitive_rating_events')) {
            Schema::create('competitive_rating_events', function (Blueprint $table) {
                $table->id();
                $table->foreignId('competitive_match_id')->constrained('competitive_matches')->cascadeOnDelete();
                $table->foreignId('competitive_rating_id')->constrained('competitive_ratings')->cascadeOnDelete();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->string('scope_key', 100);
                $table->integer('rating_before');
                $table->integer('rating_after');
                $table->integer('rating_delta');
                $table->string('result', 20);
                $table->decimal('expected_score', 6, 5)->default(0.50000);
                $table->unsignedTinyInteger('k_factor')->default(32);
                $table->string('reason', 80)->default('ranked_result');
                $table->json('meta')->nullable();
                $table->timestamps();
                $table->unique(['competitive_match_id', 'user_id', 'scope_key'], 'competitive_rating_event_unique');
                $table->index(['user_id', 'created_at'], 'competitive_rating_history_idx');
            });
        }

        if (!Schema::hasTable('season_reward_claims')) {
            Schema::create('season_reward_claims', function (Blueprint $table) {
                $table->id();
                $table->foreignId('season_id')->constrained('competitive_seasons')->cascadeOnDelete();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->string('tier_key', 40);
                $table->integer('final_rating');
                $table->unsignedBigInteger('reward_tokens')->default(0);
                $table->unsignedBigInteger('reward_xp')->default(0);
                $table->string('status', 20)->default('pending');
                $table->json('reward_payload')->nullable();
                $table->timestamp('claimed_at')->nullable();
                $table->timestamps();
                $table->unique(['season_id', 'user_id', 'tier_key'], 'season_reward_claim_unique');
                $table->index(['user_id', 'status']);
            });
        }

        if (!Schema::hasTable('competitive_standing_snapshots')) {
            Schema::create('competitive_standing_snapshots', function (Blueprint $table) {
                $table->id();
                $table->foreignId('season_id')->constrained('competitive_seasons')->cascadeOnDelete();
                $table->foreignId('game_id')->nullable()->constrained()->nullOnDelete();
                $table->foreignId('user_id')->nullable()->constrained()->cascadeOnDelete();
                $table->foreignId('club_id')->nullable()->constrained()->cascadeOnDelete();
                $table->string('scope_type', 24);
                $table->string('scope_key', 100);
                $table->unsignedInteger('rank');
                $table->integer('rating')->default(1000);
                $table->unsignedInteger('games_played')->default(0);
                $table->unsignedInteger('wins')->default(0);
                $table->json('payload')->nullable();
                $table->timestamp('captured_at');
                $table->timestamps();
                $table->index(['season_id', 'scope_type', 'scope_key', 'rank'], 'competitive_snapshot_rank_idx');
            });
        }

        if (Schema::hasTable('tournaments')) {
            Schema::table('tournaments', function (Blueprint $table) {
                if (!Schema::hasColumn('tournaments', 'season_id')) $table->unsignedBigInteger('season_id')->nullable()->index();
                if (!Schema::hasColumn('tournaments', 'format')) $table->string('format', 30)->default('single_elimination');
                if (!Schema::hasColumn('tournaments', 'scope')) $table->string('scope', 24)->default('global');
                if (!Schema::hasColumn('tournaments', 'country_code')) $table->string('country_code', 2)->nullable();
                if (!Schema::hasColumn('tournaments', 'min_rating')) $table->integer('min_rating')->nullable();
                if (!Schema::hasColumn('tournaments', 'max_rating')) $table->integer('max_rating')->nullable();
                if (!Schema::hasColumn('tournaments', 'registration_closes_at')) $table->timestamp('registration_closes_at')->nullable();
                if (!Schema::hasColumn('tournaments', 'check_in_closes_at')) $table->timestamp('check_in_closes_at')->nullable();
                if (!Schema::hasColumn('tournaments', 'bracket_version')) $table->unsignedInteger('bracket_version')->default(1);
                if (!Schema::hasColumn('tournaments', 'current_round')) $table->unsignedInteger('current_round')->default(0);
                if (!Schema::hasColumn('tournaments', 'champion_user_id')) $table->unsignedBigInteger('champion_user_id')->nullable()->index();
                if (!Schema::hasColumn('tournaments', 'champion_club_id')) $table->unsignedBigInteger('champion_club_id')->nullable()->index();
                if (!Schema::hasColumn('tournaments', 'competitive_rules')) $table->json('competitive_rules')->nullable();
            });
        }

        if (Schema::hasTable('site_settings')) {
            foreach ([
                ['competitive_enabled', '1', 'bool', 'تفعيل R12 Competitive'],
                ['ranked_matchmaking_enabled', '1', 'bool', 'تفعيل Ranked Matchmaking'],
                ['season_rewards_enabled', '1', 'bool', 'تفعيل مكافآت الموسم'],
                ['club_championships_enabled', '1', 'bool', 'تفعيل بطولات الأندية'],
                ['country_championships_enabled', '1', 'bool', 'تفعيل بطولات الدول'],
                ['ranked_queue_timeout_minutes', '15', 'int', 'مهلة طابور Ranked'],
                ['ranked_abandon_penalty', '35', 'int', 'عقوبة الانسحاب المصنف'],
            ] as [$key, $value, $type, $label]) {
                DB::table('site_settings')->updateOrInsert(
                    ['key' => $key],
                    ['value' => $value, 'type' => $type, 'group' => 'competitive', 'label' => $label, 'created_at' => now(), 'updated_at' => now()]
                );
            }
        }

        DB::table('competitive_seasons')->updateOrInsert(
            ['key' => 'r12_launch_2026'],
            [
                'name' => json_encode(['ar' => 'موسم انطلاق ورقنا', 'en' => 'Warqnaa Launch Season'], JSON_UNESCAPED_UNICODE),
                'description' => json_encode(['ar' => 'الموسم التنافسي الأول بتصنيف MMR وجوائز آمنة.', 'en' => 'The first MMR season with server-authoritative rewards.'], JSON_UNESCAPED_UNICODE),
                'status' => 'active', 'starts_at' => now()->startOfDay(), 'ends_at' => now()->addDays(90)->endOfDay(),
                'rating_soft_reset_factor' => 0.750, 'placement_games' => 10,
                'rules' => json_encode(['server_authoritative' => true, 'anti_cheat_review' => true, 'one_active_queue' => true]),
                'reward_tiers' => json_encode(config('warqna_competitive.season_rewards', [])),
                'created_at' => now(), 'updated_at' => now(),
            ]
        );
    }

    public function down(): void
    {
        if (Schema::hasTable('site_settings')) {
            DB::table('site_settings')->whereIn('key', [
                'competitive_enabled', 'ranked_matchmaking_enabled', 'season_rewards_enabled',
                'club_championships_enabled', 'country_championships_enabled',
                'ranked_queue_timeout_minutes', 'ranked_abandon_penalty',
            ])->delete();
        }
        if (Schema::hasTable('tournaments')) {
            $columns = array_values(array_filter([
                'season_id', 'format', 'scope', 'country_code', 'min_rating', 'max_rating',
                'registration_closes_at', 'check_in_closes_at', 'bracket_version', 'current_round',
                'champion_user_id', 'champion_club_id', 'competitive_rules',
            ], fn ($column) => Schema::hasColumn('tournaments', $column)));
            if ($columns !== []) Schema::table('tournaments', fn (Blueprint $table) => $table->dropColumn($columns));
        }
        foreach ([
            'competitive_standing_snapshots', 'season_reward_claims', 'competitive_rating_events',
            'competitive_matches', 'ranked_queue_entries', 'competitive_ratings', 'competitive_seasons',
        ] as $table) Schema::dropIfExists($table);
    }
};
