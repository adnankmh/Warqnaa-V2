<?php

namespace Tests\Unit;

use App\Services\GameEngine\GlobalCardEngineRules;
use PHPUnit\Framework\TestCase;

class R66RankedDealBoundaryTest extends TestCase
{
    private function players(): array
    {
        return ['user:601', 'user:602', 'user:603', 'user:604'];
    }

    public function test_ranked_and_tournaments_keep_original_random_deals_on_adapter_boundary(): void
    {
        $games = [
            'syrian_tarneeb', 'tarneeb_400', 'trix', 'trix_partner',
            'trix_complex', 'baloot', 'hand', 'hand_partner',
            'saudi_hand', 'banakil', 'pinochle',
        ];
        foreach ($games as $game) {
            $engine = new GlobalCardEngineRules($game);
            $seed = 660066;
            $random = $engine->initialState($this->players(), [
                'seed'=>$seed, 'dealPolicy'=>'random',
            ]);
            $ranked = $engine->initialState($this->players(), [
                'seed'=>$seed, 'ranked'=>true, 'competitive'=>true,
                'match_mode'=>'ranked', 'dealPolicy'=>'random',
            ]);
            $tournament = $engine->initialState($this->players(), [
                'seed'=>$seed, 'competitive'=>true,
                'match_mode'=>'tournament', 'dealPolicy'=>'random',
            ]);
            $rankedWithoutExplicitPolicy = $engine->initialState($this->players(), [
                'seed'=>$seed, 'ranked'=>true,
            ]);
            foreach ([$ranked,$tournament,$rankedWithoutExplicitPolicy] as $protected) {
                $this->assertSame($random['_global_engine']['hands'], $protected['_global_engine']['hands'], $game);
                $this->assertSame($random['_global_engine']['deck'], $protected['_global_engine']['deck'], $game);
                $this->assertArrayNotHasKey('dealQuality', $protected['_global_engine']['config'], $game);
            }
            $casual = $engine->initialState($this->players(), ['seed'=>$seed,'casualDealAttempts'=>4]);
            $this->assertNotEmpty($casual['_global_engine']['config']['dealQuality'] ?? null, $game);
        }
    }

    public function test_official_ranked_and_tournament_creation_set_random_policy_before_initial_state(): void
    {
        $sourceRoot=dirname(__DIR__, 2).'/app/Services/Competitive/';
        $ranked=file_get_contents($sourceRoot.'CompetitiveMatchmakingService.php');
        $tournament=file_get_contents($sourceRoot.'TournamentBracketService.php');
        $this->assertIsString($ranked);
        $this->assertIsString($tournament);
        $this->assertStringContainsString("'ranked'=>true,'competitive'=>true,'match_mode'=>'ranked','dealPolicy'=>'random'", $ranked);
        $this->assertStringContainsString("'competitive'=>true,'match_mode'=>'tournament','dealPolicy'=>'random'", $tournament);
    }
}
