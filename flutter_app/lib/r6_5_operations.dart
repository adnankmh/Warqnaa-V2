part of 'main.dart';

class R65OperationsPage extends StatefulWidget {
  const R65OperationsPage({super.key, required this.controller});
  final AppController controller;
  @override
  State<R65OperationsPage> createState() => _R65OperationsPageState();
}

class _R65OperationsPageState extends State<R65OperationsPage> {
  Map<String, dynamic>? report;
  String? error;
  bool loading = false;
  bool get ar => widget.controller.localeCode == 'ar';

  @override
  void initState() { super.initState(); unawaited(_load()); }

  Future<void> _load() async {
    if (loading) return;
    setState(() { loading = true; error = null; });
    try {
      if (!widget.controller.serverConnected) {
        throw StateError(ar ? 'اتصل بالخادم لعرض الحالة الفعلية.' : 'Connect to the server to view live status.');
      }
      final result = await widget.controller.api.get('/admin/operations');
      if (!mounted) return;
      setState(() => report = _r12Map(result['operations']));
    } catch (e) {
      if (mounted) setState(() { error = friendlyErrorMessage(e, widget.controller.localeCode); report = null; });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final checks = _r12Map(report?['checks']);
    final counts = _r12Map(report?['counts']);
    final labels = <String, String>{
      'database': ar ? 'قاعدة البيانات' : 'Database',
      'cache': ar ? 'التخزين المؤقت' : 'Cache',
      'schema': ar ? 'الجداول الأساسية' : 'Core tables',
      'scheduler': ar ? 'جدولة المهام' : 'Scheduler',
      'release_config': ar ? 'تطابق الإصدار' : 'Release configuration',
      'https': ar ? 'اتصال HTTPS' : 'HTTPS',
      'debug_disabled': ar ? 'إيقاف عرض أخطاء التطوير' : 'Debug disabled',
    };
    final metrics = <String, String>{
      'active_rooms': ar ? 'الغرف النشطة' : 'Active rooms',
      'ranked_waiting': ar ? 'بانتظار المنافسة' : 'Ranked waiting',
      'open_reports': ar ? 'البلاغات المفتوحة' : 'Open reports',
      'economy_reviews': ar ? 'مراجعات الاقتصاد' : 'Economy reviews',
    };
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'مركز التشغيل' : 'Operations'), actions: <Widget>[
        IconButton(tooltip: ar ? 'تحديث' : 'Refresh', onPressed: loading ? null : _load, icon: const Icon(Icons.refresh_rounded)),
      ]),
      body: RefreshIndicator(onRefresh: _load, child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (loading) const LinearProgressIndicator(),
          if (error != null) _R64StateCard(icon: Icons.cloud_off_outlined, text: error!),
          if (report != null) ...<Widget>[
            R65OperationsStatusHero(report: report!, ar: ar),
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: metrics.entries.map((entry) => SizedBox(
              width: 160, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(entry.value, style: const TextStyle(fontSize: 12)),
                Text('${counts[entry.key] ?? '—'}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              ]))),
            )).toList()),
            const SizedBox(height: 14),
            ...labels.entries.map((entry) {
              final ok = checks[entry.key] == true;
              return Card(child: ListTile(
                leading: Icon(ok ? Icons.check_circle_outline : Icons.info_outline, color: ok ? Colors.greenAccent : Colors.amber),
                title: Text(entry.value),
                subtitle: Text(ok ? (ar ? 'سليم' : 'OK') : (ar ? 'يحتاج متابعة' : 'Check needed')),
              ));
            }),
            const SizedBox(height: 14),
            R65OperationsDeploymentNotice(ar: ar),
          ],
        ],
      )),
    );
  }
}

class R65OperationsStatusHero extends StatelessWidget {
  const R65OperationsStatusHero({
    super.key,
    required this.report,
    required this.ar,
  });

