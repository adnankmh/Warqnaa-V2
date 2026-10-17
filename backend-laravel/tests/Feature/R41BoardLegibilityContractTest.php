<?php

namespace Tests\Feature;

use Tests\TestCase;

class R41BoardLegibilityContractTest extends TestCase
{
    public function test_flutter_board_surfaces_keep_readable_labels_and_semantic_piece_state(): void
    {
        $source=file_get_contents(base_path('../flutter_app/lib/main.dart'));
        $start=strpos($source,'Widget _backgammonBoard');
        $end=strpos($source,'Future<void> _reorderServerHand');

        $this->assertNotFalse($start);
        $this->assertNotFalse($end);
        $board=substr($source,$start,$end-$start);

        $this->assertStringContainsString("Semantics(label: 'Point \$number'",$board);
        $this->assertStringContainsString("Semantics(label: '\$count checkers'",$board);
        $this->assertStringContainsString("_roomText('حجر في البيت', 'Piece at home')",$board);
        $this->assertStringContainsString("_roomText('حجر في الأمان', 'Piece safe')",$board);
        $this->assertStringContainsString("_roomText('حجر عند \$progress', 'Piece at \$progress')",$board);
        $this->assertDoesNotMatchRegularExpression(
            '/fontSize:\\s*(?:[0-9](?:\\.[0-9]+)?|10(?:\\.[0-9]+)?)(?![0-9])/',
            $board
        );
    }
}
