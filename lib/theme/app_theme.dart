import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF1B6B3A);
  static const primaryDark = Color(0xFF144D2A);
  static const primaryLight = Color(0xFFE8F5E9);
  static const gold = Color(0xFFC9A84C);
  static const goldLight = Color(0xFFFEF9E8);
  static const goldDark = Color(0xFF8D6E1F);
  static const surface = Color(0xFFF5F0E8);
  static const cardBg = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1A1A1A);
  static const cardBorder = Color(0xFFD6E8D0);
  // Asset Arapça font (offline okunurluk) — assets/fonts/Amiri
  static const arabicFont = 'Amiri';

  /// Arapça metin stili (asset font, offline).
  static TextStyle arabic({double size = 20, Color color = primaryDark, FontWeight weight = FontWeight.w600, double height = 1.9}) {
    return TextStyle(fontFamily: arabicFont, fontSize: size, height: height, color: color, fontWeight: weight);
  }
  // PRO palette - yeni koyu yeşil + mat altın
  static const proGradientStart = Color(0xFF1B6B3A);
  static const proGradientEnd = Color(0xFF2A8A4A);
  static const proGoldGradientStart = Color(0xFFC9A84C);
  static const proGoldGradientEnd = Color(0xFFD4B15A);
  static const proShadow = Color(0x1A1B6B3A);

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
      titleTextStyle: const TextStyle(
        fontFamily: arabicFont,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(fontFamily: arabicFont, fontSize: 28, fontWeight: FontWeight.w700, color: primaryDark),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: primaryDark),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
      bodyLarge: GoogleFonts.inter(fontSize: 15, height: 1.6, color: textDark),
      bodyMedium: GoogleFonts.inter(fontSize: 13.5, height: 1.5, color: Color(0xFF333333)),
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textDark),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 1,
      shadowColor: proShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: cardBorder, width: 1),
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
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
      );
}
