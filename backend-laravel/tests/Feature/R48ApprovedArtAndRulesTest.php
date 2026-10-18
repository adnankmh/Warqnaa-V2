<?php

namespace Tests\Feature;

use App\Services\GameEngine\GameFactory;
use App\Services\Commerce\CommerceCatalogService;
use App\Support\R48TableArtwork;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R48ApprovedArtAndRulesTest extends TestCase
{
    use RefreshDatabase;

    public function test_banakil_rejects_fractional_or_coerced_fire_counts_without_mutation(): void
    {
        $engine=GameFactory::make('banakil');
        $state=$engine->initialState(['user:1','user:2','user:3','user:4'],['seed'=>4801]);
        $g=$state['_global_engine'];$g['currentIndex']=0;$g['phase']='draw';$g['starterDiscardPending']=false;
        $g['discard']=array_merge($g['discard'],array_splice($g['deck'],0,4));
        $state['_global_engine']=$g;$state['turn']='user:1';
        foreach([2.9,'2.9','2foo',true,false,null,[],['2'],'99999999999999999999'] as $count) {
            $this->assertFalse($engine->validate($state,'user:1','draw_discard_stack',['count'=>$count]));
            $rejected=$engine->apply($state,'user:1','draw_discard_stack',['count'=>$count]);
            $this->assertSame($g,$rejected['_global_engine']);
        }
        foreach([2,'2'] as $count) {
            $this->assertTrue($engine->validate($state,'user:1','draw_discard_stack',['count'=>$count]));
            $after=$engine->apply($state,'user:1','draw_discard_stack',['count'=>$count])['_global_engine'];
            $this->assertSame(array_slice($g['discard'],0,-2),$after['discard']);
            $this->assertSame(array_merge($g['hands']['user:1'],array_slice($g['discard'],-2)),$after['hands']['user:1']);
        }
    }

    public function test_approved_orientations_and_paired_backs_use_existing_identities(): void
    {
        foreach(R48TableArtwork::DESIGNS as $key=>$design) {
            $this->assertSame($design,R48TableArtwork::design('r61_cardback_'.$key));
            foreach([false,true] as $portrait) {
                $path=R48TableArtwork::url($key,$portrait);
                $this->assertFileExists(public_path($path));
                $this->assertSame('image/webp',getimagesize(public_path($path))['mime']);
            }
        }
        $this->assertNull(R48TableArtwork::url('unknown-item'));
    }

    public function test_cash_categories_are_explicit_and_do_not_invent_weekly_offers(): void
    {
        $catalog=app(CommerceCatalogService::class)->catalog();
        $this->assertSame(['featured','tokens'],$catalog['packages'][0]['categories']);
        foreach($catalog['packages'] as $package) {
            $this->assertContains('tokens',$package['categories']);
            $this->assertNotContains('weekly',$package['categories']);
        }
    }
}
