<?php

namespace Tests\Feature;

use Tests\TestCase;

class R92NotificationDrawerLocaleFallbackTest extends TestCase
{
    public function test_global_drawer_uses_active_locale_then_opposite_locale_fallback(): void
    {
        $layout = file_get_contents(resource_path('views/layouts/app.blade.php'));

        $this->assertStringContainsString("\$localeCode = \$english ? 'en' : 'ar';", $layout);
        $this->assertStringContainsString("\$fallbackLocale = \$english ? 'ar' : 'en';", $layout);
        $this->assertStringContainsString(
            "data_get(\$n->title,\$localeCode) ?: data_get(\$n->title,\$fallbackLocale) ?: \$n->type",
            $layout,
        );
        $this->assertStringContainsString(
            "data_get(\$n->body,\$localeCode) ?: data_get(\$n->body,\$fallbackLocale) ?: ''",
            $layout,
        );
        $this->assertStringContainsString("@if(\$notifBody!=='')<p>{{ \$notifBody }}</p>@endif", $layout);
        $this->assertStringNotContainsString("\$n->title['ar']", $layout);
        $this->assertStringNotContainsString("\$n->body['ar']", $layout);
    }
}
