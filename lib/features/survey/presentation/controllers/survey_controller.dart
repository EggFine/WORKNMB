import 'dart:collection';

import 'package:flutter/material.dart';

import '../../domain/localized_survey.dart';
import '../../domain/survey_data.dart';

enum AppSection {
  home(Icons.home_outlined, Icons.home_rounded),
  questionnaire(Icons.quiz_outlined, Icons.quiz_rounded),
  result(Icons.insights_outlined, Icons.insights_rounded),
  settings(Icons.settings_outlined, Icons.settings_rounded);

  const AppSection(this.icon, this.selectedIcon);

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

  final bool isSalaryMultiplier;
}

/// 带 locale 的 survey controller。
///
/// 切换 locale 时，外部 [SurveyApp] 应该构造一个新的 controller 实例或调用
/// [updateSurvey] —— 因为 [answers] 的 key 是 question id（所有 locale 相同），
/// 已填的答案可以直接保留。
class SurveyController extends ChangeNotifier {
  SurveyController({required LocalizedSurvey survey})
    // ignore: prefer_initializing_formals — _survey needs to be mutable to support updateSurvey
    : _survey = survey;

  LocalizedSurvey _survey;
  final Map<String, Answer> _answers = <String, Answer>{};

  int _currentQuestionIndex = 0;
  int _questionTransitionToken = 0;
  AppSection _section = AppSection.home;

  LocalizedSurvey get survey => _survey;
  List<QuizQuestion> get questions => _survey.questions;

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

  bool get isCurrentAnswered => _answers.containsKey(question.id);

  Answer? answerFor(String questionId) => _answers[questionId];

  /// 切换 locale 时替换题库（answer 由 id 匹配，保留）。
  void updateSurvey(LocalizedSurvey next) {
    if (identical(_survey, next)) return;
    _survey = next;
    // 保证 currentQuestionIndex 仍然有效
    if (_currentQuestionIndex >= next.questions.length) {
      _currentQuestionIndex = 0;
    }
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  评分计算
  // ════════════════════════════════════════════════════════════════════════════

  double? rawScoreFor(QuizQuestion q) {
    final answer = _answers[q.id];
    if (answer == null) return null;
    return switch ((q, answer)) {
      (ChoiceQuestion q, ChoiceAnswer a) => q.options[a.index].score,
      (RatingQuestion q, RatingAnswer a) => a.stars * (10 / q.maxRating),
      (NumericQuestion q, NumericAnswer a) => _scoreForNumeric(q, a.value),
      _ => 0.0,
    };
  }

  double _scoreForNumeric(NumericQuestion q, double v) {
    if (q.isSalaryMultiplier) {
      return salaryCoefficientOf(v, q.baseline) * (10 / salaryCoefficientMax);
    }
    final best = q.bestValue;
    final worst = q.worstValue;
    if (best == worst) return 10;
    final raw = ((v - worst) / (best - worst)) * 10;
    return raw.clamp(0.0, 10.0);
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

  /// 薪资系数（0.1 ~ 2.5）。未作答返回 1.0。
  double get salaryMultiplier {
    final salaryQ = _survey.salaryQuestion;
    final answer = _answers[salaryQ.id];
    if (answer is! NumericAnswer) return 1;
    return salaryCoefficientOf(answer.value, salaryQ.baseline);
  }

  double? get salaryValue {
    final salaryQ = _survey.salaryQuestion;
    final answer = _answers[salaryQ.id];
    return answer is NumericAnswer ? answer.value : null;
  }

  double get totalScore {
    return (baseScore * salaryMultiplier).clamp(0, 100);
  }

  ScoreGrade get grade => ScoreGrade.fromScore(totalScore);

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

  List<FactorScore> weakestFactors({int limit = 3}) {
    final breakdown =
        factorBreakdown.where((f) => !f.isSalaryMultiplier).toList()
          ..sort((a, b) => a.rawScore.compareTo(b.rawScore));
    return breakdown.take(limit).toList();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  答题动作
  // ════════════════════════════════════════════════════════════════════════════

  void choose(int optionIndex) {
    final q = question;
    if (q is! ChoiceQuestion) return;
    final existing = _answers[q.id];
    if (existing is ChoiceAnswer && existing.index == optionIndex) return;
    _answers[q.id] = ChoiceAnswer(optionIndex);
    notifyListeners();
  }

  void rate(int stars) {
    final q = question;
    if (q is! RatingQuestion) return;
    final existing = _answers[q.id];
    if (existing is RatingAnswer && existing.stars == stars) return;
    _answers[q.id] = RatingAnswer(stars);
    notifyListeners();
  }

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
    if (!isCurrentAnswered) {
      final q = question;
      if (q is NumericQuestion) {
        setNumeric(q.defaultValue);
      } else {
        return;
      }
    }

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
