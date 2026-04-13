/// WORKNMB 工作评分数据模型（locale 无关）。
///
/// 使用 sealed class + pattern matching 支持三种题型：
/// - [ChoiceQuestion]：单选题
/// - [RatingQuestion]：5 级评分题
/// - [NumericQuestion]：数字填空题
///
/// 每个 locale 的具体题库定义在 `questions_<locale>.dart`，
/// 最终由 `localized_survey.dart` 统一派发。
library;

/// 题目基类。
sealed class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.category,
    required this.title,
    required this.hint,
  });

  final String id;
  final String category;
  final String title;
  final String hint;
}

/// 单选题。每个选项附带 0-10 的贡献分。
class ChoiceQuestion extends QuizQuestion {
  const ChoiceQuestion({
    required super.id,
    required super.category,
    required super.title,
    required super.hint,
    required this.options,
  });

  final List<QuizOption> options;
}

/// 5 级评分题。
class RatingQuestion extends QuizQuestion {
  const RatingQuestion({
    required super.id,
    required super.category,
    required super.title,
    required super.hint,
    this.maxRating = 5,
    required this.labels,
  });

  final int maxRating;
  final List<String> labels;
}

/// 数字输入题。
///
/// [bestValue]/[worstValue] 定义线性评分锚点；[isSalaryMultiplier] 为 true 时
/// 该题不计入基础分，而作为"薪资系数"乘到最终总分上。
class NumericQuestion extends QuizQuestion {
  const NumericQuestion({
    required super.id,
    required super.category,
    required super.title,
    required super.hint,
    required this.baseline,
    required this.minValue,
    required this.maxValue,
    required this.defaultValue,
    required this.unit,
    required this.quickPicks,
    this.bestValue = 0,
    this.worstValue = 0,
    this.isSalaryMultiplier = false,
    this.allowDecimal = false,
  });

  final double baseline;
  final double minValue;
  final double maxValue;
  final double defaultValue;
  final String unit;
  final List<double> quickPicks;
  final double bestValue;
  final double worstValue;
  final bool isSalaryMultiplier;
  final bool allowDecimal;
}

/// 单选题选项。
class QuizOption {
  const QuizOption(this.title, this.note, this.score);
  final String title;
  final String note;
  final double score;
}

/// 用户答案（sealed + pattern match 保证类型安全）。
sealed class Answer {
  const Answer();
}

class ChoiceAnswer extends Answer {
  const ChoiceAnswer(this.index);
  final int index;
}

class RatingAnswer extends Answer {
  const RatingAnswer(this.stars);
  final int stars;
}

class NumericAnswer extends Answer {
  const NumericAnswer(this.value);
  final double value;
}

/// 最终得分的等级划分。
enum ScoreGrade {
  s('S', 85),
  a('A', 70),
  b('B', 55),
  c('C', 40),
  d('D', 0);

  const ScoreGrade(this.label, this.threshold);

  final String label;
  final double threshold;

  static ScoreGrade fromScore(double score) {
    for (final grade in ScoreGrade.values) {
      if (score >= grade.threshold) return grade;
    }
    return ScoreGrade.d;
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  评分配置
// ════════════════════════════════════════════════════════════════════════════

/// 薪资系数的下限 / 上限（防止极端值把分数拉爆）。
const double salaryCoefficientMin = 0.1;
const double salaryCoefficientMax = 2.5;

/// 薪资系数 = clamp(value / baseline, min, max)。
double salaryCoefficientOf(double value, double baseline) {
  final raw = value / baseline;
  if (raw.isNaN || raw.isInfinite) return salaryCoefficientMin;
  return raw.clamp(salaryCoefficientMin, salaryCoefficientMax);
}
