import 'package:flutter/widgets.dart';

import 'app_locale.dart';
import 'strings_en.dart';
import 'strings_ja.dart';
import 'strings_zh.dart';

/// 所有 UI 文案的中心容器。
///
/// 每个 locale 对应一个 [AppStrings] 实例，通过 [AppStrings.of] 从当前
/// widget 树中读取。加新 key 时在这里加字段，再在三个 locale 文件里全部填上。
///
/// 非 const 构造：带参数的文案用 `String Function(...)` 字段承载，Dart 无法
/// const lambda 表达式，所以整个类使用 `final` 字段 + 普通构造函数。
class AppStrings {
  AppStrings({
    required this.locale,
    // App chrome
    required this.appTagline,
    required this.brandSubtitle,
    // Section labels
    required this.sectionHome,
    required this.sectionQuestionnaire,
    required this.sectionResult,
    required this.sectionSettings,
    // Section descriptions (shown on page header)
    required this.homeDescription,
    required this.questionnaireDescription,
    required this.resultDescriptionLocked,
    required this.resultDescriptionUnlocked,
    required this.settingsDescription,
    // Home page
    required this.homeIntro,
    required this.homeStartButton,
    required this.homeContinueButton,
    required this.homeRestartButton,
    required this.homeViewResultButton,
    required this.homeMetaTime,
    required this.homeMetaFreeEdit,
    required this.homeProgressText,
    // Questionnaire
    required this.quickJumpTitle,
    required this.progressTitle,
    required this.progressPercentDone,
    required this.progressCurrentQuestion,
    required this.progressStatusCategory,
    required this.progressStatusAnswered,
    required this.answeredChip,
    required this.prevButton,
    required this.nextButton,
    required this.finishToResultButton,
    required this.checkUnansweredButton,
    required this.numericQuickPickSalary,
    required this.numericQuickPickOther,
    required this.numericFeedbackSalaryTitle,
    required this.numericFeedbackSalaryAtCap,
    required this.numericFeedbackSalaryBaseline,
    required this.numericFeedbackOtherTitle,
    required this.numericFeedbackHigherHint,
    required this.numericFeedbackLowerHint,
    required this.ratingSelectHint,
    required this.ratingSelectedPrefix,
    // Result page
    required this.resultLockedTitle,
    required this.resultLockedBody,
    required this.resultContinueButton,
    required this.resultSummaryTitle,
    required this.resultFormulaLabel,
    required this.resultFormulaTemplate,
    required this.resultSalaryInputTemplate,
    required this.resultFactorBreakdownTitle,
    required this.resultFactorBreakdownDesc,
    required this.resultSalaryCoefficientLabel,
    required this.resultAdviceTitle,
    required this.resultAdviceDesc,
    required this.resultRestartButton,
    required this.resultHomeButton,
    required this.gradeSText,
    required this.gradeAText,
    required this.gradeBText,
    required this.gradeCText,
    required this.gradeDText,
    // Settings page
    required this.appearanceTitle,
    required this.appearanceDescription,
    required this.themeModeLabel,
    required this.themeModeLight,
    required this.themeModeDark,
    required this.themeModeSystem,
    required this.paletteLabel,
    required this.paletteTideLabel,
    required this.paletteTideDesc,
    required this.paletteEmberLabel,
    required this.paletteEmberDesc,
    required this.paletteMossLabel,
    required this.paletteMossDesc,
    required this.languageLabel,
    required this.languageSystem,
    required this.manageTitle,
    required this.manageDescription,
    required this.manageHasAnswers,
    required this.manageNoAnswers,
    required this.manageResetButton,
    required this.aboutTitle,
    required this.aboutRepoLabel,
    required this.aboutPreviewLabel,
    // Currency / number words used in some labels
    required this.currencySymbol,
    // Unit words (localized per locale)
    required this.unitHour,
    required this.unitMinute,
    required this.unitDayPerWeek,
    required this.unitDay,
    required this.unitMonth,
    required this.unitCurrency,
    // Snackbar messages
    required this.clipboardFallback,
    // Language picker header in settings
    required this.languageSectionTitle,
  });

  final AppLocale locale;

  // App chrome
  final String appTagline;
  final String brandSubtitle;

  // Section labels
  final String sectionHome;
  final String sectionQuestionnaire;
  final String sectionResult;
  final String sectionSettings;

  // Section descriptions
  final String homeDescription;
  final String questionnaireDescription;
  final String resultDescriptionLocked;
  final String resultDescriptionUnlocked;
  final String settingsDescription;

