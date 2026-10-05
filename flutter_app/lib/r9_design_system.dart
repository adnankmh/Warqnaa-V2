import 'package:flutter/material.dart';

/// Warqnaa shared visual system.
///
/// R27 keeps the disciplined R9 spacing/typography contract while lifting the
/// global dark foundation into the bright sky-blue luxury direction used by
/// the current Warqnaa reference design. Product-specific themes can still
/// provide their own primary/secondary accent; common surfaces, focus states
/// and navigation retain a coherent blue/cyan identity.
abstract final class R9Design {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;

  static const double rSmall = 12;
  static const double rMedium = 18;
  static const double rLarge = 28;
  static const double rHero = 36;

  static const Color sky = Color(0xFF24C8FF);
  static const Color azure = Color(0xFF0B8CFF);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color gold = Color(0xFFFFC84A);
  static const Color emerald = Color(0xFF2DD4A8);
  static const Color midnight = Color(0xFF052F54);
  static const Color ink = Color(0xFF064777);
  static const Color skySurface = Color(0xFF07598F);
  static const Color ivory = Color(0xFFF6F8FC);

  static ThemeData theme({required bool light, required Color accent, String? fontFamily, bool arabic = false}) {
    // Dark product themes inherit the Warqnaa sky tonal family even when the
    // active cosmetic accent is gold/purple/etc. R10+ then overrides primary
    // and secondary with the selected cosmetic palette without losing the
    // shared blue navigation, outlines and focus treatment.
    final foundationSeed = light ? accent : sky;
    final scheme = light
        ? ColorScheme.fromSeed(
            seedColor: foundationSeed,
            brightness: Brightness.light,
            surface: ivory,
          )
        : ColorScheme.fromSeed(
            seedColor: foundationSeed,
            brightness: Brightness.dark,
            surface: skySurface,
          ).copyWith(
            tertiary: gold,
            outline: const Color(0xFF73D9FF),
            outlineVariant: const Color(0xFF2F8FC4),
          );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: light ? Brightness.light : Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: light ? const Color(0xFFF0F8FF) : midnight,
      canvasColor: light ? const Color(0xFFF0F8FF) : midnight,
      visualDensity: VisualDensity.standard,
      dividerTheme: DividerThemeData(
        color: light ? scheme.outlineVariant.withValues(alpha: .42) : sky.withValues(alpha: .24),
        thickness: .7,
      ),
      splashFactory: InkSparkle.splashFactory,
    );

    final text = base.textTheme.copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: arabic ? 0 : -.7),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: arabic ? 0 : -.45),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.35),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.35),
      labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    );

    final blueBorder = light ? scheme.outlineVariant.withValues(alpha: .42) : sky.withValues(alpha: .30);
    final darkGlass = Color.lerp(midnight, skySurface, .66)!;

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: light ? scheme.onSurface : const Color(0xFFEAF9FF)),
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: light ? Colors.white.withValues(alpha: .90) : darkGlass.withValues(alpha: .94),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rLarge),
          side: BorderSide(color: blueBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMedium)),
          textStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMedium)),
          side: BorderSide(color: light ? scheme.outlineVariant.withValues(alpha: .75) : sky.withValues(alpha: .54)),
          textStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: light ? Colors.white.withValues(alpha: .84) : sky.withValues(alpha: .075),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(rMedium), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMedium),
          borderSide: BorderSide(color: blueBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMedium),
          borderSide: BorderSide(color: light ? accent : sky, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: light ? Colors.white.withValues(alpha: .97) : ink.withValues(alpha: .98),
        indicatorColor: light ? accent.withValues(alpha: .14) : sky.withValues(alpha: .22),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? (light ? accent : sky)
                : (light ? scheme.onSurfaceVariant : const Color(0xFFBDEBFF)),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 11,
            color: states.contains(WidgetState.selected)
                ? (light ? scheme.onSurface : Colors.white)
                : (light ? scheme.onSurfaceVariant : const Color(0xFFBDEBFF)),
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: light ? const Color(0xFFF5FAFF) : const Color(0xFF064777),
        modalBackgroundColor: light ? const Color(0xFFF5FAFF) : const Color(0xFF064777),
        showDragHandle: true,
        dragHandleColor: light ? scheme.outline : sky,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(rHero))),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: light ? const Color(0xFFF8FCFF) : const Color(0xFF07598F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rLarge),
          side: BorderSide(color: blueBorder),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: light ? accent : sky,
        linearTrackColor: light ? scheme.surfaceContainerHighest : sky.withValues(alpha: .16),
        circularTrackColor: light ? scheme.surfaceContainerHighest : sky.withValues(alpha: .14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: light ? accent : sky,
        foregroundColor: light ? scheme.onPrimary : midnight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMedium)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: light ? scheme.inverseSurface : const Color(0xFF064777),
          borderRadius: BorderRadius.circular(rSmall),
          border: Border.all(color: light ? Colors.transparent : sky.withValues(alpha: .30)),
        ),
        textStyle: TextStyle(color: light ? scheme.onInverseSurface : Colors.white, fontFamily: fontFamily, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class R9Section extends StatelessWidget {
  const R9Section({super.key, required this.child, this.padding = const EdgeInsets.all(R9Design.s16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: dark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  R9Design.azure.withValues(alpha: .20),
                  theme.colorScheme.surface.withValues(alpha: .90),
                  R9Design.sky.withValues(alpha: .08),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.white.withValues(alpha: .96), const Color(0xFFE8F7FF)],
              ),
        borderRadius: BorderRadius.circular(R9Design.rLarge),
        border: Border.all(
          color: dark ? R9Design.sky.withValues(alpha: .32) : theme.colorScheme.outlineVariant.withValues(alpha: .42),
        ),
        boxShadow: dark
            ? <BoxShadow>[BoxShadow(color: R9Design.sky.withValues(alpha: .08), blurRadius: 18, offset: const Offset(0, 6))]
            : const <BoxShadow>[BoxShadow(color: Color(0x10004577), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
