import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  // ==========================================
  // ----------------- COLORS -----------------
  // ==========================================

  static const Color primaryBrand = Color(0xFFFF5500); 
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color semiWhite = Color.fromARGB(255, 188, 188, 188);
  static const Color appBarItems = Color(0xFFD6D6D6);
  static const Color link = Color(0xFF2F80ED);
  static const Color whatsApp = Color(0xFF25D366);
  static const Color whatsAppStatus = Color(0xFF128C7E);
  static const Color instagram = Color(0xFFE1306C);
  static const Color sms = Color(0xFF2F80ED);
  static const Color shareCircle = Color.fromARGB(255, 58, 58, 58);
  static const Color iconBg = Color(0xFF121212);
  
  

  // ==========================================   /// --- USAGE EXAMPLE ACROSS THE PROJECT ---
  // ----------- CUSTOM TEXT STYLES -----------   /// style: AppTheme.headlineLarge,
  // ==========================================   /// Style: AppTheme.labelSmall.copyWith(color: Colors.grey),

  static TextStyle get appBarTitle => GoogleFonts.inter(
    fontSize: 21,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.75,
    color: appBarItems,
  );

  static TextStyle get navBarText => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: textSecondary,
  );

  static TextStyle get miniPlayerFont1 => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.25,
    color: textPrimary,
  );

  static TextStyle get miniPlayerFont2 => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: semiWhite,
  );

  static TextStyle get bodyNormal => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.25,
    color: textPrimary,
  );

  // ==========================================
  // ---------- GENERAL TEXT STYLES -----------
  // ==========================================
  
  // --- HEADLINES ---
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 57,
    fontWeight: FontWeight.w900, // Black
    letterSpacing: -0.75,
    color: textPrimary,
  );

  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800, // Extra-Bold
    color: textPrimary,
  );

  // --- TITLES ---
  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.25,
    color: textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w900, // Medium
    letterSpacing: 0.15,
    color: textPrimary,
  );

  // --- BODY ---
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.5,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: textSecondary,
  );

  // --- LABELS  ---
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: textPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: textSecondary,
  );

  // ==========================================
  // ------------  THE MAIN THEME  ------------
  // ==========================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      
      colorScheme: const ColorScheme.dark(
        primary: primaryBrand,
        surface: surface,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        toolbarHeight: 56.0,
        elevation: 0,
        titleTextStyle: appBarTitle, 
        iconTheme: const IconThemeData(color:appBarItems), 
      ),
    );
  }
}