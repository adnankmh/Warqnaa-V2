part of 'main.dart';

const String warqnaaR143Release = '1.0.3+263';

extension R143AccountSecurityController on AppController {
  Future<String?> updateAccountSecurityR143({
    required String currentPassword,
    required String newUsername,
    required String newEmail,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    final cleanUsername = newUsername.trim();
    final cleanEmail = newEmail.trim().toLowerCase();
    if (!RegExp(r'^[A-Za-z0-9_-]{3,30}$').hasMatch(cleanUsername)) return localeCode == 'ar' ? 'اسم المستخدم يجب أن يكون 3–30 حرفًا/رقمًا بدون مسافات.' : 'Username must be 3–30 letters/numbers without spaces.';
    if (currentPassword.isEmpty) return 'أدخل كلمة المرور الحالية.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(cleanEmail)) {
      return 'أدخل بريدًا إلكترونيًا صحيحًا.';
    }
    if (newPassword.isNotEmpty) {
      if (newPassword.length < 10 ||
          !RegExp(r'[a-z]').hasMatch(newPassword) ||
          !RegExp(r'[A-Z]').hasMatch(newPassword) ||
          !RegExp(r'[0-9]').hasMatch(newPassword)) {
        return 'كلمة المرور الجديدة يجب أن تكون 10 أحرف على الأقل وتضم حرفًا كبيرًا وصغيرًا ورقمًا.';
      }
      if (newPassword != passwordConfirmation) return 'تأكيد كلمة المرور غير مطابق.';
      if (newPassword == currentPassword) return 'اختر كلمة مرور جديدة مختلفة عن الحالية.';
    }

    final prefs = await SharedPreferences.getInstance();
    final effectivePassword = newPassword.isEmpty ? currentPassword : newPassword;
    if (serverConnected && api.token != null && api.token!.isNotEmpty) {
      try {
        final response = await api.updateAccountSecurity(
          currentPassword: currentPassword,
          username: cleanUsername,
          email: cleanEmail,
          newPassword: newPassword.isEmpty ? null : newPassword,
        );
        final user = response['user'];
        if (user is Map && user['username'] != null) username = user['username'].toString();
        email = user is Map && user['email'] != null ? user['email'].toString() : cleanEmail;
        await _storeOfflineCredentials(prefs, username, email, effectivePassword, admin: isAdmin);
        await _save();
        refreshUi();
        return null;
      } on ApiException catch (error) {
        return error.message;
      } catch (_) {
        return 'تعذر الاتصال بالخادم. حاول مرة أخرى عند توفر الإنترنت.';
      }
    }

    if (authToken != null && authToken!.isNotEmpty) {
      return 'تغيير بيانات حساب الخادم يحتاج اتصالًا بالإنترنت.';
    }

    final alias = prefs.getString(_offlineAliasKey(username)) ?? username.trim().toLowerCase();
    final expected = prefs.getString(_offlineHashKey(alias));
    if (expected == null || expected != _offlineCredentialHash(alias, currentPassword)) {
      return 'كلمة المرور الحالية غير صحيحة.';
    }
    final oldEmail = email;
    final oldUsername = username;
    username = cleanUsername;
    displayName = displayName == oldUsername ? cleanUsername : displayName;
    email = cleanEmail;
    await _storeOfflineCredentials(prefs, username, email, effectivePassword, admin: false);
    if (oldUsername.toLowerCase() != cleanUsername.toLowerCase()) { await prefs.remove(_offlineAliasKey(oldUsername)); }
    if (oldEmail.trim().isNotEmpty && oldEmail.toLowerCase() != cleanEmail) {
      await prefs.remove(_offlineAliasKey(oldEmail));
    }
    await _save();
    refreshUi();
    return null;
  }
}

class R143AccountSecurityPage extends StatefulWidget {
  const R143AccountSecurityPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<R143AccountSecurityPage> createState() => _R143AccountSecurityPageState();
}

class _R143AccountSecurityPageState extends State<R143AccountSecurityPage> {
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmationController = TextEditingController();
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool busy = false;
  String? error;

  bool get ar => widget.controller.localeCode == 'ar';

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.controller.username);
    emailController = TextEditingController(text: widget.controller.email);
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmationController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    final result = await widget.controller.updateAccountSecurityR143(
      currentPassword: currentPasswordController.text,
      newUsername: usernameController.text,
      newEmail: emailController.text,
      newPassword: newPasswordController.text,
      passwordConfirmation: confirmationController.text,
    );
    if (!mounted) return;
    setState(() {
      busy = false;
      error = result;
    });
    if (result == null) {
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmationController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ar ? 'تم تحديث أمان الحساب بنجاح.' : 'Account security updated.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'مركز أمان الحساب' : 'Account security center')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: .22),
                  Theme.of(context).colorScheme.surface,
                ]),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .24)),
              ),
              child: Row(children: [
                const CircleAvatar(radius: 28, child: Icon(Icons.security_rounded, size: 30)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.controller.username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text(widget.controller.serverConnected
                      ? (ar ? 'حساب متصل بالخادم' : 'Server account')
                      : (ar ? 'حساب محلي أوفلاين' : 'Offline local account')),
                ])),
              ]),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: usernameController,
              autofillHints: const [AutofillHints.username],
              decoration: InputDecoration(
                labelText: ar ? 'اسم المستخدم' : 'Username',
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                labelText: ar ? 'البريد الإلكتروني الجديد' : 'New email address',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: currentPasswordController,
              obscureText: obscureCurrent,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: ar ? 'كلمة المرور الحالية' : 'Current password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                  icon: Icon(obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: obscureNew,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: ar ? 'كلمة مرور جديدة (اختياري)' : 'New password (optional)',
                prefixIcon: const Icon(Icons.key_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscureNew = !obscureNew),
                  icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmationController,
              obscureText: obscureNew,
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                labelText: ar ? 'تأكيد كلمة المرور الجديدة' : 'Confirm new password',
                prefixIcon: const Icon(Icons.verified_user_outlined),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              ar
                  ? 'بعد تغيير كلمة المرور تُلغى الجلسات الأخرى. وعند تغيير البريد يحتاج البريد الجديد إلى التحقق.'
                  : 'Changing the password revokes other sessions. A changed email must be verified again.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .64), height: 1.5),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: busy ? null : submit,
              icon: busy
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.security_rounded),
              label: Text(ar ? 'حفظ التغييرات الآمنة' : 'Save security changes'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
          ],
        ),
      ),
    );
  }
}
