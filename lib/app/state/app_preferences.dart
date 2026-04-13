import 'package:flutter/material.dart';

import '../i18n/app_locale.dart';
import '../theme/app_palette.dart';

/// 应用级偏好（主题模式、色板、语言）。
///
/// [locale] 为 `null` 时表示"跟随系统"。
class AppPreferences extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppPalette _palette = AppPalette.tide;
  AppLocale? _locale;

  ThemeMode get themeMode => _themeMode;
  AppPalette get palette => _palette;

  /// 用户明确选定的 locale；`null` 表示跟随系统。
  AppLocale? get locale => _locale;

  /// 综合考虑用户选择 + 系统 locale 后的生效 locale。
  ///
  /// 用户明确选过 → 用用户的；否则拿系统 locale 匹配；实在不匹配兜底到 zh。
  AppLocale resolveLocale(Locale? systemLocale) {
    if (_locale != null) return _locale!;
    return AppLocale.fromLocale(systemLocale) ?? AppLocale.zh;
  }

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

  /// 设置应用语言；传 `null` 恢复"跟随系统"。
  void setLocale(AppLocale? nextLocale) {
    if (_locale == nextLocale) return;
    _locale = nextLocale;
    notifyListeners();
  }
}
