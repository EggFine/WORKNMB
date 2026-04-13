import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app/app_identity.dart';
import '../../../../../app/theme/app_palette.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/theme/text_styles.dart';
import '../../../../../app/widgets/app_card.dart';
import '../../../../../app/widgets/app_section_header.dart';
import '../../controllers/survey_controller.dart';
import '../../../domain/survey_data.dart';

/// 设置页：外观（主题 + 色板）+ 测试管理（重置）+ 关于。
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.controller,
    required this.themeMode,
    required this.selectedPalette,
    required this.onThemeModeChanged,
    required this.onPaletteChanged,
    required this.onRestart,
    super.key,
  });

  final SurveyController controller;
  final ThemeMode themeMode;
  final AppPalette selectedPalette;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<AppPalette> onPaletteChanged;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppearanceCard(
          themeMode: themeMode,
          selectedPalette: selectedPalette,
          onThemeModeChanged: onThemeModeChanged,
          onPaletteChanged: onPaletteChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _ManageTestCard(controller: controller, onRestart: onRestart),
        const SizedBox(height: AppSpacing.md),
        const _AboutCard(),
      ],
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({
    required this.themeMode,
    required this.selectedPalette,
    required this.onThemeModeChanged,
    required this.onPaletteChanged,
  });

  final ThemeMode themeMode;
  final AppPalette selectedPalette;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<AppPalette> onPaletteChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: '外观设置',
            description: '主题和色板会实时重绘 WORKNMB，用来快速验证不同视觉语义下的层级和可读性。',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('主题模式', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              selected: {themeMode},
              onSelectionChanged: (selection) {
                onThemeModeChanged(selection.first);
              },
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded),
                  label: Text('浅色'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('深色'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_suggest_rounded),
                  label: Text('系统'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('动态色板', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AppPalette>(
              showSelectedIcon: false,
              selected: {selectedPalette},
              onSelectionChanged: (selection) {
                onPaletteChanged(selection.first);
              },
              segments: [
                for (final palette in AppPalette.values)
                  ButtonSegment<AppPalette>(
                    value: palette,
                    icon: Icon(palette.icon, color: palette.seedColor),
                    label: Text(palette.label),
                  ),
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
                  selectedPalette.icon,
                  color: selectedPalette.seedColor,
                  size: AppIconSize.md,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    selectedPalette.description,
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
}

class _ManageTestCard extends StatelessWidget {
  const _ManageTestCard({required this.controller, required this.onRestart});

  final SurveyController controller;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAnswers = controller.answers.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: '测试管理',
            description: '清除当前所有答案，回到首页从头开始。这个动作不可撤销。',
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
                      ? '当前已答 ${controller.answeredCount} / ${questions.length} 题'
                      : '当前没有已答题目，暂无需重置。',
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
              label: const Text('重置测试'),
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: '关于'),
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
          Text(
            '这个评测用 ${questions.length} 个维度量化你当前工作的性价比：'
            '工时、通勤、加班、补偿、休息、环境、同事、晋升、月薪。'
            '按"基础分 × 薪资系数"得到 0-100 的综合评分，配合 S/A/B/C/D 等级'
            '和薄弱项建议，帮你判断是否值得留下。',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          _LinkRow(
            icon: Icons.code_rounded,
            label: '源码仓库',
            url: appRepoUrl,
            subtitle: 'EggFine/WORKNMB',
          ),
          const SizedBox(height: AppSpacing.sm),
          _LinkRow(
            icon: Icons.public_rounded,
            label: '在线预览',
            url: appPreviewUrl,
            subtitle: appPreviewUrl.replaceFirst('https://', ''),
          ),
        ],
      ),
    );
  }
}

/// 可点击的链接行：左图标 + 标签 + 子文字 + 右箭头。
///
/// 点击：
/// - 主操作：调用 [launchUrl] 用外部浏览器打开
/// - 失败兜底：复制到剪贴板 + SnackBar 提示
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
    final uri = Uri.parse(url);
    bool ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (ok || !context.mounted) return;
    // 打不开时 fall back 到剪贴板
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('无法直接打开，已复制链接到剪贴板：$url')),
    );
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
