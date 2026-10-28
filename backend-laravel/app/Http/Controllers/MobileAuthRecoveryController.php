<?php
namespace App\Http\Controllers;

use App\Models\User;
use App\Notifications\{ResetPasswordMobile,VerifyEmailMobile};
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\{Hash,Password,URL};
use Illuminate\Support\Str;

class MobileAuthRecoveryController extends Controller
{
    private function message(string $ar, string $en): string
    {
        return app()->isLocale('ar') ? $ar : $en;
    }

    public function forgot(Request $request)
    {
        $data = $request->validate(['email'=>'required|email|max:190']);
        $user = User::where('email', $data['email'])->first();
        if ($user) {
            $token = Password::broker()->createToken($user);
            $url = route('password.reset.form', ['token'=>$token, 'email'=>$user->email]);
            try { $user->notify(new ResetPasswordMobile($url)); } catch (\Throwable $e) { report($e); }
        }
        return response()->json([
            'ok'=>true,
            'message'=>$this->message(
                'إذا كان البريد مسجلاً فستصل رسالة إعادة التعيين.',
                'If the email is registered, a password reset message will be sent.'
            ),
        ]);
    }

    public function showResetForm(Request $request)
    {
        return view('auth.mobile-reset-password', [
            'token' => (string) $request->query('token', ''),
            'email' => (string) $request->query('email', ''),
        ]);
    }

    public function resetFromWeb(Request $request)
    {
        $response = $this->reset($request);
        $payload = method_exists($response, 'getData') ? (array) $response->getData(true) : [];
        $ok = (bool) ($payload['ok'] ?? false);
        $fallback = $ok
            ? $this->message('تم تغيير كلمة المرور.', 'Your password has been changed.')
            : $this->message('تعذر تغيير كلمة المرور.', 'The password could not be changed.');
        return back()->with($ok ? 'success' : 'error', (string) ($payload['message'] ?? $fallback));
    }

    public function reset(Request $request)
    {
        $data = $request->validate([
            'email'=>'required|email|max:190',
            'token'=>'required|string',
            'password'=>'required|string|min:8|max:120|confirmed',
        ]);
        $status = Password::broker()->reset($data, function (User $user, string $password) {
            $user->forceFill(['password'=>Hash::make($password)])->setRememberToken(Str::random(60));
            $user->save();
            $user->tokens()->delete();
            event(new PasswordReset($user));
        });
        if ($status !== Password::PASSWORD_RESET) {
            return response()->json(['ok'=>false,'message'=>__($status)], 422);
        }
        return response()->json([
            'ok'=>true,
            'message'=>$this->message(
                'تم تغيير كلمة المرور. سجل الدخول من جديد.',
                'Your password has been changed. Sign in again.'
            ),
        ]);
    }

    public function sendVerification(Request $request)
    {
        $user = $request->user();
        if ($user->email_verified_at) {
            return response()->json([
                'ok'=>true,
                'message'=>$this->message('البريد مؤكد مسبقًا.', 'This email address is already verified.'),
            ]);
        }
        $url = URL::temporarySignedRoute('verification.verify.mobile', now()->addMinutes(60), [
            'id'=>$user->id,
            'hash'=>sha1($user->email),
        ]);
        try { $user->notify(new VerifyEmailMobile($url)); } catch (\Throwable $e) { report($e); }
        return response()->json([
            'ok'=>true,
            'message'=>$this->message(
                'تم إرسال رابط التأكيد إذا كانت خدمة البريد مفعلة.',
                'A verification link was sent if email delivery is enabled.'
            ),
        ]);
    }

    public function verify(Request $request, int $id, string $hash)
    {
        abort_unless(
            $request->hasValidSignature(),
            403,
            $this->message('رابط التأكيد غير صالح أو منتهي.', 'The verification link is invalid or expired.')
        );
        $user = User::findOrFail($id);
        abort_unless(
            hash_equals(sha1($user->email), $hash),
            403,
            $this->message('بيانات التأكيد غير متطابقة.', 'The verification details do not match.')
        );
        if (!$user->email_verified_at) $user->update(['email_verified_at'=>now()]);
        return view('legal.page', [
            'title'=>$this->message('تم تأكيد البريد', 'Email verified'),
            'content'=>$this->message(
                '<p class="notice">تم تأكيد بريد حساب Warqna بنجاح. يمكنك العودة إلى التطبيق وتسجيل الدخول.</p>',
                '<p class="notice">Your Warqna account email was verified successfully. You can return to the app and sign in.</p>'
            ),
        ]);
    }
}
