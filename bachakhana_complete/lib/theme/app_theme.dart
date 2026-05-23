import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color green        = Color(0xFF1B4332);
  static const Color greenDark    = Color(0xFF0F2D1F);
  static const Color greenMid     = Color(0xFF2D6A4F);
  static const Color greenLight   = Color(0xFF52B788);
  static const Color greenPale    = Color(0xFFD8F3DC);
  static const Color greenPaler   = Color(0xFFEEF8EE);
  static const Color saffron      = Color(0xFFE76F51);
  static const Color saffronLight = Color(0xFFF4A261);
  static const Color saffronPale  = Color(0xFFFFF0EB);
  static const Color cream        = Color(0xFFFDFAF5);
  static const Color bg           = Color(0xFFECEAE4);
  static const Color charcoal     = Color(0xFF1A1A2E);
  static const Color gray         = Color(0xFF6B7280);
  static const Color lightGray    = Color(0xFF9CA3AF);
  static const Color border       = Color(0xFFE8E4DC);
  static const Color blue         = Color(0xFF185FA5);
  static const Color bluePale     = Color(0xFFEFF6FF);
  static const Color gold         = Color(0xFFB45309);
  static const Color red          = Color(0xFFB91C1C);
  static const Color redPale      = Color(0xFFFEF2F2);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.saffron,
      surface: AppColors.cream,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    textTheme: GoogleFonts.soraTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.green,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.greenMid, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.sora(color: AppColors.lightGray, fontSize: 13),
    ),
  );
}

BoxDecoration cardDecoration({double radius = 18}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [BoxShadow(
    color: AppColors.green.withOpacity(0.08),
    blurRadius: 12, offset: const Offset(0, 2))],
);

BoxDecoration shadowDecoration({double radius = 18}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [BoxShadow(
    color: AppColors.green.withOpacity(0.14),
    blurRadius: 32, offset: const Offset(0, 8))],
);
