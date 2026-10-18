<?php

namespace Tests\Feature;

use Tests\TestCase;

class R45ReferenceStoreLegibilityContractTest extends TestCase
{
    public function test_reference_store_uses_live_catalogue_with_readable_responsive_items(): void
    {
        $source = file_get_contents(base_path('../flutter_app/lib/r35_reference_world.dart'));

        $this->assertStringContainsString("controller.isStoreProductVisible", $source);
        $this->assertStringContainsString("controller.priceFor(product)", $source);
        $this->assertStringContainsString("constraints.maxWidth < 420", $source);
        $this->assertStringContainsString("ValueKey('r45-store-treasure-scroll')", $source);
        $this->assertStringContainsString("width: 136", $source);
        $this->assertStringContainsString("fontSize: 12, height: 1.25", $source);
        $this->assertStringNotContainsString("fontSize: 10.5", $source);
        $this->assertStringNotContainsString("fontSize: 10)", $source);
    }
}
