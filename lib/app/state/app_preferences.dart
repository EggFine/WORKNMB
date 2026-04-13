import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class AppPreferences extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppPalette _palette = AppPalette.tide;

  ThemeMode get themeMode => _themeMode;

  AppPalette get palette => _palette;

  Brightness resolveBrightness(Brightness platformBrightness) {
    return switch (_themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };
  }

  bool isDark(Brightness platformBrightness) {
    return resolveBrightness(platformBrightness) == Brightness.dark;
  }

  void setThemeMode(ThemeMode nextMode) {
    if (_themeMode == nextMode) return;
    _themeMode = nextMode;
    notifyListeners();
  }

  void toggleBrightness(Brightness currentBrightness) {
    _themeMode = currentBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  void setPalette(AppPalette nextPalette) {
    if (_palette == nextPalette) return;
    _palette = nextPalette;
    notifyListeners();
  }
}
