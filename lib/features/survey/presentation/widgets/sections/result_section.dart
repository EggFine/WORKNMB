import 'package:flutter/material.dart';

import '../../../../../app/i18n/app_strings.dart';
import '../../../../../app/theme/app_palette.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/theme/text_styles.dart';
import '../../../../../app/widgets/app_card.dart';
import '../../../../../app/widgets/app_section_header.dart';
import '../../../../../app/widgets/responsive.dart';
import '../../controllers/survey_controller.dart';
import '../../../domain/survey_data.dart';
import '../common/survey_common_widgets.dart';

class ResultSection extends StatelessWidget {
  const ResultSection({
    required this.controller,
    required this.onRestart,
    required this.onOpenOverview,
    required this.onContinueQuestionnaire,
    super.key,
  });

  final SurveyController controller;
  final VoidCallback onRestart;
  final VoidCallback onOpenOverview;
  final VoidCallback onContinueQuestionnaire;

  @override
  Widget build(BuildContext context) {
    return FadeSlideSwitcher(
      child: KeyedSubtree(
        key: ValueKey(controller.allAnswered),
        child: controller.allAnswered
            ? _UnlockedResult(
                controller: controller,
                onRestart: onRestart,
                onOpenOverview: onOpenOverview,
              )
            : _LockedResult(
                controller: controller,
                onContinueQuestionnaire: onContinueQuestionnaire,
              ),
      ),
    );
  }
}

class _LockedResult extends StatelessWidget {
  const _LockedResult({
    required this.controller,
    required this.onContinueQuestionnaire,
  });

  final SurveyController controller;
  final VoidCallback onContinueQuestionnaire;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_clock_rounded,
            size: AppIconSize.xl,
            color: scheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(strings.resultLockedTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.resultLockedBody(controller.remainingCount),
            style: theme.bodyLargeMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedValueBar(value: controller.progress),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onContinueQuestionnaire,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(strings.resultContinueButton),
          ),
        ],
      ),
    );
  }
}

class _UnlockedResult extends StatelessWidget {
  const _UnlockedResult({
    required this.controller,
    required this.onRestart,
    required this.onOpenOverview,
  });

  final SurveyController controller;
  final VoidCallback onRestart;
  final VoidCallback onOpenOverview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = Responsive.isWideContent(constraints.maxWidth);

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ScoreSummaryCard(controller: controller)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    _FactorBreakdownCard(controller: controller),
                    const SizedBox(height: AppSpacing.md),
                    _AdviceCard(
                      controller: controller,
                      onRestart: onRestart,
                      onOpenOverview: onOpenOverview,
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _ScoreSummaryCard(controller: controller),
            const SizedBox(height: AppSpacing.md),
            _FactorBreakdownCard(controller: controller),
            const SizedBox(height: AppSpacing.md),
            _AdviceCard(
              controller: controller,
              onRestart: onRestart,
              onOpenOverview: onOpenOverview,
            ),
          ],
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  卡片 1：总分 + 等级徽章
// ════════════════════════════════════════════════════════════════════════════

/// 结果摘要卡：根据 grade 动态切换渐变背景色，叠加等级梗称号。
///
/// - 背景：`GradeBackgroundTokens.gradientFor(grade)` 提供 2 色 LinearGradient
///   （D 褐红→黑，C 砖红→深红，B 橙→棕，A 翠绿→墨绿，S 金→古铜）。
/// - 徽章：白底圆角 + 等级色数字字母，保证在任意渐变上都清晰。
/// - 主信息顺序：标题 → 大数值 + 徽章 → 梗称号 → punchline → 公式面板。
class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard({required this.controller});

  final SurveyController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final score = controller.totalScore;
    final grade = controller.grade;
    final gradientColors = GradeBackgroundTokens.gradientFor(grade);
    final badgeColor = gradientColors.first;
    final salaryValue = controller.salaryValue ?? 0;
    final coefficient = controller.salaryMultiplier;

    final gradeDesc =
        controller.survey.gradeDescriptions[grade.label] ?? grade.label;
    final memeTitle =
        controller.survey.gradeMemeTitles[grade.label] ?? grade.label;
    final memePunch = controller.survey.gradeMemePunchlines[grade.label] ?? '';

