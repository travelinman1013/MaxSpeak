import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors based on our SuperDesign theme
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color secondaryColor = Color(0xFF2ECC71);
  static const Color accentColor = Color(0xFFFFD93D);
  static const Color errorColor = Color(0xFFE74C3C);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  static const Color lightBorder = Color(0xFFE0E0E0);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkBorder = Color(0xFF3A3A3A);
  
  // Reading highlight colors
  static const Color highlightColor = Color(0x4DFFD93D);
  static const Color selectionColor = Color(0x33FF6B35);
  static const Color progressColor = Color(0xFF2ECC71);
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      background: lightBackground,
      surface: lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: lightTextPrimary,
      onSurface: lightTextPrimary,
    ),
    scaffoldBackgroundColor: lightBackground,
    
    // Typography
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: lightTextSecondary,
      ),
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: BorderSide(color: lightBorder, width: 1),
      ),
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFF8A65),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFFF8A65),
      secondary: const Color(0xFF4CAF50),
      tertiary: const Color(0xFFFFE082),
      error: const Color(0xFFF44336),
      background: darkBackground,
      surface: darkSurface,
      onPrimary: darkBackground,
      onSecondary: darkBackground,
      onBackground: darkTextPrimary,
      onSurface: darkTextPrimary,
    ),
    scaffoldBackgroundColor: darkBackground,
    
    // Typography
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: darkTextSecondary,
      ),
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFF8A65),
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: BorderSide(color: darkBorder, width: 1),
      ),
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: darkBackground,
        backgroundColor: const Color(0xFFFF8A65),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFFF8A65), width: 2),
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: const Color(0xFFFF8A65),
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
  
  // Custom text styles for reading
  static TextStyle get readingTextStyle => GoogleFonts.merriweather(
    fontSize: 18,
    height: 1.8,
    letterSpacing: 0.01,
  );
  
  static TextStyle get readingTextStyleLarge => GoogleFonts.merriweather(
    fontSize: 22,
    height: 1.8,
    letterSpacing: 0.01,
  );
}