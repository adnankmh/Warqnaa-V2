<?php

namespace Tests\Feature;

use Tests\TestCase;

class R107BilingualEngineAuditTest extends TestCase
{
    public function test_engine_audit_chrome_is_bilingual_without_changing_engine_evidence(): void
    {
        $view = file_get_contents(resource_path('views/admin/engine_audit_v124.blade.php'));

        $this->assertIsString($view);

        foreach ([
            'Engine Audit v124',
            'فحص سريع لكل الألعاب',
            'A fast audit of every game',
            'محركات عميقة',
            'Deep engines',
            'محركات fallback آمنة',
            'Safe fallback engines',
            'غير جاهز',
            'Not ready',
            "app()->isLocale('ar')",
            'dir="',
        ] as $label) {
            $this->assertStringContainsString($label, $view);
        }

        foreach ([
            "\$score['deep_engines']",
            "\$score['fallback_engines']",
            "\$r['ok']",
            "\$r['name']",
            "\$r['key']",
            "\$r['family']",
            "\$r['engine']",
            "\$r['phase']",
            "\$r['turn']",
            "\$r['error']",
        ] as $evidence) {
            $this->assertStringContainsString($evidence, $view);
        }

        $this->assertStringContainsString("'ok' : 'bad'", $view);
        $this->assertStringContainsString('@foreach($rows as $r)', $view);
    }
}
