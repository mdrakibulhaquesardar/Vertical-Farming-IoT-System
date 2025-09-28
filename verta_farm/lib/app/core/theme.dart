import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF181A29),
      primaryColor: const Color(0xFF4CAF50),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF81D4FA),
        secondary: const Color(0xFF4CAF50),
        background: const Color(0xFF181A29),
        surface: Colors.white.withOpacity(0.08),
      ),
      cardColor: Colors.white.withOpacity(0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF23243B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF81D4FA),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(const Color(0xFF81D4FA)),
        trackColor: MaterialStateProperty.all(const Color(0xFF23243B)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF81D4FA)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF23243B),
        selectedItemColor: Color(0xFF81D4FA),
        unselectedItemColor: Colors.white38,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      primaryColor: const Color(0xFF4CAF50),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF2196F3),
        secondary: const Color(0xFF4CAF50),
        background: const Color(0xFFF5F7FB),
        surface: Colors.white,
      ),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ).apply(bodyColor: Colors.black87, displayColor: Colors.black87),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(const Color(0xFF2196F3)),
        trackColor: MaterialStateProperty.all(const Color(0xFFB3E5FC)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFF5F7FB),
        selectedItemColor: Color(0xFF2196F3),
        unselectedItemColor: Colors.black38,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
