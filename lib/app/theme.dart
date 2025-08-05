import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette
  static const Color primaryGreen = Color(0xFF00651F);
  static const Color lightGreen = Color(0xFF2DBF4C);
  static const Color darkYellow = Color(0xFFFFAA00);
  static const Color lightYellow = Color(0xFFFCDB5A);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: const Color.fromARGB(255, 5, 207, 120),
        secondary: darkYellow,
        background: Color(0xFFF5F5F5),
        onPrimary: Color(0xFF00651F),
        onSecondary: Colors.black,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        bodyLarge: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        bodyMedium: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        bodySmall: GoogleFonts.nunito(fontWeight: FontWeight.normal),
      ),
      useMaterial3: true,
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.black54),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 5, 207, 120),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
        ),
      ),
    );
  }

  // Dark Theme (optional)
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: lightGreen,
        secondary: lightYellow,
        background: Colors.black,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        bodyLarge: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodySmall: GoogleFonts.nunito(
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ),
      useMaterial3: true,
    );
  }
}
