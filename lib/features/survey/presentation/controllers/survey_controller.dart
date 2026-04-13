import 'dart:collection';

import 'package:flutter/material.dart';

import '../../domain/survey_data.dart';

enum AppSection {
  home('首页', Icons.home_outlined, Icons.home_rounded),
  questionnaire('问卷', Icons.quiz_outlined, Icons.quiz_rounded),
  result('结果', Icons.insights_outlined, Icons.insights_rounded),
  settings('设置', Icons.settings_outlined, Icons.settings_rounded);

  const AppSection(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// 单个因子（题目）的最终贡献记录。
class FactorScore {
  const FactorScore({
    required this.questionId,
    required this.category,
    required this.rawScore,
    required this.isSalaryMultiplier,
  });

  final String questionId;
  final String category;

  /// 0-10 的原始贡献分（对于 salary multiplier 题，此处填系数 × 10 用于展示）。
  final double rawScore;

  /// 是否为薪资系数题（结果页对此类题展示方式不同）。
  final bool isSalaryMultiplier;
}

class SurveyController extends ChangeNotifier {
  final Map<String, Answer> _answers = <String, Answer>{};

  int _currentQuestionIndex = 0;
  int _questionTransitionToken = 0;
  AppSection _section = AppSection.home;

  Map<String, Answer> get answers => UnmodifiableMapView(_answers);

  int get currentQuestionIndex => _currentQuestionIndex;
  int get questionTransitionToken => _questionTransitionToken;
  AppSection get section => _section;
  QuizQuestion get question => questions[_currentQuestionIndex];

  int get answeredCount => _answers.length;
  int get remainingCount => questions.length - answeredCount;
  bool get allAnswered => answeredCount == questions.length;
  double get progress => answeredCount / questions.length;

  int? get firstUnansweredIndex {
    for (var i = 0; i < questions.length; i++) {
      if (!_answers.containsKey(questions[i].id)) return i;
    }
    return null;
  }

  /// 当前题是否已作答。
  bool get isCurrentAnswered => _answers.containsKey(question.id);

  Answer? answerFor(String questionId) => _answers[questionId];

  // ════════════════════════════════════════════════════════════════════════════
  //  评分计算
  // ════════════════════════════════════════════════════════════════════════════

  /// 单题归一化得分（0-10）。未作答返回 null。
  double? rawScoreFor(QuizQuestion q) {
    final answer = _answers[q.id];
    if (answer == null) return null;
    return switch ((q, answer)) {
      (ChoiceQuestion q, ChoiceAnswer a) => q.options[a.index].score,
      (RatingQuestion q, RatingAnswer a) => a.stars * (10 / q.maxRating),
      (NumericQuestion q, NumericAnswer a) =>
        q.isSalaryMultiplier
            ? salaryCoefficientOf(a.value, q.baseline) *
                  (10 / salaryCoefficientMax)
            : (a.value / q.baseline * 10).clamp(0, 10),
      _ => 0.0,
    };
  }

  /// 基础分（0-100）：所有非薪资系数题的平均分 × 10。
  double get baseScore {
    double sum = 0;
    int count = 0;
    for (final q in questions) {
      if (q is NumericQuestion && q.isSalaryMultiplier) continue;
      final raw = rawScoreFor(q);
      if (raw == null) continue;
      sum += raw;
      count++;
    }
    if (count == 0) return 0;
    return (sum / count) * 10;
  }

  /// 薪资系数（0.1 ~ 2.5）。未作答返回 1.0（不加成也不惩罚）。
  double get salaryMultiplier {
    final salaryQ = questions.whereType<NumericQuestion>().firstWhere(
      (q) => q.isSalaryMultiplier,
    );
    final answer = _answers[salaryQ.id];
    if (answer is! NumericAnswer) return 1;
    return salaryCoefficientOf(answer.value, salaryQ.baseline);
  }

  /// 薪资输入（未作答返回 null）。
  double? get salaryValue {
    final salaryQ = questions.whereType<NumericQuestion>().firstWhere(
      (q) => q.isSalaryMultiplier,
    );
    final answer = _answers[salaryQ.id];
    return answer is NumericAnswer ? answer.value : null;
  }

  /// 最终得分：基础分 × 薪资系数，截取到 0-100。
  double get totalScore {
    return (baseScore * salaryMultiplier).clamp(0, 100);
  }

  ScoreGrade get grade => ScoreGrade.fromScore(totalScore);

  /// 所有因子的贡献（用于结果页面的 breakdown）。
  List<FactorScore> get factorBreakdown {
    return [
      for (final q in questions)
        FactorScore(
          questionId: q.id,
          category: q.category,
          rawScore: rawScoreFor(q) ?? 0,
          isSalaryMultiplier: q is NumericQuestion && q.isSalaryMultiplier,
        ),
    ];
  }

  /// 得分最低的前 N 个因子（用于生成改进建议）。
  List<FactorScore> weakestFactors({int limit = 3}) {
    final breakdown =
        factorBreakdown.where((f) => !f.isSalaryMultiplier).toList()
          ..sort((a, b) => a.rawScore.compareTo(b.rawScore));
    return breakdown.take(limit).toList();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  文案
  // ════════════════════════════════════════════════════════════════════════════

  String get sectionDescription {
    return switch (_section) {
      AppSection.home =>
        'WORKNMB，即 Workplace Overall Rating & Key Numeric Metric Benchmark。'
            '用 10 道题量化你当前工作的性价比。',
      AppSection.questionnaire => '按题完成评测，可随时返回、跳转并修正答案。',
      AppSection.result =>
        allAnswered ? '结果页会展示综合评分、等级、各因子贡献与薄弱项建议。' : '你还差几题没有完成，继续答题后即可查看完整分析。',
      AppSection.settings => '调整主题模式和色板，或清除现有答案从头开始。',
    };
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  答题动作
  // ════════════════════════════════════════════════════════════════════════════

  /// 设置单选答案。
  void choose(int optionIndex) {
    final q = question;
    if (q is! ChoiceQuestion) return;
    final existing = _answers[q.id];
    if (existing is ChoiceAnswer && existing.index == optionIndex) return;
    _answers[q.id] = ChoiceAnswer(optionIndex);
    notifyListeners();
  }

  /// 设置评分题答案（1 ~ maxRating）。
  void rate(int stars) {
    final q = question;
    if (q is! RatingQuestion) return;
    final existing = _answers[q.id];
    if (existing is RatingAnswer && existing.stars == stars) return;
    _answers[q.id] = RatingAnswer(stars);
    notifyListeners();
  }

  /// 设置数字题答案（月薪等）。
  void setNumeric(double value) {
    final q = question;
    if (q is! NumericQuestion) return;
    final clamped = value.clamp(q.minValue, q.maxValue);
    final existing = _answers[q.id];
    if (existing is NumericAnswer && existing.value == clamped) return;
    _answers[q.id] = NumericAnswer(clamped);
    notifyListeners();
  }

  void next() {
    if (!isCurrentAnswered) return;

    if (_currentQuestionIndex == questions.length - 1) {
      final nextUnanswered = firstUnansweredIndex;
      if (nextUnanswered == null) {
        selectSection(AppSection.result);
      } else {
        openQuestionnaire(nextUnanswered);
      }
      return;
    }

    _goToQuestion(_currentQuestionIndex + 1);
  }

  void previous() {
    if (_currentQuestionIndex == 0) return;
    _goToQuestion(_currentQuestionIndex - 1);
  }

  void restart() {
    _answers.clear();
    _currentQuestionIndex = 0;
    _section = AppSection.home;
    _questionTransitionToken++;
    notifyListeners();
  }

  void selectSection(AppSection nextSection) {
    if (_section == nextSection) return;
    _section = nextSection;
    notifyListeners();
  }

  void openQuestionnaire([int? index]) {
    if (index != null) {
      _goToQuestion(index, notify: false);
    }

    if (_section != AppSection.questionnaire) {
      _section = AppSection.questionnaire;
      notifyListeners();
      return;
    }

    if (index != null) notifyListeners();
  }

  void _goToQuestion(int nextIndex, {bool notify = true}) {
    if (nextIndex == _currentQuestionIndex) return;
    _currentQuestionIndex = nextIndex;
    _questionTransitionToken++;
    if (notify) notifyListeners();
  }
}
