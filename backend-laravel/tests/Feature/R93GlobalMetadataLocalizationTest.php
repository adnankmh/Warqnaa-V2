<?php

namespace Tests\Feature;

use Tests\TestCase;

class R93GlobalMetadataLocalizationTest extends TestCase
{
    public function test_global_metadata_and_profile_image_label_follow_the_active_locale(): void
    {
        $source = file_get_contents(resource_path('views/layouts/app.blade.php'));

        $this->assertIsString($source);
        $this->assertStringContainsString("Warqnaa | Social card games", $source);
        $this->assertStringContainsString("Warqnaa | منصة ألعاب ورق عربية", $source);
        $this->assertStringContainsString("card games, Tarneeb, Hand, Banakel, Baloot, Trix, Tawla, Warqnaa", $source);
        $this->assertStringContainsString("ألعاب ورق, طرنيب, هاند, بناكل, بلوت, تركس, طاولة, Warqnaa", $source);
        $this->assertStringContainsString("'en' ? 'en' : 'ar'", $source);
        $this->assertStringContainsString("A polished social card-game platform", $source);
        $this->assertStringContainsString("منصة ألعاب ورق عربية اجتماعية احترافية", $source);
        $this->assertStringContainsString("\$t('الصورة الشخصية','Profile picture')", $source);
        $this->assertStringNotContainsString('"inLanguage":"ar","description":"منصة ألعاب ورق عربية اجتماعية احترافية"', $source);
        $this->assertStringNotContainsString('alt="avatar"', $source);
    }
}
