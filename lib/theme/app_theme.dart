import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema minimalis terinspirasi desain Skandinavia (warm greige gradient,
/// tipografi sans-serif tipis, garis pemisah halus, dan ikon garis minimalis).
class AppTheme {
  AppTheme._();

  // Palet warna sesuai template UI
  static const Color bgTop = Color(0xFFF6F4ED);
  static const Color bgMiddle = Color(0xFFE7E5DE);
  static const Color bgBottom = Color(0xFFD5D3CD);

  static const Color inkPrimary = Color(0xFF2E2E2B);
  static const Color inkSecondary = Color(0xFF5A5955);
  static const Color inkMuted = Color(0xFF8C8A84);
  static const Color hairline = Color(0xFFB5B3AC);
  static const Color circleBorder = Color(0xFF93918B);
  static const Color surfaceCard = Color(0x99FBF9F4);
  static const Color surfaceSolid = Color(0xFFF4F2EB);
  static const Color errorColor = Color(0xFFA6443A);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMiddle, bgBottom],
    stops: [0.0, 0.55, 1.0],
  );

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.montserratTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgTop,
      colorScheme: const ColorScheme.light(
        primary: inkPrimary,
        onPrimary: bgTop,
        secondary: inkSecondary,
        onSecondary: bgTop,
        surface: surfaceSolid,
        onSurface: inkPrimary,
        error: errorColor,
        onError: bgTop,
        outline: hairline,
      ),
      textTheme: baseTextTheme.copyWith(
        // Nama kota di bagian atas (misal: STOCKHOLM)
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          letterSpacing: 4.5,
          color: inkPrimary,
        ),
        // Angka suhu utama berukuran sangat besar dan tipis (misal: 75)
        displayLarge: GoogleFonts.montserrat(
          fontSize: 132,
          fontWeight: FontWeight.w100,
          height: 1.0,
          letterSpacing: -2.0,
          color: inkPrimary,
        ),
        // Deskripsi kondisi cuaca (misal: MOSTLY SUNNY)
        titleMedium: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 3.2,
          color: inkSecondary,
        ),
        // Label hari pada prakiraan (TODAY, MON, TUES)
        labelLarge: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.2,
          color: inkPrimary,
        ),
        // Angka suhu harian (77° | 54°)
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          color: inkPrimary,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: inkPrimary,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.8,
          color: inkSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: inkPrimary,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        hintStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.0,
          color: inkMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: hairline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: hairline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: inkPrimary, width: 1.2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: hairline,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
