<?php
namespace App\Services\Commerce;

use Illuminate\Support\Facades\Http;

/**
 * Server-side paid receipt verification boundary.
 *
 * The client can never grant itself currency. Production verification can use
 * either a trusted provider-verifier endpoint for Google/Apple/Web or Stripe
 * PaymentIntents for web. Secrets stay in environment configuration only.
 */
class ReceiptVerificationService
{
    public function verify(string $provider, string $productId, string $receiptToken): array
    {
        if ((bool)config('warqna_commerce.sandbox', false) && str_starts_with($receiptToken,'sandbox:')) {
            return [
                'verified'=>true,
                'status'=>'verified',
                'transaction_id'=>substr(hash('sha256', $provider.'|'.$receiptToken), 0, 32),
                'payload'=>['sandbox'=>true,'product_id'=>$productId],
            ];
        }

        if (!in_array($provider, ['google_play','apple','web'], true)) {
            return ['verified'=>false,'status'=>'rejected','reason'=>'unsupported_provider'];
        }
        if (!(bool)config("warqna_commerce.providers.$provider.enabled", false)) {
            return ['verified'=>false,'status'=>'rejected','reason'=>'provider_disabled'];
        }

        if ($provider === 'web') {
            $stripe = $this->verifyStripePaymentIntent($productId, $receiptToken);
            if ($stripe !== null) return $stripe;
        }

        $remote = $this->verifyThroughTrustedEndpoint($provider, $productId, $receiptToken);
        if ($remote !== null) return $remote;

        return ['verified'=>false,'status'=>'pending','reason'=>'provider_verifier_not_configured'];
    }

    private function verifyStripePaymentIntent(string $productId, string $receiptToken): ?array
    {
        $secret = trim((string)config('warqna_commerce.providers.web.stripe_secret', ''));
        if ($secret === '' || !str_starts_with($receiptToken, 'pi_')) return null;

        try {
            $response = Http::withToken($secret)
                ->acceptJson()
                ->timeout(12)
                ->retry(1, 200)
                ->get('https://api.stripe.com/v1/payment_intents/'.rawurlencode($receiptToken));
            if (!$response->successful()) {
                return ['verified'=>false,'status'=>'pending','reason'=>'stripe_unavailable','payload'=>['http_status'=>$response->status()]];
            }
            $payload = (array)$response->json();
            $metadataProduct = (string)(data_get($payload, 'metadata.warqnaa_product_id') ?: data_get($payload, 'metadata.product_id') ?: '');
            $verified = ($payload['status'] ?? null) === 'succeeded'
                && $metadataProduct !== ''
                && hash_equals($productId, $metadataProduct);
            return [
                'verified'=>$verified,
                'status'=>$verified ? 'verified' : 'rejected',
                'transaction_id'=>(string)($payload['id'] ?? $receiptToken),
                'reason'=>$verified ? null : 'stripe_payment_or_product_mismatch',
                'payload'=>[
                    'provider'=>'stripe',
                    'product_id'=>$metadataProduct,
                    'amount_received'=>(int)($payload['amount_received'] ?? 0),
                    'currency'=>(string)($payload['currency'] ?? ''),
                ],
            ];
        } catch (\Throwable $e) {
            report($e);
            return ['verified'=>false,'status'=>'pending','reason'=>'stripe_verification_error'];
        }
    }

    private function verifyThroughTrustedEndpoint(string $provider, string $productId, string $receiptToken): ?array
    {
        $url = trim((string)config("warqna_commerce.providers.$provider.verifier_url", ''));
        $secret = trim((string)config("warqna_commerce.providers.$provider.verifier_secret", ''));
        if ($url === '' || $secret === '') return null;

        $timestamp = (string)time();
        $nonce = bin2hex(random_bytes(12));
        $body = [
            'provider'=>$provider,
            'product_id'=>$productId,
            'receipt_token'=>$receiptToken,
            'timestamp'=>$timestamp,
            'nonce'=>$nonce,
        ];
        $signature = hash_hmac('sha256', json_encode($body, JSON_UNESCAPED_SLASHES), $secret);

        try {
            $response = Http::acceptJson()
                ->timeout(12)
                ->retry(1, 200)
                ->withHeaders([
                    'X-Warqnaa-Timestamp'=>$timestamp,
                    'X-Warqnaa-Nonce'=>$nonce,
                    'X-Warqnaa-Signature'=>$signature,
                ])
                ->post($url, $body);
            if (!$response->successful()) {
                return ['verified'=>false,'status'=>'pending','reason'=>'provider_verifier_unavailable','payload'=>['http_status'=>$response->status()]];
            }
            $data = (array)$response->json();
            $verified = ($data['verified'] ?? false) === true
                && isset($data['product_id'])
                && hash_equals($productId, (string)$data['product_id']);
            return [
                'verified'=>$verified,
                'status'=>$verified ? 'verified' : (in_array(($data['status'] ?? ''), ['rejected','pending'], true) ? $data['status'] : 'rejected'),
                'transaction_id'=>isset($data['transaction_id']) ? (string)$data['transaction_id'] : null,
                'reason'=>$verified ? null : (string)($data['reason'] ?? 'provider_rejected'),
                'payload'=>array_merge(['trusted_verifier'=>true], (array)($data['payload'] ?? [])),
            ];
        } catch (\Throwable $e) {
            report($e);
            return ['verified'=>false,'status'=>'pending','reason'=>'provider_verification_error'];
        }
    }
}
