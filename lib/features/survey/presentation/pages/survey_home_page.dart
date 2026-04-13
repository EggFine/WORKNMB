import 'package:flutter/material.dart';

import '../../../../app/app_identity.dart';
import '../../../../app/state/app_preferences.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/widgets/responsive.dart';
import '../controllers/survey_controller.dart';
import '../widgets/common/survey_common_widgets.dart';
import '../widgets/sections/home_section.dart';
import '../widgets/sections/questionnaire_section.dart';
import '../widgets/sections/result_section.dart';
import '../widgets/sections/settings_section.dart';

class SurveyHomePage extends StatefulWidget {
  const SurveyHomePage({required this.preferences, super.key});

  final AppPreferences preferences;

  @override
  State<SurveyHomePage> createState() => _SurveyHomePageState();
}

class _SurveyHomePageState extends State<SurveyHomePage> {
  late final SurveyController controller;
  late final Listenable mergedListenable;

  @override
  void initState() {
    super.initState();
    controller = SurveyController();
    mergedListenable = Listenable.merge([controller, widget.preferences]);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mergedListenable,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth;
            final useRail = Responsive.useRail(viewportWidth);
            final extendedRail = Responsive.useExtendedRail(viewportWidth);

            return Scaffold(
              // 去除 AppBar：品牌由侧边栏 logo 承担；当前 tab 标题由主内容区页头承担
              bottomNavigationBar: useRail
                  ? null
                  : _MobileNavigationBar(
                      section: controller.section,
                      onSelected: controller.selectSection,
                    ),
              body: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    if (useRail)
                      _BrandedNavigationRail(
                        section: controller.section,
                        extended: extendedRail,
                        onSelected: controller.selectSection,
                      ),
                    Expanded(child: _buildContent(useRail: useRail)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent({required bool useRail}) {
    final isHome = controller.section == AppSection.home;

    // Home 页完全沉浸：无页头、无滚动容器外壳，登陆页自己占满视口
    if (isHome) {
      return FadeSlideSwitcher(
        child: KeyedSubtree(key: ValueKey(controller.section), child: _home()),
      );
    }

    // 其他页面：顶部统一的 PageHeader（tab 标题 + 简短描述）+ section 内容
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        useRail ? AppSpacing.xl : AppSpacing.md,
        useRail ? AppSpacing.lg : AppSpacing.md,
        useRail ? AppSpacing.xl : AppSpacing.md,
        useRail ? AppSpacing.xl : AppLayout.bottomBarReserved,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PageHeader(
                title: controller.section.label,
                description: controller.sectionDescription,
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeSlideSwitcher(
                child: KeyedSubtree(
                  key: ValueKey(controller.section),
                  child: _buildSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _home() {
    return HomeSection(
      controller: controller,
      onStartOrContinue: () {
        if (controller.allAnswered) {
          controller.restart();
          controller.openQuestionnaire(0);
        } else {
          controller.openQuestionnaire(controller.firstUnansweredIndex);
        }
      },
      onViewResult: () => controller.selectSection(AppSection.result),
    );
  }

  Widget _buildSection() {
    return switch (controller.section) {
      AppSection.home => _home(),
      AppSection.questionnaire => QuestionnaireSection(
        controller: controller,
        onChooseOption: controller.choose,
        onRate: controller.rate,
        onNumericChanged: controller.setNumeric,
        onNext: controller.next,
        onPrevious: controller.previous,
        onOpenQuestionnaire: controller.openQuestionnaire,
      ),
      AppSection.result => ResultSection(
        controller: controller,
        onRestart: controller.restart,
        onOpenOverview: () => controller.selectSection(AppSection.home),
        onContinueQuestionnaire: () {
          controller.openQuestionnaire(controller.firstUnansweredIndex);
        },
      ),
      AppSection.settings => SettingsSection(
        controller: controller,
        themeMode: widget.preferences.themeMode,
        selectedPalette: widget.preferences.palette,
        onThemeModeChanged: widget.preferences.setThemeMode,
        onPaletteChanged: widget.preferences.setPalette,
        onRestart: controller.restart,
      ),
    };
  }
}

/// 底部导航（窄屏）。4 个 destination，与 Rail 对齐。
class _MobileNavigationBar extends StatelessWidget {
  const _MobileNavigationBar({required this.section, required this.onSelected});

  final AppSection section;
  final ValueChanged<AppSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: section.index,
      onDestinationSelected: (index) => onSelected(AppSection.values[index]),
      destinations: [
        for (final item in AppSection.values)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          ),
      ],
    );
  }
}

/// 品牌化的 NavigationRail（PC 端）。
///
/// 在 Material 原生 NavigationRail 基础上：
/// - `leading`：品牌徽标（+ 名称，extended 模式下）。
/// - 间距对齐设计令牌。
/// - 收窄时显示紧凑样式；extended 时显示全名与副标题。
class _BrandedNavigationRail extends StatelessWidget {
  const _BrandedNavigationRail({
    required this.section,
    required this.extended,
    required this.onSelected,
  });

  final AppSection section;
  final bool extended;
  final ValueChanged<AppSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: scheme.outlineVariant)),
        color: scheme.surface,
      ),
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height,
            ),
            child: NavigationRail(
              selectedIndex: section.index,
              extended: extended,
              minWidth: 88,
              minExtendedWidth: 240,
              groupAlignment: -0.85,
              backgroundColor: Colors.transparent,
              indicatorColor: scheme.secondaryContainer,
              useIndicator: true,
              onDestinationSelected: (index) =>
                  onSelected(AppSection.values[index]),
              leading: _RailBrandHeader(extended: extended),
              destinations: [
                for (final item in AppSection.values)
                  NavigationRailDestination(
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxs,
                      ),
                      child: Icon(item.icon),
                    ),
                    selectedIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxs,
                      ),
                      child: Icon(item.selectedIcon),
                    ),
                    label: Text(item.label),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RailBrandHeader extends StatelessWidget {
  const _RailBrandHeader({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // 侧边栏 leading 仅显示 logo 图标 —— 品牌文字由顶部 AppBar 承担。
    // 目的是避免品牌标题在 AppBar + 侧边栏两处重复出现。
    final logo = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Icon(
        Icons.query_stats_rounded,
        size: AppIconSize.md,
        color: scheme.onPrimaryContainer,
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        extended ? AppSpacing.md : AppSpacing.sm,
        AppSpacing.md,
        extended ? AppSpacing.md : AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Align(
        alignment: extended ? Alignment.centerLeft : Alignment.center,
        child: Tooltip(message: appShortName, child: logo),
      ),
    );
  }
}

/// 页面顶部的标准页头：大字号 tab 标题 + 次要描述。
///
/// 取代了顶部 AppBar 的"当前页面"指示功能 —— 让 tab 标题属于主内容区，
/// 而不是悬浮于屏幕顶部的 chrome。
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(description!, style: theme.bodyMediumMuted),
        ],
      ],
    );
  }
}
