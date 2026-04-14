import 'package:flutter/material.dart';

import '../../../../../app/app_identity.dart';
import '../../../../../app/i18n/app_strings.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../controllers/survey_controller.dart';
import '../common/survey_common_widgets.dart';

/// 首页 / 登陆页：采用全新设计的 Bento Box (便当盒) 聚合网格布局，彻底重构 UI。
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
        final width = constraints.maxWidth;
        final isWide = width >= 900;
        final isMedium = width >= 600 && width < 900;

        if (isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Column(
                        children: [
                          _buildHeroTile(context, height: 360),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoTile(context, height: 240),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildMetaTile(context, height: 240),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: _buildActionTile(context, height: 624),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (isMedium) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                _buildHeroTile(context, height: 300),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildInfoTile(context, height: 220)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildMetaTile(context, height: 220)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildActionTile(context, height: 420),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildHeroTile(context, height: 300),
                const SizedBox(height: 16),
                _buildActionTile(context, height: 420),
                const SizedBox(height: 16),
                _buildInfoTile(context, height: 240),
                const SizedBox(height: 16),
                _buildMetaTile(context, height: 240),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildHeroTile(BuildContext context, {required double height}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _BentoCard(
      height: height,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [scheme.primary, scheme.tertiary],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -40,
            child: Icon(
              Icons.insights_rounded,
              size: 280,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.query_stats_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                appShortName,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appFullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required double height}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    final answered = controller.answeredCount;
    final total = controller.questions.length;
    final progress = controller.progress;
    final allAnswered = controller.allAnswered;

    final ctaLabel =
        allAnswered
            ? strings.homeRestartButton
            : (answered > 0
                ? strings.homeContinueButton
                : strings.homeStartButton);
    final ctaIcon =
        allAnswered ? Icons.replay_rounded : Icons.play_arrow_rounded;

    return _BentoCard(
      height: height,
      color: scheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes_rounded, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                allAnswered ? strings.sectionResult : strings.progressTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            allAnswered ? '100%' : '${(progress * 100).toInt()}%',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 88,
              fontWeight: FontWeight.w900,
              color: scheme.primary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            strings.homeProgressText(answered, total),
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          AnimatedValueBar(value: progress, minHeight: 12),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: FilledButton.icon(
              onPressed: onStartOrContinue,
              icon: Icon(ctaIcon, size: 28),
              label: Text(
                ctaLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          if (allAnswered) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: FilledButton.tonalIcon(
                onPressed: onViewResult,
                icon: const Icon(Icons.insights_rounded, size: 28),
                label: Text(
                  strings.homeViewResultButton,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {required double height}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    return _BentoCard(
      height: height,
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const Spacer(),
          Text(
            strings.homeIntro,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTile(BuildContext context, {required double height}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final totalQuestions = controller.questions.length;
    final String questionsLabel = switch (strings.locale.locale.languageCode) {
      'ja' => '$totalQuestions 問',
      'en' => '$totalQuestions Q',
      _ => '$totalQuestions 题',
    };

    return _BentoCard(
      height: height,
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.tune_rounded, color: scheme.onTertiaryContainer),
          ),
          const Spacer(),
          _buildMetaRow(
            context,
            Icons.format_list_numbered_rounded,
            questionsLabel,
          ),
          const SizedBox(height: 16),
          _buildMetaRow(context, Icons.timer_outlined, strings.homeMetaTime),
          const SizedBox(height: 16),
          _buildMetaRow(
            context,
            Icons.edit_note_rounded,
            strings.homeMetaFreeEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 24, color: scheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.child,
    required this.height,
    this.color,
    this.gradient,
  });

  final Widget child;
  final double height;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? scheme.surfaceContainer) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
        border:
            gradient == null
                ? Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                )
                : null,
        boxShadow:
            gradient != null
                ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.25),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ]
                : [],
      ),
      child: child,
    );
  }
}
