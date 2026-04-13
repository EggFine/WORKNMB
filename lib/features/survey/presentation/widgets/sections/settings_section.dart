import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app/app_identity.dart';
import '../../../../../app/i18n/app_locale.dart';
import '../../../../../app/i18n/app_strings.dart';
import '../../../../../app/state/app_preferences.dart';
import '../../../../../app/theme/app_palette.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/theme/text_styles.dart';
import '../../../../../app/widgets/app_card.dart';
import '../../../../../app/widgets/app_section_header.dart';
import '../../controllers/survey_controller.dart';

/// 设置页：外观（主题 + 色板 + 语言）+ 测试管理（重置）+ 关于。
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.controller,
    required this.preferences,
    super.key,
  });

  final SurveyController controller;
  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppearanceCard(preferences: preferences),
        const SizedBox(height: AppSpacing.md),
        _ManageTestCard(controller: controller, onRestart: controller.restart),
        const SizedBox(height: AppSpacing.md),
        const _AboutCard(),
      ],
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({required this.preferences});

  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: strings.appearanceTitle,
            description: strings.appearanceDescription,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(strings.themeModeLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              selected: {preferences.themeMode},
              onSelectionChanged: (selection) {
                preferences.setThemeMode(selection.first);
              },
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_rounded),
                  label: Text(strings.themeModeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_rounded),
                  label: Text(strings.themeModeDark),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.settings_suggest_rounded),
                  label: Text(strings.themeModeSystem),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(strings.paletteLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AppPalette>(
              showSelectedIcon: false,
              selected: {preferences.palette},
              onSelectionChanged: (selection) {
                preferences.setPalette(selection.first);
              },
              segments: [
                for (final palette in AppPalette.values)
                  ButtonSegment<AppPalette>(
                    value: palette,
                    icon: Icon(palette.icon, color: palette.seedColor),
                    label: Text(_paletteLabel(palette, strings)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings.languageSectionTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AppLocale?>(
              showSelectedIcon: false,
              selected: {preferences.locale},
              onSelectionChanged: (selection) {
                preferences.setLocale(selection.first);
              },
              segments: [
                ButtonSegment(
                  value: null,
                  icon: const Icon(Icons.translate_rounded),
                  label: Text(strings.languageSystem),
                ),
                for (final l in AppLocale.values)
                  ButtonSegment(value: l, label: Text(l.displayName)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedContainer(
            duration: AppDurations.normal,
            curve: AppCurves.standard,
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Row(
              children: [
                Icon(
                  preferences.palette.icon,
                  color: preferences.palette.seedColor,
                  size: AppIconSize.md,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _paletteDesc(preferences.palette, strings),
                    style: theme.bodyMediumMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _paletteLabel(AppPalette p, AppStrings s) => switch (p) {
    AppPalette.tide => s.paletteTideLabel,
    AppPalette.ember => s.paletteEmberLabel,
    AppPalette.moss => s.paletteMossLabel,
  };

  String _paletteDesc(AppPalette p, AppStrings s) => switch (p) {
    AppPalette.tide => s.paletteTideDesc,
    AppPalette.ember => s.paletteEmberDesc,
    AppPalette.moss => s.paletteMossDesc,
  };
}

class _ManageTestCard extends StatelessWidget {
  const _ManageTestCard({required this.controller, required this.onRestart});

  final SurveyController controller;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final hasAnswers = controller.answers.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: strings.manageTitle,
            description: strings.manageDescription,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(
                hasAnswers
                    ? Icons.restart_alt_rounded
                    : Icons.sentiment_satisfied_rounded,
                color: hasAnswers
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  hasAnswers
                      ? strings.manageHasAnswers(
                          controller.answeredCount,
                          controller.questions.length,
                        )
                      : strings.manageNoAnswers,
                  style: theme.bodyMediumMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: hasAnswers ? onRestart : null,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(strings.manageResetButton),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: strings.aboutTitle),
          const SizedBox(height: AppSpacing.md),
          Text(
            appShortName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(appFullName, style: theme.bodyMediumMuted),
          const SizedBox(height: AppSpacing.md),
          Text(strings.homeIntro, style: theme.bodyMediumMuted),
          const SizedBox(height: AppSpacing.lg),
          _LinkRow(
            icon: Icons.code_rounded,
            label: strings.aboutRepoLabel,
            url: appRepoUrl,
            subtitle: 'EggFine/WORKNMB',
          ),
          const SizedBox(height: AppSpacing.sm),
          _LinkRow(
            icon: Icons.public_rounded,
            label: strings.aboutPreviewLabel,
            url: appPreviewUrl,
            subtitle: appPreviewUrl.replaceFirst('https://', ''),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.url,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String url;
  final String subtitle;

  Future<void> _open(BuildContext context) async {
    final strings = AppStrings.of(context);
    final uri = Uri.parse(url);
    bool ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (ok || !context.mounted) return;
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.clipboardFallback(url))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Icon(icon, size: AppIconSize.sm, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: AppIconSize.sm,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
