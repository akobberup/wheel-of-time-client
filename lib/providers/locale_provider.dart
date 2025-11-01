import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('da')); // Danish as default

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLocale() {
    state = state.languageCode == 'da' ? const Locale('en') : const Locale('da');
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
