
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppPalette.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPalette.white,
    fontFamily: GoogleFonts.poppins().fontFamily,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
     backgroundColor: AppPalette.white,
      selectedItemColor: AppPalette.black,
      unselectedItemColor: AppPalette.grey,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.blue,
     iconTheme: IconThemeData(color: Colors.black),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.poppins(color: AppPalette.black),
      bodyMedium: GoogleFonts.poppins(color: AppPalette.black),
      bodySmall: GoogleFonts.poppins(color: AppPalette.black),
    )
  );
}