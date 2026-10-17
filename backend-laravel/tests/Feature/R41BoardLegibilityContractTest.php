<?php

namespace Tests\Feature;

use Tests\TestCase;

class R41BoardLegibilityContractTest extends TestCase
{
    public function test_flutter_board_surfaces_keep_readable_labels_and_semantic_piece_state(): void
    {
        $board=file_get_contents(base_path('../flutter_app/lib/r41_board_legibility.dart'));

        $this->assertStringContainsString("text('النقطة \$number', 'Point \$number')",$board);
        $this->assertStringContainsString("text('\$count أحجار', '\$count checkers')",$board);
        $this->assertStringContainsString("text('حجر في البيت', 'Piece at home')",$board);
        $this->assertStringContainsString("text('حجر في الأمان', 'Piece safe')",$board);
        $this->assertStringContainsString("'حجر عند \$progress'",$board);
        $this->assertStringContainsString("'Piece at \$progress'",$board);
        $this->assertDoesNotMatchRegularExpression(
            '/fontSize:\\s*(?:[0-9](?:\\.[0-9]+)?|10(?:\\.[0-9]+)?)(?![0-9])/',
            $board
        );
    }
}
