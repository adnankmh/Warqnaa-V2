<?php

namespace Tests\Feature;

use Tests\TestCase;

class R91GlobalActivityLocalizationTest extends TestCase
{
    public function test_activity_notifications_and_chat_have_server_rendered_english_contracts(): void
    {
        $layout = file_get_contents(resource_path('views/layouts/app.blade.php'));

        foreach ([
            'Club notifications',
            'Game invitations',
            'Open competitions',
            'Chat center',
            'Search chat',
            'Notification center',
            'Mark all read',
            'No new notifications.',
            'Messages and friends',
            'Toggle sound',
            'Leave game',
            'Log out',
            'Install app',
            'Close chat',
            'Type a message and press Enter',
        ] as $englishContract) {
            $this->assertStringContainsString($englishContract, $layout);
        }

        $this->assertStringContainsString("data_get(\$n->title,\$localeCode)", $layout);
        $this->assertStringContainsString("data_get(\$n->body,\$localeCode)", $layout);
        $this->assertStringContainsString("route('notifications.read',\$n)", $layout);
        $this->assertStringContainsString("route('notifications.delete',\$n)", $layout);
        $this->assertStringContainsString("route('rooms.leave',\$activeRoom->code)", $layout);
    }
}
