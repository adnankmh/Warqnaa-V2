# رفع Warqnaa V221 إلى GitHub
1. طبّق Upgrade R10.1 على R10 Build 220.
2. لا ترفع backend-laravel/.env ولا أي أسرار دفع/AdMob حقيقية.
3. شغّل CHECK_WARQNA_WINDOWS.bat.
4. Commit ثم Push.
5. GitHub Actions يشغّل R8/R9/R9.1/R10/R10.1 ثم flutter analyze وflutter test.

مفاتيح Google/Apple/Web وإعلانات الإنتاج توضع Secrets/Environment ولا تُحفظ في Git.
