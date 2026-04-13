import '../theme/design_tokens.dart';

/// 响应式判断辅助。
///
/// 约定：
/// - 判断顶层布局（Rail / BottomBar）用 `isCompact` / `isMedium` / `isExpanded`，
///   传入视口宽度（MediaQuery / 顶层 LayoutBuilder）。
/// - 判断节内宽屏（卡片排成 Row）用 `isWideContent`，
///   传入**内容区**的 LayoutBuilder `constraints.maxWidth`（已扣除 Rail）。
abstract final class Responsive {
  /// 视口 < 840：紧凑布局，使用底部 NavigationBar。
  static bool isCompact(double viewportWidth) =>
      viewportWidth < AppBreakpoints.medium;

  /// 视口 ∈ [840, 1200)：中等布局，使用窄 Rail。
  static bool isMedium(double viewportWidth) =>
      viewportWidth >= AppBreakpoints.medium &&
      viewportWidth < AppBreakpoints.expanded;

  /// 视口 ≥ 1200：展开布局，使用 Extended Rail。
  static bool isExpanded(double viewportWidth) =>
      viewportWidth >= AppBreakpoints.expanded;

  /// 视口是否需要侧边导航（≥ 840）。
  static bool useRail(double viewportWidth) =>
      viewportWidth >= AppBreakpoints.medium;

  /// 视口是否需要展开的 Rail（≥ 1200）。
  static bool useExtendedRail(double viewportWidth) =>
      viewportWidth >= AppBreakpoints.expanded;

  /// 节内容区是否足够宽以采用横向排布（≥ 900，扣除 Rail 后的可用宽度）。
  ///
  /// 该阈值稍小于 [AppBreakpoints.expanded]，因为 LayoutBuilder 拿到的是
  /// 去除 Rail 与 padding 之后的净宽度。900 对应 1200 视口 + 窄 Rail + 两侧 padding。
  static bool isWideContent(double bodyWidth) => bodyWidth >= 900;

  /// 在给定宽度下，MetricCard 栅格应显示几列。
  static int metricColumns(double bodyWidth) {
    if (bodyWidth < AppBreakpoints.compact) return 1;
    if (bodyWidth < 900) return 2;
    return 3;
  }
}
