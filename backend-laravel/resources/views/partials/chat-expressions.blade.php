<details class="wq-expressions" id="wq-expressions">
 <summary>{{ $t('😄 تعبيرات متحركة وعبارات صوتية','😄 Animated expressions & voice phrases') }}</summary>
 <div class="wq-exp-tabs" role="group" aria-label="{{ $t('نوع التعبير','Expression category') }}">
  <button type="button" data-exp-tab="animated" aria-pressed="true">{{ $t('متحركة','Animated') }}</button>
  <button type="button" data-exp-tab="voice" aria-pressed="false">{{ $t('عبارات صوتية','Voice phrases') }}</button>
 </div>
 <div id="wq-exp-grid" class="wq-exp-grid"></div>
 <p class="wq-exp-hint" id="wq-exp-status" role="status">{{ $t('اختر تعبيرًا لإضافته إلى الرسالة، ثم أرسلها. الصوت يعمل عند طلبه فقط.','Choose an expression to add to your message, then send it. Audio plays only on request.') }}</p>
</details>
<link rel="stylesheet" href="{{asset('assets/css/chat-expressions-r291.css')}}">
<script defer src="{{asset('assets/js/chat-expressions-r291.js')}}"></script>
