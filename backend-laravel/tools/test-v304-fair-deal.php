<?php
require_once __DIR__.'/../app/Services/GameEngine/Card.php';
require_once __DIR__.'/../app/Services/GameEngine/DeckFactory.php';

use App\Services\GameEngine\DeckFactory;

$iterations=max(100,(int)(getenv('WARQNAA_FAIR_DEAL_SCENARIOS') ?: 3000));
$players=['p1','p2','p3','p4'];
$fingerprints=[];
$qualitySamples=[];
$seatPremium=array_fill_keys($players,0);
$seatCards=array_fill_keys($players,0);
$rankWeight=['A'=>4,'K'=>3,'Q'=>2,'J'=>1,'10'=>1];

for($i=0;$i<$iterations;$i++){
    $deal=DeckFactory::balancedDeal($players,13,null,48);
    $hands=$deal['hands'] ?? [];
    $all=[];
    foreach($players as $p){
        if(count($hands[$p] ?? [])!==13){ fwrite(STDERR,"[FAIL] $p did not receive 13 cards at scenario $i\n"); exit(1); }
        foreach($hands[$p] as $card){
            $id=$card->id(); $all[]=$id;
            $seatPremium[$p]+=$rankWeight[$card->rank] ?? 0;
            $seatCards[$p]++;
        }
    }
    if(count($all)!==52 || count(array_unique($all))!==52){ fwrite(STDERR,"[FAIL] duplicate/missing card at scenario $i\n"); exit(1); }
    sort($all);
    // Fingerprint the actual seat assignment, not merely the common deck set.
    $parts=[]; foreach($players as $p){ $ids=array_map(fn($c)=>$c->id(),$hands[$p]); sort($ids); $parts[]=implode(',',$ids); }
    $fingerprints[hash('sha256',implode('|',$parts))]=true;
    $qualitySamples[]=(float)($deal['quality'] ?? 0);
}
$unique=count($fingerprints);
if($unique < (int)($iterations*0.98)){ fwrite(STDERR,"[FAIL] insufficient distribution diversity: $unique/$iterations\n"); exit(1); }
$means=[]; foreach($players as $p) $means[$p]=$seatPremium[$p]/max(1,$seatCards[$p]);
$spread=max($means)-min($means);
if($spread>0.08){ fwrite(STDERR,'[FAIL] long-run seat strength drift: '.json_encode($means)."\n"); exit(1); }
$minQ=min($qualitySamples); $avgQ=array_sum($qualitySamples)/count($qualitySamples);
printf("[PASS] B304 FAIR DEAL: %d secure scenarios, %d unique assignments (%.2f%%), no duplicates, 13 cards/seat, seat-drift %.4f, min quality %.2f, avg quality %.2f.\n",
    $iterations,$unique,$unique*100/$iterations,$spread,$minQ,$avgQ);
