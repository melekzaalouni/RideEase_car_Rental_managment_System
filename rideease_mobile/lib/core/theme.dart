import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFFD9480F); // burnt orange
  static const accent = Color(0xFFF59F00); // amber
  static const ink = Color(0xFF1F1A17);
  static const surface = Color(0xFFFAF7F2);
  static const border = Color(0xFFE8E0D6);
  static const muted = Color(0xFF756D64);
  static const success = Color(0xFF2F9E44);
  static const warning = Color(0xFFF08C00);
  static const danger = Color(0xFFE03131);
  static const heroStart = Color(0xFF2A211B); // dark espresso
  static const heroEnd = Color(0xFF9C3408); // rust
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
    surface: dark ? const Color(0xFF17120F) : AppColors.surface,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: b);
  final cardColor = dark ? const Color(0xFF231C18) : Colors.white;
  final borderColor = dark ? const Color(0xFF3A2F28) : AppColors.border;
  final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

  OutlineInputBorder ob(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );

  return base.copyWith(
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: dark ? Colors.white : AppColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.all(16),
      border: ob(borderColor),
      enabledBorder: ob(borderColor),
      focusedBorder: ob(AppColors.primary, 1.6),
      errorBorder: ob(AppColors.danger),
      focusedErrorBorder: ob(AppColors.danger, 1.6),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(88, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(88, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: borderColor),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: cardColor,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: StadiumBorder(side: BorderSide(color: borderColor)),
    ),
  );
}
