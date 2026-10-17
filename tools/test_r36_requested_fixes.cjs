const assert = require('node:assert/strict');
const {RummyDraft} = require('../backend-laravel/public/assets/js/r36-rummy-workspace.js');
const draft = new RummyDraft(['3_spades','3_spades','4_spades','5_spades','4_hearts','5_hearts']);
draft.toggle(0); draft.toggle(2);
assert.equal(draft.add(),false,'incomplete group must stay a draft');
draft.toggle(3); assert.equal(draft.add(),true);
draft.toggle(0); assert.equal(draft.selected.size,0,'a card cannot be reused in another draft');
draft.toggle(1); draft.toggle(4); draft.toggle(5); assert.equal(draft.add(),true);
assert.deepEqual(draft.payload(),[['3_spades','4_spades','5_spades'],['3_spades','4_hearts','5_hearts']]);
draft.undo(0); draft.toggle(0); draft.toggle(2); draft.toggle(3); assert.equal(draft.add(),true);
const all=draft.payload().flat();
assert.equal(all.length,6); assert.equal(all.filter(card=>card==='3_spades').length,2);
draft.toggle(-1); draft.toggle(80); assert.equal(draft.selected.size,0);
console.log('R36 rummy drafts: duplicate-card selection, grouping, undo and card conservation PASS');

