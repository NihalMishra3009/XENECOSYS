import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildXenHubTheme(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF07111D),
    textTheme: GoogleFonts.comfortaaTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: const Color(0xFFE6EEF8),
      displayColor: const Color(0xFFE6EEF8),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      toolbarHeight: 76,
      iconTheme: const IconThemeData(color: Color(0xFFEAF6FF)),
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFEAF6FF),
        letterSpacing: 0.8,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: const Color(0xFFEAF6FF),
      unselectedLabelColor: const Color(0xFF8AA3BF),
      indicatorColor: Colors.transparent,
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF0E1A2B),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: const EdgeInsets.all(0),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF132235),
      labelStyle: const TextStyle(color: Color(0xFFE6EEF8)),
      side: BorderSide(color: const Color(0xFF2A4561).withValues(alpha: 0.7)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    ),
    dividerTheme: const DividerThemeData(space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF132235),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
  );
}
