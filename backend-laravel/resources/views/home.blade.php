@extends('layouts.app')
@section('title','Warqnaa | World-Class Social Card Gaming')
@section('content')
@php
  $isAuthed = auth()->check();
  $locale = app()->getLocale();
  $copy = [
    'ar'=>['k'=>'WORLD EXPERIENCE • B303','title'=>'طاولتك. عالمك. منافستك.','desc'=>'منصة ألعاب ورق اجتماعية مصممة لتشعر كمنتج عالمي: لعب خادمي عادل، منافسات، أصدقاء، أندية، تخصيص عميق وتجربة سريعة على الهاتف والويب.','play'=>'العب الآن','explore'=>'استكشف الألعاب','live'=>'مباشر الآن','games'=>'ألعابك المفضلة','gamesSub'=>'دخول سريع إلى ألعابك بدون قوائم مزدحمة.','all'=>'كل الألعاب','rooms'=>'غرف نشطة','events'=>'منافسات','engines'=>'محرك لعب','security'=>'حماية خادمية','social'=>'Social World','socialD'=>'أصدقاء، حضور مباشر، هدايا، متابعون وإعادات آمنة.','ranked'=>'الساحة التنافسية','rankedD'=>'MMR ومواسم وبطولات بنتيجة موثقة من الخادم.','custom'=>'تخصيص فاخر','customD'=>'ثيمات، طاولات، أغلفة، إطارات، بطاقات وإيموجي.','fair'=>'عدالة وأمان','fairD'=>'الحركة والنتيجة والاقتصاد تُحسم من الخادم، لا من جهاز اللاعب.','ready'=>'جاهز للعب','instant'=>'دخول سريع','multi'=>'6 لغات','themes'=>'15 ثيم'],
    'en'=>['k'=>'WORLD EXPERIENCE • B303','title'=>'Your table. Your world. Your competition.','desc'=>'A social card-gaming platform built to feel global: fair server-authoritative play, ranked competition, friends, clubs, deep customization, and a fast web/mobile experience.','play'=>'Play now','explore'=>'Explore games','live'=>'Live now','games'=>'Your favorite games','gamesSub'=>'Fast access to your games without crowded menus.','all'=>'All games','rooms'=>'Active rooms','events'=>'Competitions','engines'=>'game engines','security'=>'Server protection','social'=>'Social World','socialD'=>'Friends, live presence, gifts, follows and privacy-safe replays.','ranked'=>'Competitive Arena','rankedD'=>'MMR, seasons and tournaments settled by the server.','custom'=>'Premium customization','customD'=>'Themes, tables, covers, frames, card backs and reactions.','fair'=>'Fair play & security','fairD'=>'Turns, results and economy are decided server-side, not by the client.','ready'=>'Ready to play','instant'=>'Fast entry','multi'=>'6 languages','themes'=>'15 themes'],
    'de'=>['k'=>'WORLD EXPERIENCE • B303','title'=>'Dein Tisch. Deine Welt. Dein Wettbewerb.','desc'=>'Eine soziale Kartenplattform auf globalem Niveau: faires servergesteuertes Spiel, Ranglisten, Freunde, Clubs und umfangreiche Personalisierung.','play'=>'Jetzt spielen','explore'=>'Spiele entdecken','live'=>'Jetzt live','games'=>'Deine Lieblingsspiele','gamesSub'=>'Schneller Zugriff ohne überladene Menüs.','all'=>'Alle Spiele','rooms'=>'Aktive Räume','events'=>'Wettbewerbe','engines'=>'Spiel-Engines','security'=>'Server-Schutz','social'=>'Social World','socialD'=>'Freunde, Live-Präsenz, Geschenke und sichere Replays.','ranked'=>'Competitive Arena','rankedD'=>'MMR, Saisons und serverseitig bestätigte Turniere.','custom'=>'Premium-Anpassung','customD'=>'Themes, Tische, Cover, Rahmen, Kartenrückseiten und Reaktionen.','fair'=>'Fairplay & Sicherheit','fairD'=>'Züge, Ergebnisse und Wirtschaft werden serverseitig entschieden.','ready'=>'Spielbereit','instant'=>'Schneller Einstieg','multi'=>'6 Sprachen','themes'=>'15 Themes'],
    'tr'=>['k'=>'WORLD EXPERIENCE • B303','title'=>'Masan. Dünyan. Rekabetin.','desc'=>'Dünya standartlarında sosyal kart deneyimi: sunucu kontrollü adil oyun, dereceli rekabet, arkadaşlar, kulüpler ve derin kişiselleştirme.','play'=>'Şimdi oyna','explore'=>'Oyunları keşfet','live'=>'Şimdi canlı','games'=>'Favori oyunların','gamesSub'=>'Kalabalık menüler olmadan hızlı erişim.','all'=>'Tüm oyunlar','rooms'=>'Aktif odalar','events'=>'Müsabakalar','engines'=>'oyun motoru','security'=>'Sunucu koruması','social'=>'Social World','socialD'=>'Arkadaşlar, canlı durum, hediyeler ve güvenli tekrarlar.','ranked'=>'Competitive Arena','rankedD'=>'MMR, sezonlar ve sunucu onaylı turnuvalar.','custom'=>'Premium kişiselleştirme','customD'=>'Temalar, masalar, kapaklar, çerçeveler ve tepkiler.','fair'=>'Adil oyun & güvenlik','fairD'=>'Hamle, sonuç ve ekonomi sunucu tarafından belirlenir.','ready'=>'Oyuna hazır','instant'=>'Hızlı giriş','multi'=>'6 dil','themes'=>'15 tema'],
    'fr'=>['k'=>'WORLD EXPERIENCE • B303','title'=>'Votre table. Votre monde. Votre compétition.','desc'=>'Une plateforme de cartes sociale pensée au niveau mondial : jeu équitable piloté par le serveur, classement, amis, clubs et personnalisation profonde.','play'=>'Jouer maintenant','explore'=>'Découvrir les jeux','live'=>'En direct','games'=>'Vos jeux favoris','gamesSub'=>'Accès rapide sans menus encombrés.','all'=>'Tous les jeux','rooms'=>'Salles actives','events'=>'Compétitions','engines'=>'moteurs de jeu','security'=>'Protection serveur','social'=>'Social World','socialD'=>'Amis, présence en direct, cadeaux et replays respectueux de la vie privée.','ranked'=>'Competitive Arena','rankedD'=>'MMR, saisons et tournois validés côté serveur.','custom'=>'Personnalisation premium','customD'=>'Thèmes, tables, couvertures, cadres et réactions.','fair'=>'Jeu équitable & sécurité','fairD'=>'Tours, résultats et économie sont décidés côté serveur.','ready'=>'Prêt à jouer','instant'=>'Accès rapide','multi'=>'6 langues','themes'=>'15 thèmes'],
    'es'=>['k'=>'WORLD EXPERIENCE • B303','title'=>'Tu mesa. Tu mundo. Tu competición.','desc'=>'Una plataforma social de cartas con nivel global: juego justo controlado por servidor, ranking, amigos, clubes y personalización profunda.','play'=>'Jugar ahora','explore'=>'Explorar juegos','live'=>'En vivo','games'=>'Tus juegos favoritos','gamesSub'=>'Acceso rápido sin menús saturados.','all'=>'Todos los juegos','rooms'=>'Salas activas','events'=>'Competiciones','engines'=>'motores de juego','security'=>'Protección del servidor','social'=>'Social World','socialD'=>'Amigos, presencia en vivo, regalos y repeticiones privadas.','ranked'=>'Competitive Arena','rankedD'=>'MMR, temporadas y torneos verificados por el servidor.','custom'=>'Personalización premium','customD'=>'Temas, mesas, portadas, marcos y reacciones.','fair'=>'Juego justo y seguridad','fairD'=>'Turnos, resultados y economía se deciden en el servidor.','ready'=>'Listo para jugar','instant'=>'Entrada rápida','multi'=>'6 idiomas','themes'=>'15 temas'],
  ];
  $t = $copy[$locale] ?? $copy['en'];
  $publicKeys=array_keys(\App\Services\Games\GameCatalog::all());
  $games = class_exists('\App\Models\Game') ? \App\Models\Game::where('active',true)->whereIn('key',$publicKeys)->orderBy('id')->take(8)->get() : collect();
  $openRooms = class_exists('\App\Models\Room') ? \App\Models\Room::whereIn('status',['waiting','bidding','playing'])->count() : 0;
  $activeTournaments = class_exists('\App\Models\Tournament') ? \App\Models\Tournament::whereIn('status',['open','running'])->count() : 0;
  $engineCount = count($publicKeys);
