import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand color palette
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep Royal Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Vibrant Blue
  static const Color accentIndigo = Color(0xFF6366F1); // Indigo Accent
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color cardLight = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500

  // Status & Urgency Colors
  static const Color statusUrgent = Color(0xFFEF4444); // Red 500
  static const Color statusHigh = Color(0xFFF97316); // Orange 500
  static const Color statusMedium = Color(0xFFF59E0B); // Amber 500
  static const Color statusLow = Color(0xFF10B981); // Emerald 500
  static const Color aiBadgeColor = Color(0xFF8B5CF6); // Purple 500

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentIndigo,
        background: backgroundLight,
        surface: cardLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48), // Touch target >= 48dp (FR-PLAT-06)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
