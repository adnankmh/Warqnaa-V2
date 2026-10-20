<?php
namespace App\Http\Controllers;

use App\Models\{DailyRewardClaim,Wallet,PrizeBox};
use App\Services\WarqnaPro\{DailyRewardService,LuckyWheelService,PrizeBoxService};
use Illuminate\Http\Request;

class RewardController
{
 public function index(LuckyWheelService $wheelService, PrizeBoxService $boxService)
 {
  $today=DailyRewardClaim::where('user_id',auth()->id())->whereDate('claim_date',today())->first();
  $claims=DailyRewardClaim::where('user_id',auth()->id())->latest()->limit(14)->get();
  $wheel=$wheelService->center(auth()->user());
  $boxes=$boxService->center(auth()->user());
  return view('rewards.index',compact('today','claims','wheel','boxes'));
 }

 public function spin(Request $r, LuckyWheelService $service)
 {
  $data=$r->validate(['source'=>'required|in:free,tokens']);
  try { $result=$service->spin($r->user(),$data['source']); }
  catch (\RuntimeException $error) { throw \Illuminate\Validation\ValidationException::withMessages(['reward'=>$error->getMessage()]); }
  return back()->with('r52_reward',$result['reward']);
 }

 public function openBox(Request $r, PrizeBox $box, PrizeBoxService $service)
 {
  abort_unless((int)$box->user_id===(int)$r->user()->id,404);
  try { $result=$service->open($r->user(),$box); }
  catch (\RuntimeException $error) { throw \Illuminate\Validation\ValidationException::withMessages(['reward'=>$error->getMessage()]); }
  return back()->with('r52_reward',$result['reward']);
 }

 public function claim(DailyRewardService $svc, Request $r)
 {
  $last=DailyRewardClaim::where('user_id',auth()->id())->latest('claim_date')->first();
  $streak=$last && $last->claim_date?->isYesterday() ? $last->streak+1 : 1;
  $coins=$svc->rewardForStreak($streak);
  $claim=DailyRewardClaim::firstOrCreate(
   ['user_id'=>auth()->id(),'claim_date'=>today()],
   ['streak'=>$streak,'coins'=>$coins,'payload'=>$svc->spinPrize()]
  );
  if($claim->wasRecentlyCreated){
   $wallet=Wallet::firstOrCreate(['user_id'=>auth()->id()],['tokens'=>0,'gems'=>0]);
   $wallet->increment('tokens',$claim->coins);
  }
  if($r->expectsJson() || $r->ajax()) return response()->json(['ok'=>true,'message'=>'تم استلام المكافأة اليومية','claim'=>$claim]);
  return back()->with('ok','تم استلام المكافأة اليومية');
 }
}
