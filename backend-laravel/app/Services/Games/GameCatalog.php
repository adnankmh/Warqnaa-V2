<?php
namespace App\Services\Games;

class GameCatalog
{
    public static function all(): array
    {
        return [
            'tarneeb'=>['ar'=>'طرنيب','en'=>'Tarneeb','min'=>4,'max'=>4,'partners'=>true,'engine'=>'tarneeb','targets'=>[31,41,61],'family'=>'tarneeb','icon'=>'🃏','summary'=>'طرنيب كامل: 13 ورقة، طلب 7–13، اختيار الحكم، اتباع النوع، لمّات وفوز أو خسارة للطلب.'],
            'syrian_tarneeb'=>['ar'=>'طرنيب سوري','en'=>'Syrian Tarneeb','min'=>4,'max'=>4,'partners'=>true,'engine'=>'syrian_tarneeb','targets'=>[61],'family'=>'tarneeb','icon'=>'🇸🇾','summary'=>'طرنيب سوري بأربعة لاعبين وشراكة ومزايدة واتباع إلزامي للنوع.'],
            'tarneeb_400'=>['ar'=>'طرنيب 400','en'=>'Tarneeb 400','min'=>4,'max'=>4,'partners'=>true,'engine'=>'tarneeb_400','targets'=>[400],'family'=>'tarneeb','icon'=>'4️⃣','summary'=>'طرنيب 400 بنظام فريقين والكبة كحكم ثابت واحتساب طلبات ونقاط خاص.'],
            'trix'=>['ar'=>'تركس','en'=>'Trix','min'=>4,'max'=>4,'partners'=>false,'engine'=>'trix','targets'=>[],'family'=>'trix','icon'=>'👑','summary'=>'ممالك وعقود شيخ الكبة والبنات والديناري واللطوش وتركس.'],
            'trix_partner'=>['ar'=>'تركس شراكة','en'=>'Partner Trix','min'=>4,'max'=>4,'partners'=>true,'engine'=>'trix_partner','targets'=>[],'family'=>'trix','icon'=>'👥','summary'=>'تركس بنظام فريقين متقابلين مع جمع نقاط الشريكين.'],
            'trix_complex'=>['ar'=>'تركس كمبلكس','en'=>'Trix Complex','min'=>4,'max'=>4,'partners'=>false,'engine'=>'trix_complex','targets'=>[],'family'=>'trix','icon'=>'💎','summary'=>'كمبلكس يجمع العقود السلبية مع طلب تركس حسب النمط.'],
            'hand'=>['ar'=>'هاند','en'=>'Hand','min'=>2,'max'=>4,'partners'=>false,'engine'=>'hand','targets'=>[51,101],'family'=>'meld','icon'=>'🂡','summary'=>'14 ورقة، سحب ثم نزول مجموعات أو سلاسل ثم رمي، والفوز بإنهاء اليد.'],
            'hand_partner'=>['ar'=>'هاند شراكة','en'=>'Hand Partner','min'=>4,'max'=>4,'partners'=>true,'engine'=>'hand_partner','targets'=>[51,101],'family'=>'meld','icon'=>'🤝','summary'=>'هاند بنظام فريقين وشروط نزول واحتساب نقاط مشتركة.'],
            'saudi_hand'=>['ar'=>'هاند سعودي','en'=>'Saudi Hand','min'=>2,'max'=>4,'partners'=>false,'engine'=>'saudi_hand','targets'=>[51,101],'family'=>'meld','icon'=>'🇸🇦','summary'=>'هاند سعودي بسحب ونزول وتركيب ورمي واحتساب الأوراق المتبقية.'],
            'banakil'=>['ar'=>'بناكل','en'=>'Banakil','min'=>2,'max'=>4,'partners'=>true,'engine'=>'banakil','targets'=>[100],'family'=>'meld','icon'=>'🎴','summary'=>'بناكل بمجموعتي ورق وجوكرات، نزول مجموعات وسلاسل والتخلص من اليد.'],
            'baloot'=>['ar'=>'بلوت','en'=>'Baloot','min'=>4,'max'=>4,'partners'=>true,'engine'=>'baloot','targets'=>[152],'family'=>'gulf','icon'=>'♠️','summary'=>'بلوت 32 ورقة، صن أو حكم، شراكة وترتيب وقيم ونقاط خاصة.'],
            'basra'=>['ar'=>'باصرة','en'=>'Basra','min'=>2,'max'=>2,'partners'=>false,'engine'=>'basra','targets'=>[31],'family'=>'basra','icon'=>'♦️','summary'=>'أربع أوراق لكل لاعب وأربع على الطاولة، التقاط المماثل أو مجموع القيم واحتساب الباصرة.'],
        ];
    }

