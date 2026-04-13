import 'package:flutter/material.dart';

import '../../../../../app/app_identity.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/theme/text_styles.dart';
import '../../controllers/survey_controller.dart';
import '../../../domain/survey_data.dart';
import '../common/survey_common_widgets.dart';

/// 首页 / 登陆页：品牌聚焦，一个主 CTA 直达问卷。
///
/// 布局策略：
/// - 全部内容纵向居中；在任何视口下保持视觉稳定。
/// - 内容最大宽度 560dp，避免大屏下文字过宽。
/// - 有部分答案时将 CTA 改为"继续答题"，并显示进度；全部答完则额外提供"查看我的结果"次按钮。
class HomeSection extends StatelessWidget {
  const HomeSection({
    required this.controller,
    required this.onStartOrContinue,
    required this.onViewResult,
    super.key,
  });

  final SurveyController controller;
  final VoidCallback onStartOrContinue;
  final VoidCallback onViewResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasProgress = controller.answeredCount > 0;
    final allAnswered = controller.allAnswered;

    final ctaLabel = allAnswered ? '重新开始答题' : (hasProgress ? '继续答题' : '开始答题');
    final ctaIcon = allAnswered
        ? Icons.replay_rounded
        : Icons.play_arrow_rounded;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // —— 品牌徽标区 ——
                      _BrandMark(),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        appShortName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        appFullName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        '用 ${questions.length} 个维度量化你当前工作的性价比，'
                        '包含工时、通勤、加班、休息、月薪等关键指标。',
                        textAlign: TextAlign.center,
                        style: theme.bodyLargeMuted,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // —— 主 CTA ——
                      _PrimaryCta(
                        label: ctaLabel,
                        icon: ctaIcon,
                        onPressed: onStartOrContinue,
                      ),
                      if (allAnswered) ...[
                        const SizedBox(height: AppSpacing.sm),
                        TextButton.icon(
                          onPressed: onViewResult,
                          icon: const Icon(Icons.insights_rounded),
                          label: const Text('查看我的结果'),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      // —— 元信息 / 进度 ——
                      if (hasProgress && !allAnswered)
                        _ProgressIndicatorStrip(controller: controller)
                      else
                        const _MetaBullets(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 品牌徽标：带圆形底纹的图标。
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(
        Icons.query_stats_rounded,
        size: 48,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}

/// 放大的主 CTA 按钮。
class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: AppIconSize.md),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        label: Text(label),
      ),
    );
  }
}

/// 元信息条（首次进入显示）：题数 + 预计时长。
class _MetaBullets extends StatelessWidget {
  const _MetaBullets();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget dot() => Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant,
        shape: BoxShape.circle,
      ),
    );

    final textStyle = theme.textTheme.labelLarge?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${questions.length} 题', style: textStyle),
        const SizedBox(width: AppSpacing.sm),
        dot(),
        const SizedBox(width: AppSpacing.sm),
        Text('约 5 分钟', style: textStyle),
        const SizedBox(width: AppSpacing.sm),
        dot(),
        const SizedBox(width: AppSpacing.sm),
        Text('可随时返回调整', style: textStyle),
      ],
    );
  }
}

/// 进度条（已有部分答案时显示）。
class _ProgressIndicatorStrip extends StatelessWidget {
  const _ProgressIndicatorStrip({required this.controller});

  final SurveyController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_rounded,
              size: AppIconSize.sm,
              color: scheme.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '已完成 ${controller.answeredCount} / ${questions.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: AnimatedValueBar(value: controller.progress),
        ),
      ],
    );
  }
}
