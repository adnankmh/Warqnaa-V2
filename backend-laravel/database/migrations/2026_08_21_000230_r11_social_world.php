<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('social_preferences')) {
            Schema::create('social_preferences', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
                $table->string('profile_visibility', 20)->default('public');
                $table->string('presence_visibility', 20)->default('friends');
                $table->string('activity_visibility', 20)->default('friends');
                $table->string('message_policy', 20)->default('friends');
                $table->string('invite_policy', 20)->default('friends');
                $table->boolean('discoverable')->default(true);
                $table->boolean('allow_friend_requests')->default(true);
                $table->boolean('allow_follows')->default(true);
                $table->boolean('allow_spectators')->default(true);
                $table->boolean('allow_replay_share')->default(true);
                $table->boolean('allow_voice')->default(true);
                $table->boolean('show_online_status')->default(true);
                $table->boolean('show_current_room')->default(false);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('social_follows')) {
            Schema::create('social_follows', function (Blueprint $table) {
                $table->id();
                $table->foreignId('follower_id')->constrained('users')->cascadeOnDelete();
                $table->foreignId('followed_id')->constrained('users')->cascadeOnDelete();
                $table->timestamps();
                $table->unique(['follower_id', 'followed_id']);
                $table->index(['followed_id', 'created_at']);
            });
        }

        if (!Schema::hasTable('social_activities')) {
            Schema::create('social_activities', function (Blueprint $table) {
                $table->id();
                $table->foreignId('actor_id')->constrained('users')->cascadeOnDelete();
                $table->foreignId('room_id')->nullable()->constrained()->nullOnDelete();
                $table->foreignId('club_id')->nullable()->constrained()->nullOnDelete();
                $table->string('type', 60);
                $table->string('audience', 20)->default('friends');
                $table->json('payload')->nullable();
                $table->timestamp('published_at')->nullable();
                $table->timestamp('expires_at')->nullable();
                $table->boolean('hidden')->default(false);
                $table->foreignId('moderated_by')->nullable()->constrained('users')->nullOnDelete();
                $table->string('moderation_note', 500)->nullable();
                $table->timestamps();
                $table->index(['hidden', 'published_at']);
                $table->index(['actor_id', 'audience']);
                $table->index(['club_id', 'published_at']);
            });
        }

        if (!Schema::hasTable('social_events')) {
            Schema::create('social_events', function (Blueprint $table) {
                $table->id();
                $table->foreignId('created_by')->constrained('users')->cascadeOnDelete();
                $table->foreignId('club_id')->nullable()->constrained()->nullOnDelete();
                $table->foreignId('game_id')->nullable()->constrained()->nullOnDelete();
                $table->foreignId('room_id')->nullable()->constrained()->nullOnDelete();
                $table->json('title');
                $table->json('description')->nullable();
                $table->string('visibility', 20)->default('public');
                $table->string('status', 20)->default('scheduled');
                $table->timestamp('starts_at');
                $table->timestamp('ends_at')->nullable();
                $table->unsignedInteger('capacity')->nullable();
                $table->string('banner_url', 500)->nullable();
                $table->boolean('featured')->default(false);
                $table->json('settings')->nullable();
                $table->timestamps();
                $table->index(['status', 'starts_at']);
                $table->index(['featured', 'starts_at']);
            });
        }

        if (!Schema::hasTable('social_event_attendees')) {
            Schema::create('social_event_attendees', function (Blueprint $table) {
                $table->id();
                $table->foreignId('social_event_id')->constrained('social_events')->cascadeOnDelete();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->string('status', 20)->default('going');
                $table->timestamp('joined_at')->nullable();
                $table->timestamps();
                $table->unique(['social_event_id', 'user_id']);
                $table->index(['social_event_id', 'status']);
            });
        }

        if (!Schema::hasTable('room_spectators')) {
            Schema::create('room_spectators', function (Blueprint $table) {
                $table->id();
                $table->foreignId('room_id')->constrained()->cascadeOnDelete();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->string('status', 20)->default('active');
                $table->timestamp('joined_at')->nullable();
                $table->timestamp('last_seen_at')->nullable();
                $table->boolean('can_chat')->default(false);
                $table->boolean('voice_enabled')->default(false);
                $table->json('meta')->nullable();
                $table->timestamps();
                $table->unique(['room_id', 'user_id']);
                $table->index(['room_id', 'status', 'last_seen_at']);
            });
        }

        if (!Schema::hasTable('match_replays')) {
            Schema::create('match_replays', function (Blueprint $table) {
                $table->id();
                $table->foreignId('room_id')->unique()->constrained()->cascadeOnDelete();
                $table->foreignId('owner_id')->nullable()->constrained('users')->nullOnDelete();
                $table->foreignId('game_id')->nullable()->constrained()->nullOnDelete();
                $table->string('visibility', 20)->default('friends');
                $table->string('status', 20)->default('recording');
                $table->unsignedInteger('duration_seconds')->default(0);
                $table->unsignedInteger('frames_count')->default(0);
                $table->json('event_log')->nullable();
                $table->json('final_state')->nullable();
                $table->string('sha256', 64)->nullable();
                $table->unsignedBigInteger('views')->default(0);
                $table->boolean('featured')->default(false);
                $table->timestamp('published_at')->nullable();
                $table->timestamp('expires_at')->nullable();
                $table->timestamps();
                $table->index(['status', 'published_at']);
                $table->index(['featured', 'views']);
            });
        }

        if (!Schema::hasTable('social_gifts')) {
            Schema::create('social_gifts', function (Blueprint $table) {
                $table->id();
                $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
                $table->foreignId('recipient_id')->constrained('users')->cascadeOnDelete();
                $table->foreignId('room_id')->nullable()->constrained()->nullOnDelete();
                $table->foreignId('social_activity_id')->nullable()->constrained('social_activities')->nullOnDelete();
                $table->string('gift_key', 60);
                $table->unsignedBigInteger('token_cost')->default(0);
                $table->string('animation_key', 80);
                $table->string('message', 240)->nullable();
                $table->boolean('visible')->default(true);
                $table->timestamp('delivered_at')->nullable();
                $table->json('meta')->nullable();
                $table->timestamps();
                $table->index(['recipient_id', 'created_at']);
                $table->index(['room_id', 'created_at']);
            });
        }

        if (Schema::hasTable('site_settings')) {
            $defaults = [
                ['social_world_enabled', '1', 'bool', 'social_world', 'تفعيل العالم الاجتماعي'],
                ['social_feed_enabled', '1', 'bool', 'social_world', 'تفعيل موجز المجتمع'],
                ['social_events_enabled', '1', 'bool', 'social_world', 'تفعيل فعاليات المجتمع'],
                ['spectator_mode_enabled', '1', 'bool', 'social_world', 'تفعيل وضع المشاهدة'],
                ['replay_system_enabled', '1', 'bool', 'social_world', 'تفعيل نظام الإعادات'],
                ['animated_gifts_enabled', '1', 'bool', 'social_world', 'تفعيل الهدايا المتحركة'],
                ['max_room_spectators', '120', 'int', 'social_world', 'أقصى عدد مشاهدي الغرفة'],
                ['replay_retention_days', '30', 'int', 'social_world', 'مدة حفظ الإعادات بالأيام'],
                ['social_feed_page_size', '30', 'int', 'social_world', 'حجم صفحة موجز المجتمع'],
            ];
            foreach ($defaults as [$key, $value, $type, $group, $label]) {
                DB::table('site_settings')->updateOrInsert(
                    ['key' => $key],
                    ['value' => $value, 'type' => $type, 'group' => $group, 'label' => $label, 'created_at' => now(), 'updated_at' => now()]
                );
            }
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('site_settings')) {
            DB::table('site_settings')->whereIn('key', [
                'social_world_enabled', 'social_feed_enabled', 'social_events_enabled',
                'spectator_mode_enabled', 'replay_system_enabled', 'animated_gifts_enabled',
                'max_room_spectators', 'replay_retention_days', 'social_feed_page_size',
            ])->delete();
        }
        foreach ([
            'social_gifts', 'match_replays', 'room_spectators', 'social_event_attendees',
            'social_events', 'social_activities', 'social_follows', 'social_preferences',
        ] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
