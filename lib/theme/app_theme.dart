import 'package:flutter/material.dart';

/// App theme configured for MediCare AI.
/// Provides a calm, trustworthy healthcare aesthetic with high contrast,
/// legible typography, and generous touch targets suited for patients of all ages.
class AppTheme {
  AppTheme._();

  // Primary palette: Medical Teal / Ocean Green - promotes calm and trust
  static const Color primaryTeal = Color(0xFF5300B7);
  static const Color primaryTealDark = Color(0xFF250059);
  static const Color primaryTealLight = Color(0xFFEBDDFF);
  static const Color primaryTealMuted = Color(0xFF6D28D9);

  // Accent & Status colors
  static const Color accentSage = Color(0xFF4A7C59);
  static const Color successGreen = Color(0xFF1E824C);
  static const Color errorRed = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Neutral palette: High-contrast slate and warm off-whites
  static const Color backgroundLight = Color(0xFFFAF8FF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFCCC3D7);
  static const Color textPrimary = Color(0xFF131B2E); // AAA contrast on light
  static const Color textSecondary = Color(0xFF4A4455);
  static const Color textTertiary = Color(0xFF7B7486);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryTeal,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF6D28D9),
      onPrimaryContainer: Colors.white,
      secondary: const Color(0xFF6E3ACA),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF8856E5),
      onSecondaryContainer: Colors.white,
      error: errorRed,
      onError: Colors.white,
      errorContainer: errorContainer,
      onErrorContainer: const Color(0xFF410002),
      surface: surfaceWhite,
      onSurface: textPrimary,
      surfaceContainerHighest: const Color(0xFFEAEDFF),
      outline: cardBorder,
      outlineVariant: const Color(0xFFCCC3D7),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: null, // Uses system default readable font
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary, size: 24),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
          height: 1.25,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.45,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: const TextStyle(
          color: textTertiary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryTeal,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: primaryTeal,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryTeal, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed, width: 2.0),
        ),
        errorStyle: const TextStyle(
          color: errorRed,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54), // Accessible touch target
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          minimumSize: const Size(48, 48), // Ensure minimum 48x48 tap target
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
