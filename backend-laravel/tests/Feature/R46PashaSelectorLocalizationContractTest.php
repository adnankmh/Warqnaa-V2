<?php

namespace Tests\Feature;

use Tests\TestCase;

class R46PashaSelectorLocalizationContractTest extends TestCase
{
    public function test_pasha_selector_is_bilingual_legible_and_uses_live_prices(): void
    {
        $source = file_get_contents(base_path('../flutter_app/lib/v173_global.dart'));

        $this->assertStringContainsString("class PashaStyleSelectorV173 extends StatelessWidget", $source);
        $this->assertStringContainsString("controller.localeCode == 'ar'", $source);
        $this->assertStringContainsString("'Pasha fez colors'", $source);
        $this->assertStringContainsString("ar ? style.nameAr : style.nameEn", $source);
        $this->assertStringContainsString("controller.priceFor(product)", $source);
        $this->assertStringContainsString("fontSize: 12, color: Colors.white", $source);
        $this->assertStringContainsString("if (owned || controller.isAdmin)", $source);
        $this->assertStringNotContainsString("'🪙 6,500'", $source);
        $this->assertStringNotContainsString("Text(style.nameAr", $source);
    }
}
