<?php

namespace Tests\Feature;

use Tests\TestCase;

class R43SocialNavigationLegibilityContractTest extends TestCase
{
    public function test_social_navigation_keeps_readable_copy_and_real_destinations(): void
    {
        $source = file_get_contents(base_path('../flutter_app/lib/r6_1_world_class.dart'));

        $this->assertStringContainsString('class R61BottomNavigation extends StatelessWidget', $source);
        $this->assertStringContainsString('class R61SocialHubPage extends StatelessWidget', $source);
        $this->assertStringContainsString('showFriends(context, controller)', $source);
        $this->assertStringContainsString('R11SocialWorldPage(controller: controller)', $source);
        $this->assertStringContainsString('R11ClubsWorldPage(controller: controller)', $source);
        $this->assertStringContainsString('R61ProfilePage(controller: controller)', $source);
        $this->assertDoesNotMatchRegularExpression(
            '/fontSize:\\s*(?:[0-9](?:\\.[0-9]+)?|10(?:\\.[0-9]+)?)(?![0-9])/',
            $source
        );
    }
}
