import 'package:flutter/material.dart';

/// TextTheme 派生扩展：集中消除重复的 `.copyWith(color: onSurfaceVariant, height: 1.5)` 链。
///
/// 使用示例：
/// ```dart
/// Text('描述', style: Theme.of(context).bodyMediumMuted);
/// ```
extension AppTextStyles on ThemeData {
  /// 主体正文（次要颜色 + 舒适行高）。
  TextStyle get bodyMediumMuted => textTheme.bodyMedium!.copyWith(
    color: colorScheme.onSurfaceVariant,
    height: 1.5,
  );

  /// 较大正文（次要颜色 + 舒适行高）。
  TextStyle get bodyLargeMuted => textTheme.bodyLarge!.copyWith(
    color: colorScheme.onSurfaceVariant,
    height: 1.5,
  );

  /// 次要标签（hint / caption 语义）。
  TextStyle get labelMuted =>
      textTheme.labelLarge!.copyWith(color: colorScheme.onSurfaceVariant);

  /// Hero / 填充容器上的标题（自定义 onContainer 颜色）。
  TextStyle titleOnContainer(Color onContainer) =>
      textTheme.displaySmall!.copyWith(color: onContainer);

  /// Hero / 填充容器上的描述正文（半透明 onContainer）。
  TextStyle bodyOnContainer(Color onContainer) => textTheme.bodyLarge!.copyWith(
    color: onContainer.withValues(alpha: 0.84),
    height: 1.5,
  );
}
