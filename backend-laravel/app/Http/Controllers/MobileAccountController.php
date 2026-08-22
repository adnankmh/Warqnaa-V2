<?php

namespace App\Http\Controllers;

use App\Models\AccountDeletionRequest;
use App\Services\Account\AccountCancellationService;
use App\Services\Account\AccountSecurityService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\{DB, Hash};
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class MobileAccountController extends Controller
{
    public function security(Request $request)
    {
        $user = $request->user();
        return response()->json([
            'ok' => true,
            'account' => [
                'username' => $user->username,
                'email' => $user->email,
                'email_verified' => (bool) $user->email_verified_at,
                'is_admin' => (bool) $user->is_admin,
                'admin_role' => $user->admin_role,
                'active_sessions' => $user->tokens()->count(),
            ],
        ]);
    }

    public function updateEmail(Request $request, AccountSecurityService $security)
    {
        $user = $request->user();
        $data = $request->validate([
            'current_password' => 'required|string|max:120',
            'email' => ['required', 'email:rfc', 'max:190', Rule::unique('users', 'email')->ignore($user->id)],
        ]);
        $currentToken = $user->currentAccessToken()?->getKey();
        $updated = $security->changeEmail($user, $data['current_password'], $data['email'], $currentToken ? (int) $currentToken : null);

        return response()->json([
            'ok' => true,
            'message' => 'تم تغيير البريد. افتح رابط التأكيد المرسل إلى البريد الجديد.',
            'account' => [
                'username' => $updated->username,
                'email' => $updated->email,
                'email_verified' => false,
                'is_admin' => (bool) $updated->is_admin,
            ],
        ]);
    }

    public function updatePassword(Request $request, AccountSecurityService $security)
    {
        $data = $request->validate([
            'current_password' => 'required|string|max:120',
            'password' => ['required', 'confirmed', Password::min(8)->letters()->mixedCase()->numbers(), 'max:120'],
        ]);
        $user = $request->user();
        $currentToken = $user->currentAccessToken()?->getKey();
        $security->changePassword($user, $data['current_password'], $data['password'], $currentToken ? (int) $currentToken : null);

        return response()->json([
            'ok' => true,
            'message' => 'تم تغيير كلمة المرور وإغلاق جلسات التطبيق الأخرى.',
            'current_session_preserved' => true,
        ]);
    }

    public function export(Request $request)
    {
        $user = $request->user()->load([
            'profile', 'wallet', 'inventoryItems', 'walletTransactions', 'notifications', 'sentMessages', 'receivedMessages',
        ]);
        $payload = [
            'exported_at' => now()->toIso8601String(),
            'account' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
                'created_at' => $user->created_at?->toIso8601String(),
                'last_seen_at' => $user->last_seen_at?->toIso8601String(),
            ],
            'profile' => $user->profile,
            'wallet' => $user->wallet,
            'inventory' => $user->inventoryItems,
            'wallet_transactions' => $user->walletTransactions()->latest()->limit(5000)->get(),
            'notifications' => $user->notifications()->latest()->limit(1000)->get(),
            'messages' => [
                'sent' => $user->sentMessages()->latest()->limit(2000)->get(),
                'received' => $user->receivedMessages()->latest()->limit(2000)->get(),
            ],
        ];

        return response()->json(['ok' => true, 'export' => $payload]);
    }

    public function sessions(Request $request)
    {
        $current = $request->user()->currentAccessToken()?->getKey();

        return response()->json([
            'ok' => true,
            'sessions' => $request->user()->tokens()->latest()->get()->map(fn ($token) => [
                'id' => $token->id,
                'name' => $token->name,
                'current' => (int) $token->id === (int) $current,
                'last_used_at' => $token->last_used_at?->toIso8601String(),
                'created_at' => $token->created_at?->toIso8601String(),
                'expires_at' => $token->expires_at?->toIso8601String(),
            ]),
        ]);
    }

    public function revokeSession(Request $request, int $tokenId)
    {
        $token = $request->user()->tokens()->whereKey($tokenId)->firstOrFail();
        $current = $request->user()->currentAccessToken()?->getKey();
        $token->delete();

        return response()->json([
            'ok' => true,
            'message' => (int) $current === $tokenId ? 'تم تسجيل الخروج من هذه الجلسة.' : 'تم إغلاق الجلسة.',
            'current_revoked' => (int) $current === $tokenId,
        ]);
    }

    public function requestDeletion(Request $request, AccountCancellationService $cancellation)
    {
        $user = $request->user();
        abort_if($user->is_admin, 403, 'لا يمكن إلغاء حساب المدير الرئيسي.');

        $data = $request->validate([
            'password' => 'required|string|max:120',
            'reason' => 'nullable|string|max:500',
            'confirmation' => 'sometimes|accepted',
        ]);
        abort_unless(Hash::check($data['password'], $user->password), 422, 'كلمة المرور غير صحيحة.');

        $deletion = $cancellation->request($user, $data['reason'] ?? null);
        $days = $cancellation->graceDays();

        return response()->json([
            'ok' => true,
            'account_cancelled' => true,
            'grace_days' => $days,
            'message' => "تم إلغاء الحساب وتسجيل الخروج. سيُحذف نهائياً إذا لم تفتحه وتسجل الدخول خلال {$days} يوماً.",
            'scheduled_for' => $deletion->scheduled_for?->toIso8601String(),
        ]);
    }

    public function cancelDeletion(Request $request, AccountCancellationService $cancellation)
    {
        $restored = $cancellation->reactivate($request->user());
        abort_unless($restored, 404, 'لا يوجد إلغاء حساب معلق.');

        return response()->json([
            'ok' => true,
            'message' => 'تمت استعادة الحساب وإلغاء الحذف النهائي.',
        ]);
    }
}
