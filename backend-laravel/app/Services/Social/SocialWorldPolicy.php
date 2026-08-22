<?php

namespace App\Services\Social;

use App\Models\{ClubMember, Friendship, MatchReplay, Room, SocialActivity, SocialFollow, SocialPreference, User};
use Illuminate\Support\Facades\Schema;

class SocialWorldPolicy
{
    public function preferences(User $user): SocialPreference
    {
        if (!Schema::hasTable('social_preferences')) {
            return new SocialPreference([
                'user_id' => $user->id,
                'profile_visibility' => 'public',
                'presence_visibility' => 'friends',
                'activity_visibility' => 'friends',
                'message_policy' => 'friends',
                'invite_policy' => 'friends',
                'discoverable' => true,
                'allow_friend_requests' => true,
                'allow_follows' => true,
                'allow_spectators' => true,
                'allow_replay_share' => true,
                'allow_voice' => true,
                'show_online_status' => true,
                'show_current_room' => false,
            ]);
        }

        return SocialPreference::firstOrCreate(
            ['user_id' => $user->id],
            [
                'profile_visibility' => 'public',
                'presence_visibility' => 'friends',
                'activity_visibility' => 'friends',
                'message_policy' => 'friends',
                'invite_policy' => 'friends',
                'discoverable' => true,
                'allow_friend_requests' => true,
                'allow_follows' => true,
                'allow_spectators' => true,
                'allow_replay_share' => true,
                'allow_voice' => true,
                'show_online_status' => true,
                'show_current_room' => false,
            ]
        );
    }

    public function blocked(int $a, int $b): bool
    {
        if ($a === $b) return false;
        return Friendship::query()->where('status', 'blocked')->where(function ($query) use ($a, $b) {
            $query->where(fn ($q) => $q->where('requester_id', $a)->where('addressee_id', $b))
                ->orWhere(fn ($q) => $q->where('requester_id', $b)->where('addressee_id', $a));
        })->exists();
    }

    public function friends(int $a, int $b): bool
    {
        if ($a === $b) return true;
        return Friendship::query()->where('status', 'accepted')->where(function ($query) use ($a, $b) {
            $query->where(fn ($q) => $q->where('requester_id', $a)->where('addressee_id', $b))
                ->orWhere(fn ($q) => $q->where('requester_id', $b)->where('addressee_id', $a));
        })->exists();
    }

    public function follows(int $viewerId, int $targetId): bool
    {
        if ($viewerId === $targetId) return true;
        if (!Schema::hasTable('social_follows')) return false;
        return SocialFollow::where('follower_id', $viewerId)->where('followed_id', $targetId)->exists();
    }

    public function canDiscover(User $viewer, User $target): bool
    {
        if ($viewer->id === $target->id || $viewer->is_admin) return true;
        if ($this->blocked($viewer->id, $target->id)) return false;
        $preferences = $this->preferences($target);
        return (bool) $preferences->discoverable && $this->visibilityAllows($preferences->profile_visibility, $viewer, $target);
    }

    public function canViewProfile(User $viewer, User $target): bool
    {
        if ($viewer->id === $target->id || $viewer->is_admin) return true;
        if ($this->blocked($viewer->id, $target->id)) return false;
        return $this->visibilityAllows($this->preferences($target)->profile_visibility, $viewer, $target);
    }

    public function canSeePresence(User $viewer, User $target): bool
    {
        if ($viewer->id === $target->id || $viewer->is_admin) return true;
        if ($this->blocked($viewer->id, $target->id)) return false;
        $preferences = $this->preferences($target);
        if (!$preferences->show_online_status) return false;
        return $this->visibilityAllows($preferences->presence_visibility, $viewer, $target);
    }

    public function canMessage(User $sender, User $recipient): bool
    {
        if ($sender->id === $recipient->id || $this->blocked($sender->id, $recipient->id)) return false;
        return match ($this->preferences($recipient)->message_policy) {
            'everyone', 'public' => true,
            'friends' => $this->friends($sender->id, $recipient->id),
            default => false,
        };
    }

    public function canInvite(User $sender, User $recipient): bool
    {
        if ($sender->id === $recipient->id || $this->blocked($sender->id, $recipient->id)) return false;
        return match ($this->preferences($recipient)->invite_policy) {
            'everyone', 'public' => true,
            'friends' => $this->friends($sender->id, $recipient->id),
            default => false,
        };
    }

