part of 'main.dart';

/// Presentation only: the calling prize-box service has already settled the
/// reward. Skipping/continuing this animation never makes another reward call.
class R53PrizeOpeningScene extends StatelessWidget {
  const R53PrizeOpeningScene({super.key, required this.locale, required this.boxKey,
    required this.reward, required this.progress, required this.completed,
    required this.onSkip, required this.onContinue});

  final String locale, boxKey;
  final Map<String, dynamic> reward;
  final double progress;
  final bool completed;
  final VoidCallback onSkip, onContinue;

  double _interval(double start, double end) =>
      ((progress - start) / (end - start)).clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final ar = locale == 'ar';
    final revealed = progress >= .78;
    final theme = Theme.of(context).textTheme;
    return ColoredBox(color: const Color(0xff071323), child: LayoutBuilder(
      builder: (context, area) {
        final horizontal = area.maxWidth >= 700 && area.maxWidth > area.maxHeight;
        final inset = area.maxHeight < 450 ? 12.0 : 20.0;
        final availableHeight = math.max(0.0, area.maxHeight - inset * 2);
        final summary = ConstrainedBox(
          key: const ValueKey('r53-prize-summary-viewport'),
          constraints: BoxConstraints(maxWidth: 440,
            maxHeight: horizontal ? availableHeight : availableHeight * .46),
          child: SingleChildScrollView(child: Container(
            key: const ValueKey('r53-prize-summary'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: R35ReferenceColors.navy,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: R35ReferenceColors.paleGold, width: 1.5)),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(revealed ? V02Text.t(locale, 'reward') : (ar ? 'لحظة حظ ملكية' : 'A royal moment'),
                textAlign: TextAlign.center,
                style: theme.labelLarge?.copyWith(color: R35ReferenceColors.paleGold, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Semantics(liveRegion: revealed, child: Text(
                revealed ? prizeRewardLabelV02(locale, reward) : (ar ? 'جارٍ فتح الصندوق…' : 'Opening your chest…'),
                key: const ValueKey('r53-prize-description'), textAlign: TextAlign.center,
                style: theme.titleLarge?.copyWith(color: Colors.white, fontSize: 22, height: 1.25, fontWeight: FontWeight.w900))),
              const SizedBox(height: 14),
              FilledButton.icon(key: const ValueKey('r53-prize-continue'),
                onPressed: completed ? onContinue : null,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(V02Text.t(locale, 'close')),
                style: FilledButton.styleFrom(backgroundColor: R35ReferenceColors.gold,
                  foregroundColor: R35ReferenceColors.deep, minimumSize: const Size.fromHeight(52),
                  disabledBackgroundColor: R35ReferenceColors.deep,
                  disabledForegroundColor: R35ReferenceColors.paleGold,
                  textStyle: theme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w800))),
              if (!completed) ...[
                const SizedBox(height: 6),
                TextButton.icon(key: const ValueKey('r53-prize-skip'), onPressed: onSkip,
                  icon: const Icon(Icons.skip_next_rounded), label: Text(ar ? 'تخطي الحركة' : 'Skip animation'),
                  style: TextButton.styleFrom(foregroundColor: R35ReferenceColors.cyan,
                    minimumSize: const Size.fromHeight(48),
                    textStyle: theme.labelLarge?.copyWith(fontSize: 14))),
              ],
            ]),
          )),
        );
        final stage = Expanded(child: _R53ChestStage(boxKey: boxKey, reward: reward,
          progress: progress, open: Curves.easeInOutCubic.transform(_interval(.28, .72)),
          reveal: Curves.easeOutCubic.transform(_interval(.56, .90))));
        return Padding(padding: EdgeInsets.all(inset), child: horizontal
          ? Row(key: const ValueKey('r53-prize-landscape'), children: [stage, const SizedBox(width: 20), Flexible(child: summary)])
          : Column(key: const ValueKey('r53-prize-portrait'), children: [stage, const SizedBox(height: 12), summary]));
      },
    ));
  }
}

class _R53ChestStage extends StatelessWidget {
  const _R53ChestStage({required this.boxKey, required this.reward,
    required this.progress, required this.open, required this.reveal});
  final String boxKey;
  final Map<String, dynamic> reward;
  final double progress, open, reveal;

  @override
  Widget build(BuildContext context) => ClipRect(
    key: const ValueKey('r53-prize-stage'),
    child: LayoutBuilder(builder: (context, area) {
      // All original sprites share one 720x540 canvas, including transparent
      // registration margins. Keep their geometry identical at every size.
      final width = math.min(area.maxWidth, area.maxHeight * 1.18);
      final height = width * 3 / 4;
      final left = (area.maxWidth - width) / 2;
      final top = area.maxHeight - height;
      final rewardSize = math.min(width * .46, area.maxHeight * .38);
      final rewardTop = math.max(4.0, top - rewardSize * .70);
      final shake = progress < .28 ? math.sin(progress * 85) * (1 - progress / .28) * 4 : 0.0;
      Widget sprite(String suffix) => Image.asset(prizeBoxAssetV02(boxKey, suffix),
        key: ValueKey('r53-prize-sprite-$suffix'), fit: BoxFit.contain,
        filterQuality: FilterQuality.high, excludeFromSemantics: true);
      return Stack(children: [
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: RadialGradient(radius: .85, colors: [
            R35ReferenceColors.gold.withValues(alpha: .10 + .08 * reveal), const Color(0xff071323)])))),
        Positioned(left: left + shake, top: top, width: width, height: height,
          child: Stack(fit: StackFit.expand, children: [
            sprite('body'),
            // The front-panel sprite duplicates the body's front. Fade it in
            // place instead of sending a second face down over the prize text.
            Opacity(opacity: 1 - open, child: sprite('front_panel')),
            Transform(alignment: const FractionalOffset(.5, 235 / 540),
              transform: Matrix4.identity()..setEntry(3, 2, .001)..rotateX(-open * 1.25),
              child: sprite('lid')),
          ])),
        for (var i = 0; i < 10; i++)
          Positioned(left: area.maxWidth * (.08 + ((i * 19) % 78) / 100),
            top: area.maxHeight * (.08 + ((i * 13) % 58) / 100),
            child: Opacity(opacity: math.sin(reveal * math.pi).clamp(0.0, 1.0).toDouble(),
              child: const Icon(Icons.auto_awesome_rounded, color: R35ReferenceColors.paleGold, size: 14))),
        Positioned(left: (area.maxWidth - rewardSize) / 2,
          top: top + height * .24 + (rewardTop - top - height * .24) * reveal,
          width: rewardSize, height: rewardSize,
          child: IgnorePointer(child: Opacity(opacity: reveal,
            child: Transform.scale(scale: .5 + .5 * reveal, child: Container(
              key: const ValueKey('r53-prize-reward-art'), padding: EdgeInsets.all(rewardSize * .08),
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: R35ReferenceColors.gold.withValues(alpha: .08),
                boxShadow: [BoxShadow(color: R35ReferenceColors.gold.withValues(alpha: .35 * reveal),
                  blurRadius: rewardSize * .22, spreadRadius: rewardSize * .03)]),
              child: PrizeRewardVisualV210(reward: reward, size: rewardSize * .84)),
            )))),
      ]);
    }),
  );
}
