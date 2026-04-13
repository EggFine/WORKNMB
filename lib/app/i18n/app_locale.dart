import 'dart:ui';

/// 支持的语言 / 地区。enum value 同时承担本地化参数的"分派键"。
///
/// 添加一个 locale：在枚举里加一项、在 [AppStrings.of] 里加一个 case、
/// 在 domain 下新增对应的 questions_xx.dart 并在 localized_survey.dart 注册。
enum AppLocale {
  zh('简体中文', Locale('zh', 'CN')),
  ja('日本語', Locale('ja', 'JP')),
  en('English', Locale('en', 'US'));

  const AppLocale(this.displayName, this.locale);

  /// 供语言选择器显示的本地化自称。
  final String displayName;

  /// 对应的 Flutter [Locale]，传给 MaterialApp。
  final Locale locale;

  /// 从 Flutter Locale 解析回 AppLocale；未匹配时返回 null。
  static AppLocale? fromLocale(Locale? flutterLocale) {
    if (flutterLocale == null) return null;
    for (final v in values) {
      if (v.locale.languageCode == flutterLocale.languageCode) return v;
    }
    return null;
  }
}
