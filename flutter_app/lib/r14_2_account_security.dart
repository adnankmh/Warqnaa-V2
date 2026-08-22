part of 'main.dart';

String r142Text(String locale, String key) {
  const ar = <String, String>{
    'title': 'أمان الحساب',
    'subtitle': 'تغيير البريد وكلمة المرور وإدارة حماية الدخول',
    'eyebrow': 'R14.2 • مركز الحماية',
    'verified': 'البريد مؤكّد',
    'pending': 'البريد يحتاج تأكيدًا',
    'onlineRequired': 'تغيير بيانات الدخول يحتاج اتصالاً بالخادم.',
    'emailTitle': 'تغيير البريد الإلكتروني',
    'emailHint': 'سنرسل رابط تأكيد إلى البريد الجديد ونغلق الجلسات الأخرى.',
    'newEmail': 'البريد الإلكتروني الجديد',
    'currentPassword': 'كلمة المرور الحالية',
    'saveEmail': 'حفظ البريد الجديد',
    'passwordTitle': 'تغيير كلمة المرور',
    'passwordHint': 'استخدم 8 أحرف على الأقل تشمل حرفًا كبيرًا وصغيرًا ورقمًا.',
    'newPassword': 'كلمة المرور الجديدة',
    'confirmPassword': 'تأكيد كلمة المرور الجديدة',
    'savePassword': 'تغيير كلمة المرور',
    'mismatch': 'تأكيد كلمة المرور غير مطابق.',
    'weak': 'كلمة المرور يجب أن تحتوي حرفًا كبيرًا وصغيرًا ورقمًا وأن تكون 8 أحرف على الأقل.',
    'invalidEmail': 'أدخل بريدًا إلكترونيًا صحيحًا.',
    'adminProtected': 'حساب المدير محمي؛ تغيير بيانات الدخول لا يغيّر الصلاحيات.',
    'sessions': 'الجلسات النشطة',
  };
  const en = <String, String>{
    'title': 'Account security',
    'subtitle': 'Change email, password and sign-in protection',
    'eyebrow': 'R14.2 • SECURITY CENTER',
    'verified': 'Email verified',
    'pending': 'Email verification required',
    'onlineRequired': 'Changing sign-in credentials requires a server connection.',
    'emailTitle': 'Change email address',
    'emailHint': 'We will verify the new email and close other sessions.',
    'newEmail': 'New email address',
    'currentPassword': 'Current password',
    'saveEmail': 'Save new email',
    'passwordTitle': 'Change password',
    'passwordHint': 'Use at least 8 characters with uppercase, lowercase and a number.',
    'newPassword': 'New password',
    'confirmPassword': 'Confirm new password',
    'savePassword': 'Change password',
    'mismatch': 'Password confirmation does not match.',
    'weak': 'Use at least 8 characters with uppercase, lowercase and a number.',
    'invalidEmail': 'Enter a valid email address.',
    'adminProtected': 'Admin account protected; credentials do not change permissions.',
    'sessions': 'Active sessions',
  };
  return (locale == 'ar' ? ar : en)[key] ?? key;
}

extension R142AccountSecurityController on AppController {
  Future<Map<String, dynamic>> changeAccountEmailR142(String currentPassword, String newEmail) async {
    if (!serverConnected || api.token == null || api.token!.isEmpty) {
      throw ApiException(r142Text(localeCode, 'onlineRequired'));
    }
    final data = await api.updateAccountEmailR142(currentPassword: currentPassword, email: newEmail);
    final account = data['account'];
    if (account is Map && account['email'] != null) email = account['email'].toString();
    final prefs = await SharedPreferences.getInstance();
    await _storeOfflineCredentials(prefs, username, email, currentPassword);
    await _save();
    refreshUi();
    return data;
  }

