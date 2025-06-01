import 'package:budgify/initialization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    String? storedLang = sharedPreferences.getString('language');
    Locale newLocale;
    switch (storedLang) {
      case 'العربية':
        newLocale = const Locale('ar');
        break;
      case 'Spanish':
        newLocale = const Locale('es');
        break;
      case 'French':
        newLocale = const Locale('fr');
        break;
      case 'German':
        newLocale = const Locale('de');
        break;
      case 'Chinese':
        newLocale = const Locale('zh');
        break;
      case 'Portuguese':
        newLocale = const Locale('pt');
        break;
      default:
        newLocale = const Locale('en');
    }
    state = newLocale;
    Get.updateLocale(state);
  }

  Future<void> setLanguage(String lang) async {
    Locale newLocale;
    // Map UI display name to stored value
    String storedLang = lang == 'العربية' ? 'Arabic' : lang;
    switch (storedLang) {
      case 'Arabic':
        newLocale = const Locale('ar');
        break;
      case 'Spanish':
        newLocale = const Locale('es');
        break;
      case 'French':
        newLocale = const Locale('fr');
        break;
      case 'German':
        newLocale = const Locale('de');
        break;
      case 'Chinese':
        newLocale = const Locale('zh');
        break;
      case 'Portuguese':
        newLocale = const Locale('pt');
        break;
      default:
        newLocale = const Locale('en');
        storedLang = 'English';
    }
    state = newLocale;
    await sharedPreferences.setString('language', lang);
    Get.updateLocale(newLocale);
  }
}
