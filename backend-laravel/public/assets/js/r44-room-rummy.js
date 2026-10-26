/* R44: genuine DOM gameplay affordances over the existing server-authoritative room.
   Does not touch hidden hands, prices or card-deal algorithms. */
(() => {
  'use strict';
  const games = new Set(['hand','hand_partner','saudi_hand','banakil','pinochle']);
  const game = String(window.GAME_KEY || '');
  if (!games.has(game)) return;
  const byId = id => document.getElementById(id);
  const isBanakil = game === 'banakil';
  const isPartner = game === 'banakil' || game === 'hand_partner';
  const labelCard = card => {
    const c = String(card || '');
    const parts = c.split('_');
    const symbols = {H:'♥',D:'♦',S:'♠',C:'♣',hearts:'♥',diamonds:'♦',spades:'♠',clubs:'♣'};
    return /JOKER/i.test(c) ? '★' : (parts[0] || c) + (symbols[parts[1]] || '');
  };
  const create = (tag, cls, text) => {
    const el = document.createElement(tag);
    if (cls) el.className = cls;
    if (text !== undefined) el.textContent = String(text);
    return el;
  };
  const latestState = () => window.LAST_STATE || window.INITIAL_STATE || {};
  const canDraw = state => {
    const own = String(state.turn || '') === String(window.MY_PLAYER_KEY || '');
    // Laravel's public phase collapses draw and discard into "playing".
    // Use the exposed engine_phase to disable picking during meld/discard.
    const enginePhase = String(state.engine_phase || '');
    if (enginePhase) return own && enginePhase === 'draw';
    const raw = state.drew_this_turn || state.rummy_turn_meta || {};
    const meta = raw[window.MY_PLAYER_KEY] || {};
    return own && state.phase === 'playing'
      && meta !== true && !meta.drew_discard && !meta.drew_deck;
  };

  function showStackPicker(state) {
    const discards = Array.isArray(state.discard) ? state.discard : [];
    if (!isBanakil || discards.length < 2 || !canDraw(state)) return;
    const modal = create('dialog','r44-pick-dialog');
    const title = create('h2','', 'اختيار ورقة من كومة الرمي');
    const detail = create('p','', 'اختر أي ورقة؛ ستسحبها مع كل الأوراق الموضوعة فوقها.');
    const list = create('div','r44-fire-selection');
    let amount = 2;
    const confirmation = create('b','r44-pick-count','سحب ورقتين');
    const visibleStart = Math.max(0,discards.length - 18);
    const options = [];
    for(let index=visibleStart;index<discards.length;index++){
      const n=discards.length-index;
      const button=create('button','r44-pick-card',labelCard(discards[index]));
      button.type='button';
      button.setAttribute('aria-label','اسحب '+n+' أوراق، بدءًا من '+labelCard(discards[index]));
      const select=()=>{
        amount=Math.max(2,n);
        confirmation.textContent='سيتم سحب '+amount+' أوراق';
        for(const item of options) {
          item.button.classList.toggle('selected',item.count<=amount);
          item.button.setAttribute('aria-pressed',String(item.count<=amount));
        }
      };
      button.addEventListener('click',select);
      options.push({count:n,button});
      list.append(button);
    }
    const controls=create('div','r44-dialog-actions');
    const cancel=create('button','r44-dialog-cancel','إلغاء');
    cancel.type='button';
    cancel.addEventListener('click',()=>modal.close());
    const confirm=create('button','r44-dialog-confirm','اسحب الأوراق المختارة');
    confirm.type='button';
    confirm.addEventListener('click',()=>{
      modal.close();
      if (typeof window.roomAction === 'function') {
        window.roomAction('draw_discard_stack',{count:amount});
      }
    });
    controls.append(cancel,confirm);
    modal.append(title,detail,list,confirmation,controls);
    modal.addEventListener('close',()=>modal.remove(),{once:true});
    document.body.append(modal);
    options.find(x=>x.count===2)?.button.click();
    if(typeof modal.showModal === 'function')modal.showModal();
    else modal.setAttribute('open','');
  }

  function render(state) {
    const piles=byId('r44RoomPiles');
    const area=byId('r44OwnerMelds');
    if(!piles || !area) return;
    const discarded = Array.isArray(state.discard) ? state.discard : [];
    const number = Number.isFinite(Number(state.deck_count)) ? Number(state.deck_count) : 0;
    const allow = canDraw(state);
    const stack=create('div','r44-pile-row');
    const stock=create('button','r44-central-pile r44-stock');
    stock.type='button';
    stock.disabled=!allow;
    stock.append(create('span','r44-card-back','🂠'),create('strong','','الرزمة · '+number));
    stock.addEventListener('click',()=>window.roomAction?.('draw_deck',{}));
    const discard=create('button','r44-central-pile r44-discard');
    discard.type='button';
    discard.disabled=!allow || !discarded.length;
    discard.append(create('span','r44-face-card',discarded.length ? labelCard(discarded.at(-1)) : '—'),
                   create('strong','','الرمي · '+discarded.length));
    discard.addEventListener('click',()=>window.roomAction?.('draw_discard',{}));
    stack.append(stock,discard);
    if(isBanakil && discarded.length>=2) {
      const multi=create('button','r44-select-stack','اختر من النار');
      multi.type='button';
      multi.disabled=!allow;
      multi.addEventListener('click',()=>showStackPicker(state));
      stack.append(multi);
    }
    piles.replaceChildren(stack);

    const melds = state.melds && typeof state.melds === 'object' ? state.melds : {};
    const teams = state.teams && typeof state.teams === 'object' ? state.teams : {};
    const cols=create('div','r44-owner-grid');
    const buckets=new Map();
    Object.entries(melds).forEach(([owner,groups])=>{
      if(!Array.isArray(groups) || !groups.length)return;
      const team = (teams.teamA||[]).includes(owner) ? 'a' :
                   (teams.teamB||[]).includes(owner) ? 'b' : 'solo';
      const display = owner===window.MY_PLAYER_KEY ? 'أنت' : owner.startsWith('bot:') ? 'روبوت' : 'لاعب';
      const bucketKey=isPartner && team!=='solo' ? 'team-'+team : 'owner-'+owner;
      if(!buckets.has(bucketKey))buckets.set(bucketKey,{team,owners:[]});
      buckets.get(bucketKey).owners.push({owner,display,groups});
    });
    const english=String(document.documentElement.lang||'').toLowerCase().startsWith('en');
    buckets.forEach(bucket=>{
      const tile=create('div','r44-meld-owner team-'+(isPartner ? bucket.team : 'solo'));
      tile.dataset.owners=bucket.owners.map(item=>item.owner).join(',');
      const names=bucket.owners.map(item=>item.display).join(' + ');
      const teamName=bucket.team==='a' ? (english?'Team A':'فريق أ') :
                     bucket.team==='b' ? (english?'Team B':'فريق ب') : '';
      tile.append(create('strong','',isPartner ? teamName+' • '+names : names));
      for(const item of bucket.owners) {
        const ownerSection=create('div','r84-meld-owner-section');
        ownerSection.dataset.owner=item.owner;
        if(isPartner)ownerSection.append(create('small','r84-meld-owner-name',item.display));
        for(const record of item.groups) {
          const cards=Array.isArray(record) ? record : record?.cards;
          if(!Array.isArray(cards) || !cards.length)continue;
          const set=create('div','r44-meld-set');
          for(const card of cards)set.append(create('span','r44-meld-card',labelCard(card)));
          ownerSection.append(set);
        }
        tile.append(ownerSection);
      }
      cols.append(tile);
    });
    area.replaceChildren(cols);
    area.hidden=!cols.children.length;
  }

  window.addEventListener('load',()=>{
    const base=window.renderState;
    if(typeof base==='function'){
      window.renderState=function(state) {
        const result=base.apply(this,arguments);
        render(state||{});
        return result;
      };
    }
    render(latestState());
  },{once:true});
})();