    const onGradient = GradeBackgroundTokens.onGradient;
    final onGradientMuted = GradeBackgroundTokens.onGradientMuted;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.resultSummaryTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: onGradientMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: AppDurations.normal,
                child: Text(
                  score.toStringAsFixed(1),
                  key: ValueKey(score.round()),
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: onGradient,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  ' / 100',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: onGradientMuted,
                  ),
                ),
              ),
              const Spacer(),
              _GradeBadge(grade: grade, gradeColor: badgeColor),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // —— 梗称号：大字号，带引号装饰 ——
          AnimatedSwitcher(
            duration: AppDurations.fast,
            child: Text(
              '「$memeTitle」',
              key: ValueKey('meme-title-$memeTitle'),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: onGradient,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            gradeDesc,
            style: theme.textTheme.labelLarge?.copyWith(
              color: onGradientMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (memePunch.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              memePunch,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: onGradient,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          // —— 公式面板（半透明黑色底，保证即使在金色渐变上也可读）——
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: GradeBackgroundTokens.innerPanel,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.resultFormulaLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: onGradientMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.resultFormulaTemplate(
                    controller.baseScore.toStringAsFixed(1),
                    coefficient.toStringAsFixed(2),
                    score.toStringAsFixed(1),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onGradient,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.resultSalaryInputTemplate(
                    _formatSalary(salaryValue),
                    _formatSalary(controller.survey.salaryQuestion.baseline),
                    strings.currencySymbol,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: onGradientMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSalary(double v) {
    final int iv = v.round();
    final s = iv.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

/// 等级徽章：白底圆角 + 等级色字母，任意渐变背景上都清晰。
class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade, required this.gradeColor});

  final ScoreGrade grade;
  final Color gradeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        grade.label,
        style: theme.textTheme.displayMedium?.copyWith(
          color: gradeColor,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  卡片 2：因子贡献条
// ════════════════════════════════════════════════════════════════════════════

class _FactorBreakdownCard extends StatelessWidget {
  const _FactorBreakdownCard({required this.controller});

  final SurveyController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final breakdown = controller.factorBreakdown;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: strings.resultFactorBreakdownTitle,
            description: strings.resultFactorBreakdownDesc,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...breakdown.map((f) {
            if (f.isSalaryMultiplier) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _SalaryCoefficientRow(
                  coefficient: controller.salaryMultiplier,
                  theme: theme,
                  label: strings.resultSalaryCoefficientLabel,
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _FactorRow(factor: f),
            );
          }),
        ],
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.factor});

  final FactorScore factor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _colorFor(scheme, factor.rawScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(factor.category, style: theme.textTheme.titleMedium),
            ),
            Text(
              factor.rawScore.toStringAsFixed(1),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              ' / 10',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedValueBar(value: factor.rawScore / 10, color: color),
      ],
    );
  }

  Color _colorFor(ColorScheme scheme, double score) {
    if (score >= 7) return scheme.primary;
    if (score >= 4) return scheme.tertiary;
    return scheme.error;
  }
}

class _SalaryCoefficientRow extends StatelessWidget {
  const _SalaryCoefficientRow({
    required this.coefficient,
    required this.theme,
    required this.label,
  });

  final double coefficient;
  final ThemeData theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final normalized = (coefficient / salaryCoefficientMax).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_money_rounded,
              size: AppIconSize.sm,
              color: scheme.primary,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            Text(
              '×${coefficient.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedValueBar(value: normalized, color: scheme.primary),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  卡片 3：薄弱项建议 + 操作
// ════════════════════════════════════════════════════════════════════════════

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({
    required this.controller,
    required this.onRestart,
    required this.onOpenOverview,
  });

  final SurveyController controller;
  final VoidCallback onRestart;
  final VoidCallback onOpenOverview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final weakest = controller.weakestFactors(limit: 3);
    final tips = controller.survey.improvementTips;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: strings.resultAdviceTitle,
            description: strings.resultAdviceDesc,
          ),
          const SizedBox(height: AppSpacing.md),
          ...weakest.map((f) {
            final tip = tips[f.questionId] ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: scheme.error,
                      size: AppIconSize.md,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${f.category}（${f.rawScore.toStringAsFixed(1)} / 10）',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          tip,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                key: const Key('restart-button'),
                onPressed: onRestart,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(strings.resultRestartButton),
              ),
              OutlinedButton.icon(
                onPressed: onOpenOverview,
                icon: const Icon(Icons.home_outlined),
                label: Text(strings.resultHomeButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
