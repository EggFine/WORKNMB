import 'package:flutter/material.dart';

import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/theme/text_styles.dart';
import '../../../../../app/widgets/app_card.dart';

/// 带淡入 + 轻微横向滑入的 [AnimatedSwitcher]。
class FadeSlideSwitcher extends StatelessWidget {
  const FadeSlideSwitcher({
    required this.child,
    super.key,
    this.duration = AppDurations.normal,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppCurves.standard,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: child,
    );
  }
}

/// 带补间动画的线性进度条。
class AnimatedValueBar extends StatelessWidget {
  const AnimatedValueBar({
    required this.value,
    super.key,
    this.color,
    this.minHeight = 12,
  });

  final double value;
  final Color? color;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: AppDurations.slow,
      curve: AppCurves.standard,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(minHeight / 2),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: minHeight,
            color: color ?? scheme.primary,
          ),
        );
      },
    );
  }
}

/// 装饰性状态条（pill），用于 Hero / 结果页等容器内的指标标签。
class StatusChip extends StatelessWidget {
  const StatusChip({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.sm, color: scheme.onSurface),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 概览页顶部的指标卡片（完成题数 / 进度 / 状态等）。
class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: AppIconSize.md),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: theme.labelMuted),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(hint, style: theme.bodyMediumMuted),
        ],
      ),
    );
  }
}

/// 概览页的"步骤指引"项：图标徽章 + 标题 + 描述。
class GuideItem extends StatelessWidget {
  const GuideItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppIconSize.xl,
          height: AppIconSize.xl,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Icon(icon, color: scheme.primary, size: AppIconSize.md),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(subtitle, style: theme.bodyMediumMuted),
            ],
          ),
        ),
      ],
    );
  }
}
