import 'package:flutter/material.dart';

/// Warqnaa R9 visual system.
///
/// R9 deliberately reduces visual noise: one spacing scale, one radius scale,
/// restrained glow, readable surfaces, and only two product locales (ar/en).
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

  static const Color gold = Color(0xFFE9C46A);
  static const Color emerald = Color(0xFF2A9D8F);
  static const Color midnight = Color(0xFF09111F);
  static const Color ink = Color(0xFF0D1524);
  static const Color ivory = Color(0xFFF6F2E8);

  static ThemeData theme({required bool light, required Color accent}) {
    final scheme = light
        ? ColorScheme.fromSeed(
            seedColor: accent,
            brightness: Brightness.light,
            surface: ivory,
          )
        : ColorScheme.fromSeed(
            seedColor: accent,
            brightness: Brightness.dark,
            surface: const Color(0xFF111B2E),
          );

    final base = ThemeData(
      useMaterial3: true,
      brightness: light ? Brightness.light : Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: light ? const Color(0xFFF2EEE6) : midnight,
      visualDensity: VisualDensity.standard,
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: .42), thickness: .7),
      splashFactory: InkSparkle.splashFactory,
    );

    final text = base.textTheme.copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.7),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.45),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.35),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.35),
      labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: light ? Colors.white.withValues(alpha: .82) : const Color(0xFF121E31).withValues(alpha: .92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rLarge),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .35)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMedium)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMedium)),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .75)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: light ? Colors.white.withValues(alpha: .7) : Colors.white.withValues(alpha: .045),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(rMedium), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMedium),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: .42)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMedium),
          borderSide: BorderSide(color: accent.withValues(alpha: .9), width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: light ? Colors.white.withValues(alpha: .96) : const Color(0xFF101B2C).withValues(alpha: .97),
        indicatorColor: accent.withValues(alpha: .14),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: light ? const Color(0xFFF8F5EE) : const Color(0xFF0E1828),
        modalBackgroundColor: light ? const Color(0xFFF8F5EE) : const Color(0xFF0E1828),
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(rHero))),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: light ? const Color(0xFFFBF8F1) : const Color(0xFF111D2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rLarge)),
      ),
    );
  }
}

class R9Section extends StatelessWidget {
  const R9Section({super.key, required this.child, this.padding = const EdgeInsets.all(R9Design.s16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .74),
          borderRadius: BorderRadius.circular(R9Design.rLarge),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .35)),
        ),
        child: Padding(padding: padding, child: child),
      );
}
