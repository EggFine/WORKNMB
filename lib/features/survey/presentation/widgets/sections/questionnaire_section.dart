import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/design_tokens.dart';
import '../../../../../app/theme/text_styles.dart';
import '../../../../../app/widgets/app_card.dart';
import '../../../../../app/widgets/app_section_header.dart';
import '../../../../../app/widgets/responsive.dart';
import '../../controllers/survey_controller.dart';
import '../../../domain/survey_data.dart';
import '../common/survey_common_widgets.dart';

class QuestionnaireSection extends StatelessWidget {
  const QuestionnaireSection({
    required this.controller,
    required this.onChooseOption,
    required this.onRate,
    required this.onNumericChanged,
    required this.onNext,
    required this.onPrevious,
    required this.onOpenQuestionnaire,
    super.key,
  });

  final SurveyController controller;
  final ValueChanged<int> onChooseOption;
  final ValueChanged<int> onRate;
  final ValueChanged<double> onNumericChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<int?> onOpenQuestionnaire;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = Responsive.isWideContent(constraints.maxWidth);

        final questionCard = _QuestionCard(
          controller: controller,
          onChooseOption: onChooseOption,
          onRate: onRate,
          onNumericChanged: onNumericChanged,
          onNext: onNext,
          onPrevious: onPrevious,
        );

        final progressCard = _ProgressCard(
          controller: controller,
          onJumpTo: onOpenQuestionnaire,
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: questionCard),
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 2, child: progressCard),
            ],
          );
        }

        return Column(
          children: [
            progressCard,
            const SizedBox(height: AppSpacing.md),
            questionCard,
          ],
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  进度卡（进度条 + 状态芯片 + 跳题圆点）
// ════════════════════════════════════════════════════════════════════════════

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.controller, required this.onJumpTo});

  final SurveyController controller;
  final ValueChanged<int?> onJumpTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: '完成进度'),
          const SizedBox(height: AppSpacing.sm),
          AnimatedValueBar(value: controller.progress),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: AppDurations.fast,
            child: Text(
              '${(controller.progress * 100).round()}% 已完成 · 当前第 ${controller.currentQuestionIndex + 1}/${questions.length} 题',
              key: ValueKey(
                '${controller.answeredCount}-${controller.currentQuestionIndex}',
              ),
              style: theme.bodyMediumMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusChip(
                icon: Icons.track_changes_rounded,
                label: '当前分类：${controller.question.category}',
              ),
              StatusChip(
                icon: Icons.assignment_turned_in_outlined,
                label: '已答 ${controller.answeredCount} 题',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '跳转到题目',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _QuickJumpRow(controller: controller, onSelected: onJumpTo),
        ],
      ),
    );
  }
}

class _QuickJumpRow extends StatelessWidget {
  const _QuickJumpRow({required this.controller, required this.onSelected});

  final SurveyController controller;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: List.generate(questions.length, (index) {
        final q = questions[index];
        final answered = controller.answers.containsKey(q.id);
        final current = controller.currentQuestionIndex == index;
        return _JumpDot(
          number: index + 1,
          answered: answered,
          current: current,
          onTap: () => onSelected(index),
        );
      }),
    );
  }
}

class _JumpDot extends StatelessWidget {
  const _JumpDot({
    required this.number,
    required this.answered,
    required this.current,
    required this.onTap,
  });

  final int number;
  final bool answered;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color bg;
    final Color fg;
    final Color border;
    if (current) {
      bg = scheme.primary;
      fg = scheme.onPrimary;
      border = scheme.primary;
    } else if (answered) {
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
      border = scheme.primaryContainer;
    } else {
      bg = Colors.transparent;
      fg = scheme.onSurfaceVariant;
      border = scheme.outlineVariant;
    }

    return Semantics(
      button: true,
      selected: current,
      label: '跳转到第 $number 题${answered ? "，已作答" : "，未作答"}',
      child: Tooltip(
        message: '第 $number 题${answered ? "（已答）" : ""}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppCurves.standard,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  问题卡（按题型分发）
// ════════════════════════════════════════════════════════════════════════════

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.controller,
    required this.onChooseOption,
    required this.onRate,
    required this.onNumericChanged,
    required this.onNext,
    required this.onPrevious,
  });

  final SurveyController controller;
  final ValueChanged<int> onChooseOption;
  final ValueChanged<int> onRate;
  final ValueChanged<double> onNumericChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = controller.question;

