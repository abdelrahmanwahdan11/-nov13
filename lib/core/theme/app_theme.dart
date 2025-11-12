import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeniusColors {
  GeniusColors({
    required this.bgGradientFrom,
    required this.bgGradientTo,
    required this.ink,
    required this.inkSecondary,
    required this.outline,
    required this.surface,
    required this.accent,
  });

  final Color bgGradientFrom;
  final Color bgGradientTo;
  final Color ink;
  final Color inkSecondary;
  final Color outline;
  final Color surface;
  final Color accent;
}

class GeniusTheme {
  const GeniusTheme({
    required this.light,
    required this.dark,
  });

  final GeniusColors light;
  final GeniusColors dark;
}

final geniusTheme = GeniusTheme(
  light: GeniusColors(
    bgGradientFrom: const Color(0xFFFFF9AE),
    bgGradientTo: const Color(0xFFFFE95A),
    ink: const Color(0xFF0E0E0E),
    inkSecondary: const Color(0xFF5C5C5C),
    outline: const Color(0xFF0E0E0E),
    surface: const Color(0xFFFFF8B0),
    accent: const Color(0xFFFFE563),
  ),
  dark: GeniusColors(
    bgGradientFrom: const Color(0xFF1B1B1B),
    bgGradientTo: const Color(0xFF0E0E0E),
    ink: const Color(0xFFF5F5F5),
    inkSecondary: const Color(0xFFBDBDBD),
    outline: const Color(0xFFF5F5F5),
    surface: const Color(0xFF161616),
    accent: const Color(0xFFFFD84D),
  ),
);

const double geniusStrokeWidth = 1.8;
const double radiusSm = 12;
const double radiusMd = 18;
const double radiusLg = 28;
const double pillRadius = 999;

class ThemeTokens {
  ThemeTokens._();

  static ThemeData createTheme({required bool dark, required Color seed}) {
    final colors = dark ? geniusTheme.dark : geniusTheme.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: seed,
    );
    final textTheme = GoogleFonts.interTextTheme(
      (dark ? ThemeData.dark() : ThemeData.light()).textTheme,
    ).apply(
      bodyColor: colors.ink,
      displayColor: colors.ink,
    );
    return ThemeData(
      brightness: colorScheme.brightness,
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.archivoBlack(
          textStyle: textTheme.displayLarge?.copyWith(
            color: colors.ink,
          ),
        ),
        headlineLarge: GoogleFonts.archivoBlack(
          textStyle: textTheme.headlineLarge?.copyWith(
            color: colors.ink,
          ),
        ),
        headlineMedium: GoogleFonts.archivoBlack(
          textStyle: textTheme.headlineMedium?.copyWith(
            color: colors.ink,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.ink,
        titleTextStyle: GoogleFonts.archivoBlack(
          fontSize: 24,
          color: colors.ink,
        ),
      ),
      dividerColor: colors.outline,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(
            color: colors.outline,
            width: geniusStrokeWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(
            color: colors.outline,
            width: geniusStrokeWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(
            color: seed,
            width: geniusStrokeWidth + 0.4,
          ),
        ),
        labelStyle: TextStyle(
          color: colors.inkSecondary,
        ),
        hintStyle: TextStyle(
          color: colors.inkSecondary,
        ),
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.dark, required this.child});

  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = dark ? geniusTheme.dark : geniusTheme.light;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.bgGradientFrom, palette.bgGradientTo],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
