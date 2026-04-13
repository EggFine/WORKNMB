import 'app_locale.dart';
import 'app_strings.dart';

final stringsEn = AppStrings(
  locale: AppLocale.en,
  // App chrome
  appTagline: 'Quantify your job ratio',
  brandSubtitle: 'Workplace rating benchmark',
  // Section labels
  sectionHome: 'Home',
  sectionQuestionnaire: 'Survey',
  sectionResult: 'Result',
  sectionSettings: 'Settings',
  // Section descriptions
  homeDescription: 'Score your current job across 13 weighted dimensions.',
  questionnaireDescription:
      'Answer at your own pace. Jump back, skip, and revise anytime.',
  resultDescriptionLocked:
      'A few questions to go. Finish them to unlock the full analysis.',
  resultDescriptionUnlocked:
      'See your overall score, grade, per-factor contribution and advice.',
  settingsDescription:
      'Tweak theme, palette and language, or wipe answers to restart.',
  // Home page
  homeIntro:
      'Score 13 real-world dimensions of your current job — hours, commute, '
      'overtime, rest, salary and more — to get a grounded ratio rating.',
  homeStartButton: 'Start',
  homeContinueButton: 'Continue',
  homeRestartButton: 'Restart survey',
  homeViewResultButton: 'View my result',
  homeMetaTime: '~5 min',
  homeMetaFreeEdit: 'Edit anytime',
  homeProgressText: (answered, total) => 'Done $answered / $total',
  // Questionnaire
  quickJumpTitle: 'Jump to question',
  progressTitle: 'Progress',
  progressPercentDone: (percent, current, total) =>
      '$percent% done · now on $current/$total',
  progressCurrentQuestion: 'Current question',
  progressStatusCategory: (category) => 'Category: $category',
  progressStatusAnswered: (answered) => '$answered answered',
  answeredChip: 'Answered',
  prevButton: 'Previous',
  nextButton: 'Next',
  finishToResultButton: 'See my score',
  checkUnansweredButton: 'Check missing',
  numericQuickPickSalary: 'Quick picks',
  numericQuickPickOther: 'Common values',
  numericFeedbackSalaryTitle: (c) =>
      'Salary coefficient ×${c.toStringAsFixed(2)}',
  numericFeedbackSalaryAtCap: (m) =>
      'Capped at ×${m.toStringAsFixed(1)} (higher salaries no longer boost the score)',
  numericFeedbackSalaryBaseline: (baseline) => 'Baseline $baseline = ×1.00',
  numericFeedbackOtherTitle: (s) =>
      'Current score ${s.toStringAsFixed(1)} / 10',
  numericFeedbackHigherHint: (best, unit, worst) =>
      'Closer to $best $unit scores higher; below $worst $unit scores 0',
  numericFeedbackLowerHint: (best, unit, worst) =>
      'Closer to $best $unit scores higher; above $worst $unit scores 0',
  ratingSelectHint: 'Pick a rating',
  ratingSelectedPrefix: (label, stars, max) => 'Picked: $label ($stars / $max)',
  // Result
  resultLockedTitle: 'Score not unlocked yet',
  resultLockedBody: (remaining) =>
      '$remaining question(s) still to go. '
      'Finish them all to see your overall score, grade, factor breakdown and advice.',
  resultContinueButton: 'Continue',
  resultSummaryTitle: 'WORKNMB overall score',
  resultFormulaLabel: 'Formula',
  resultFormulaTemplate: (base, coef, total) =>
      '$base base × $coef salary coef = $total',
  resultSalaryInputTemplate: (salary, baseline, symbol) =>
      'Monthly salary input: $symbol$salary / mo (baseline $symbol$baseline)',
  resultFactorBreakdownTitle: 'Factor breakdown',
  resultFactorBreakdownDesc:
      'Each dimension is scored out of 10. Colors reflect relative contribution — higher is healthier.',
  resultSalaryCoefficientLabel: 'Salary coefficient',
  resultAdviceTitle: 'Weakest factors & advice',
  resultAdviceDesc:
      'The three lowest-scoring factors — usually the ones dragging your ratio down.',
  resultRestartButton: 'Restart',
  resultHomeButton: 'Home',
  gradeSText: 'Top-tier ratio',
  gradeAText: 'Good',
  gradeBText: 'OK',
  gradeCText: 'Mediocre',
  gradeDText: 'Consider switching jobs',
  // Settings
  appearanceTitle: 'Appearance',
  appearanceDescription:
      'Theme and palette changes repaint WORKNMB instantly so you can see '
      'how hierarchy and readability hold up under different visual languages.',
  themeModeLabel: 'Theme mode',
  themeModeLight: 'Light',
  themeModeDark: 'Dark',
  themeModeSystem: 'System',
  paletteLabel: 'Dynamic palette',
  paletteTideLabel: 'Tide',
  paletteTideDesc: 'Calm teal — balanced, professional',
  paletteEmberLabel: 'Ember',
  paletteEmberDesc: 'Warm orange — action-oriented',
  paletteMossLabel: 'Moss',
  paletteMossDesc: 'Quiet green — dark-mode friendly',
  languageLabel: 'Language',
  languageSystem: 'System',
  languageSectionTitle: 'Language / 语言',
  manageTitle: 'Survey reset',
  manageDescription:
      'Wipe all current answers and return to Home. This cannot be undone.',
  manageHasAnswers: (a, t) => '$a / $t questions answered',
  manageNoAnswers: 'No answers yet — nothing to reset.',
  manageResetButton: 'Reset survey',
  aboutTitle: 'About',
  aboutRepoLabel: 'Source code',
  aboutPreviewLabel: 'Live demo',
  // Currency / units
  currencySymbol: r'$',
  unitHour: 'h',
  unitMinute: 'min',
  unitDayPerWeek: 'day/wk',
  unitDay: 'days',
  unitMonth: 'mo',
  unitCurrency: 'USD',
  // Misc
  clipboardFallback: (url) =>
      'Could not open it — link copied to clipboard: $url',
);
