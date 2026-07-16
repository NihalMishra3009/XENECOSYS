import 'package:flutter/material.dart';

class AppTheme {
  static const Color _bg = Color(0xFF08111B);
  static const Color _surface = Color(0xFF0F1A27);
  static const Color _ink = Color(0xFFEAF4FB);
  static const Color _muted = Color(0xFF90A7BC);
  static const Color _border = Color(0xFF21384D);

  static ThemeData lightTheme() {
    return _theme(Brightness.light);
  }

  static ThemeData darkTheme() {
    return _theme(Brightness.dark);
  }

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF071019) : _bg;
    final surface = isDark ? const Color(0xFF0D1723) : _surface;
    final ink = isDark ? const Color(0xFFF2F7FB) : _ink;
    final muted = isDark ? const Color(0xFF9AB0C3) : _muted;
    final border = isDark ? const Color(0xFF243A4F) : _border;
    final accent = isDark ? const Color(0xFF79D4F2) : const Color(0xFF7BC5E8);

    final scheme = isDark
        ? ColorScheme.dark(
            primary: ink,
            onPrimary: const Color(0xFF08111B),
            secondary: accent,
            onSecondary: const Color(0xFF08111B),
            surface: surface,
            onSurface: ink,
            error: const Color(0xFFF08A8A),
            onError: const Color(0xFF08111B),
          )
        : ColorScheme.light(
            primary: ink,
            onPrimary: const Color(0xFF08111B),
            secondary: accent,
            onSecondary: const Color(0xFF08111B),
            surface: surface,
            onSurface: ink,
            error: const Color(0xFFF08A8A),
            onError: const Color(0xFF08111B),
          );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Comfortaa',
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: ink,
        titleTextStyle: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shadowColor: const Color(0x26112635),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: ink,
          foregroundColor: const Color(0xFF08111B),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: const Color(0xFF08111B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ink),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF152232) : const Color(0xFF162636),
        selectedColor: ink.withValues(alpha: 0.12),
        labelStyle: TextStyle(color: ink),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: border),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: muted),
      ),
    );
  }
}
