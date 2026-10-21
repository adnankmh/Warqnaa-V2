<?php

namespace Tests\Feature;

use App\Services\GameEngine\GlobalCardEngineRules;
use Tests\TestCase;

class R61HandModeIsolationTest extends TestCase
{
    public function test_factory_enables_escalation_only_for_saudi_hand(): void
    {
        foreach (['hand'=>false,'saudi_hand'=>true] as $key=>$escalates) {
            $engine=new GlobalCardEngineRules($key);
            $state=$engine->initialState(['p0','p1'],['seed'=>6102]);
            $this->assertSame($escalates,(bool)($state['_global_engine']['config']['openingEscalates'] ?? false),$key);
            $this->assertSame(51,$state['opening_threshold'],$key);
        }
    }
}