@endphp
<div class="b303-home">
  <section class="b303-hero">
    <div class="b303-copy">
      <span class="b303-kicker"><i></i>{{ $t['k'] }}</span>
      <h1><span>{{ $t['title'] }}</span></h1>
      <p>{{ $t['desc'] }}</p>
      <div class="b303-actions">
        @if($isAuthed)
          <a class="b303-primary" href="{{ route('games.index') }}">▶ {{ $t['play'] }}</a>
          <a href="{{ route('competitive') }}">♛ {{ $t['ranked'] }}</a>
          <a href="{{ route('social-world') }}">✦ {{ $t['social'] }}</a>
        @else
          <a class="b303-primary" href="{{ route('register') }}">✦ {{ $t['play'] }}</a>
          <a href="{{ route('login') }}">→ {{ $t['explore'] }}</a>
        @endif
      </div>
    </div>
    <aside class="b303-control">
      <div class="b303-control-head"><b>{{ $t['live'] }}</b><span class="b303-live">● LIVE</span></div>
      <div class="b303-orbit"><div class="b303-orbit-core">W</div></div>
      <div class="b303-metrics">
        <div class="b303-metric"><b>{{ $openRooms }}</b><small>{{ $t['rooms'] }}</small></div>
        <div class="b303-metric"><b>{{ $activeTournaments }}</b><small>{{ $t['events'] }}</small></div>
        <div class="b303-metric"><b>{{ $engineCount }}</b><small>{{ $t['engines'] }}</small></div>
        <div class="b303-metric"><b>100%</b><small>{{ $t['security'] }}</small></div>
      </div>
    </aside>
  </section>

  <section class="b303-section">
    <div class="b303-section-head"><div><h2>{{ $t['games'] }}</h2><p>{{ $t['gamesSub'] }}</p></div>@if($isAuthed)<a href="{{ route('games.index') }}">{{ $t['all'] }} →</a>@endif</div>
    <div class="b303-game-grid">
      @forelse($games as $game)
        <a class="b303-game" href="{{ $isAuthed ? route('rooms.index',$game->key) : route('login') }}">
          <span class="b303-badge">SERVER ENGINE</span>
          <img loading="lazy" decoding="async" src="{{ game_art_url($game->key) }}" alt="{{ $game->name[$locale] ?? $game->name['en'] ?? $game->key }}">
          <span class="b303-game-body"><b>{{ $game->name[$locale] ?? $game->name['en'] ?? $game->key }}</b><span>PLAY →</span></span>
        </a>
      @empty
        <div class="b303-feature"><div class="icon">W</div><h3>Warqnaa</h3><p>{{ $t['ready'] }}</p></div>
      @endforelse
    </div>
  </section>

  <section class="b303-section b303-feature-grid">
    <article class="b303-feature"><div class="icon">✦</div><h3>{{ $t['social'] }}</h3><p>{{ $t['socialD'] }}</p></article>
    <article class="b303-feature gold"><div class="icon">♛</div><h3>{{ $t['ranked'] }}</h3><p>{{ $t['rankedD'] }}</p></article>
    <article class="b303-feature violet"><div class="icon">◇</div><h3>{{ $t['custom'] }}</h3><p>{{ $t['customD'] }}</p></article>
    <article class="b303-feature"><div class="icon">🛡</div><h3>{{ $t['fair'] }}</h3><p>{{ $t['fairD'] }}</p></article>
  </section>

  <div class="b303-trust"><span>⚡ {{ $t['instant'] }}</span><span>🌐 {{ $t['multi'] }}</span><span>🎨 {{ $t['themes'] }}</span><span>🛡 {{ $t['security'] }}</span></div>
</div>
@endsection
