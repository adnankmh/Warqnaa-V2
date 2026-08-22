<?php
/**
 * Warqnaa R8 deep rules audit.
 * Standalone: no Composer/Laravel boot required.
 */
$engineBase = dirname(__DIR__) . '/app/Services/GameEngine';
require_once $engineBase.'/TarneebStandalone/TarneebEngine.php';
require_once $engineBase.'/GlobalEngines/SaudiHandEngine.php';
require_once $engineBase.'/GlobalEngines/HandPartnershipEngine.php';
require_once $engineBase.'/GlobalEngines/BanakilEngine.php';

use App\Services\GameEngine\TarneebStandalone\TarneebEngine;

function r8assert(bool $ok,string $message): void {
    if(!$ok){fwrite(STDERR,"[FAIL] $message\n");exit(1);} echo "[PASS] $message\n";
}
function r8players(int $n): array { $out=[]; for($i=0;$i<$n;$i++) $out[]=['id'=>'p'.$i,'name'=>'P'.$i,'bot'=>false]; return $out; }

class R8HandEngine extends SaudiHandEngine {
    public function scoreState(array $state,string $winner,bool $fullHand): array { return $this->scoreRummyRound($state,$winner,$fullHand); }
    public function validMeld(array $cards): bool { return $this->isValidMeld($cards); }
    public function openingValue(array $cards): int { return $this->meldValue($cards); }
}
class R8PartnerHandEngine extends HandPartnershipEngine {
    public function scoreState(array $state,string $winner,bool $fullHand): array { return $this->scoreRummyRound($state,$winner,$fullHand); }
}
class R8BanakilEngine extends BanakilEngine {
    public function scoreState(array $state,string $winner,bool $fullHand): array { return $this->scoreBanakilRound($state,$winner,$fullHand); }
    public function validMeld(array $cards): bool { return $this->isValidMeld($cards); }
}

// --- Tarneeb official-style scoring and trick continuity ---
$tarneeb = new TarneebEngine();
$players = [
    ['id'=>'p0','name'=>'P0','bot'=>false],['id'=>'p1','name'=>'P1','bot'=>false],
    ['id'=>'p2','name'=>'P2','bot'=>false],['id'=>'p3','name'=>'P3','bot'=>false],
];
$scoreMethod = new ReflectionMethod(TarneebEngine::class, 'scoreRound');
$base = $tarneeb->newGameWithTarget($players,41,208,['dealPolicy'=>'random','singleRound'=>false]);
$case=$base; $case['scores']=[0,0]; $case['bid']=['seat'=>0,'team'=>0,'amount'=>7,'passed'=>[false,false,false,false],'history'=>[]]; $case['roundTricks']=[8,5];
$out=$scoreMethod->invoke($tarneeb,$case);
r8assert($out['scores']===[8,0],'Tarneeb made contract scores only the bidding team');
$case=$base; $case['scores']=[0,0]; $case['bid']=['seat'=>0,'team'=>0,'amount'=>8,'passed'=>[false,false,false,false],'history'=>[]]; $case['roundTricks']=[7,6];
$out=$scoreMethod->invoke($tarneeb,$case);
r8assert($out['scores']===[-8,6],'Tarneeb failed contract deducts bid and credits opponent tricks');
$case=$base; $case['scores']=[0,0]; $case['bid']=['seat'=>0,'team'=>0,'amount'=>7,'passed'=>[false,false,false,false],'history'=>[]]; $case['roundTricks']=[13,0];
$out=$scoreMethod->invoke($tarneeb,$case);
r8assert($out['scores']===[16,0],'Tarneeb 13-trick sweep without bid 13 scores 16');
$case=$base; $case['scores']=[0,0]; $case['bid']=['seat'=>0,'team'=>0,'amount'=>13,'passed'=>[false,false,false,false],'history'=>[]]; $case['roundTricks']=[13,0];
$out=$scoreMethod->invoke($tarneeb,$case);
r8assert($out['scores']===[26,0],'Tarneeb bid 13 and sweep scores 26');
$case=$base; $case['scores']=[0,0]; $case['bid']=['seat'=>0,'team'=>0,'amount'=>13,'passed'=>[false,false,false,false],'history'=>[]]; $case['roundTricks']=[12,1];
$out=$scoreMethod->invoke($tarneeb,$case);
r8assert($out['scores']===[-16,1],'Tarneeb failed bid 13 deducts 16');
$case=$base; $case['scores']=[0,0]; $case['rules']['singleRound']=true; $case['bid']=['seat'=>0,'team'=>0,'amount'=>7,'passed'=>[false,false,false,false],'history'=>[]]; $case['roundTricks']=[8,5];
$out=$scoreMethod->invoke($tarneeb,$case);
r8assert($out['phase']==='game_over' && $out['winnerTeam']===0,'Tarneeb single-round mode ends after scoring one round');

