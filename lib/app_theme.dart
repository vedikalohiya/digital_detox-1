import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark Ocean Blue Design System for Digital Detox App
class AppTheme {
  // ============ COLOR PALETTE ============

  /// Deep Blue (#2C5F8D) - Rich, sophisticated
  static const Color primaryDeepTeal = Color(0xFF2C5F8D);

  /// Medium Blue (#4A8AB8) - Balanced blue
  static const Color softTeal = Color(0xFF4A8AB8);

  /// Dark Blue Background (#4A8AB8) - Aesthetic dark background
  static const Color coolWhite = Color(0xFF4A8AB8);

  /// Accent colors
  static const Color accentTeal = Color(0xFF5BA3D4);
  static const Color darkTeal = Color(0xFF1E4A6B);
  static const Color lightTeal = Color(0xFF7EC4E8);

  /// Semantic colors
  static const Color successGreen = Color(0xFF81C784);
  static const Color warningOrange = Color(0xFFFFB74D);
  static const Color errorRed = Color(0xFFE57373);
  static const Color infoBlue = Color(0xFF64B5F6);

  /// Text colors - Light for visibility on dark background
  static const Color textPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color textSecondary = Color.fromARGB(255, 0, 0, 0);
  static const Color textOnPrimary = Color.fromARGB(255, 0, 0, 0);

  // ============ GRADIENTS ============

  /// Primary gradient - dark aesthetic blue
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A8AB8), Color(0xFF5BA3D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background gradient - darker aesthetic blue
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF4A8AB8), Color(0xFF2C5F8D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Card gradient - semi-transparent white containers
  static LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF).withOpacity(0.15),
      Color(0xFFFFFFFF).withOpacity(0.1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ TYPOGRAPHY ============

  /// Heading style (Poppins)
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryDeepTeal,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryDeepTeal,
    letterSpacing: -0.3,
  );

  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primaryDeepTeal,
  );

  static TextStyle heading4 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryDeepTeal,
  );

  /// Body text style (Inter)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );

  /// Button text style
  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textOnPrimary,
    letterSpacing: 0.5,
  );

  /// Label text style
  static TextStyle labelText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryDeepTeal,
  );

  // ============ COMPONENT STYLES ============

  /// Input decoration theme
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    String? errorText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      labelStyle: AppTheme.labelText,
      hintStyle: bodyMedium.copyWith(color: textSecondary),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: primaryDeepTeal)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: softTeal.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: softTeal.withOpacity(0.5), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryDeepTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// Primary button style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryDeepTeal,
    foregroundColor: textOnPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    shadowColor: primaryDeepTeal.withOpacity(0.4),
    textStyle: buttonText,
  );

  /// Secondary button style
  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryDeepTeal,
    side: const BorderSide(color: primaryDeepTeal, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: buttonText.copyWith(color: primaryDeepTeal),
  );

  /// Card decoration
  static BoxDecoration cardDecoration({
    bool useGradient = true,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      gradient: useGradient ? cardGradient : null,
      color: backgroundColor ?? (useGradient ? null : Colors.white),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: primaryDeepTeal.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// App bar theme
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primaryDeepTeal,
    foregroundColor: textOnPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textOnPrimary,
    ),
  );

  // ============ THEME DATA ============

  /// Complete Material theme
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDeepTeal,
        primary: primaryDeepTeal,
        secondary: softTeal,
        background: coolWhite,
        surface: Colors.white,
        error: errorRed,
      ),
      scaffoldBackgroundColor: coolWhite,
      appBarTheme: appBarTheme,
      textTheme: TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        headlineMedium: heading4,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: buttonText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: primaryDeepTeal.withOpacity(0.15),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softTeal.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softTeal.withOpacity(0.5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDeepTeal, width: 2),
        ),
      ),
    );
  }
}
