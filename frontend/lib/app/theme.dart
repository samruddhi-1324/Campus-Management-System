import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Stitch Brand Color Palette
  static const Color primaryIndigo = Color(0xFF070235); // Deep Midnight Indigo
  static const Color primaryContainer = Color(0xFF1E1B4B);
  static const Color secondaryCobalt = Color(0xFF0051D5); // Vivid Cobalt
  static const Color secondaryContainer = Color(0xFF316BF3);
  static const Color tertiaryMint = Color(0xFF85F8C4); // Mint Emerald Glow
  static const Color tertiaryDim = Color(0xFF68DBA9);
  static const Color backgroundLight = Color(0xFFF7F9FB); // Off-white / Cool slate
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color textPrimary = Color(0xFF191C1E);
  static const Color textSecondary = Color(0xFF47464F);
  static const Color outlineVariant = Color(0xFFC8C5D0);
  static const Color outline = Color(0xFF787680);

  // Status & Urgency Colors
  static const Color statusUrgent = Color(0xFFBA1A1A); // Red
  static const Color statusCritical = Color(0xFFDC2626); // Critical Red
  static const Color statusHigh = Color(0xFFEA580C); // High Orange
  static const Color statusMedium = Color(0xFFD97706); // Medium Amber
  static const Color statusLow = Color(0xFF16A34A); // Low Green
  static const Color accentMint = Color(0xFF2DD4BF); // Mint Accent
  static const Color neutralLightOutline = Color(0xFFD9DEE8); // Light Neutral Outline
  static const Color aiBadgeColor = Color(0xFF316BF3); // Cobalt blue accent

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.manropeTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryIndigo,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: Color(0xFF8683BA),
        secondary: secondaryCobalt,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: Color(0xFFFEFCFF),
        tertiary: tertiaryMint,
        onTertiary: Color(0xFF002114),
        error: statusUrgent,
        onError: Colors.white,
        background: backgroundLight,
        onBackground: textPrimary,
        surface: surfaceWhite,
        onSurface: textPrimary,
        surfaceVariant: surfaceContainerHigh,
        onSurfaceVariant: textSecondary,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.newsreader(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: -0.8,
        ),
        displayMedium: GoogleFonts.newsreader(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.newsreader(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.newsreader(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        labelSmall: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceWhite,
        foregroundColor: textPrimary,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryCobalt, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: statusUrgent),
        ),
        hintStyle: GoogleFonts.manrope(
          fontSize: 14,
          color: outline,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryIndigo,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
