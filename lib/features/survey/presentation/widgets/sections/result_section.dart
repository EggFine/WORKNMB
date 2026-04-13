import 'package:flutter/material.dart';

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

// ════════════════════════════════════════════════════════════════════════════
//  未解锁（未答完所有题）
// ════════════════════════════════════════════════════════════════════════════

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
          Text('评分尚未解锁', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '还剩 ${controller.remainingCount} 道题未完成。'
            '完成所有题目后，会展示综合评分、等级、因子贡献和薄弱项建议。',
            style: theme.bodyLargeMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedValueBar(value: controller.progress),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onContinueQuestionnaire,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('继续答题'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  已解锁（全部答完）
// ════════════════════════════════════════════════════════════════════════════

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

class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard({required this.controller});

  final SurveyController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final score = controller.totalScore;
    final grade = controller.grade;
    final gradeColor = GradeColorTokens.colorFor(scheme, grade);
    final salaryValue = controller.salaryValue ?? 0;
    final coefficient = controller.salaryMultiplier;

    return AppCard(
      variant: AppCardVariant.featured,
      fillColor: scheme.primaryContainer,
      featuredAccentColor: gradeColor.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WORKNMB 综合评分', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          // —— 大分数 + 等级徽章 ——
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
                    color: scheme.onPrimaryContainer,
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
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const Spacer(),
              _GradeBadge(grade: grade, color: gradeColor),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            grade.description,
            style: theme.bodyOnContainer(scheme.onPrimaryContainer),
          ),
          const SizedBox(height: AppSpacing.xl),
          // —— 公式与输入 ——
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '评分公式',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${controller.baseScore.toStringAsFixed(1)} 基础分 × ${coefficient.toStringAsFixed(2)} 薪资系数 = ${score.toStringAsFixed(1)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '月薪输入：¥${_formatSalary(salaryValue)} / 月（基准 ¥10,000）',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
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

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade, required this.color});

  final ScoreGrade grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        grade.label,
        style: theme.textTheme.displayMedium?.copyWith(
          color: Colors.white,
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
    final breakdown = controller.factorBreakdown;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: '因子贡献',
            description: '每个维度满分 10，颜色代表相对贡献，值越高越健康。',
          ),
          const SizedBox(height: AppSpacing.lg),
          ...breakdown.map((f) {
            if (f.isSalaryMultiplier) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _SalaryCoefficientRow(
                  coefficient: controller.salaryMultiplier,
                  theme: theme,
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
    // 红（0-3）→ 黄（3-7）→ 绿（7-10）的语义色，跟随主题 primary / error
    if (score >= 7) return scheme.primary;
    if (score >= 4) return scheme.tertiary;
    return scheme.error;
  }
}

class _SalaryCoefficientRow extends StatelessWidget {
  const _SalaryCoefficientRow({required this.coefficient, required this.theme});

  final double coefficient;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    // 系数归一化到 0-1（系数上限 2.5）
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
            Expanded(child: Text('月薪系数', style: theme.textTheme.titleMedium)),
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
    final weakest = controller.weakestFactors(limit: 3);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: '薄弱项与建议',
            description: '得分最低的 3 项 — 通常也是性价比被拉低的元凶。',
          ),
          const SizedBox(height: AppSpacing.md),
          ...weakest.map((f) {
            final tip = improvementTips[f.questionId] ?? '';
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
                label: const Text('重新测试'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenOverview,
                icon: const Icon(Icons.home_outlined),
                label: const Text('返回首页'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
