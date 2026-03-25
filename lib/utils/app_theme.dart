import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background    = Color(0xFF0A0F0A);
  static const Color surface       = Color(0xFF111A11);
  static const Color card          = Color(0xFF172117);
  static const Color cardAlt       = Color(0xFF1E2A1E);
  static const Color primary       = Color(0xFF6FCF3A);
  static const Color primaryDark   = Color(0xFF4CAF1E);
  static const Color lime          = Color(0xFFB8FF57);
  static const Color accent        = Color(0xFF39D353);
  static const Color textPrimary   = Color(0xFFF0FFF0);
  static const Color textSecondary = Color(0xFF8FAF8F);
  static const Color textHint      = Color(0xFF4A6A4A);
  static const Color divider       = Color(0xFF1F2F1F);
  static const Color error         = Color(0xFFFF6B6B);
  static const Color warning       = Color(0xFFFFB347);
  static const Color proteinColor  = Color(0xFF6FCF3A);
  static const Color carbsColor    = Color(0xFF57C8FF);
  static const Color fatColor      = Color(0xFFFFB347);
  static const Color calorieColor  = Color(0xFFB8FF57);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.lime,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.poppins(color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.poppins(color: AppColors.textSecondary),
      bodySmall: GoogleFonts.poppins(color: AppColors.textHint),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
      hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
