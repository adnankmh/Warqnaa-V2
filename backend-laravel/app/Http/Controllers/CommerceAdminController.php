<?php
namespace App\Http\Controllers;

use App\Models\{SiteSetting,StoreOffer,PurchaseReceipt};
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CommerceAdminController
{
    private function guard(): void { abort_unless(auth()->user()?->hasAdminPermission('commerce'),403); }

    public function saveSettings(Request $request)
    {
        $this->guard();
        $data=$request->validate([
            'commerce_enabled'=>'nullable|boolean','ads_rewarded_enabled'=>'nullable|boolean','ads_interstitial_enabled'=>'nullable|boolean',
            'rewarded_daily_limit'=>'required|integer|min:0|max:25','interstitial_min_minutes'=>'required|integer|min:5|max:180',
        ]);
        SiteSetting::setValue('commerce_enabled',$request->boolean('commerce_enabled'),'bool','commerce','Real-money commerce');
        SiteSetting::setValue('ads_rewarded_enabled',$request->boolean('ads_rewarded_enabled'),'bool','ads','Rewarded ads');
        SiteSetting::setValue('ads_interstitial_enabled',$request->boolean('ads_interstitial_enabled'),'bool','ads','Interstitial ads');
        SiteSetting::setValue('rewarded_daily_limit',(int)$data['rewarded_daily_limit'],'int','ads','Rewarded daily limit');
        SiteSetting::setValue('interstitial_min_minutes',(int)$data['interstitial_min_minutes'],'int','ads','Interstitial spacing');
        // Safety invariant: never display interstitial advertising during a live match.
        SiteSetting::setValue('ads_during_match',false,'bool','ads','Ads during match');
        return back()->with('ok','تم حفظ إعدادات التجارة والإعلانات. الإعلانات داخل المباراة تبقى معطلة دائمًا.');
    }

    public function saveOffer(Request $request)
    {
        $this->guard();
        $data=$request->validate([
            'key'=>'required|string|max:80|regex:/^[a-z0-9_.:-]+$/i',
            'cadence'=>['required',Rule::in(['daily','weekly','monthly','annual','custom'])],
            'title_ar'=>'required|string|max:120','title_en'=>'required|string|max:120',
            'description_ar'=>'nullable|string|max:300','description_en'=>'nullable|string|max:300',
            'discount_percent'=>'required|integer|min:0|max:90','starts_at'=>'nullable|date','ends_at'=>'nullable|date|after_or_equal:starts_at',
            'item_keys'=>'nullable|string|max:4000','active'=>'nullable|boolean',
        ]);
        $keys=collect(preg_split('/[\s,]+/',(string)($data['item_keys'] ?? ''),-1,PREG_SPLIT_NO_EMPTY))->map(fn($v)=>trim($v))->unique()->values()->all();
        StoreOffer::updateOrCreate(['key'=>$data['key']],[
            'title'=>['ar'=>$data['title_ar'],'en'=>$data['title_en']],
            'description'=>['ar'=>$data['description_ar'] ?? '', 'en'=>$data['description_en'] ?? '', 'cadence'=>$data['cadence']],
            'discount_percent'=>(int)$data['discount_percent'],'starts_at'=>$data['starts_at'] ?? null,'ends_at'=>$data['ends_at'] ?? null,
            'active'=>$request->boolean('active'),'item_keys'=>$keys,
        ]);
        return back()->with('ok','تم حفظ العرض التجاري ونشره حسب المدة المحددة.');
    }

    public function deleteOffer(StoreOffer $offer)
    {
        $this->guard();
        $offer->delete();
        return back()->with('ok','تم حذف العرض.');
    }

    public function receiptStats(): array
    {
        return [
            'verified'=>PurchaseReceipt::where('status','verified')->count(),
            'pending'=>PurchaseReceipt::where('status','pending')->count(),
            'rejected'=>PurchaseReceipt::where('status','rejected')->count(),
        ];
    }
}
