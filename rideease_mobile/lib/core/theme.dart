import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern indigo / cyan palette on slate neutrals. Works in light and dark mode.
class AppColors {
  static const primary = Color(0xFF6366F1); // indigo
  static const accent = Color(0xFF22D3EE); // cyan
  static const ink = Color(0xFF0F172A); // slate 900
  static const surface = Color(0xFFF6F7FB);
  // Translucent on purpose: reads as a soft line on white and on dark cards.
  static const border = Color(0x338A94AD);
  static const muted = Color(0xFF6B7490);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFE5484D);
  static const heroStart = Color(0xFF1E1B4B); // deep indigo
  static const heroEnd = Color(0xFF6D28D9); // violet

  // Dark theme surfaces
  static const darkSurface = Color(0xFF0B1020);
  static const darkCard = Color(0xFF131A30);
  static const darkSnack = Color(0xFF263049);
}

class AppSpacing {
  static const xs = 4.0, sm = 8.0, md = 16.0, lg = 24.0, xl = 32.0;
}

class AppRadius {
  static const sm = 12.0, md = 16.0, lg = 24.0;
}

const heroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.heroStart, AppColors.heroEnd],
);

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: b).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    onPrimary: Colors.white,
    surface: dark ? AppColors.darkSurface : AppColors.surface,
    outlineVariant: AppColors.border,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: b);
  final cardColor = dark ? AppColors.darkCard : Colors.white;
  const borderColor = AppColors.border;
  final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

  OutlineInputBorder ob(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: w),
      );

  return base.copyWith(
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: dark ? Colors.white : AppColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: dark ? 0 : 2,
      shadowColor: const Color(0x1A0F172A),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: borderColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.all(16),
      border: ob(borderColor),
      enabledBorder: ob(borderColor),
      focusedBorder: ob(AppColors.primary, 1.8),
      errorBorder: ob(AppColors.danger),
      focusedErrorBorder: ob(AppColors.danger, 1.8),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(88, 54),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(88, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: const BorderSide(color: borderColor),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 70,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: cardColor,
      indicatorColor: AppColors.primary.withValues(alpha: dark ? 0.28 : 0.14),
      indicatorShape: const StadiumBorder(),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.muted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.muted,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: const StadiumBorder(side: BorderSide(color: borderColor)),
      selectedColor: AppColors.primary.withValues(alpha: dark ? 0.30 : 0.16),
      showCheckmark: false,
    ),
  );
}
