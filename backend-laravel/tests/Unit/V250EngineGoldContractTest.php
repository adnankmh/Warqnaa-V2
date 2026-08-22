<?php

namespace Tests\Unit;

use App\Services\GameEngine\EngineRegistry;
use App\Services\GameEngine\GameFactory;
use Tests\TestCase;

class V250EngineGoldContractTest extends TestCase
{
    public function test_every_customer_engine_is_registered_for_gold_certification(): void
    {
        $configured = config('warqna_engine_gold.engines');
        $registered = array_keys(EngineRegistry::all());
        sort($configured);
        sort($registered);

        $this->assertSame($configured, $registered);
        foreach (EngineRegistry::all() as $key => $metadata) {
            $this->assertSame('r13_engine_gold_v1', $metadata['engine_certification'], $key);
            $this->assertTrue($metadata['server_authoritative'], $key);
            $this->assertNotEmpty($metadata['actions'], $key);
        }
    }

    public function test_global_adapter_preserves_a_replayable_seed_and_advertises_only_valid_moves(): void
    {
        $players = ['gold:p0', 'gold:p1', 'gold:p2', 'gold:p3'];
        $rules = GameFactory::make('trix');
        $state = $rules->initialState($players, ['seed' => 2501313, 'single_round' => true]);

        $this->assertSame(2501313, $state['_global_engine']['seed']);
        $this->assertSame('r13_engine_gold_v1', $state['engine_certification']);
        $actions = $rules->availableActions($state, $state['turn']);
        $this->assertNotEmpty($actions);
        foreach ($actions as $action) {
            $type = $action['type'];
            unset($action['type'], $action['label'], $action['reason']);
            $this->assertTrue($rules->validate($state, $state['turn'], $type, $action), $type);
        }
    }

    public function test_release_profile_certifies_thousands_of_matches_per_engine(): void
    {
        $this->assertGreaterThanOrEqual(2000, config('warqna_engine_gold.profiles.release.matches_per_engine'));
        $this->assertGreaterThanOrEqual(5000, config('warqna_engine_gold.profiles.nightly.matches_per_engine'));
        $this->assertCount(20, config('warqna_engine_gold.engines'));
    }
}
