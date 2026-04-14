import 'package:flutter/material.dart';

import '../../../../../app/app_identity.dart';
import '../../../../../app/i18n/app_strings.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/widgets/responsive.dart';
import '../../controllers/survey_controller.dart';
import '../common/survey_common_widgets.dart';

/// 首页 / 登陆页：采用现代双栏（宽屏）或堆叠（窄屏）布局。
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
    final strings = AppStrings.of(context);
    final hasProgress = controller.answeredCount > 0;
    final allAnswered = controller.allAnswered;

    final ctaLabel = allAnswered
        ? strings.homeRestartButton
        : (hasProgress ? strings.homeContinueButton : strings.homeStartButton);
    final ctaIcon = allAnswered
        ? Icons.replay_rounded
        : Icons.play_arrow_rounded;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = Responsive.isWideContent(constraints.maxWidth);

        Widget content;
        if (wide) {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xxl),
                  child: _HeroTextAndActions(
                    controller: controller,
                    ctaLabel: ctaLabel,
                    ctaIcon: ctaIcon,
                    hasProgress: hasProgress,
                    allAnswered: allAnswered,
                    onStartOrContinue: onStartOrContinue,
                    onViewResult: onViewResult,
                    centered: false,
                  ),
                ),
              ),
              const Expanded(
                flex: 9,
                child: Center(
                  child: _HeroVisual(),
                ),
              ),
            ],
          );
        } else {
          content = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const _HeroVisual(),
              const SizedBox(height: AppSpacing.xxl),
              _HeroTextAndActions(
                controller: controller,
                ctaLabel: ctaLabel,
                ctaIcon: ctaIcon,
                hasProgress: hasProgress,
                allAnswered: allAnswered,
                onStartOrContinue: onStartOrContinue,
                onViewResult: onViewResult,
                centered: true,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        }

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.maxContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? AppSpacing.xxl : AppSpacing.xl,
                    vertical: wide ? 80 : AppSpacing.xxl,
                  ),
                  child: content,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroTextAndActions extends StatelessWidget {
  const _HeroTextAndActions({
    required this.controller,
    required this.ctaLabel,
    required this.ctaIcon,
    required this.hasProgress,
    required this.allAnswered,
    required this.onStartOrContinue,
    required this.onViewResult,
    required this.centered,
  });

  final SurveyController controller;
  final String ctaLabel;
  final IconData ctaIcon;
  final bool hasProgress;
  final bool allAnswered;
  final VoidCallback onStartOrContinue;
  final VoidCallback onViewResult;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final alignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.left;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [scheme.primary, scheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            appShortName,
            textAlign: textAlign,
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          appFullName,
          textAlign: textAlign,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          strings.homeIntro,
          textAlign: textAlign,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _PrimaryCta(
              label: ctaLabel,
              icon: ctaIcon,
              onPressed: onStartOrContinue,
            ),
            if (allAnswered)
              SizedBox(
                height: 56,
                child: FilledButton.tonalIcon(
                  onPressed: onViewResult,
                  icon: const Icon(Icons.insights_rounded),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  label: Text(strings.homeViewResultButton),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (hasProgress && !allAnswered)
          _ProgressIndicatorStrip(controller: controller, centered: centered)
        else
          _MetaBullets(
            totalQuestions: controller.questions.length,
            strings: strings,
            centered: centered,
          ),
      ],
    );
  }
}

/// 首页视觉：带有光晕和层次感的图标卡片排列。
class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow (Primary)
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.25),
                  scheme.primary.withValues(alpha: 0.0),
                ],
                stops: const [0.2, 1.0],
              ),
            ),
          ),
          // Background Glow (Tertiary)
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.tertiary.withValues(alpha: 0.20),
                    scheme.tertiary.withValues(alpha: 0.0),
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),
          // Main Icon Card
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primaryContainer, scheme.tertiaryContainer],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.05),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Icon(
              Icons.query_stats_rounded,
              size: 88,
              color: scheme.onPrimaryContainer,
            ),
          ),
          // Floating badge top right
          Positioned(
            top: 40,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: scheme.primary,
                size: 28,
              ),
            ),
          ),
          // Floating badge bottom left
          Positioned(
            bottom: 50,
            left: 40,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: scheme.tertiary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        icon: Icon(icon, size: 24),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        label: Text(label),
      ),
    );
  }
}

class _MetaBullets extends StatelessWidget {
  const _MetaBullets({
    required this.totalQuestions,
    required this.strings,
    required this.centered,
  });

  final int totalQuestions;
  final AppStrings strings;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final String questionsLabel = switch (strings.locale.locale.languageCode) {
      'ja' => '$totalQuestions 問',
      'en' => '$totalQuestions Q',
      _ => '$totalQuestions 题',
    };

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      children: [
        StatusChip(
          icon: Icons.format_list_numbered_rounded,
          label: questionsLabel,
        ),
        StatusChip(icon: Icons.timer_outlined, label: strings.homeMetaTime),
        StatusChip(
          icon: Icons.edit_note_rounded,
          label: strings.homeMetaFreeEdit,
        ),
      ],
    );
  }
}

class _ProgressIndicatorStrip extends StatelessWidget {
  const _ProgressIndicatorStrip({
    required this.controller,
    required this.centered,
  });

  final SurveyController controller;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final alignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final mainAxis =
        centered ? MainAxisAlignment.center : MainAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: mainAxis,
          children: [
            Icon(
              Icons.bookmark_rounded,
              size: AppIconSize.sm,
              color: scheme.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              strings.homeProgressText(
                controller.answeredCount,
                controller.questions.length,
              ),
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
