<?php
namespace App\Http\Controllers;

use App\Models\PurchaseReceipt;
use App\Services\Commerce\CommerceCatalogService;
use App\Services\Commerce\ReceiptVerificationService;
use App\Services\Wallet\WalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class MobileCommerceController extends Controller
{
    public function catalog(CommerceCatalogService $catalog)
    {
        return response()->json(['ok'=>true,'commerce'=>$catalog->catalog()]);
    }

    public function verifyReceipt(Request $request, CommerceCatalogService $catalog, ReceiptVerificationService $verifier, WalletService $wallet)
    {
        abort_unless((bool)config('warqna_commerce.enabled',true),503,'المتجر النقدي متوقف مؤقتًا.');
        $data=$request->validate([
            'provider'=>['required',Rule::in(['google_play','apple','web'])],
            'package_key'=>'required|string|max:80',
            'product_id'=>'required|string|max:180',
            'receipt_token'=>'required|string|min:8|max:8000',
        ]);
        $packages=collect($catalog->catalog()['packages'] ?? [])->keyBy('key');
        $package=$packages->get($data['package_key']);
        abort_unless($package && hash_equals((string)$package['product_id'],(string)$data['product_id']),422,'حزمة الشراء غير مطابقة للكتالوج.');

        $receipt=PurchaseReceipt::where('provider',$data['provider'])->where('receipt_token',$data['receipt_token'])->first();
        if($receipt){
            return response()->json(['ok'=>$receipt->status==='verified','status'=>$receipt->status,'receipt_id'=>$receipt->id,'duplicate'=>true]);
        }
        $check=$verifier->verify($data['provider'],$data['product_id'],$data['receipt_token']);
        $user=$request->user();
        $receipt=DB::transaction(function() use($user,$data,$package,$check,$wallet){
            $row=PurchaseReceipt::create([
                'user_id'=>$user->id,'provider'=>$data['provider'],'package_key'=>$data['package_key'],
                'receipt_token'=>$data['receipt_token'],'status'=>$check['status'] ?? 'pending',
                'payload'=>array_merge($check['payload'] ?? [],['product_id'=>$data['product_id'],'tokens'=>(int)$package['tokens']]),
                'product_id'=>$data['product_id'],'transaction_id'=>$check['transaction_id'] ?? null,
                'amount_minor'=>(int)$package['price_minor'],'currency'=>$package['currency'] ?? 'USD',
                'verified_at'=>!empty($check['verified']) ? now() : null,
            ]);
            if(!empty($check['verified'])){
                $wallet->credit($user,(int)$package['tokens'],'real_money_token_purchase',['receipt_id'=>$row->id,'provider'=>$data['provider'],'package_key'=>$data['package_key']]);
            }
            return $row;
        });
        return response()->json([
            'ok'=>$receipt->status==='verified','status'=>$receipt->status,'receipt_id'=>$receipt->id,
            'credited_tokens'=>$receipt->status==='verified' ? (int)$package['tokens'] : 0,
            'message'=>$receipt->status==='verified' ? 'تم التحقق من الشراء وإضافة الرصيد.' : 'تم تسجيل الإيصال وينتظر تحقق مزود الدفع.',
        ],$receipt->status==='verified'?200:202);
    }

    public function receipt(Request $request, PurchaseReceipt $receipt)
    {
        abort_unless((int)$receipt->user_id===(int)$request->user()->id || $request->user()->is_admin,403);
        return response()->json(['ok'=>true,'receipt'=>$receipt]);
    }
}
