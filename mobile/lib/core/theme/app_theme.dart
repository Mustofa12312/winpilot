// WinPilot Mobile — Design System & Theme
// Glassmorphism + Material 3 + Dark/Light modes
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WinPilotTheme {
  WinPilotTheme._();

  // ─── Colors ───────────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2D8CFF);
  static const Color primaryBlueDark = Color(0xFF1A6FDB);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color successGreen = Color(0xFF00C896);
  static const Color warningOrange = Color(0xFFFF8C42);
  static const Color dangerRed = Color(0xFFFF4D6D);
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8FA3CC);
  static const Color textMuted = Color(0xFF5A6A8A);

  // Dark background layers
  static const Color bgBase = Color(0xFF0A0D1A);
  static const Color bgSurface = Color(0xFF111827);
  static const Color bgCard = Color(0xFF1C2333);
  static const Color bgCardHover = Color(0xFF232D45);
  static const Color bgGlass = Color(0x1A2D5AFF);

  // Borders
  static const Color borderSubtle = Color(0x1A8FA3CC);
  static const Color borderGlass = Color(0x33FFFFFF);

  // Status colors
  static const Color statusOnline = Color(0xFF00C896);
  static const Color statusOffline = Color(0xFF5A6A8A);
  static const Color statusWarning = Color(0xFFFF8C42);
  static const Color statusCritical = Color(0xFFFF4D6D);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D8CFF), Color(0xFF00D4FF)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0D1A), Color(0xFF111827), Color(0xFF0D1529)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C2333), Color(0xFF151E2E)],
  );

  static const LinearGradient cpuGradient = LinearGradient(
    colors: [Color(0xFF2D8CFF), Color(0xFF00D4FF)],
  );

  static const LinearGradient ramGradient = LinearGradient(
    colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
  );

  static const LinearGradient diskGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF00C896)],
  );

  static const LinearGradient netGradient = LinearGradient(
    colors: [Color(0xFFE67E22), Color(0xFFFF8C42)],
  );

  // ─── Typography ───────────────────────────────────────────────────────────
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
    const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w600, color: textPrimary),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: textPrimary),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.15),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.1),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.5),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 0.5),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted, letterSpacing: 0.5),
    ),
  );

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgBase,
    textTheme: textTheme,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentCyan,
      surface: bgSurface,
      error: dangerRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgBase,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: bgCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderSubtle, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bgSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      indicatorColor: primaryBlue.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderSubtle,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(color: textSecondary, size: 20),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

// ─── Spacing System ──────────────────────────────────────────────────────────
class Spacing {
  Spacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// ─── Border Radius ───────────────────────────────────────────────────────────
class Radii {
  Radii._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
  static BorderRadius get smBR => BorderRadius.circular(sm);
  static BorderRadius get mdBR => BorderRadius.circular(md);
  static BorderRadius get lgBR => BorderRadius.circular(lg);
  static BorderRadius get xlBR => BorderRadius.circular(xl);
}

// ─── Shadows ─────────────────────────────────────────────────────────────────
class AppShadows {
  AppShadows._();
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x402D8CFF),
      blurRadius: 30,
      offset: Offset(0, 0),
      spreadRadius: -5,
    ),
  ];
}
