// theme_provider.dart - Keep this as it was
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { dark, purple, yellow, pink, green, blue, brown, red }

class ThemeNotifier extends StateNotifier<ThemeModeOption> {
  // Default theme
  ThemeNotifier() : super(ThemeModeOption.dark) {
    loadTheme(); // Call public method in constructor
  }

  // Make this method public
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedTheme = prefs.getString('theme');

    if (storedTheme != null) {
      // Find the enum value matching the stored string
      state = ThemeModeOption.values.firstWhere(
        (e) => e.toString().split('.').last == storedTheme,
        orElse: () => ThemeModeOption.dark, // Fallback to dark if not found
      );
    } else {
      // If nothing stored, ensure state is default (already set by super, but safe)
      state = ThemeModeOption.dark;
    }
  }

  // setTheme remains public
  void setTheme(ThemeModeOption theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.toString().split('.').last);
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeModeOption>(
  (ref) => ThemeNotifier(),
);

final themeLoadingProvider = FutureProvider<void>((ref) async {
  await ref.read(themeNotifierProvider.notifier).loadTheme();
});