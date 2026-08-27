<?php

namespace App\Support;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Laravel\Sanctum\PersonalAccessToken;

final class AuthenticatedActor
{
    /**
     * Resolve the actor from the bearer token for API calls and refresh the
     * model from the database. This avoids stale guard state across repeated
     * feature-test requests and guarantees newly granted admin permissions are
     * visible immediately. Session/web requests fall back to the authenticated
     * user and are refreshed as well.
     */
    public static function resolve(Request $request): User
    {
        $accessToken = null;
        $actor = null;
        $bearer = trim((string) $request->bearerToken());

        if ($bearer !== '') {
            $accessToken = PersonalAccessToken::findToken($bearer);
            if ($accessToken) {
                $tokenable = $accessToken->tokenable;
                if ($tokenable instanceof User) {
                    $actor = User::query()->find($tokenable->getKey());
                }
            }
        }

        if (!$actor && $request->user()) {
            $actor = User::query()->find($request->user()->getKey());
        }

        abort_unless($actor instanceof User, 401, 'Authentication required.');

        if ($accessToken) {
            $actor->withAccessToken($accessToken);
        }

        $request->setUserResolver(static fn () => $actor);
        Auth::setUser($actor);

        return $actor;
    }
}
