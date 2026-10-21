<?php

namespace Tests\Feature;

use App\Services\GameEngine\GlobalCardEngineRules;
use Tests\TestCase;

class R62RummyStarterProjectionTest extends TestCase
{
    public function test_adapter_projects_the_actual_dealer_right_starter(): void
    {
        foreach(['saudi_hand'=>14,'banakil'=>18] as $key=>$cardsEach){
            $engine=new GlobalCardEngineRules($key);
            $state=$engine->initialState(['p0','p1','p2','p3'],[
                'seed'=>6204,
                'dealer_index'=>1,
            ]);
            $global=$state['_global_engine'];
            $this->assertSame(1,$global['dealerIndex'],$key);
            $this->assertSame(2,$global['currentIndex'],$key);
            $this->assertSame('p2',$state['turn'],$key);
            $this->assertCount($cardsEach+1,$state['hands']['p2'],$key);
        }
    }
}
