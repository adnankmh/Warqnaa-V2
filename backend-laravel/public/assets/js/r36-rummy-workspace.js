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
    if (JSON.stringify(hand) !== signature) { signature=JSON.stringify(hand); draft=new RummyDraft(hand); }
    let controls = document.getElementById('r36-rummy-workspace');
    const zone = document.getElementById('meldZone');
    if (!zone) return;
    if (!controls) { controls=node('div',''); controls.id='r36-rummy-workspace'; zone.appendChild(controls); }
    controls.replaceChildren();
    const actions = Array.isArray(state.available_actions) ? state.available_actions : [];
    const types = new Set(actions.map(action=>action.type));
    const myTurn = state.turn === root.MY_PLAYER_KEY;
    const stack = actions.find(action=>action.type==='draw_discard_stack');
    if (stack) {
      const chooser=node('select',''); chooser.setAttribute('aria-label',t('عدد أوراق النار','Discard count'));
      for (let count=2;count<=stack.max_count;count++) { const option=node('option',String(count)); option.value=String(count); chooser.appendChild(option); }
      controls.append(chooser,node('button',t('اسحب عدة أوراق من النار','Take discard stack'),()=>root.roomAction('draw_discard_stack',{count:Number(chooser.value)})));
    }
    const add=node('button',t('أضف المحدد إلى مجموعة','Group selected cards'),()=>{if(draft.add())repaint(state);});
    add.disabled=draft.selected.size<3; controls.appendChild(add);
    for(let index=0;index<draft.groups.length;index++) {
      const row=node('div',draft.payload()[index].join(' · '));
      row.appendChild(node('button',t('تراجع','Undo'),()=>{draft.undo(index);repaint(state);})); controls.appendChild(row);
    }
    const submit=node('button',t('نزّل جميع المجموعات','Meld all groups'),()=>root.roomAction('meld_many',{groups:draft.payload()}));
    submit.disabled=!myTurn || !types.has('organize') || !draft.groups.length;
    controls.appendChild(submit);
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
      if(cards.length>=3) return root.roomAction('meld',{cards});
      root.showNotice?.(t('حدد ثلاث أوراق على الأقل.','Select at least three cards.'));
    };
    root.arrangeMelds=()=>{
      if(draft.selected.size>=3)draft.add();
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
