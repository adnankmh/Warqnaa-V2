<?php
namespace App\Services\GameEngine;

/**
 * Secure server-side deck construction.
 * R9.1 can select a stronger *symmetric* candidate deal for casual card engines:
 * every seat is scored by the same hand-quality formula and no user/seat/name is
 * favoured. The underlying candidates are always generated with random_int().
 */
class DeckFactory
{
    public static function standard52(bool $balanced=false): array
    {
        $deck=self::rawStandard52();
        return self::secureShuffle($deck);
    }

    public static function pinochle(): array
    {
        $deck=[];
        for($i=0;$i<2;$i++)
            foreach(['clubs','diamonds','spades','hearts'] as $s)
                foreach(['A','K','Q','J','10','9','8','7','6','5','4','3','2'] as $r)
                    $deck[]=new Card($s,$r);
        $deck[]=new Card('joker','JOKER');
        $deck[]=new Card('joker','JOKER');
        return self::secureShuffle($deck);
    }

    /**
     * Symmetric playable-hand selector. It never targets a player and never
     * changes a card after the deal. Instead it securely shuffles whole decks,
     * evaluates every seat with the same formula, and keeps the candidate whose
     * weakest hand is strongest. This preserves fairness while reducing dead
     * casual hands across all seats.
     *
     * @return array<string,array<int,Card>>
     */
    public static function balancedHands(array $players, int $cardsPerPlayer=13, ?string $nonce=null): array
    {
        return self::balancedDeal($players,$cardsPerPlayer,$nonce)['hands'];
    }

    /** @return array{hands:array<string,array<int,Card>>,deck:array<int,Card>,quality:float} */
    public static function balancedDeal(array $players,int $cardsPerPlayer=13,?string $nonce=null,int $attempts=48): array
    {
        $players=array_values(array_unique(array_map('strval',$players)));
        if(!$players || $cardsPerPlayer<1 || count($players)*$cardsPerPlayer>52){
            return ['hands'=>array_fill_keys($players,[]),'deck'=>self::standard52(false),'quality'=>0.0];
        }
        $attempts=max(1,min(96,$attempts));
        $best=null; $bestMinimum=-INF;
        for($try=0;$try<$attempts;$try++){
            $deck=self::secureShuffle(self::rawStandard52());
            $hands=[]; foreach($players as $p)$hands[$p]=[];
            for($round=0;$round<$cardsPerPlayer;$round++){
                foreach($players as $p){ if($deck) $hands[$p][]=array_shift($deck); }
            }
            $minimum=INF;
            foreach($hands as $hand) $minimum=min($minimum,self::handQuality($hand));
            if($minimum>$bestMinimum){
                $bestMinimum=$minimum;
                $best=['hands'=>$hands,'deck'=>array_values($deck),'quality'=>(float)$minimum];
            }
            if($minimum>=self::targetMinimumQuality($cardsPerPlayer)) break;
        }
        return $best ?? ['hands'=>array_fill_keys($players,[]),'deck'=>self::standard52(false),'quality'=>0.0];
    }

    /** @param array<int,Card> $hand */
    private static function handQuality(array $hand): float
    {
        $rank=['A'=>4.0,'K'=>3.0,'Q'=>2.0,'J'=>1.25,'10'=>0.75];
        $score=0.0; $premium=0; $suits=[];
        foreach($hand as $card){
            $score+=$rank[$card->rank] ?? 0.0;
            if(in_array($card->rank,['A','K'],true)) $premium++;
            if($card->suit!=='joker') $suits[$card->suit]=($suits[$card->suit]??0)+1;
        }
        // A natural long suit is useful in trick-taking games, but its bonus is
        // deliberately small so high-card strength remains the primary signal.
        $longest=$suits?max($suits):0;
        $score+=min(1.4,max(0,$longest-4)*0.35);
        $score+=min(1.0,$premium*0.2);
        return $score;
    }

    private static function targetMinimumQuality(int $cardsPerPlayer): float
    {
        if($cardsPerPlayer>=13) return 7.5;
        if($cardsPerPlayer>=10) return 5.0;
        if($cardsPerPlayer>=7) return 3.0;
        return 1.0;
    }

    /** @return array<int,Card> */
    private static function rawStandard52(): array
    {
        $deck=[];
        foreach(['clubs','diamonds','spades','hearts'] as $s)
            foreach(['A','K','Q','J','10','9','8','7','6','5','4','3','2'] as $r)
                $deck[]=new Card($s,$r);
        return $deck;
    }

    /** @template T @param array<int,T> $items @return array<int,T> */
    public static function secureShuffle(array $items): array
    {
        for($i=count($items)-1;$i>0;$i--){
            $j=random_int(0,$i);
            [$items[$i],$items[$j]]=[$items[$j],$items[$i]];
        }
        return array_values($items);
    }
}
