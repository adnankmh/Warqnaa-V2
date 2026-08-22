<?php
namespace App\Http\Controllers;

use App\Models\Game;
use App\Services\Games\GameCatalog;

class GameController
{
    public function index()
    {
        $this->syncGameCatalog();
        $games=Game::where('active',true)->whereIn('key', GameCatalog::customerKeys())->orderBy('id')->get();
        $families=config('warqna_games_matrix.families',[]);
        $supported=config('warqna_games_matrix.supported',[]);
        return view('games.index',compact('games','families','supported'));
    }

    public function rules()
    {
        $this->syncGameCatalog();
        return view('games.rules',['games'=>Game::where('active',true)->whereIn('key', GameCatalog::customerKeys())->orderBy('key')->get(),'ruleGuide'=>config('warqna_game_rules',[])]);
    }

    private function syncGameCatalog(): void
    {
        try{
            foreach(GameCatalog::all() as $key=>$g){
                $game=Game::firstOrNew(['key'=>$key]);
                $isNew=!$game->exists;
                $game->fill([
                    'name'=>['ar'=>$g['ar'] ?? $key,'en'=>$g['en'] ?? $key],
                    'min_players'=>$g['min'] ?? 2,
                    'max_players'=>$g['max'] ?? 4,
                    'partnership'=>(bool)($g['partners'] ?? false),
                    'rules'=>['engine'=>$g['engine'] ?? 'generic','family'=>$g['family'] ?? 'training','icon'=>$g['icon'] ?? '🃏','targets'=>$g['targets'] ?? [],'summary'=>$g['summary'] ?? 'لعبة ورق احترافية'],
                ]);
                // Never undo a GUI admin deactivation just because a customer opens the games page.
                if($isNew) $game->active=true;
                $game->save();
            }
        }catch(\Throwable $e){}
    }
}
