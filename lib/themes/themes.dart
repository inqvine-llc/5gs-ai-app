import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4FC3F7),
      brightness: Brightness.light,
      primary: const Color(0xFF4FC3F7),
      secondary: const Color(0xFFCDDC39),
      background: const Color(0xFFF8F8FF),
      surface: const Color(0xFFF5F5F5),
      onPrimary: const Color(0xFF003366),
      onSecondary: const Color(0xFF2F4F4F),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF0F8FF),
      titleTextStyle: GoogleFonts.orbitron(
        textStyle: const TextStyle(color: Color(0xFF003366), fontSize: 20),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.quantico(
        textStyle: const TextStyle(color: Color(0xFF003366)),
      ),
      bodyMedium: GoogleFonts.quantico(
        textStyle: const TextStyle(color: Color(0xFF2F4F4F)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true, // Enable Material 3
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7DF9FF),
      brightness: Brightness.dark,
      primary: const Color(0xFF7DF9FF),
      secondary: const Color(0xFFFF8767),
      tertiary: const Color(0xFF6CAC7E),
      background: const Color(0xFF1B1B1B),
      surface: const Color(0xFF353839),
      onPrimary: const Color(0xFF000000),
      onSecondary: const Color(0xFF2a3439),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF414A4C),
      titleTextStyle: GoogleFonts.orbitron(
        textStyle: const TextStyle(color: Color(0xFF7DF9FF), fontSize: 20),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.quantico(
        textStyle: const TextStyle(color: Color(0xFFFFFFFF)),
      ),
      bodyMedium: GoogleFonts.quantico(
        textStyle: const TextStyle(color: Color(0xFFCCCCCC)),
      ),
    ),
  );
}
