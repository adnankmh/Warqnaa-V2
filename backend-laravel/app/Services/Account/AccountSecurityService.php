<?php

namespace App\Services\Account;

use App\Models\User;
use App\Notifications\VerifyEmailMobile;
use Illuminate\Support\Facades\{DB, Hash, Log, URL};
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AccountSecurityService
{
    public function changeEmail(User $user, string $currentPassword, string $email, ?int $currentTokenId = null): User
    {
        $updated = DB::transaction(function () use ($user, $currentPassword, $email, $currentTokenId): User {
            $locked = User::query()->whereKey($user->getKey())->lockForUpdate()->firstOrFail();
            $this->assertCurrentPassword($locked, $currentPassword);

            $normalized = Str::lower(trim($email));
            if (strcasecmp((string) $locked->email, $normalized) === 0) {
                throw ValidationException::withMessages(['email' => 'البريد الجديد مطابق للبريد الحالي.']);
            }

            $previous = (string) $locked->email;
            $locked->forceFill([
                'email' => $normalized,
                'email_verified_at' => null,
            ])->save();
            $this->revokeOtherApiTokens($locked, $currentTokenId);

            Log::notice('Warqnaa account email changed', [
                'user_id' => $locked->id,
                'admin' => (bool) $locked->is_admin,
                'previous_email_hash' => hash('sha256', Str::lower($previous)),
                'new_email_hash' => hash('sha256', $normalized),
            ]);

            return $locked->fresh();
        });

        $this->sendVerification($updated);
        return $updated;
    }

    public function changePassword(User $user, string $currentPassword, string $newPassword, ?int $currentTokenId = null): User
    {
        return DB::transaction(function () use ($user, $currentPassword, $newPassword, $currentTokenId): User {
            $locked = User::query()->whereKey($user->getKey())->lockForUpdate()->firstOrFail();
            $this->assertCurrentPassword($locked, $currentPassword);

            if (Hash::check($newPassword, (string) $locked->password)) {
                throw ValidationException::withMessages(['password' => 'اختر كلمة مرور جديدة مختلفة عن الحالية.']);
            }

            $locked->forceFill([
                'password' => Hash::make($newPassword),
                'remember_token' => Str::random(60),
            ])->save();
            $this->revokeOtherApiTokens($locked, $currentTokenId);

            Log::notice('Warqnaa account password changed', [
                'user_id' => $locked->id,
                'admin' => (bool) $locked->is_admin,
            ]);

            return $locked->fresh();
        });
    }

    public function sendVerification(User $user): void
    {
        $url = URL::temporarySignedRoute('verification.verify.mobile', now()->addMinutes(60), [
            'id' => $user->id,
            'hash' => sha1((string) $user->email),
        ]);
        try {
            $user->notify(new VerifyEmailMobile($url));
        } catch (\Throwable $error) {
            report($error);
        }
    }

    private function assertCurrentPassword(User $user, string $password): void
    {
        if (!Hash::check($password, (string) $user->password)) {
            throw ValidationException::withMessages(['current_password' => 'كلمة المرور الحالية غير صحيحة.']);
        }
    }

    private function revokeOtherApiTokens(User $user, ?int $currentTokenId): void
    {
        $tokens = $user->tokens();
        if ($currentTokenId !== null) {
            $tokens->where('id', '!=', $currentTokenId)->delete();
            return;
        }
        $tokens->delete();
    }
}
