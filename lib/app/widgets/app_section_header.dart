import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../theme/text_styles.dart';

/// 统一的节标题 + 描述组合。
///
/// 替代 `Column` 中散落的 `Text(titleLarge) + SizedBox(8) + Text(bodyMediumMuted)` 结构。
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.description,
    this.trailing,
    super.key,
  });

  final String title;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleRow = trailing == null
        ? Text(title, style: theme.textTheme.titleLarge)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
              trailing!,
            ],
          );

    if (description == null) return titleRow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleRow,
        const SizedBox(height: AppSpacing.xs),
        Text(description!, style: theme.bodyMediumMuted),
      ],
    );
  }
}
