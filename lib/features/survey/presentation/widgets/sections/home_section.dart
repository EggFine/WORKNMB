import 'package:flutter/material.dart';

import '../../../../../app/app_identity.dart';
import '../../../../../app/i18n/app_strings.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/theme/text_styles.dart';
import '../../controllers/survey_controller.dart';
import '../common/survey_common_widgets.dart';

/// 首页 / 登陆页：品牌聚焦 + 一个主 CTA 直达问卷。
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
                      _BrandMark(),
                      const SizedBox(height: AppSpacing.xl),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [scheme.primary, scheme.tertiary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          appShortName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        appFullName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        strings.homeIntro,
                        textAlign: TextAlign.center,
                        style: theme.bodyLargeMuted,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
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
                          label: Text(strings.homeViewResultButton),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      if (hasProgress && !allAnswered)
                        _ProgressIndicatorStrip(controller: controller)
                      else
                        _MetaBullets(
                          totalQuestions: controller.questions.length,
                          strings: strings,
                        ),
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
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 48,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Icon(
        Icons.query_stats_rounded,
        size: 64,
        color: scheme.onPrimaryContainer,
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
      height: 64,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          textStyle: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        label: Text(label),
      ),
    );
  }
}

class _MetaBullets extends StatelessWidget {
  const _MetaBullets({required this.totalQuestions, required this.strings});

  final int totalQuestions;
  final AppStrings strings;

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
      alignment: WrapAlignment.center,
      children: [
        StatusChip(icon: Icons.format_list_numbered_rounded, label: questionsLabel),
        StatusChip(icon: Icons.timer_outlined, label: strings.homeMetaTime),
        StatusChip(icon: Icons.edit_note_rounded, label: strings.homeMetaFreeEdit),
      ],
    );
  }
}

class _ProgressIndicatorStrip extends StatelessWidget {
  const _ProgressIndicatorStrip({required this.controller});

  final SurveyController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);

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
