/* Original CSS motion for standard Unicode symbols; no third-party art or recordings. */
(() => {
 'use strict';
 const animated=[
 ['😂','ضحك','Laugh','bounce'],['🤣','ضحك شديد','Big laugh','shake'],['😍','إعجاب','Love','pulse'],['🥳','احتفال','Party','bounce'],
 ['👏','تصفيق','Applause','shake'],['🙌','رائع','Hooray','bounce'],['👋','تلويح','Wave','wave'],['👍','ممتاز','Great','pulse'],
 ['🤝','اتفاق','Handshake','shake'],['💪','قوة','Strength','pulse'],['🔥','حماس','Fire','pulse'],['✨','بريق','Sparkle','spin'],
 ['🎉','تهنئة','Celebrate','bounce'],['💥','انفجار','Boom','pulse'],['⚡','برق','Lightning','shake'],['🌟','نجمة','Star','spin'],
 ['😎','ثقة','Cool','wave'],['😜','مزاح','Joking','shake'],['🤔','تفكير','Thinking','wave'],['😱','مفاجأة','Surprise','bounce'],
 ['😴','نعاس','Sleepy','pulse'],['😅','إحراج','Awkward','shake'],['😭','بكاء','Crying','shake'],['😡','غضب','Angry','shake'],
 ['🥰','محبة','Affection','pulse'],['🤩','انبهار','Amazing','spin'],['❤️','قلب','Heart','pulse'],['🌹','وردة','Rose','wave'],
 ['☕','قهوة','Coffee','wave'],['⏳','انتظار','Waiting','spin'],['🎯','هدف','Target','pulse'],['🫡','تحية','Salute','wave']
 ];
 const phrases=[
 ['👋','السلام عليكم','Peace be upon you'],['🤝','وعليكم السلام','And peace be upon you'],['😊','مرحبا','Hello'],
 ['⏩','أسرع لو سمحت','Please hurry up'],['⏳','لحظة من فضلك','One moment please'],['🙏','شكرًا جزيلًا','Thank you very much'],
 ['👏','أحسنت','Well played'],['🎉','مبروك','Congratulations'],['💪','بالتوفيق','Good luck'],['🃏','دورك الآن','Your turn now'],
 ['😅','آسف','Sorry'],['🤗','ولا يهمك','No worries'],['👍','تمام','All right'],['🔥','لعبة رائعة','Great game'],
 ['🤔','فكر جيدًا','Think carefully'],['🫡','جاهز','Ready'],['☕','استراحة قصيرة','Short break'],['🌹','إلى اللقاء','See you later'],
 ['😂','يا سلام','Wow'],['🙌','هيا نلعب','Let us play']
 ];
 const host=document.getElementById('wq-expressions');
 if(!host)return;
 const grid=document.getElementById('wq-exp-grid'),status=document.getElementById('wq-exp-status');
 const ar=()=>document.documentElement.lang!=='en';
 const tr=(a,b)=>ar()?a:b;
 const say=(a,b)=>{status.textContent=tr(a,b);};
 const canSpeak=()=>typeof window.speechSynthesis!=='undefined'&&typeof window.SpeechSynthesisUtterance==='function';
 const speech=(phrase,language)=>{
   if(document.body.dataset.sound==='0'){say('الصوت مغلق في إعداداتك.','Sound is disabled in your settings.');return;}
   if(!canSpeak()){say('النطق غير مدعوم في هذا المتصفح.','Speech is unavailable in this browser.');return;}
   const utterance=new window.SpeechSynthesisUtterance(phrase);
   utterance.lang=language==='ar'?'ar':'en-US';
   const voices=window.speechSynthesis.getVoices();
   const voice=voices.find(v=>v.lang.toLowerCase().split('-')[0]===language);
   if(voice)utterance.voice=voice;
   else if(voices.length){say('لا يوجد صوت لهذه اللغة على جهازك.','No voice for this language is installed.');return;}
   utterance.rate=1;utterance.volume=.8;
   utterance.onerror=()=>say('تعذر تشغيل الصوت على هذا الجهاز.','Audio could not play on this device.');
   window.speechSynthesis.cancel();window.speechSynthesis.speak(utterance);
 };
 const insert=text=>{
   const input=document.getElementById('chatInput');
   if(!input||input.disabled||input.readOnly)return;
   const next=(input.value.trim()?input.value.trim()+' ':'')+text;
   if([...next].length>500){say('الرسالة طويلة جدًا.','Message is too long.');return;}
   input.value=next;input.dispatchEvent(new Event('input',{bubbles:true}));input.focus();
   say('تمت الإضافة، اضغط إرسال.','Added. Press send.');
 };
 function button(label,action,cls=''){
   const b=document.createElement('button');b.type='button';b.className=cls;b.textContent=label;b.addEventListener('click',action);return b;
 }
 function render(tab){
   grid.replaceChildren();
   host.querySelectorAll('[data-exp-tab]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.expTab===tab)));
   if(tab==='animated'){
     for(const [symbol,a,b,motion] of animated){
       const item=button('',()=>insert(symbol),'wq-exp-emoji');
       item.setAttribute('aria-label',tr(a,b));item.title=tr(a,b);
       const glyph=document.createElement('span');glyph.className='wq-motion wq-motion-'+motion;glyph.textContent=symbol;glyph.setAttribute('aria-hidden','true');item.append(glyph);grid.append(item);
     }
   }else{
     for(const [symbol,a,b] of phrases){
       const text=tr(a,b),row=document.createElement('div');row.className='wq-exp-phrase';
       row.append(button(symbol+' '+text,()=>insert(symbol+' '+text),'wq-exp-insert'));
       const play=button('🔊',()=>speech(text,ar()?'ar':'en'),'wq-exp-play');play.setAttribute('aria-label',tr('استمع: ','Listen: ')+text);
       row.append(play);grid.append(row);
     }
   }
 }
 host.querySelectorAll('[data-exp-tab]').forEach(b=>b.addEventListener('click',()=>render(b.dataset.expTab)));
 render('animated');
 // Received messages use the existing authorized chat path. Recognize only exact catalog text.
 // Never auto-play incoming messages; the recipient chooses to listen.
 const known=new Map();
 for(const [symbol,a,b] of phrases){known.set(symbol+' '+a,[a,'ar']);known.set(symbol+' '+b,[b,'en']);}
 const glyphs=new Map(animated.map(([symbol,,,motion])=>[symbol,motion]));
 const decorate=body=>{
   body.querySelectorAll('.msg > span, .game-chat-msg > span').forEach(el=>{
     const text=el.textContent.trim(), phrase=known.get(text),motion=glyphs.get(text);
     if(motion)el.classList.add('wq-received-emoji','wq-motion','wq-motion-'+motion);
     if(!phrase||el.parentElement.querySelector('.wq-exp-message-play'))return;
     const play=button('🔊',()=>speech(...phrase),'wq-exp-message-play');
     play.setAttribute('aria-label',tr('استمع إلى العبارة','Listen to phrase'));el.after(play);
   });
 };
 for(const id of ['chatBody','gameRoomChatBody']){
   const body=document.getElementById(id);if(!body)continue;
   const observer=new MutationObserver(()=>decorate(body));observer.observe(body,{childList:true,subtree:true});decorate(body);
 }
})();