  final Map<String, dynamic> report;
  final bool ar;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final gradientStart =
        Color.lerp(colors.surfaceContainerHighest, colors.primary, 0.14)!;
    final gradientEnd =
        Color.lerp(colors.surface, colors.secondary, 0.08)!;
    return Container(
      key: const ValueKey('r152-operations-status-hero'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: <Color>[gradientStart, gradientEnd],
        ),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.monitor_heart_outlined,
            color: Color(0xffffcf58),
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            ar ? 'حالة منصتك الآن' : 'Your platform now',
            key: const ValueKey('r152-operations-status-title'),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '${report['release']} • ${report['environment']}',
            key: const ValueKey('r152-operations-status-release'),
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            '${report['generated_at']}',
            key: const ValueKey('r152-operations-status-generated-at'),
            style: TextStyle(color: colors.outline, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class R65OperationsDeploymentNotice extends StatelessWidget {
  const R65OperationsDeploymentNotice({super.key, required this.ar});

  final bool ar;

  @override
  Widget build(BuildContext context) => Text(
    ar
        ? 'HTTP ووضع التطوير طبيعيان محليًا. يلزم HTTPS وإيقاف وضع التطوير للنشر العام. صحة الجدولة تعني تسجيل تشغيل فعلي خلال آخر ثلاث دقائق.'
        : 'HTTP and debug mode are expected locally. Public deployment requires HTTPS and debug disabled. Scheduler health needs a recorded run within three minutes.',
    key: const ValueKey('r151-operations-deployment-notice'),
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      height: 1.7,
    ),
  );
}

class R65PartyErrorMessage extends StatelessWidget {
  const R65PartyErrorMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      message,
      key: const ValueKey('r154-party-error-message'),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}

class R65PartyCodeLabel extends StatelessWidget {
  const R65PartyCodeLabel({super.key, required this.ar});

  final bool ar;

  @override
  Widget build(BuildContext context) => Text(
    ar ? 'رمز المجموعة' : 'Party code',
    key: const ValueKey('r153-party-code-label'),
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

class R65PartyPage extends StatefulWidget {
  const R65PartyPage({super.key, required this.controller});
  final AppController controller;
  @override
  State<R65PartyPage> createState() => _R65PartyPageState();
}

class _R65PartyPageState extends State<R65PartyPage> {
  Map<String, dynamic> party = <String, dynamic>{};
  bool busy = false;
  String? error;
  final code = TextEditingController();
  final friendId = TextEditingController();
  bool get ar => widget.controller.localeCode == 'ar';
  @override
  void initState() { super.initState(); unawaited(_load()); }
  @override
  void dispose() { code.dispose(); friendId.dispose(); super.dispose(); }

  Future<void> _load() => _run(() => widget.controller.api.myPartyV300());
  Future<void> _run(Future<Map<String, dynamic>> Function() action, {bool refresh = false}) async {
    if (busy) return;
    setState(() { busy = true; error = null; });
    try {
      if (!widget.controller.serverConnected) throw StateError(ar ? 'المجموعات تحتاج اتصال الخادم.' : 'Parties require a server connection.');
      final result = await action();
      final current = refresh ? await widget.controller.api.myPartyV300() : result;
      if (mounted) setState(() => party = _r12Map(current['party']));
    } catch (e) {
      if (mounted) setState(() => error = friendlyErrorMessage(e, widget.controller.localeCode));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = '${party['owner_id']}' == '${widget.controller.currentUserId}';
    final members = _r12List(party['members']);
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'مجموعتي' : 'My party'), actions: <Widget>[IconButton(onPressed: busy ? null : _load, icon: const Icon(Icons.refresh))]),
      body: ListView(padding: const EdgeInsets.all(18), children: <Widget>[
        if (busy) const LinearProgressIndicator(),
        if (error != null) R65PartyErrorMessage(message: error!),
        if (party.isEmpty) ...<Widget>[
          _R64StateCard(icon: Icons.groups_outlined, text: ar ? 'اجمع أصدقاءك في مجموعة خاصة.' : 'Bring your friends into a private party.'),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: busy ? null : () => _run(() => widget.controller.api.createPartyV300()), icon: const Icon(Icons.add), label: Text(ar ? 'إنشاء مجموعة' : 'Create party')),
          const SizedBox(height: 20),
          TextField(controller: code, textCapitalization: TextCapitalization.characters, maxLength: 7, decoration: InputDecoration(labelText: ar ? 'رمز مجموعة تمت دعوتك إليها' : 'Code of a party you were invited to')),
          OutlinedButton(onPressed: busy ? null : () {
            final value = code.text.trim().toUpperCase();
            if (!RegExp(r'^[A-Z0-9]{7}$').hasMatch(value)) { setState(() => error = ar ? 'أدخل رمزًا من 7 أحرف أو أرقام.' : 'Enter a seven-character code.'); return; }
            unawaited(_run(() => widget.controller.api.joinPartyV300(value)));
          }, child: Text(ar ? 'قبول الدعوة والانضمام' : 'Accept invitation')),
        ] else ...<Widget>[
          R65PartyCodeLabel(ar: ar),
          SelectableText('${party['code']}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xffffcf58))),
          TextButton.icon(onPressed: () async { await Clipboard.setData(ClipboardData(text: '${party['code']}')); if (context.mounted) showToast(context, ar ? 'تم نسخ الرمز' : 'Code copied'); }, icon: const Icon(Icons.copy), label: Text(ar ? 'نسخ' : 'Copy')),
          ...members.where((member) => member['status'] == 'joined' || member['status'] == 'invited').map((member) {
            final user = _r12Map(member['user']);
            return Card(child: ListTile(leading: Icon(member['role'] == 'owner' ? Icons.star_outline : Icons.person_outline), title: Text('${user['username'] ?? member['user_id']}'), subtitle: Text(member['status'] == 'joined' ? (ar ? 'منضم' : 'Joined') : (ar ? 'مدعو' : 'Invited'))));
          }),
          if (owner) ...<Widget>[
            const SizedBox(height: 16),
            TextField(controller: friendId, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: ar ? 'رقم اللاعب الصديق' : 'Friend player ID', helperText: ar ? 'يلزم أن تكون الصداقة مقبولة.' : 'An accepted friendship is required.')),
            FilledButton.icon(onPressed: busy ? null : () async {
              final id = int.tryParse(friendId.text.trim());
              if (id == null || id < 1) { setState(() => error = ar ? 'أدخل رقم لاعب صحيحًا.' : 'Enter a valid player ID.'); return; }
              await _run(() => widget.controller.api.invitePartyV300(_r12Int(party['id']), id), refresh: true);
              if (context.mounted && error == null) showToast(context, ar ? 'تم إرسال الدعوة' : 'Invitation sent');
            }, icon: const Icon(Icons.person_add_alt), label: Text(ar ? 'دعوة صديق' : 'Invite friend')),
          ],
          const SizedBox(height: 20),
          OutlinedButton(onPressed: busy ? null : () => _run(() => widget.controller.api.leavePartyV300(_r12Int(party['id'])), refresh: true), child: Text(ar ? 'مغادرة المجموعة' : 'Leave party')),
        ],
      ]),
    );
  }
}
