<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\{DB,Hash,Schema};
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

final class AccountSecurityController extends Controller
{
    public function show(Request $request)
    {
        return view('account.security', ['user' => $request->user()]);
    }

    public function updateWeb(Request $request)
    {
        $this->updateAccount($request);
        $request->session()->regenerate();

        return back()->with('ok', 'تم تحديث البريد وكلمة المرور وإغلاق الجلسات الأخرى بأمان.');
    }

    public function updateMobile(Request $request)
    {
        $user = $this->updateAccount($request)->fresh('profile');

        return response()->json([
            'ok' => true,
            'message' => 'تم تحديث أمان الحساب بنجاح.',
            'user' => $user->publicProfile() + ['email' => $user->email],
        ]);
    }

    private function updateAccount(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'current_password' => ['required', 'string', 'max:120'],
            'username' => ['nullable','string','min:3','max:30','alpha_dash',Rule::unique('users','username')->ignore($user->id)],
            'email' => ['required', 'email:rfc', 'max:190', Rule::unique('users', 'email')->ignore($user->id)],
            'password' => ['nullable', 'confirmed', 'different:current_password', Password::min(10)->mixedCase()->numbers()],
        ]);

        abort_unless(Hash::check($data['current_password'], $user->password), 422, 'كلمة المرور الحالية غير صحيحة.');

        $newUsername = trim((string)($data['username'] ?? $user->username));
        if ($newUsername !== '' && $newUsername !== $user->username) {
            $user->username = $newUsername;
            if ($user->profile && trim((string)$user->profile->display_name) === '') $user->profile->update(['display_name'=>$newUsername]);
        }

        $newEmail = mb_strtolower(trim($data['email']));
        $emailChanged = strcasecmp((string)$user->email, $newEmail) !== 0;
        if ($emailChanged) {
            $user->email = $newEmail;
            $user->email_verified_at = null;
        }
        if (!empty($data['password'])) $user->password = Hash::make($data['password']);
        $user->save();

        if (!empty($data['password'])) {
            $currentTokenId = $request->user()?->currentAccessToken()?->id;
            $tokens = $user->tokens();
            if ($currentTokenId) $tokens->where('id', '!=', $currentTokenId);
            $tokens->delete();

            if (Schema::hasTable('sessions')) {
                $currentSessionId = $request->hasSession() ? $request->session()->getId() : null;
                $sessions = DB::table('sessions')->where('user_id', $user->id);
                if ($currentSessionId) $sessions->where('id', '!=', $currentSessionId);
                $sessions->delete();
            }
        }

        return $user;
    }
}
