/* Drafts are local; only the authoritative engine can accept a meld. */
(function (root) {
  'use strict';
  class RummyDraft {
    constructor(hand) { this.hand = hand.slice(); this.selected = new Set(); this.groups = []; }
    toggle(index) {
      if (!Number.isInteger(index) || index < 0 || index >= this.hand.length || this.groups.some(group => group.includes(index))) return;
      this.selected.has(index) ? this.selected.delete(index) : this.selected.add(index);
    }
    add() {
      if (this.selected.size < 3 || this.groups.length >= 8) return false;
      this.groups.push([...this.selected].sort((a,b)=>a-b)); this.selected.clear(); return true;
    }
    undo(index) { this.groups.splice(index,1); }
    payload() { return this.groups.map(group=>group.map(index=>this.hand[index])); }
  }
  if (typeof module !== 'undefined' && module.exports) module.exports = {RummyDraft};
  if (!root.document) return;
  const document = root.document;
  const ar = document.documentElement.lang !== 'en';
  const t = (a,e)=>ar?a:e;
  const rummy = state => ['hand','hand_partner','saudi_hand','banakil','pinochle'].includes(state.game || root.GAME_KEY || state.game_type);
  let draft = new RummyDraft([]);
  let signature = '';
  const node = (tag,text,callback) => {
    const element = document.createElement(tag); element.textContent = text;
    if (callback) { element.type = 'button'; element.onclick = callback; }
    return element;
  };
  function repaint(state) {
    if (!rummy(state)) return;
    const hand = Array.isArray(state.hand) ? state.hand : [];
    const nextSignature = JSON.stringify([state.round, state.you || root.MY_PLAYER_KEY, hand]);
    if (nextSignature !== signature) { signature=nextSignature; draft=new RummyDraft(hand); }
    let controls = document.getElementById('r36-rummy-workspace');
    const zone = document.getElementById('meldZone');
    if (!zone) return;
    if (!controls) { controls=node('div',''); controls.id='r36-rummy-workspace'; zone.appendChild(controls); }
    controls.replaceChildren();
    const actions = Array.isArray(state.available_actions) ? state.available_actions : [];
    const types = new Set(actions.map(action=>action.type));
    const myTurn = state.turn === root.MY_PLAYER_KEY;
    // Re-read the latest public/private snapshot at click time. A detached old
    // control must not submit an action after a sync has changed the turn.
    const current = () => root.LAST_STATE || state;
    const allowed = type => current().turn === root.MY_PLAYER_KEY &&
      (current().available_actions || []).some(action => action.type === type);
    const send = (type, payload = {}) => {
      if (!allowed(type)) return;
      const candidates = current().available_actions.filter(action => action.type === type);
      if (['discard','layoff','replace_wild'].includes(type) && !candidates.some(action =>
        Object.entries(payload).every(([key,value]) => JSON.stringify(action[key]) === JSON.stringify(value)))) return;
      if (type === 'draw_discard_stack' && !candidates.some(action =>
        Number.isInteger(payload.count) && payload.count >= 2 && payload.count <= action.max_count)) return;
      return root.roomAction(type, payload);
    };
    const cardLabel = card => {
      if (String(card).startsWith('JOKER')) return '🃏';
      const [rank,suit] = String(card).split('_');
      return rank + ({clubs:'♣',diamonds:'♦',spades:'♠',hearts:'♥',C:'♣',D:'♦',S:'♠',H:'♥'}[suit] || suit || '');
    };
    const pile = Array.isArray(state.discard) ? state.discard : [];
    const status = node('div', t('الرزمة: ', 'Deck: ') +
      (Number.isInteger(state.deck_count) ? state.deck_count : '—') + ' · ' +
      t('النار: ', 'Discards: ') + pile.length +
      (pile.length ? ' · ' + t('المكشوف: ', 'Top: ') + cardLabel(pile[pile.length-1]) : ''));
    status.className = 'r40-pile-status'; controls.appendChild(status);
    const stack = actions.find(action=>action.type==='draw_discard_stack');
    if (stack) {
      const chooser=node('select',''); chooser.setAttribute('aria-label',t('عدد أوراق النار','Discard count'));
      for (let count=2;count<=stack.max_count;count++) { const option=node('option',String(count)); option.value=String(count); chooser.appendChild(option); }
      chooser.value = '2';
      const preview = node('div',''); preview.id = 'r40-fire-preview';
      preview.setAttribute('aria-live','polite');
      const previewCards = () => {
        preview.replaceChildren(node('span',t('الأوراق التي ستسحبها: ','Cards you will take: ')));
        for (const card of pile.slice(-Number(chooser.value))) {
          const item = node('span',cardLabel(card)); item.className = 'r40-preview-card'; preview.appendChild(item);
        }
      };
      chooser.onchange = previewCards; previewCards();
      const take = node('button',t('اسحب عدة أوراق من النار','Take discard stack'),()=>send('draw_discard_stack',{count:Number(chooser.value)}));
      take.disabled = !myTurn;
      controls.append(chooser,take,preview);
    }
    const add=node('button',t('أضف المحدد إلى مجموعة','Group selected cards'),()=>{if(draft.add())repaint(state);});
    add.disabled=draft.selected.size<3 || draft.groups.length>=8; controls.appendChild(add);
    for(let index=0;index<draft.groups.length;index++) {
      const row=node('div',draft.payload()[index].join(' · '));
      row.appendChild(node('button',t('تراجع','Undo'),()=>{draft.undo(index);repaint(state);})); controls.appendChild(row);
    }
    const submit=node('button',t('نزّل جميع المجموعات','Meld all groups'),()=>root.arrangeMelds());
    submit.disabled=!myTurn || !types.has('organize') || !draft.groups.length || draft.selected.size>0;
    controls.appendChild(submit);
    const discard = node('button',t('ارمِ الورقة المحددة','Discard selected card'),()=>{
      if (draft.selected.size !== 1) return;
      return send('discard',{card:draft.hand[[...draft.selected][0]]});
    });
    discard.id = 'r40-discard-selected';
    discard.disabled = !myTurn || draft.selected.size !== 1 || !actions.some(action =>
      action.type === 'discard' && action.card === draft.hand[[...draft.selected][0]]);
    controls.appendChild(discard);
    const clear = node('button',t('إلغاء تحديد الأوراق','Clear selection'),()=>{draft.selected.clear();repaint(current());});
    clear.disabled = !draft.selected.size; controls.appendChild(clear);
    for (const [type,caption] of [['layoff',t('ركّب على مجموعة','Add to a meld')],['replace_wild',t('استبدل الجوكر','Replace joker')]]) {
      const legal = actions.filter(action=>action.type===type);
      if (!legal.length) continue;
      const chooser = node('select',''); chooser.setAttribute('aria-label',caption);
      legal.forEach((action,index)=>{
        const cards = action.cards || [action.card];
        const owner = root.WARQNA_PLAYER_NAMES?.[action.target_player] || t('مجموعة على الطاولة','Table meld');
        const option = node('option',cards.map(cardLabel).join(' ')+' → '+owner+' #'+(Number(action.meld_index)+1));
        option.value=String(index); chooser.appendChild(option);
      });
      chooser.value='0';
      const play = node('button',caption,()=>{
        const action = legal[Number(chooser.value)]; if(!action) return;
        const payload = {target_player:action.target_player,meld_index:action.meld_index};
        if(type==='layoff')payload.cards=action.cards;else payload.card=action.card;
        return send(type,payload);
      });
      play.disabled=!myTurn; controls.append(chooser,play);
    }
    const used=new Set(draft.groups.flat());
    [...document.querySelectorAll('#myHand [data-card]')].forEach((card,index)=>{
      card.classList.toggle('selected-card',draft.selected.has(index));
      card.classList.toggle('r36-grouped-card',used.has(index));
      card.setAttribute('aria-pressed',String(draft.selected.has(index)));
      card.onclick=()=>{draft.toggle(index);repaint(state);};
    });
    // Wire both old desktop controls and mobile controls to the same draft.
    root.meldSelectedCards=()=>{
      const cards=[...draft.selected].map(index=>draft.hand[index]);
      if(cards.length>=3 && allowed('organize')) return root.roomAction('meld',{cards});
      root.showNotice?.(t('حدد ثلاث أوراق على الأقل.','Select at least three cards.'));
    };
    root.arrangeMelds=()=>{
      if (!allowed('organize')) return;
      if(draft.selected.size>=3)draft.add();
      if(draft.selected.size) {
        root.showNotice?.(t('أضف الأوراق المحددة إلى مجموعة أو ألغِ تحديدها أولاً.','Group or clear the selected cards first.')); return;
      }
      if(draft.groups.length)return root.roomAction('meld_many',{groups:draft.payload()});
    };
    document.querySelectorAll('[data-action="draw_deck"],[data-action="draw_discard"]').forEach(button=>{
      button.disabled=!myTurn || !types.has(button.dataset.action);
    });
  }
  const previous=root.renderState;
  root.renderState=function(state){previous?.(state);if(state)repaint(state);};
  document.addEventListener('DOMContentLoaded',()=>{if(root.LAST_STATE)repaint(root.LAST_STATE);});
})(typeof window==='undefined'?globalThis:window);
