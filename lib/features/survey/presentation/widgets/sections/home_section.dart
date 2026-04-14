import 'package:flutter/material.dart';

import '../../../../../app/app_identity.dart';
import '../../../../../app/i18n/app_strings.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/widgets/responsive.dart';
import '../../controllers/survey_controller.dart';
import '../common/survey_common_widgets.dart';

/// 首页 / 登陆页：极简高级感 (Premium Minimalist) 设计。
/// 彻底抛弃厚重的卡片，采用大面积留白、模糊光晕和精致的无界排版。
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = Responsive.isWideContent(constraints.maxWidth);

        if (isWide) {
          return _buildWideLayout(context, constraints);
        } else {
          return _buildCompactLayout(context, constraints);
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl * 2,
        vertical: AppSpacing.xxxl,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - AppSpacing.xxxl * 2,
          maxWidth: 1200,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 12,
              child: _buildTextContent(context, isWide: true),
            ),
            const SizedBox(width: AppSpacing.xxxl),
            Expanded(
              flex: 10,
              child: _buildHeroGraphic(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - AppSpacing.xxl * 2,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.lg),
              _buildHeroGraphic(context),
              const SizedBox(height: AppSpacing.xxl),
              _buildTextContent(context, isWide: false),
              const Spacer(),
              const SizedBox(height: AppSpacing.xxl),
              _buildActionArea(context, isWide: false),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroGraphic(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 呼吸感光晕背景
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                scheme.primary.withValues(alpha: 0.12),
                scheme.tertiary.withValues(alpha: 0.08),
                scheme.surface.withValues(alpha: 0.0),
              ],
              stops: const [0.2, 0.5, 1.0],
            ),
          ),
        ),
        // 核心 Icon
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: scheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.tertiary],
              ).createShader(bounds),
              child: const Icon(
                Icons.query_stats_rounded,
                size: 64,
                color: Colors.white, // Required for ShaderMask
              ),
            ),
          ),
        ),
        // Small floating decorative elements
        Positioned(
          top: 40,
          right: 60,
          child: _FloatingBadge(
            icon: Icons.auto_awesome_rounded,
            color: scheme.primary,
          ),
        ),
        Positioned(
          bottom: 50,
          left: 70,
          child: _FloatingBadge(
            icon: Icons.insights_rounded,
            color: scheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context, {required bool isWide}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final alignment =
        isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = isWide ? TextAlign.left : TextAlign.center;

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                'v1.0',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Title
        Text(
          appShortName,
          textAlign: textAlign,
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            height: 1.1,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Subtitle
        Text(
          appFullName,
          textAlign: textAlign,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Intro
        Text(
          strings.homeIntro,
          textAlign: textAlign,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Meta Info Inline
        _buildInlineMeta(context, isWide: isWide),

        if (isWide) ...[
          const SizedBox(height: AppSpacing.xxxl),
          _buildActionArea(context, isWide: true),
        ],
      ],
    );
  }

  Widget _buildInlineMeta(BuildContext context, {required bool isWide}) {
    final strings = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final totalQuestions = controller.questions.length;
    final String questionsLabel = switch (strings.locale.locale.languageCode) {
      'ja' => '$totalQuestions 問',
      'en' => '$totalQuestions Q',
      _ => '$totalQuestions 题',
    };

    final items = [
      (Icons.format_list_numbered_rounded, questionsLabel),
      (Icons.timer_outlined, strings.homeMetaTime),
      (Icons.edit_note_rounded, strings.homeMetaFreeEdit),
    ];

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
      children:
          items.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$1, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  item.$2,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildActionArea(BuildContext context, {required bool isWide}) {
    final strings = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;

    final answered = controller.answeredCount;
    final total = controller.questions.length;
    final progress = controller.progress;
    final allAnswered = controller.allAnswered;
    final hasProgress = answered > 0;

    final ctaLabel =
        allAnswered
            ? strings.homeRestartButton
            : (hasProgress
                ? strings.homeContinueButton
                : strings.homeStartButton);
    final ctaIcon =
        allAnswered ? Icons.replay_rounded : Icons.play_arrow_rounded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
      children: [
        if (hasProgress && !allAnswered) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Text(
                strings.homeProgressText(answered, total),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 320 : double.infinity,
            ),
            child: AnimatedValueBar(value: progress, minHeight: 8),
          ),
          const SizedBox(height: 24),
        ],

        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            SizedBox(
              height: 56,
              width: isWide ? null : double.infinity,
              child: FilledButton.icon(
                onPressed: onStartOrContinue,
                icon: Icon(ctaIcon, size: 24),
                label: Text(
                  ctaLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
              ),
            ),
            if (allAnswered)
              SizedBox(
                height: 56,
                width: isWide ? null : double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: onViewResult,
                  icon: const Icon(Icons.insights_rounded, size: 24),
                  label: Text(
                    strings.homeViewResultButton,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
