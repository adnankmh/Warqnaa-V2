<?php

namespace App\Http\Controllers;

use App\Services\Account\AccountSecurityService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class AccountSecurityController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();
        return view('account.security', [
            'user' => $user,
            'activeSessions' => $user->tokens()->count() + 1,
        ]);
    }

    public function updateEmail(Request $request, AccountSecurityService $security)
    {
        $user = $request->user();
        $data = $request->validate([
            'current_password' => 'required|string|max:120',
            'email' => ['required', 'email:rfc', 'max:190', Rule::unique('users', 'email')->ignore($user->id)],
        ]);

        $security->changeEmail($user, $data['current_password'], $data['email']);
        $request->session()->regenerate();

        return back()->with('ok', 'تم تغيير البريد الإلكتروني. أرسلنا رابط تأكيد إلى البريد الجديد.');
    }

    public function updatePassword(Request $request, AccountSecurityService $security)
    {
        $data = $request->validate([
            'current_password' => 'required|string|max:120',
            'password' => ['required', 'confirmed', Password::min(8)->letters()->mixedCase()->numbers(), 'max:120'],
        ]);

        $security->changePassword($request->user(), $data['current_password'], $data['password']);
        $request->session()->regenerate();

        return back()->with('ok', 'تم تغيير كلمة المرور وإغلاق جلسات التطبيق الأخرى بنجاح.');
    }
}
