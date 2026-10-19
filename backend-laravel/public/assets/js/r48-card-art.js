/* Original resolution-independent card faces shared by tables and previews. */
(function (root) {
  'use strict';
  const suits={clubs:'♣',diamonds:'♦',spades:'♠',hearts:'♥',C:'♣',D:'♦',S:'♠',H:'♥'};
  const rows={
    2:[[50,36],[50,104]],3:[[50,34],[50,70],[50,106]],
    4:[[33,36],[67,36],[33,104],[67,104]],
    5:[[33,36],[67,36],[50,70],[33,104],[67,104]],
    6:[[33,34],[67,34],[33,70],[67,70],[33,106],[67,106]],
    7:[[33,34],[67,34],[50,51],[33,70],[67,70],[33,106],[67,106]],
    8:[[33,31],[67,31],[33,57],[67,57],[33,83],[67,83],[33,109],[67,109]],
    9:[[33,31],[67,31],[33,57],[67,57],[50,70],[33,83],[67,83],[33,109],[67,109]],
    10:[[33,29],[67,29],[50,43],[33,56],[67,56],[33,84],[67,84],[50,97],[33,111],[67,111]],
  };
  function parse(code) {
    const value=String(code);
    if (/^JOKER(?:_[RB])?$/.test(value)||value==='🃏') return {rank:'JK',suit:'★',joker:true};
    const parts=value.split('_');
    const rank=parts[0],suit=suits[parts[1]];
    return /^(?:[2-9]|10|J|Q|K|A)$/.test(rank)&&suit?{rank,suit,joker:false}:null;
  }
  function markup(code) {
    const card=parse(code);if(!card)return '';
    const {rank,suit,joker}=card;
    const ink=suit==='♥'||suit==='♦'?'#b42335':'#101419';
    const glyph=(text,x,y,size,extra='')=>`<text x="${x}" y="${y}" font-size="${size}" ${extra}>${text}</text>`;
    let center='';
    if(rows[rank]) center=rows[rank].map(([x,y])=>glyph(suit,x,y,20,`data-pip="1"${y>70?` transform="rotate(180 ${x} ${y})"`:''}`)).join('');
    else if(rank==='A') center=`<circle cx="50" cy="70" r="26" fill="none" stroke="#b8893e" stroke-width="1"/>`+glyph(suit,50,70,48);
    else center=`<rect x="24" y="35" width="52" height="70" rx="9" fill="#fbf5e7" stroke="#b8893e"/><path d="M34 56L31 43L43 48L50 38L57 48L69 43L66 56Z" fill="#b8893e"/>`+glyph(joker?'★':rank,50,73,joker?31:27)+glyph(suit,50,94,17);
    return `<svg xmlns="http://www.w3.org/2000/svg" class="r48-card-face" viewBox="0 0 100 140" role="img" aria-label="${rank}${suit}" focusable="false"><rect x="1" y="1" width="98" height="138" rx="9" fill="#fffdf7" stroke="#b9a271"/><g fill="${ink}" font-family="Georgia,serif" font-weight="bold" text-anchor="middle" dominant-baseline="central">${glyph(rank,13,15,14)}${glyph(suit,13,30,13)}<g transform="rotate(180 50 70)">${glyph(rank,13,15,14)}${glyph(suit,13,30,13)}</g>${center}</g></svg>`;
  }
  root.WarqnaaCardArt={parse,markup};
  if(typeof module!=='undefined')module.exports=root.WarqnaaCardArt;
})(typeof window==='undefined'?globalThis:window);
