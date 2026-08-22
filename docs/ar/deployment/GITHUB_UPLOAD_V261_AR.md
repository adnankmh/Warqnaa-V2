# رفع Warqnaa Build 261 إلى GitHub

1. شغّل CHECK_WARQNA_WINDOWS.bat أو scripts/unix/current/check-v261.sh.
2. ارفع **محتويات** Full Repository إلى جذر المستودع.
3. شغّل Backend CI وFlutter Android وFlutter iOS وFlutter Web وGlobal Release.
4. لا تنشئ Release نهائيًا إلا بعد نجاح كل البوابات.
5. خزّن أسرار الإنتاج والتوقيع في GitHub Environments فقط.

إصلاح Build 261 يمنع احتساب public/build المولّد ضمن سقف أصول R10 المصدرية، لكنه يفرض عليه سقفًا مستقلًا وسقفًا كليًا للنشر.
