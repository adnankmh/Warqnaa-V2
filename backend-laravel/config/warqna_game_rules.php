<?php
return [
 'tarneeb'=>[
  'title'=>'طرنيب',
  'summary'=>'4 لاعبين، فريقان، 13 ورقة لكل لاعب، طلب من 7 إلى 13، صاحب أعلى طلب يختار الطرنيب ويبدأ اللعب.',
  'summary_en'=>'Four players in two teams receive 13 cards each. Bidding runs from 7 to 13, and the highest bidder chooses trump and leads.',
  'core'=>['اتباع نوع أول ورقة إلزامي إذا كان لديك منها.','الطرنيب يكسر النوع ويتفوق على كل الأنواع.','نجاح الطلب يضيف عدد اللمات للفريق الطالب، والفشل يخصم قيمة الطلب.','الفائز باللفة يبدأ اللفة التالية.'],
  'core_en'=>['Follow the led suit whenever you hold it.','Trump beats every non-trump suit.','Making the bid scores the declaring team’s tricks; failing deducts the bid.','The trick winner leads the next trick.']
 ],
 'hand'=>[
  'title'=>'هاند',
  'summary'=>'سحب من الدك أو الرمي، تنزيل مجموعات وسلاسل صحيحة، ثم رمي ورقة. 5 جولات بنظام نقاط واضح.',
  'summary_en'=>'Draw from the stock or discard pile, lay legal sets and runs, then discard one card. A match uses five clearly scored rounds.',
  'core'=>['المجموعة أو السلسلة لا تقل عن 3 أوراق.','النزول الأول يحتاج مجموعة قانونية.','الفائز ينهي الجولة ويتم احتساب نقاط الباقين.'],
  'core_en'=>['Every set or run contains at least three cards.','The opening meld must be a legal group.','The first player to go out ends the round, and remaining cards are scored.']
 ],
 'banakil'=>[
  'title'=>'بناكل',
  'summary'=>'نسخة مطورة من الهاند مع أوراق مساعدة 2 والجوكر، وسلاسل ومجموعات وشراكة.',
  'summary_en'=>'An extended Hand variant with twos and jokers as wild cards, runs, sets, and partnership play.',
  'core'=>['2 والجوكر أوراق مساعدة.','يمكن الإضافة على مجموعات الشريك.','لا يجوز للخصم الإضافة على مجموعات لاعب أو فريق آخر.','عند اختيار ورقة مدفونة من كومة الرمي تُسحب هي وكل الأوراق الأحدث فوقها فقط.','الهدف الافتراضي 222.'],
  'core_en'=>['Twos and jokers are wild cards.','A player may lay off on a partner’s meld.','An opponent may not lay off on another player’s or team’s meld.','Choosing a buried discard takes that card and every newer card above it—nothing below it.','The default target is 222.']
 ],
 'trix'=>[
  'title'=>'تركس',
  'summary'=>'مملكة وعقود متعددة، مع اتباع النوع ونقاط سلبية/إيجابية حسب العقد.',
  'summary_en'=>'Kingdom play uses several contracts, mandatory suit following, and positive or negative scoring according to the contract.',
  'core'=>['اتباع النوع إلزامي.','كل عقد له حساب مختلف.','الفوز يعتمد على أقل خسائر أو أعلى نقاط حسب العقد.'],
  'core_en'=>['Following the led suit is mandatory.','Each contract has its own scoring rules.','Winning depends on minimizing penalties or maximizing points for the active contract.']
 ],
 'baloot'=>[
  'title'=>'بلوت',
  'summary'=>'فرق، مزاد/حكم أو صن، اتباع النوع وحساب المشاريع واللمات.',
  'summary_en'=>'Teams bid for Hokum or Sun, follow suit, and score projects and tricks.',
  'core'=>['النوع والحكم يحددان قوة الورق.','الفريق يحقق أو يفشل حسب العقد.'],
  'core_en'=>['Suit and trump determine card strength.','The declaring team either makes or fails its contract.']
 ],
 'domino'=>[
  'title'=>'دومينو',
  'summary'=>'لعب البلاطات على اليمين أو اليسار، السحب عند عدم وجود حركة، والفوز عند إنهاء البلاطات.',
  'summary_en'=>'Play tiles on either end, draw when no legal move exists, and win by emptying your hand.',
  'core'=>['مطابقة الرقم على طرف السلسلة.','إن لم توجد حركة، اسحب أو مرر حسب الحالة.'],
  'core_en'=>['Match a number on either open end of the chain.','When no move exists, draw or pass according to the current state.']
 ],
 'backgammon'=>[
  'title'=>'طاولة',
  'summary'=>'رمي النرد وتحريك القطع حسب الأرقام، إخراج القطع عند اكتمال البيت.',
  'summary_en'=>'Roll the dice, move checkers by the rolled values, and bear them off after bringing every checker home.',
  'core'=>['النرد يحدد الحركة.','لا تتحرك على خانة مغلقة.','الفائز من يخرج قطعه أولًا.'],
  'core_en'=>['The dice determine legal movement.','A checker cannot move onto a blocked point.','The first player to bear off every checker wins.']
 ],
];