    public function canFollow(User $viewer, User $target): bool
    {
        return $viewer->id !== $target->id
            && !$this->blocked($viewer->id, $target->id)
            && (bool) $this->preferences($target)->allow_follows
            && $this->canViewProfile($viewer, $target);
    }

    public function canViewActivity(User $viewer, SocialActivity $activity): bool
    {
        if ($activity->hidden) return false;
        if ($activity->expires_at && $activity->expires_at->isPast()) return false;
        $actor = $activity->actor;
        if (!$actor || $this->blocked($viewer->id, $actor->id)) return false;
        if ($viewer->id === $actor->id || $viewer->is_admin) return true;
        return match ($activity->audience) {
            'public' => $this->canViewProfile($viewer, $actor),
            'friends' => $this->friends($viewer->id, $actor->id),
            'followers' => $this->follows($viewer->id, $actor->id),
            'club' => $activity->club_id && $this->sameClub($viewer->id, (int) $activity->club_id),
            default => false,
        };
    }

    public function canSpectate(User $viewer, Room $room): bool
    {
        if (!filter_var(\App\Models\SiteSetting::getValue('spectator_mode_enabled', true), FILTER_VALIDATE_BOOLEAN)) return false;
        if (!in_array($room->status, ['waiting', 'bidding', 'playing'], true)) return false;
        if ($room->players()->where('user_id', $viewer->id)->where('is_bot', false)->exists()) return false;
        $state = $room->state ?: [];
        if (array_key_exists('allow_spectators', $state) && !$state['allow_spectators']) return false;
        $owner = $room->owner ?: User::find($room->owner_id);
        if (!$owner || !$this->preferences($owner)->allow_spectators || $this->blocked($viewer->id, $owner->id)) return false;
        $players = $room->relationLoaded('players')
            ? $room->players->where('is_bot', false)
            : $room->players()->with('user')->where('is_bot', false)->get();
        foreach ($players as $player) {
            $participant = $player->user;
            if (!$participant || (int) $participant->id === (int) $viewer->id) continue;
            if (!$this->preferences($participant)->allow_spectators || $this->blocked($viewer->id, $participant->id)) return false;
        }
        if ($viewer->is_admin || $viewer->id === $owner->id) return true;
        return match ($room->visibility) {
            'public' => true,
            'friends' => $this->friends($viewer->id, $owner->id),
            default => false,
        };
    }

    public function canViewReplay(User $viewer, MatchReplay $replay): bool
    {
        if ($replay->status !== 'ready') return false;
        $owner = $replay->owner;
        if (!$owner) {
            if ($replay->visibility !== 'public') return false;
            $replay->loadMissing('room.players.user');
            foreach ($replay->room?->players?->where('is_bot', false) ?? [] as $player) {
                if ($player->user && (!$this->preferences($player->user)->allow_replay_share || $this->blocked($viewer->id, $player->user->id))) return false;
            }
            return true;
        }
        if ($viewer->id === $owner->id || $viewer->is_admin) return true;
        if ($this->blocked($viewer->id, $owner->id) || !$this->canShareReplay($owner, $replay)) return false;
        $replay->loadMissing('room.players.user');
        foreach ($replay->room?->players?->where('is_bot', false) ?? [] as $player) {
            if ($player->user && $this->blocked($viewer->id, $player->user->id)) return false;
        }
        return match ($replay->visibility) {
            'public' => true,
            'friends' => $this->friends($viewer->id, $owner->id),
            default => false,
        };
    }

    public function canShareReplay(User $owner, MatchReplay $replay): bool
    {
        if ((int) $replay->owner_id !== (int) $owner->id || $replay->status !== 'ready') return false;
        if (!$this->preferences($owner)->allow_replay_share) return false;
        $replay->loadMissing('room.players.user');
        foreach ($replay->room?->players?->where('is_bot', false) ?? [] as $player) {
            if ($player->user && !$this->preferences($player->user)->allow_replay_share) return false;
        }
        return true;
    }

    private function visibilityAllows(?string $visibility, User $viewer, User $target): bool
    {
        return match ($visibility) {
            'public', 'everyone' => true,
            'friends' => $this->friends($viewer->id, $target->id),
            default => false,
        };
    }

    private function sameClub(int $userId, int $clubId): bool
    {
        return ClubMember::where('club_id', $clubId)->where('user_id', $userId)->exists();
    }
}
