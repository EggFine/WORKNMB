import 'package:flutter/material.dart';

import '../../../../app/app_identity.dart';
import '../../../../app/i18n/app_strings.dart';
import '../../../../app/state/app_preferences.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/widgets/responsive.dart';
import '../../domain/localized_survey.dart';
import '../../domain/questions_zh.dart';
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
    // 初始化时使用默认 locale 的题库；切语言时会在 didChangeDependencies 更新
    controller = SurveyController(survey: surveyZh);
    mergedListenable = Listenable.merge([controller, widget.preferences]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 从 AppStringsScope 里拿当前 locale 对应的题库
    final strings = AppStrings.of(context);
    controller.updateSurvey(surveyFor(strings.locale));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// 获取某个 section 的本地化标题。
  String _sectionLabel(AppStrings s, AppSection section) => switch (section) {
    AppSection.home => s.sectionHome,
    AppSection.questionnaire => s.sectionQuestionnaire,
    AppSection.result => s.sectionResult,
    AppSection.settings => s.sectionSettings,
  };

  /// 获取某个 section 的本地化描述（用于 PageHeader）。
  String _sectionDescription(AppStrings s, AppSection section) =>
      switch (section) {
        AppSection.home => s.homeDescription,
        AppSection.questionnaire => s.questionnaireDescription,
        AppSection.result =>
          controller.allAnswered
              ? s.resultDescriptionUnlocked
              : s.resultDescriptionLocked,
        AppSection.settings => s.settingsDescription,
      };

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return AnimatedBuilder(
      animation: mergedListenable,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth;
            final useRail = Responsive.useRail(viewportWidth);
            final extendedRail = Responsive.useExtendedRail(viewportWidth);

            return Scaffold(
              bottomNavigationBar: useRail
                  ? null
                  : _MobileNavigationBar(
                      section: controller.section,
                      labelFor: (sec) => _sectionLabel(strings, sec),
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
                        labelFor: (sec) => _sectionLabel(strings, sec),
                        onSelected: controller.selectSection,
                      ),
                    Expanded(
                      child: _buildContent(useRail: useRail, strings: strings),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent({required bool useRail, required AppStrings strings}) {
    final isHome = controller.section == AppSection.home;

    if (isHome) {
      return FadeSlideSwitcher(
        child: KeyedSubtree(key: ValueKey(controller.section), child: _home()),
      );
    }

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
                title: _sectionLabel(strings, controller.section),
                description: _sectionDescription(strings, controller.section),
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
        preferences: widget.preferences,
      ),
    };
  }
}

/// 底部导航（窄屏）。4 个 destination。
class _MobileNavigationBar extends StatelessWidget {
  const _MobileNavigationBar({
    required this.section,
    required this.labelFor,
    required this.onSelected,
  });

  final AppSection section;
  final String Function(AppSection) labelFor;
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
            label: labelFor(item),
          ),
      ],
    );
  }
}

/// 品牌化的 NavigationRail（PC 端）。
class _BrandedNavigationRail extends StatelessWidget {
  const _BrandedNavigationRail({
    required this.section,
    required this.extended,
    required this.labelFor,
    required this.onSelected,
  });

  final AppSection section;
  final bool extended;
  final String Function(AppSection) labelFor;
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
                    label: Text(labelFor(item)),
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
