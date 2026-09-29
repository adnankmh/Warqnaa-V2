<?php

namespace Tests\Feature;

use App\Services\Commerce\CommerceCatalogService;
use App\Services\Commerce\ReceiptVerificationService;
use App\Services\Platform\ProductionConfigService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R16CommerceVoiceReadinessTest extends TestCase
{
    use RefreshDatabase;

    public function test_paid_store_never_trusts_an_unverified_client_receipt(): void
    {
        config()->set('warqna_commerce.enabled', true);
        config()->set('warqna_commerce.sandbox', false);
        config()->set('warqna_commerce.providers.web.enabled', true);
        config()->set('warqna_commerce.providers.web.stripe_secret', '');
        config()->set('warqna_commerce.providers.web.verifier_url', '');
        config()->set('warqna_commerce.providers.web.verifier_secret', '');

        $result = app(ReceiptVerificationService::class)->verify('web', 'warqnaa.tokens.starter', 'client-says-success');
        $this->assertFalse($result['verified']);
        $this->assertSame('pending', $result['status']);
        $this->assertSame('provider_verifier_not_configured', $result['reason']);
    }

    public function test_commerce_catalog_exposes_readiness_without_exposing_secrets(): void
    {
        config()->set('warqna_commerce.sandbox', false);
        config()->set('warqna_commerce.providers.web.enabled', true);
        config()->set('warqna_commerce.providers.web.stripe_secret', 'sk_test_not_for_output');

        $catalog = app(CommerceCatalogService::class)->catalog();
        $this->assertTrue($catalog['providers']['web']['verification_ready']);
        $this->assertTrue($catalog['production_ready']);
        $this->assertStringNotContainsString('sk_test_not_for_output', json_encode($catalog));
    }

    public function test_production_config_reports_multiplayer_and_voice_readiness(): void
    {
        config()->set('app.url', 'https://play.warqnaa.example');
        config()->set('voice.stun_urls', ['stun:stun.l.google.com:19302']);
        config()->set('voice.turn_urls', ['turn:turn.warqnaa.example:3478']);

        $config = app(ProductionConfigService::class)->publicConfig('web');
        $this->assertTrue($config['multiplayer']['server_authoritative']);
        $this->assertTrue($config['multiplayer']['heartbeat']);
        $this->assertTrue($config['multiplayer']['reconnect']);
        $this->assertTrue($config['multiplayer']['public_runtime']);
        $this->assertTrue($config['voice']['turn_configured']);
        $this->assertGreaterThanOrEqual(1, $config['voice']['stun_count']);
    }
}