  Future<Map<String, dynamic>> changeAccountPasswordR142(String currentPassword, String newPassword) async {
    if (!serverConnected || api.token == null || api.token!.isEmpty) {
      throw ApiException(r142Text(localeCode, 'onlineRequired'));
    }
    final data = await api.updateAccountPasswordR142(currentPassword: currentPassword, password: newPassword);
    final prefs = await SharedPreferences.getInstance();
    await _storeOfflineCredentials(prefs, username, email, newPassword);
    await _save();
    refreshUi();
    return data;
  }
}

class AccountSecurityPageR142 extends StatefulWidget {
  final AppController controller;
  const AccountSecurityPageR142({super.key, required this.controller});

  @override
  State<AccountSecurityPageR142> createState() => _AccountSecurityPageR142State();
}

class _AccountSecurityPageR142State extends State<AccountSecurityPageR142> {
  late final TextEditingController email;
  final emailCurrentPassword = TextEditingController();
  final passwordCurrent = TextEditingController();
  final password = TextEditingController();
  final passwordConfirmation = TextEditingController();
  bool loading = true;
  bool busyEmail = false;
  bool busyPassword = false;
  bool emailVerified = false;
  int activeSessions = 1;
  bool hideEmailPassword = true;
  bool hideCurrentPassword = true;
  bool hideNewPassword = true;
  String? loadError;

  bool get isArabic => widget.controller.localeCode == 'ar';
  String t(String key) => r142Text(widget.controller.localeCode, key);

  @override
  void initState() {
    super.initState();
    email = TextEditingController(text: widget.controller.email);
    unawaited(_load());
  }

