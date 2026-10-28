<?php

namespace Tests\Feature;

use Tests\TestCase;

class R112AuthoritativeThemePreferenceTest extends TestCase
{
    public function test_server_theme_and_admin_lock_cannot_be_overridden_by_stale_browser_state(): void
    {
        $layout = file_get_contents(resource_path('views/layouts/app.blade.php'));
        $javascript = file_get_contents(public_path('assets/js/app.js'));

        $this->assertIsString($layout);
        $this->assertIsString($javascript);
        $this->assertStringContainsString('data-theme-locked="{{ $forceGlobalTheme ? \'1\' : \'0\' }}"', $layout);
        $this->assertStringContainsString('data-theme-authority="{{ $currentUser ? \'server\' : \'local\' }}"', $layout);
        $this->assertStringContainsString("document.body?.dataset?.themeLocked==='1'", $javascript);
        $this->assertStringContainsString("body?.dataset?.themeLocked==='1'||body?.dataset?.themeAuthority==='server'", $javascript);
        $this->assertStringContainsString('localStorage.siteTheme=body.dataset.theme', $javascript);
        $this->assertStringContainsString('return false', $javascript);
    }

    public function test_theme_picker_persists_immediately_reports_failures_and_respects_admin_lock(): void
    {
        $settings = file_get_contents(resource_path('views/pages/settings.blade.php'));
        $controller = file_get_contents(app_path('Http/Controllers/PageController.php'));

        $this->assertIsString($settings);
        $this->assertIsString($controller);
        foreach ([
            "SiteSetting::getValue('default_theme','dark')",
            "SiteSetting::getValue('force_global_theme',false)",
            '$activeTheme=$forceGlobalTheme ? $globalTheme : $profileTheme;',
            "{{$forceGlobalTheme?'disabled':''}}",
            'data-theme-choice="{{$themeKey}}"',
            'aria-pressed="{{$activeTheme===$themeKey?',
            'aria-live="polite"',
            'window.saveThemePreference=async(theme)',
            "body:JSON.stringify({theme})",
            'if(!response.ok||payload.ok===false)',
            'window.setSiteTheme?.(previous)',
            'syncThemeControls(previous)',
            'الثيم مفروض من الإدارة',
            'The administrator has locked one theme',
        ] as $contract) {
            $this->assertStringContainsString($contract, $settings);
        }

        $this->assertStringContainsString(
            "'theme'=>'nullable|string|in:dark,light,green,gold,purple,classic'",
            $controller,
        );
        $this->assertStringContainsString('$p->active_site_theme=$data[\'theme\'];', $controller);
    }
}
