<?php
namespace App\Services\Commerce;

/**
 * Provider verification boundary.
 *
 * R10.1 never grants paid rewards from a client-supplied "success" flag.
 * Sandbox tokens are intentionally explicit. Real Google/Apple/Web receipts
 * remain pending until the deployment config supplies a provider verifier.
 */
class ReceiptVerificationService
{
    public function verify(string $provider, string $productId, string $receiptToken): array
    {
        if ((bool)config('warqna_commerce.sandbox',true) && str_starts_with($receiptToken,'sandbox:')) {
            return ['verified'=>true,'status'=>'verified','transaction_id'=>substr(hash('sha256',$provider.'|'.$receiptToken),0,32),'payload'=>['sandbox'=>true,'product_id'=>$productId]];
        }
        if (!in_array($provider,['google_play','apple','web'],true)) {
            return ['verified'=>false,'status'=>'rejected','reason'=>'unsupported_provider'];
        }
        return ['verified'=>false,'status'=>'pending','reason'=>'provider_verifier_not_configured'];
    }
}
