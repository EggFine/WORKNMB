import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// [AppCard] 的三种视觉变体。
///
/// - [outlined]：常规卡片，使用主题 [CardTheme] 默认样式（描边 + 微阴影）。
/// - [filled]：强调卡片，使用 [fillColor]（常为 primaryContainer / 自定义高亮色）。
/// - [featured]：顶级焦点卡片（如 Hero / 结果摘要），在 filled 基础上增加柔光装饰层。
enum AppCardVariant { outlined, filled, featured }

/// 标准化的 Card 容器：统一 padding、radius、decoration。
///
/// 所有业务 section 应优先使用 [AppCard] 而非直接 `Card(child: Padding(...))`，
/// 以避免 card padding / radius 在不同页面漂移。
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.variant = AppCardVariant.outlined,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.fillColor,
    this.featuredAccentColor,
    super.key,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;

  /// filled / featured 变体的背景色。未指定时使用 `primaryContainer`。
  final Color? fillColor;

  /// featured 变体的装饰光斑色。未指定时使用 `secondaryContainer`。
  final Color? featuredAccentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (variant) {
      case AppCardVariant.outlined:
        return Card(
          child: Padding(padding: padding, child: child),
        );

      case AppCardVariant.filled:
        return Card.filled(
          color: fillColor ?? scheme.primaryContainer,
          child: Padding(padding: padding, child: child),
        );

      case AppCardVariant.featured:
        final baseColor = fillColor ?? scheme.primaryContainer;
        final accent =
            featuredAccentColor ??
            scheme.secondaryContainer.withValues(alpha: 0.55);
        return Card.filled(
          color: baseColor,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Stack(
              children: [
                // 右上角光斑：在 featured 卡片上形成视觉焦点。
                Positioned(
                  right: -60,
                  top: -60,
                  child: IgnorePointer(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                      ),
                    ),
                  ),
                ),
                // 左下角更柔和的第二层光斑，增加纵深。
                Positioned(
                  left: -80,
                  bottom: -80,
                  child: IgnorePointer(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        );
    }
  }
}
