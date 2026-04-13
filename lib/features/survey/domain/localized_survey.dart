import '../../../app/i18n/app_locale.dart';
import 'questions_en.dart';
import 'questions_ja.dart';
import 'questions_zh.dart';
import 'survey_data.dart';

/// 一个 locale 的完整题库数据包。
class LocalizedSurvey {
  const LocalizedSurvey({
    required this.questions,
    required this.improvementTips,
    required this.gradeDescriptions,
  });

  /// 题目列表（固定 13 道）。所有 locale 的题目 `id` 必须一致，
  /// 以保证切语言时用户已填的答案能继续匹配。
  final List<QuizQuestion> questions;

  /// 薄弱项建议（key = 题目 id）。
  final Map<String, String> improvementTips;

  /// 等级（S/A/B/C/D）的一句话描述。
  final Map<String, String> gradeDescriptions;

  /// 工具：查找薪资系数题。
  NumericQuestion get salaryQuestion {
    return questions.whereType<NumericQuestion>().firstWhere(
      (q) => q.isSalaryMultiplier,
    );
  }
}

/// 根据当前 [AppLocale] 返回对应的题库。
LocalizedSurvey surveyFor(AppLocale locale) {
  return switch (locale) {
    AppLocale.zh => surveyZh,
    AppLocale.ja => surveyJa,
    AppLocale.en => surveyEn,
  };
}