    return AppCard(
      child: FadeSlideSwitcher(
        child: KeyedSubtree(
          key: ValueKey(controller.questionTransitionToken),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // —— 标签与进度芯片 ——
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(
                    avatar: const Icon(
                      Icons.label_outline_rounded,
                      size: AppIconSize.sm,
                    ),
                    label: Text(q.category),
                  ),
                  Chip(
                    avatar: const Icon(
                      Icons.format_list_numbered_rounded,
                      size: AppIconSize.sm,
                    ),
                    label: Text(
                      '第 ${controller.currentQuestionIndex + 1}/${questions.length} 题',
                    ),
                  ),
                  if (controller.isCurrentAnswered)
                    const Chip(
                      avatar: Icon(
                        Icons.check_circle_rounded,
                        size: AppIconSize.sm,
                      ),
                      label: Text('已作答'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // —— 题目文本 ——
              Text(
                q.title,
                key: const Key('question-title'),
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(q.hint, style: theme.bodyLargeMuted),
              const SizedBox(height: AppSpacing.xl),
              // —— 按题型分发 ——
              switch (q) {
                ChoiceQuestion question => _ChoiceBody(
                  question: question,
                  answer: controller.answerFor(q.id) as ChoiceAnswer?,
                  onChoose: onChooseOption,
                ),
                RatingQuestion question => _RatingBody(
                  question: question,
                  answer: controller.answerFor(q.id) as RatingAnswer?,
                  onRate: onRate,
                ),
                NumericQuestion question => _NumericBody(
                  question: question,
                  answer: controller.answerFor(q.id) as NumericAnswer?,
                  onChanged: onNumericChanged,
                ),
              },
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              // —— 翻页按钮 ——
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: controller.currentQuestionIndex == 0
                        ? null
                        : onPrevious,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('上一题'),
                  ),
                  FilledButton.icon(
                    key: const Key('next-button'),
                    onPressed: controller.isCurrentAnswered ? onNext : null,
                    icon: Icon(
                      controller.currentQuestionIndex == questions.length - 1 &&
                              controller.allAnswered
                          ? Icons.auto_awesome_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(
                      controller.currentQuestionIndex == questions.length - 1
                          ? (controller.allAnswered ? '查看评分' : '检查未答题')
                          : '下一题',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  选择题 body
// ════════════════════════════════════════════════════════════════════════════

class _ChoiceBody extends StatelessWidget {
  const _ChoiceBody({
    required this.question,
    required this.answer,
    required this.onChoose,
  });

  final ChoiceQuestion question;
  final ChoiceAnswer? answer;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<int>(
      groupValue: answer?.index,
      onChanged: (value) {
        if (value != null) onChoose(value);
      },
      child: Column(
        children: List.generate(question.options.length, (index) {
          final option = question.options[index];
          final selected = answer?.index == index;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == question.options.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: _OptionCard(
              option: option,
              index: index,
              selected: selected,
              onTap: () => onChoose(index),
            ),
          );
        }),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final QuizOption option;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedScale(
      duration: AppDurations.fast,
      curve: AppCurves.standard,
      scale: selected ? 1 : 0.996,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        decoration: BoxDecoration(
          color: selected
              ? scheme.secondaryContainer
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio<int>(value: index),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(option.note, style: theme.bodyMediumMuted),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    duration: AppDurations.fast,
                    opacity: selected ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.sm,
                        top: 2,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  评分题 body（5 个按钮 + 标签）
// ════════════════════════════════════════════════════════════════════════════

class _RatingBody extends StatelessWidget {
  const _RatingBody({
    required this.question,
    required this.answer,
    required this.onRate,
  });

  final RatingQuestion question;
  final RatingAnswer? answer;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = answer?.stars;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 每个按钮最小 56px 宽度 + spacing 12px
        final compact = constraints.maxWidth < 420;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(question.maxRating, (i) {
                final stars = i + 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 2 : AppSpacing.xxs,
                    ),
                    child: _RatingButton(
                      stars: stars,
                      label: question.labels[i],
                      selected: selected == stars,
                      onTap: () => onRate(stars),
                      compact: compact,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Text(
                selected == null
                    ? '请选择一个评级'
                    : '已选：${question.labels[selected - 1]}（$selected / ${question.maxRating}）',
                key: ValueKey(selected),
                style: theme.bodyMediumMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.stars,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final int stars;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          padding: EdgeInsets.symmetric(
            vertical: compact ? AppSpacing.sm : AppSpacing.md,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected
                ? scheme.secondaryContainer
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$stars',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? scheme.primary : scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  数字题 body（月薪输入）
// ════════════════════════════════════════════════════════════════════════════

class _NumericBody extends StatefulWidget {
  const _NumericBody({
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final NumericQuestion question;
  final NumericAnswer? answer;
  final ValueChanged<double> onChanged;

  @override
  State<_NumericBody> createState() => _NumericBodyState();
}

class _NumericBodyState extends State<_NumericBody> {
  late final TextEditingController _controller;

  bool get _isSalary => widget.question.isSalaryMultiplier;
  bool get _allowDecimal => widget.question.allowDecimal;

  @override
  void initState() {
    super.initState();
    final initial = widget.answer?.value ?? widget.question.defaultValue;
    _controller = TextEditingController(text: _formatNumber(initial));
  }

  @override
  void didUpdateWidget(covariant _NumericBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 controller 外部重置（例如点击"重新测试"）时，更新输入框
    final external = widget.answer?.value;
    if (external != null && external != _parseCurrent()) {
      _controller.text = _formatNumber(external);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _parseCurrent() {
    final raw = _controller.text.replaceAll(',', '').trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  /// 统一数字格式化：
  /// - 薪资题（整数）：千分位展示，如 `10,000`
  /// - 允许小数的普通数字题：非整数保留 1 位小数，如 `8.5`；整数不带小数点
  /// - 只允许整数的普通数字题：直接展示整数
  String _formatNumber(double v) {
    if (_isSalary) {
      final iv = v.round();
      final s = iv.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
        buffer.write(s[i]);
      }
      return buffer.toString();
    }
    if (_allowDecimal && v != v.roundToDouble()) {
      return v.toStringAsFixed(1);
    }
    return v.round().toString();
  }

  /// 快捷芯片 label：薪资用"1 万 / 8k"；其他用"8 小时 / 30 分钟"这种带单位格式
  String _formatQuickPick(double v) {
    if (_isSalary) {
      return v >= 10000
          ? '${(v / 10000).toStringAsFixed(v % 10000 == 0 ? 0 : 1)} 万'
          : '${(v / 1000).toStringAsFixed(0)}k';
    }
    return '${_formatNumber(v)} ${widget.question.unit}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final q = widget.question;
    final current = _parseCurrent() ?? q.defaultValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // —— 输入框 ——
        TextField(
          controller: _controller,
          keyboardType: TextInputType.numberWithOptions(decimal: _allowDecimal),
          inputFormatters: _isSalary
              ? [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  _ThousandsFormatter(),
                ]
              : [
                  FilteringTextInputFormatter.allow(
                    RegExp(_allowDecimal ? r'[0-9.]' : r'[0-9]'),
                  ),
                ],
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            prefixIcon: _isSalary
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.xs,
                    ),
                    child: Text(
                      '¥',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixText: q.unit,
            suffixStyle: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide: BorderSide(color: scheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
          ),
          onChanged: (_) {
            final parsed = _parseCurrent();
            if (parsed != null) {
              widget.onChanged(parsed);
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        // —— 快速选择 ——
        Text(
          _isSalary ? '快捷金额' : '常见值',
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final v in q.quickPicks)
              ActionChip(
                label: Text(_formatQuickPick(v)),
                onPressed: () {
                  _controller.text = _formatNumber(v);
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                  widget.onChanged(v);
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // —— 实时反馈（薪资题显示系数；其他数字题显示当前得分）——
        _FeedbackCard(question: q, currentValue: current),
      ],
    );
  }
}

/// 数字题下方的实时反馈卡：薪资题显示系数；其他数字题显示"当前得分 N/10"。
class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.question, required this.currentValue});

  final NumericQuestion question;
  final double currentValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isSalary = question.isSalaryMultiplier;

    String title;
    String subtitle;
    IconData icon;

    if (isSalary) {
      final coefficient = salaryCoefficientOf(currentValue, question.baseline);
      final atCap = coefficient >= salaryCoefficientMax;
      title = '薪资系数 ×${coefficient.toStringAsFixed(2)}';
      subtitle = atCap
          ? '已达到封顶系数 ×${salaryCoefficientMax.toStringAsFixed(1)}（薪资越高不再继续加成）'
          : '基准值 ${question.baseline.round()} 元 / 月 = ×1.00';
      icon = Icons.calculate_rounded;
    } else {
      final score = _linearScore(question, currentValue);
      title = '当前得分 ${score.toStringAsFixed(1)} / 10';
      final higher = question.bestValue > question.worstValue;
      subtitle = higher
          ? '越接近 ${_fmt(question.bestValue)} ${question.unit}得分越高；低于 ${_fmt(question.worstValue)} ${question.unit}得 0 分'
          : '越接近 ${_fmt(question.bestValue)} ${question.unit}得分越高；高于 ${_fmt(question.worstValue)} ${question.unit}得 0 分';
      icon = Icons.score_rounded;
    }

    return AnimatedContainer(
      duration: AppDurations.fast,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: AppIconSize.md),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }

  static double _linearScore(NumericQuestion q, double v) {
    final best = q.bestValue;
    final worst = q.worstValue;
    if (best == worst) return 10;
    return (((v - worst) / (best - worst)) * 10).clamp(0.0, 10.0);
  }
}

/// 千分位格式化：用户输入时实时加/移逗号（仅用于薪资题）。
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final n = int.tryParse(raw);
    if (n == null) return oldValue;

    final formatted = _group(raw);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _group(String s) {
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
