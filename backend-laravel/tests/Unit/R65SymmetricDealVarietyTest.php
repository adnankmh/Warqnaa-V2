<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/TrixEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/TrixComplexEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/BalootEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/BanakilEngine.php';

class R65SymmetricDealVarietyTest extends TestCase
{
    private function players(): array
    {
        return array_map(fn (int $i): array => ['id'=>'seat:'.$i,'name'=>'Seat '.$i,'bot'=>$i % 2 === 1], range(0, 3));
    }

    private function physicalDeck(string $deckType): array
    {
        $ranks = $deckType === 'baloot32'
            ? ['7','8','9','J','Q','K','10','A']
            : ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
        $cards=[];
        foreach (['C','D','S','H'] as $suit) {
            foreach ($ranks as $rank) {
                $cards[]=$rank.'_'.$suit;
                if ($deckType === 'double-joker') $cards[]=$rank.'_'.$suit;
            }
        }
        if ($deckType === 'double-joker') array_push($cards,'JOKER_R','JOKER_B');
        sort($cards);
        return $cards;
    }

    public function test_playable_casual_deals_are_symmetric_replayable_and_preserve_every_physical_card(): void
    {
        $cases=[
            [new \TrixEngine(),'52'],
            [new \TrixComplexEngine(),'52'],
            [new \BalootEngine(),'baloot32'],
            [new \SaudiHandEngine(),'double-joker'],
            [new \HandPartnershipEngine(),'double-joker'],
            [new \BanakilEngine(),'double-joker'],
        ];
        foreach ($cases as [$engine,$deckType]) {
            $fingerprints=[];
            for($seed=650001;$seed<=650008;$seed++) {
                $options=['seed'=>$seed,'casualDealAttempts'=>8];
                $state=$engine->newGame($this->players(),$options);
                $quality=$state['config']['dealQuality'] ?? null;
                $this->assertSame('symmetric_casual_balanced', $quality['policy'] ?? null);
                $this->assertSame(8, $quality['attempts']);
                $cards=$state['deck'];
                foreach ($state['hands'] as $hand) {
                    $this->assertCount($deckType === 'baloot32' ? 8 : ($deckType === '52' ? 13 : (int) $state['config']['cardsEach'] + (count($hand) === (int)$state['config']['cardsEach'] + 1 ? 1 : 0)), $hand);
                    $cards=array_merge($cards,$hand);
                }
                $cards=array_merge($cards,$state['discard']);
                sort($cards);
                $this->assertSame($this->physicalDeck($deckType),$cards);
                $again=$engine->newGame($this->players(),$options);
                $this->assertSame($state['hands'],$again['hands']);
                $this->assertSame($state['deck'],$again['deck']);
                $fingerprints[hash('sha256',json_encode($state['hands']))]=true;
            }
            $this->assertGreaterThanOrEqual(7,count($fingerprints),'Casual shuffles must stay varied across seeds');
        }
    }

    public function test_ranked_and_unbalanced_deals_remain_unconditioned_and_identical_with_the_same_seed(): void
    {
        foreach ([new \TrixEngine(),new \BalootEngine(),new \SaudiHandEngine(),new \BanakilEngine()] as $engine) {
            $seed=650090;
            $random=$engine->newGame($this->players(),['seed'=>$seed,'dealPolicy'=>'random']);
            $ranked=$engine->newGame($this->players(),['seed'=>$seed,'ranked'=>true]);
            $competition=$engine->newGame($this->players(),['seed'=>$seed,'match_mode'=>'tournament']);
            $this->assertSame($random['hands'],$ranked['hands']);
            $this->assertSame($random['hands'],$competition['hands']);
            $this->assertArrayNotHasKey('dealQuality',$ranked['config']);
            $this->assertArrayNotHasKey('dealQuality',$competition['config']);
        }
    }
}