    /** Customer-facing games intentionally exclude engines that still require the full online/server UX. */
    public static function customerKeys(): array
    {
        return array_keys(self::all());
    }

    public static function isCustomerVisible(string $key): bool
    {
        return in_array($key, self::customerKeys(), true);
    }

    public static function rules(string $key): string
    {
        $game=self::all()[$key] ?? ['ar'=>$key,'summary'=>'قواعد قابلة للتوسعة'];
        $base=[
            'tarneeb'=>'طرنيب: 4 لاعبين، فريقان متقابلان، 52 ورقة، 13 ورقة لكل لاعب. الطلب من 7 إلى 13 أو Pass. اللاعب الذي يمرر لا يطلب مرة أخرى في نفس الجولة. تنتهي المزايدة بعد 3 Pass بعد أعلى طلب. صاحب أعلى طلب يختار الطرنيب ويبدأ اللعب. يجب اتباع نوع أول ورقة إن توفر. اللمة لأعلى ورقة من النوع المطلوب أو لأعلى طرنيب. إذا حقق فريق الطالب الطلب تُضاف له اللمات، وإذا فشل تُخصم قيمة الطلب ويُضاف للخصم ما أخذه من لمات.',
            'hand'=>'هاند: سحب من الدك أو الرمي، ثم تنزيل مجموعات/سلاسل 3+ حسب شرط النزول، ثم رمي ورقة. نهاية اليد عند التخلص من الأوراق، ويتم حساب أوراق الخصوم.',
            'baloot'=>'بلوت: 32 ورقة، صن/حكم، مشاريع، ترتيب وقيم خاصة في الحكم والصن، واحتساب نقاط الفريق. محرك Warqna يفصل الاختيار واللعب واحتساب النقاط.',
            'trix'=>'تركس: عقود ممالك، إلزام اتباع النوع، عقوبات للعقود السلبية، وتدبيل للأوراق الخاصة في الكمبلكس.',
            'basra'=>'باصرة: لاعبان، 52 ورقة، أربع أوراق لكل لاعب في كل دفعة وأربع على الطاولة. يلتقط اللاعب الورقة المماثلة أو مجموعة أوراق مجموعها يساوي قيمة ورقته، مع أحكام خاصة للولد وسبعة الديناري. تُحسب الباصرات وأكثرية الورق والديناري والآسات وفق النمط المعتمد.',
        ];
        $family=$game['family'] ?? '';
        $txt=$base[$key] ?? ($base[$family] ?? ($game['ar'].': '.$game['summary']));
        return $txt."\n\nمبدأ Warqna: السيرفر هو الحكم، لا تُرسل أوراق الخصوم، يتم التحقق من الدور والحركة واتباع النوع والنقاط، ويتم التعامل مع الانقطاع عبر Auto-play مؤقت.";
    }

    public static function translations(string $key): array
    {
        $names = self::all()[$key] ?? ['en'=>$key,'ar'=>$key];
        $en=$names['en'] ?? $key;
        return [
            'ar'=>self::rules($key),
            'en'=>$en.': Official Warqnaa rules are enforced by the server, including legal turns/actions, scoring, timeout auto-play, reconnect protection and anti-cheat validation.',
            'de'=>$en.': Die offiziellen Warqnaa-Regeln werden serverseitig durchgesetzt, einschließlich gültiger Züge/Aktionen, Wertung, automatischem Spiel bei Zeitüberschreitung, Wiederverbindung und Anti-Cheat-Prüfung.',
            'tr'=>$en.': Resmî Warqnaa kuralları sunucu tarafından uygulanır; geçerli sıra/hamle denetimi, puanlama, süre aşımında otomatik oynama, yeniden bağlanma ve hile önleme kontrolleri dahildir.',
            'fr'=>$en.': Les règles officielles de Warqnaa sont appliquées côté serveur, avec validation des tours/actions, calcul des scores, jeu automatique en cas d’expiration, reconnexion et protection anti-triche.',
            'es'=>$en.': Las reglas oficiales de Warqnaa se aplican en el servidor, incluyendo validación de turnos/acciones, puntuación, juego automático por tiempo agotado, reconexión y protección antitrampas.',
        ];
    }
}
