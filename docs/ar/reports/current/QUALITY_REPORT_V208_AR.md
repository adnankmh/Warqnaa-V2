# تقرير الجودة — Warqnaa V0.4.8+208 R8

## نطاق R8
- تدقيق قواعد اللعبة على مستوى الخادم، وليس الواجهة فقط.
- تقوية Hand / Hand Partnership / Saudi Hand / Banakil / Pinochle.
- تصحيح حسابات Tarneeb الخاصة بالطلب 13 واكتساح 13 لَمّة.
- استمرار قائد اللمة الفائز مباشرة في اللمة التالية، مع انتقال الجولة التالية آليًا في جلسات API عندما لا تكون الغرفة جولة واحدة.
- خيار `single_round` من Flutter وLaravel.
- التحقق الخادمي Dry-Run للأوامر المركبة قبل اعتمادها.

## مصفوفة المحركات التي تدخل اختبارات R8
| المحرك | النوع | R8 Stress | R8 Playthrough |
|---|---|---:|---:|
| Tarneeb | شراكة/لمات | PASS | PASS |
| Syrian Tarneeb | طرنيب سوري | PASS | PASS |
| Tarneeb 400 | فردي داخل فرق | PASS | PASS |
| Hand | Rummy | PASS | PASS |
| Hand Partnership | Rummy شراكة | PASS | PASS |
| Saudi Hand | Rummy | PASS | PASS |
| Banakil | Rummy شراكة/1v1 | PASS | PASS |
| Pinochle | Banakil family | PASS | PASS |
| Trix | Kingdom | PASS | PASS |
| Trix Partnership | Kingdom شراكة | PASS | PASS |
| Trix Complex | Contracts | PASS | PASS |
| Baloot | Sun/Hokm | PASS | PASS |
| Solitaire Multiplayer | Cards | PASS | PASS |
| Domino | Tiles | PASS | PASS |
| Basra | Capture cards | PASS | PASS |
| Backgammon | Board | PASS | PASS |
| Jackaroo | Board/cards | PASS | PASS |
| Chess | Board | PASS | PASS |

## R8 Deep Rules Audit
يختبر حالات محددة تشمل: نجاح وفشل طلب الطرنيب، 13 لمة، طلب 13، سحب Hand من النار، إلزام التنزيل، قيمة الآس/الجوكر، Hand الكامل، Partnership scoring، Banakil wild restrictions، استبدال الجوكر، وFull-hand Banakil.

## حدود الاختبار المحلي
اختبارات Flutter framework وLaravel PHPUnit الكاملة تبقى ضمن GitHub Actions عند توفر Flutter SDK وComposer dependencies. اختبارات المصدر والمحركات المستقلة لا تحتاج Android Studio.
