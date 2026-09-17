import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF0D5C3D);
  static const primaryDark = Color(0xFF083826);
  static const primaryLight = Color(0xFFE8F5E9);
  static const gold = Color(0xFFC5A253);
  static const goldLight = Color(0xFFFFF8E1);
  static const goldDark = Color(0xFF8D6E1F);
  static const surface = Color(0xFFF9FAF7);
  static const cardBg = Colors.white;
  // PRO palette
  static const proGradientStart = Color(0xFF0D5C3D);
  static const proGradientEnd = Color(0xFF1A8A5A);
  static const proGoldGradientStart = Color(0xFFB8942E);
  static const proGoldGradientEnd = Color(0xFFD4B15A);
  static const proShadow = Color(0x1A0D5C3D);

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: gold,
      surface: surface,
      onPrimary: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.amiri(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.amiri(fontSize: 28, fontWeight: FontWeight.w700, color: primaryDark),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: primaryDark),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryDark),
      bodyLarge: GoogleFonts.inter(fontSize: 15, height: 1.6, color: const Color(0xFF2D3A36)),
      bodyMedium: GoogleFonts.inter(fontSize: 13.5, height: 1.5, color: const Color(0xFF5A6B66)),
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 2,
      shadowColor: proShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static LinearGradient get proGradient => const LinearGradient(colors: [proGradientStart, proGradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static LinearGradient get goldGradient => const LinearGradient(colors: [proGoldGradientStart, proGoldGradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static BoxDecoration get proCardDecoration => BoxDecoration(
        gradient: proGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 6))],
      );
}
