<?php
namespace App\Http\Controllers;

use App\Models\{RewardedAdClaim,RewardedAdSession,SiteSetting,User};
use App\Services\Commerce\AdMobSsvVerifier;
use App\Services\Leveling\XpService;
use App\Services\Wallet\WalletService;
use App\Support\AuthenticatedActor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MobileRewardedAdsController extends Controller
{
    public static function ready(): bool
    {
        return (bool)config('warqna_commerce.ads.ssv_enabled',false)
            && count((array)config('warqna_commerce.ads.ssv_ad_units',[]))>0
            && filter_var(SiteSetting::getValue('ads_rewarded_enabled',true),FILTER_VALIDATE_BOOLEAN);
    }

    public function start(Request $request)
    {
        AuthenticatedActor::resolve($request);
        abort_unless(self::ready(),503,'Rewarded ad verification is not configured.');
        $user=$request->user();
        abort_if($user->is_banned,403);
        $session=DB::transaction(function() use($user) {
            User::whereKey($user->id)->lockForUpdate()->firstOrFail();
            abort_if(RewardedAdClaim::where('user_id',$user->id)->whereDate('claim_date',today())->count()>=8,429,'Daily ad reward limit reached.');
            $pending=RewardedAdSession::where('user_id',$user->id)->where('status','pending')->where('expires_at','>',now())->latest()->first();
            return $pending ?: RewardedAdSession::create(['id'=>(string)Str::uuid(),'user_id'=>$user->id,'expires_at'=>now()->addMinutes(30)]);
        });
        return response()->json(['session_id'=>$session->id,'user_id'=>(string)$user->id,'tokens'=>50,'xp'=>15,'expires_at'=>$session->expires_at->toIso8601String()]);
    }

    public function status(Request $request,string $session)
    {
        AuthenticatedActor::resolve($request);
        $row=RewardedAdSession::whereKey($session)->where('user_id',$request->user()->id)->firstOrFail();
        return response()->json(['status'=>$row->status==='pending' && $row->expires_at->isPast()?'expired':$row->status,
            'tokens'=>(int)$row->reward_tokens,'xp'=>(int)$row->reward_xp,
            'wallet'=>$request->user()->wallet()->first(),'profile'=>$request->user()->publicProfile()]);
    }

    public function callback(Request $request,AdMobSsvVerifier $verifier,WalletService $wallet,XpService $xp)
    {
        abort_unless(self::ready(),503,'Rewarded ad verification is not configured.');
        // QUERY_STRING is the original signed byte sequence. Rebuilding it with
        // Request::query() would reorder/decode the bytes and invalidate trust.
        $data=$verifier->verify((string)$request->server('QUERY_STRING',''));
        abort_unless(in_array($data['ad_unit'],(array)config('warqna_commerce.ads.ssv_ad_units',[]),true),403,'Unrecognized ad unit.');
        $row=RewardedAdSession::whereKey($data['custom_data'])->firstOrFail();
        abort_unless((string)$row->user_id===$data['user_id'],403,'Ad identity mismatch.');
        $eventTime=(int)$data['timestamp'];
        abort_unless($eventTime>=$row->created_at->getTimestampMs()-30000 && $eventTime<=$row->expires_at->getTimestampMs(),403,'Ad session expired.');
        DB::transaction(function() use($row,$data,$wallet,$xp) {
            $user=User::whereKey($row->user_id)->lockForUpdate()->firstOrFail();
            abort_if($user->is_banned,403);
            $session=RewardedAdSession::whereKey($row->id)->lockForUpdate()->firstOrFail();
            if($session->status!=='pending') return;
            abort_if(RewardedAdSession::where('provider_transaction_id',$data['transaction_id'])->exists(),409,'Ad transaction already used.');
            if(RewardedAdClaim::where('user_id',$user->id)->whereDate('claim_date',today())->count()>=8) {
                $session->update(['status'=>'daily_limit','provider_transaction_id'=>$data['transaction_id']]);return;
            }
            RewardedAdClaim::create(['user_id'=>$user->id,'claim_date'=>today(),'network'=>'admob_ssv',
                'verification_id'=>$session->id,'reward_tokens'=>50,'reward_xp'=>15,
                'payload'=>['transaction_id'=>$data['transaction_id'],'ad_unit'=>$data['ad_unit']]]);
            $wallet->credit($user,50,'rewarded_ad',['ad_session'=>$session->id]);
            $user->load(['profile','wallet']);
            $xp->award($user,15,0,false,false,false);
            if($user->isPrimaryAdmin()) {$user->profile->level=max(99,(int)$user->profile->level);$user->profile->save();}
            $session->update(['status'=>'rewarded','provider_transaction_id'=>$data['transaction_id'],
                'rewarded_at'=>now(),'reward_tokens'=>50,'reward_xp'=>15]);
        });
        return response()->json(['ok'=>true]);
    }
}