// Exercise the shipped UI adapter, not a second implementation of its rules.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const browserSource = fs.readFileSync(path.join(__dirname,'../backend-laravel/public/assets/js/r36-rummy-workspace.js'),'utf8');
class UiElement {
  constructor(tag='div') {
    this.tagName=tag;this.children=[];this.dataset={};this.attributes={};this.classes=new Set();
    this.textContent='';this.value='';this.disabled=false;
    this.classList={toggle:(name,on)=>on?this.classes.add(name):this.classes.delete(name)};
  }
  appendChild(child){this.children.push(child);return child;}
  append(...children){children.forEach(child=>this.appendChild(child));}
  replaceChildren(...children){this.children=[];this.append(...children);}
  setAttribute(name,value){this.attributes[name]=value;}
}
function descendants(element){return [element,...element.children.flatMap(descendants)];}
function fixture(language,game='banakil') {
  const zone=new UiElement(), draw=[new UiElement('button'),new UiElement('button')];
  draw[0].dataset.action='draw_deck';draw[1].dataset.action='draw_discard';
  let cards=[];const calls=[],notices=[];
  const root={MY_PLAYER_KEY:'user:1',GAME_KEY:game,WARQNA_PLAYER_NAMES:{'user:2':'Partner'},
    roomAction:(type,payload)=>calls.push(JSON.parse(JSON.stringify({type,payload}))),
    showNotice:message=>notices.push(message),
    renderState:state=>{root.LAST_STATE=state;cards=state.hand.map(card=>Object.assign(new UiElement('button'),{dataset:{card}}));},
    document:{documentElement:{lang:language},createElement:tag=>new UiElement(tag),addEventListener(){},
      getElementById:id=>id==='meldZone'?zone:descendants(zone).find(element=>element.id===id),
      querySelectorAll:selector=>selector.startsWith('#myHand')?cards:draw}};
  vm.runInNewContext(browserSource,{window:root});
  const elements=()=>descendants(zone);
  const button=(ar,en)=>elements().find(e=>e.tagName==='button'&&e.textContent===(language==='ar'?ar:en));
  return {root,draw,calls,notices,render:state=>root.renderState(state),card:i=>cards[i],elements,button};
}
for(const language of ['ar','en']) for(const game of ['hand','hand_partner','saudi_hand','banakil','pinochle']) {
  const ui=fixture(language,game);
  const hand=['3_spades','3_spades','4_spades','5_spades','K_hearts','A_clubs'];
  const state={game,round:1,you:'user:1',turn:'user:1',hand,phase:'playing',deck_count:70,
    discard:['JOKER_R','Q_hearts','K_hearts'],available_actions:[{type:'draw_deck'},{type:'draw_discard'},{type:'draw_discard_stack',max_count:3}]};
  ui.render(state);
  assert.equal(ui.elements().find(e=>e.id==='r40-discard-selected').disabled,true);
  const chooser=ui.elements().find(e=>e.tagName==='select');
  chooser.value='3';chooser.onchange();
  const preview=ui.elements().find(e=>e.id==='r40-fire-preview');
  assert.deepEqual(preview.children.slice(1).map(e=>e.textContent),['🃏','Q♥','K♥']);
  ui.button('اسحب عدة أوراق من النار','Take discard stack').onclick();
  assert.deepEqual(ui.calls.pop(),{type:'draw_discard_stack',payload:{count:3}});
  const layoff={type:'layoff',target_player:'user:2',meld_index:0,cards:['A_clubs']};
  const replacement={type:'replace_wild',target_player:'user:2',meld_index:1,card:'3_spades'};
  state.available_actions=[{type:'organize'},...hand.map(card=>({type:'discard',card})),layoff,replacement];
  ui.render(state);
  assert.ok(ui.draw.every(button=>button.disabled),'draw controls stop after drawing');
  ui.card(0).onclick();ui.card(1).onclick();
  assert.equal(ui.elements().find(e=>e.id==='r40-discard-selected').disabled,true,'two identical cards are two physical selections');
  ui.card(1).onclick();
  const discard=ui.elements().find(e=>e.id==='r40-discard-selected');
  assert.equal(discard.disabled,false);discard.onclick();
  assert.deepEqual(ui.calls.pop(),{type:'discard',payload:{card:'3_spades'}});
  ui.render(state);
  assert.equal(ui.elements().find(e=>e.id==='r40-discard-selected').disabled,false,'a rejected unchanged hand preserves selection');
  ui.button('ركّب على مجموعة','Add to a meld').onclick();
  assert.deepEqual(ui.calls.pop(),{type:'layoff',payload:{target_player:'user:2',meld_index:0,cards:['A_clubs']}});
  const replace=ui.button('استبدل الجوكر','Replace joker');replace.onclick();
  assert.deepEqual(ui.calls.pop(),{type:'replace_wild',payload:{target_player:'user:2',meld_index:1,card:'3_spades'}});
  state.available_actions=state.available_actions.filter(action=>action.type!=='replace_wild');replace.onclick();
  assert.equal(ui.calls.length,0,'a formerly advertised joker action cannot send after a sync removes it');
  state.turn='user:2';ui.render(state);discard.onclick();
  assert.equal(ui.calls.length,0,'an old discard control cannot act after the turn changes');
  assert.ok(ui.draw.every(button=>button.disabled));
  state.turn='user:1';state.available_actions=[{type:'organize'}];ui.render(state);
  assert.equal(ui.elements().find(e=>e.id==='r40-discard-selected').disabled,true,'must-meld hands cannot discard');
  ui.button('إلغاء تحديد الأوراق','Clear selection').onclick();
  for(const i of [0,2,3])ui.card(i).onclick();
  ui.button('أضف المحدد إلى مجموعة','Group selected cards').onclick();
  ui.card(1).onclick();
  assert.equal(ui.button('نزّل جميع المجموعات','Meld all groups').disabled,true);
  ui.root.arrangeMelds();assert.equal(ui.calls.length,0,'an incomplete extra selection is not silently ignored');
  assert.ok(ui.notices.length);
  ui.button('إلغاء تحديد الأوراق','Clear selection').onclick();
  ui.button('نزّل جميع المجموعات','Meld all groups').onclick();
  assert.deepEqual(ui.calls.pop(),{type:'meld_many',payload:{groups:[['3_spades','4_spades','5_spades']]}});
  state.round=2;ui.render(state);
  assert.equal(ui.button('نزّل جميع المجموعات','Meld all groups').disabled,true,'a new round cannot inherit a stale meld draft');
}
const nonRummy=fixture('en','tarneeb');
nonRummy.render({game:'tarneeb',hand:['A_spades'],available_actions:[],turn:'user:1'});
assert.equal(nonRummy.elements().length,1,'non-rummy tables are left to their own renderer');
console.log('R40 shipped rummy controls: AR/EN × five games; legal discard/layoff/joker, public preview, sync rejection and stale-turn guards PASS');