  // Home page
  final String homeIntro;
  final String homeStartButton;
  final String homeContinueButton;
  final String homeRestartButton;
  final String homeViewResultButton;
  final String homeMetaTime;
  final String homeMetaFreeEdit;

  /// format(answered, total)
  final String Function(int answered, int total) homeProgressText;

  // Questionnaire
  final String quickJumpTitle;
  final String progressTitle;

  /// format(percent)
  final String Function(int percent, int current, int total)
  progressPercentDone;
  final String progressCurrentQuestion;

  /// format(category)
  final String Function(String category) progressStatusCategory;

  /// format(answered)
  final String Function(int answered) progressStatusAnswered;
  final String answeredChip;
  final String prevButton;
  final String nextButton;
  final String finishToResultButton;
  final String checkUnansweredButton;
  final String numericQuickPickSalary;
  final String numericQuickPickOther;

  /// format(coefficient)
  final String Function(double coefficient) numericFeedbackSalaryTitle;

  /// format(maxCoefficient)
  final String Function(double maxCoefficient) numericFeedbackSalaryAtCap;

  /// format(baselineFormatted, unit)
  final String Function(String baseline) numericFeedbackSalaryBaseline;

  /// format(score)
  final String Function(double score) numericFeedbackOtherTitle;

  /// format(bestValue, unit, worstValue, unit)
  final String Function(String best, String unit, String worst)
  numericFeedbackHigherHint;
  final String Function(String best, String unit, String worst)
  numericFeedbackLowerHint;
  final String ratingSelectHint;

  /// format(label, stars, maxRating)
  final String Function(String label, int stars, int max) ratingSelectedPrefix;

  // Result page
  final String resultLockedTitle;

  /// format(remaining)
  final String Function(int remaining) resultLockedBody;
  final String resultContinueButton;
  final String resultSummaryTitle;
  final String resultFormulaLabel;

  /// format(base, coef, total)
  final String Function(String base, String coef, String total)
  resultFormulaTemplate;

  /// format(salaryFormatted, baselineFormatted, symbol)
  final String Function(String salary, String baseline, String symbol)
  resultSalaryInputTemplate;
  final String resultFactorBreakdownTitle;
  final String resultFactorBreakdownDesc;
  final String resultSalaryCoefficientLabel;
  final String resultAdviceTitle;
  final String resultAdviceDesc;
  final String resultRestartButton;
  final String resultHomeButton;

  final String gradeSText;
  final String gradeAText;
  final String gradeBText;
  final String gradeCText;
  final String gradeDText;

  // Settings
  final String appearanceTitle;
  final String appearanceDescription;
  final String themeModeLabel;
  final String themeModeLight;
  final String themeModeDark;
  final String themeModeSystem;
  final String paletteLabel;
  final String paletteTideLabel;
  final String paletteTideDesc;
  final String paletteEmberLabel;
  final String paletteEmberDesc;
  final String paletteMossLabel;
  final String paletteMossDesc;
  final String languageLabel;
  final String languageSystem;
  final String manageTitle;
  final String manageDescription;

  /// format(answered, total)
  final String Function(int answered, int total) manageHasAnswers;
  final String manageNoAnswers;
  final String manageResetButton;
  final String aboutTitle;
  final String aboutRepoLabel;
  final String aboutPreviewLabel;

  // Currency / units
  final String currencySymbol;
  final String unitHour;
  final String unitMinute;
  final String unitDayPerWeek;
  final String unitDay;
  final String unitMonth;
  final String unitCurrency;

  // Misc
  /// format(url)
  final String Function(String url) clipboardFallback;
  final String languageSectionTitle;

  /// 从 widget 树获取当前 AppStrings。
  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
    assert(scope != null, 'AppStringsScope missing. Wrap your app with it.');
    return scope!.strings;
  }

  /// 根据 locale 返回对应的常量实例。
  static AppStrings forLocale(AppLocale l) {
    return switch (l) {
      AppLocale.zh => stringsZh,
      AppLocale.ja => stringsJa,
      AppLocale.en => stringsEn,
    };
  }
}

/// 把 [AppStrings] 注入 widget 树的 InheritedWidget。
class AppStringsScope extends InheritedWidget {
  const AppStringsScope({
    required this.strings,
    required super.child,
    super.key,
  });

  final AppStrings strings;

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) =>
      oldWidget.strings.locale != strings.locale;
}