$play=$tarneeb->newGameWithTarget($players,41,209,['dealPolicy'=>'random']);
$turn=(int)$play['currentSeat'];
$tarneebId=$play['players'][$turn]['id']; $play=$tarneeb->bid($play,$tarneebId,7);
for($guard=0;$guard<8 && $play['phase']==='bidding';$guard++){
    $seat=(int)$play['currentSeat']; $play=$tarneeb->bid($play,$play['players'][$seat]['id'],null);
}
if($play['phase']==='choose_trump') $play=$tarneeb->chooseTrump($play,$play['players'][(int)$play['currentSeat']]['id'],'H');
for($i=0;$i<4;$i++){
    $seat=(int)$play['currentSeat']; $legal=$tarneeb->legalCards($play,$seat); $play=$tarneeb->playCard($play,$play['players'][$seat]['id'],$legal[0]);
}
$last=end($play['completedTricks']);
r8assert($play['phase']==='playing' && (int)$play['currentSeat']===(int)$last['winnerSeat'],'Tarneeb trick winner immediately leads the next trick');

// --- Hand draw/fire, opening, scoring ---
$hand = new R8HandEngine();
$state=$hand->newGame(r8players(2),['seed'=>208]);
r8assert(count($state['hands']['p0'])===15 && count($state['hands']['p1'])===14,'Hand deals 15 to starter and 14 to others');
$state=$hand->applyAction($state,'p0',['type'=>'discard','card'=>$state['hands']['p0'][0]]);
r8assert($state['phase']==='draw' && $state['players'][$state['currentIndex']]['id']==='p1','Hand starter discards extra card before normal draw cycle');
$state['currentIndex']=1; $state['phase']='draw'; $state['discard']=['A_S'];
$state['hands']['p1']=['A_C','A_D','10_H','J_H','Q_H','2_C','3_D'];
$actions=$hand->availableActions($state,'p1');
r8assert((bool)array_filter($actions,fn($a)=>($a['type']??'')==='draw_discard'),'Hand exposes fire-pile draw when a legal meld is available');
$state=$hand->applyAction($state,'p1',['type'=>'draw_discard']);
$blocked=false; try{$hand->applyAction($state,'p1',['type'=>'discard','card'=>'2_C']);}catch(Throwable $e){$blocked=true;}
r8assert($blocked,'Hand forbids ending the turn immediately after drawing from fire pile');
$state=$hand->applyAction($state,'p1',['type'=>'meld_many','groups'=>[['A_C','A_D','A_S'],['10_H','J_H','Q_H']]]);
r8assert(empty($state['rummyTurnMeta']['p1']['must_meld']),'Hand valid meld clears fire-pile mandatory-meld flag');
$state=$hand->applyAction($state,'p1',['type'=>'discard','card'=>'2_C']);
r8assert($state['phase']==='draw','Hand allows discard after satisfying fire-pile meld rule');
r8assert($hand->openingValue(['A_C','A_D','A_S'])===33,'Hand opening values Ace as 11');
r8assert($hand->openingValue(['10_C','J_C','Q_C'])===30,'Hand face-card opening values are 10 each');

$scoreState=$hand->newGame(r8players(2),['seed'=>210]);
$scoreState['scores']=['p0'=>0,'p1'=>0]; $scoreState['hands']['p0']=[]; $scoreState['hands']['p1']=['A_C','JOKER_R','10_C','2_C'];
$scoreState['melds']['p1']=[['cards'=>['3_C','4_C','5_C'],'value'=>12]];
$out=$hand->scoreState($scoreState,'p0',false);
r8assert((int)$out['scores']['p0']===-30 && (int)$out['scores']['p1']===38,'Hand residual scoring uses A=11, Joker=15 and normal winner -30');
$scoreState=$hand->newGame(r8players(2),['seed'=>211]);
$scoreState['scores']=['p0'=>0,'p1'=>0]; $scoreState['hands']['p0']=[]; $scoreState['hands']['p1']=['A_C','JOKER_R','10_C','2_C']; $scoreState['melds']['p1']=[];
$out=$hand->scoreState($scoreState,'p0',false);
r8assert((int)$out['scores']['p1']===138,'Hand adds 100 penalty to a player who never laid down');
$scoreState=$hand->newGame(r8players(2),['seed'=>212]);
$scoreState['scores']=['p0'=>0,'p1'=>0]; $scoreState['hands']['p0']=[]; $scoreState['hands']['p1']=['A_C','JOKER_R','10_C','2_C']; $scoreState['melds']['p1']=[];
$out=$hand->scoreState($scoreState,'p0',true);
r8assert((int)$out['scores']['p0']===-60 && (int)$out['scores']['p1']===276,'Hand full-hand finish doubles losing penalties and awards -60');