  @override
  void dispose() {
    email.dispose();
    emailCurrentPassword.dispose();
    passwordCurrent.dispose();
    password.dispose();
    passwordConfirmation.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!widget.controller.serverConnected) {
      if (mounted) setState(() { loading = false; loadError = t('onlineRequired'); });
      return;
    }
    try {
      final data = await widget.controller.api.accountSecurityR142();
      final account = data['account'];
      if (account is Map) {
        email.text = account['email']?.toString() ?? widget.controller.email;
        widget.controller.email = email.text;
        emailVerified = account['email_verified'] == true;
        activeSessions = int.tryParse(account['active_sessions']?.toString() ?? '') ?? 1;
        await widget.controller._save();
      }
    } catch (error) {
      loadError = error.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _saveEmail() async {
    final nextEmail = email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(nextEmail)) {
      showToast(context, t('invalidEmail'));
      return;
    }
    if (emailCurrentPassword.text.isEmpty) {
      showToast(context, t('currentPassword'));
      return;
    }
    setState(() => busyEmail = true);
    try {
      final data = await widget.controller.changeAccountEmailR142(emailCurrentPassword.text, nextEmail);
      emailCurrentPassword.clear();
      emailVerified = false;
      if (mounted) showToast(context, data['message']?.toString() ?? t('saveEmail'));
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => busyEmail = false);
    }
  }

  Future<void> _savePassword() async {
    final next = password.text;
    final strong = next.length >= 8 && RegExp(r'[A-Z]').hasMatch(next) && RegExp(r'[a-z]').hasMatch(next) && RegExp(r'[0-9]').hasMatch(next);
    if (!strong) {
      showToast(context, t('weak'));
      return;
    }
    if (next != passwordConfirmation.text) {
      showToast(context, t('mismatch'));
      return;
    }
    if (passwordCurrent.text.isEmpty) {
      showToast(context, t('currentPassword'));
      return;
    }
    setState(() => busyPassword = true);
    try {
      final data = await widget.controller.changeAccountPasswordR142(passwordCurrent.text, next);
      passwordCurrent.clear();
      password.clear();
      passwordConfirmation.clear();
      if (mounted) showToast(context, data['message']?.toString() ?? t('savePassword'));
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => busyPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('title'))),
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 36),
          children: [
            _securityHero(),
            if (loading) const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator())),
            if (loadError != null) _securityNotice(loadError!, Colors.amber),
            const SizedBox(height: 14),
            _securityCard(
              icon: Icons.alternate_email_rounded,
              title: t('emailTitle'),
              hint: t('emailHint'),
              children: [
                TextField(controller: email, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: t('newEmail'), prefixIcon: const Icon(Icons.email_outlined))),
                const SizedBox(height: 10),
                TextField(controller: emailCurrentPassword, obscureText: hideEmailPassword, decoration: InputDecoration(labelText: t('currentPassword'), prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => hideEmailPassword = !hideEmailPassword), icon: Icon(hideEmailPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
                const SizedBox(height: 14),
                Semantics(button: true, label: t('saveEmail'), child: FilledButton.icon(onPressed: busyEmail || !widget.controller.serverConnected ? null : _saveEmail, icon: busyEmail ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.verified_user_outlined), label: Text(t('saveEmail')))),
              ],
            ),
            const SizedBox(height: 14),
            _securityCard(
              icon: Icons.password_rounded,
              title: t('passwordTitle'),
              hint: t('passwordHint'),
              children: [
                TextField(controller: passwordCurrent, obscureText: hideCurrentPassword, decoration: InputDecoration(labelText: t('currentPassword'), prefixIcon: const Icon(Icons.lock_clock_outlined), suffixIcon: IconButton(onPressed: () => setState(() => hideCurrentPassword = !hideCurrentPassword), icon: Icon(hideCurrentPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
                const SizedBox(height: 10),
                TextField(controller: password, obscureText: hideNewPassword, decoration: InputDecoration(labelText: t('newPassword'), prefixIcon: const Icon(Icons.key_rounded), suffixIcon: IconButton(onPressed: () => setState(() => hideNewPassword = !hideNewPassword), icon: Icon(hideNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
                const SizedBox(height: 10),
                TextField(controller: passwordConfirmation, obscureText: hideNewPassword, decoration: InputDecoration(labelText: t('confirmPassword'), prefixIcon: const Icon(Icons.check_circle_outline_rounded))),
                const SizedBox(height: 14),
                Semantics(button: true, label: t('savePassword'), child: FilledButton.icon(onPressed: busyPassword || !widget.controller.serverConnected ? null : _savePassword, icon: busyPassword ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.shield_lock_outlined), label: Text(t('savePassword')))),
              ],
            ),
            if (widget.controller.isAdmin) ...[const SizedBox(height: 14), _securityNotice(t('adminProtected'), const Color(0xffffcf67))],
          ],
        ),
      ),
    );
  }

  Widget _securityHero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff123b42), Color(0xff091824)]), borderRadius: BorderRadius.circular(26), border: Border.all(color: const Color(0x3355e2c8))),
        child: Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xffffdf8b), Color(0xff55e2c8)]), borderRadius: BorderRadius.circular(19)), child: const Icon(Icons.security_rounded, color: Color(0xff07151d), size: 31)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t('eyebrow'), style: const TextStyle(color: Color(0xff69e4cf), fontWeight: FontWeight.w900, fontSize: 11)), const SizedBox(height: 5), Text(widget.controller.email, textDirection: TextDirection.ltr, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), const SizedBox(height: 5), Text('${emailVerified ? '✓ ${t('verified')}' : '◷ ${t('pending')}'} • $activeSessions ${t('sessions')}', style: TextStyle(color: emailVerified ? Colors.greenAccent : Colors.amber, fontSize: 11, fontWeight: FontWeight.w700))])),
        ]),
      );

  Widget _securityCard({required IconData icon, required String title, required String hint, required List<Widget> children}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: .08)), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 28, offset: Offset(0, 14))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0x1855e2c8), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: const Color(0xff55e2c8))), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text(hint, style: const TextStyle(color: Colors.white60, height: 1.45, fontSize: 11))]))]), const SizedBox(height: 18), ...children]),
      );

  Widget _securityNotice(String text, Color color) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withValues(alpha: .09), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: .22))), child: Row(children: [Icon(Icons.info_outline_rounded, color: color), const SizedBox(width: 10), Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, height: 1.45)))]));
}
