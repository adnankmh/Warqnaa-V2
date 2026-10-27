<?php

namespace Tests\Feature;

use Tests\TestCase;

class R100BilingualSecureOffersTest extends TestCase
{
    public function test_offers_checkout_localizes_the_surface_without_changing_commerce_contracts(): void
    {
        $source = file_get_contents(resource_path('views/store/offers.blade.php'));

        $this->assertIsString($source);
        foreach ([
            'العروض والشراء الآمن',
            'Offers & secure checkout',
            'الدولة',
            'Country',
            'الحساب',
            'Account',
            'العروض المميزة',
            'Featured offers',
            'عروض الأسبوع',
            'Weekly offers',
            'اختيار العرض',
            'Select offer',
            'إتمام الشراء',
            'Complete purchase',
            'متابعة إلى مزود الدفع',
            'Continue to payment provider',
            'التحقق من الإيصال خادميًا',
            'verified server-side',
        ] as $localizedCopy) {
            $this->assertStringContainsString($localizedCopy, $source);
        }

        foreach ([
            'data-filter="all"',
            'data-filter="featured"',
            'data-filter="weekly"',
            'data-filter="tokens"',
            'value="PS"',
            'value="JO"',
            'value="SA"',
            'value="AE"',
            'value="IQ"',
            'value="KW"',
            'value="QA"',
            'value="OM"',
            'value="BH"',
            'value="OTHER"',
            "\$package['price_minor']",
            "\$package['tokens']",
            "\$package['currency']",
            'data-package-key=',
            'selectB307Offer',
            'b307BeginCheckout',
            "\$catalog['sandbox']",
        ] as $stableContract) {
            $this->assertStringContainsString($stableContract, $source);
        }
    }
}
