import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('darkModeEnabled')) {
      state = (prefs.getBool('darkModeEnabled') ?? false) ? ThemeMode.dark : ThemeMode.light;
    } else {
      state = ThemeMode.light;
      await prefs.setBool('darkModeEnabled', false);
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkModeEnabled', enabled);
    state = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}
