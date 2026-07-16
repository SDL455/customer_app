import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design system for the FoodPanda-style app.
/// The brand uses a vibrant pink/rose palette consistent with FoodPanda.
class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFFE21B70); // FoodPanda pink
  static const Color primaryDark = Color(0xFFB3135B);
  static const Color primaryLight = Color(0xFFFFE6F0);
  static const Color secondary = Color(0xFFFE3913); // accent orange-red
  static const Color accent = Color(0xFFFFC107);

  // Neutrals
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF7F8FA);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFECECEC);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.poppins(
            fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        displayMedium: GoogleFonts.poppins(
            fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        displaySmall: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineMedium: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, color: textPrimary),
        bodyMedium: GoogleFonts.poppins(fontSize: 13, color: textSecondary),
        labelLarge: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        primaryColor: primary,
        scaffoldBackgroundColor: scaffoldBg,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: secondary,
          error: error,
          surface: surface,
          background: background,
        ),
        textTheme: _textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          elevation: 0,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: TextStyle(
              color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: error),
          ),
          labelStyle: const TextStyle(color: textSecondary),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.06),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: textPrimary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
}