$partner=new R8PartnerHandEngine(); $scoreState=$partner->newGame(r8players(4),['seed'=>213]);
$scoreState['scores']=[0=>0,1=>0]; $scoreState['hands']['p0']=[]; $scoreState['hands']['p2']=['A_C','K_C'];
$scoreState['hands']['p1']=['10_C']; $scoreState['hands']['p3']=['9_C']; $scoreState['melds']['p1']=[['cards'=>['3_C','4_C','5_C'],'value'=>12]]; $scoreState['melds']['p3']=[['cards'=>['6_C','7_C','8_C'],'value'=>21]];
$out=$partner->scoreState($scoreState,'p0',false);
r8assert((int)$out['scores'][0]===-30 && (int)$out['scores'][1]===19,'Partnership Hand gives winner team one -30 bonus and sums only losing-team hands');

// --- Banakil partnership / 1v1 / wild-card rules ---
$banakil=new R8BanakilEngine(); $b=$banakil->newGame(r8players(2),['seed'=>214,'targetScore'=>150]);
r8assert((int)$b['config']['targetScore']===150 && count($b['hands']['p0'])===19 && count($b['hands']['p1'])===18,'Banakil 1v1 supports 150 target and 19/18 deal');
r8assert($banakil->validMeld(['3_C','4_C','JOKER_R']),'Banakil accepts one Joker in a legal run');
r8assert(!$banakil->validMeld(['3_C','JOKER_R','JOKER_B']),'Banakil rejects two Jokers in one meld');
r8assert(!$banakil->validMeld(['3_C','2_D','2_H']),'Banakil rejects two Banakil/2 wild cards in one meld');

$b=$banakil->newGame(r8players(2),['seed'=>215,'targetScore'=>150]);
$b['phase']='discard';$b['starterDiscardPending']=false;$b['currentIndex']=0;$b['hands']['p0']=['4_C','9_D'];$b['melds']['p0']=[['cards'=>['3_C','JOKER_R','5_C'],'value'=>0]];
$b=$banakil->applyAction($b,'p0',['type'=>'replace_wild','target_player'=>'p0','meld_index'=>0,'card'=>'4_C']);
r8assert($b['melds']['p0'][0]['cards']===['3_C','4_C','5_C'] && in_array('JOKER_R',$b['hands']['p0'],true),'Banakil can replace a Joker with its natural card and return Joker to hand');

$b=$banakil->newGame(r8players(4),['seed'=>216,'targetScore'=>222]); $b['scores']=[0=>0,1=>0]; $b['hands']['p0']=[];
foreach(['p1','p2','p3'] as $pid) $b['hands'][$pid]=['9_C']; $b['melds']=[];
$out=$banakil->scoreState($b,'p0',true);
r8assert((float)$out['scores'][0]===102.0 && (float)$out['scores'][1]===0.0,'Banakil clean full-hand finish scores 102 when opponents have no melds');
$b=$banakil->newGame(r8players(4),['seed'=>217,'targetScore'=>222]); $b['scores']=[0=>0,1=>0]; $b['hands']['p0']=[];
foreach(['p1','p2','p3'] as $pid) $b['hands'][$pid]=['9_C']; $b['melds']['p1']=[['cards'=>['3_C','4_C','5_C'],'value'=>0]];
$out=$banakil->scoreState($b,'p0',true);
r8assert((float)$out['scores'][0]===51.0 && (float)$out['scores'][1]===0.0,'Banakil full-hand finish scores 51 when opponents already melded');

echo "\n[PASS] Warqnaa R8 deep Tarneeb/Hand/Banakil rules audit completed.\n";
