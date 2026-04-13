/// WORKNMB 设计令牌（Design Tokens）
///
/// 所有视觉原语（断点、间距、圆角、动效、图标尺寸、布局约束）的单一事实来源。
/// 任何 UI 代码都不应直接硬编码这些维度的具体数值，请通过此文件引用。
library;

import 'package:flutter/material.dart';

/// Material 3 标准响应式断点。
abstract final class AppBreakpoints {
  /// < 600：手机竖屏等紧凑布局。
  static const double compact = 600;

  /// 600 ~ 839：手机横屏 / 小平板，仍采用紧凑交互。
  static const double medium = 840;

  /// 840 ~ 1199：平板 / 小桌面，启用 NavigationRail。
  static const double expanded = 1200;

  /// ≥ 1600：大桌面，可考虑更丰富的多栏布局。
  static const double large = 1600;
}

/// 8dp 网格间距体系。用于所有 `Padding`、`SizedBox`、`Wrap.spacing` 等。
abstract final class AppSpacing {
  static const double none = 0;
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;

  /// 最常用间距：节内组件默认间距 / 卡片之间。
  static const double md = 16;
  static const double lg = 20;

  /// 卡片标准内边距 / 节之间大间距。
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// 圆角语义层级。
abstract final class AppRadius {
  /// Chip / 小型 pill。
  static const double chip = 12;

  /// 按钮（Filled / Outlined / Segmented）。
  static const double button = 16;

  /// 输入框 / 选项卡。
  static const double input = 12;

  /// 标准卡片。
  static const double card = 24;

  /// Hero 等顶层装饰容器。
  static const double hero = 28;

  /// 全圆（Status chip、头像等）。
  static const double pill = 999;
}

/// 动效时长层级。
abstract final class AppDurations {
  /// 极短（120ms）：瞬时反馈。
  static const Duration instant = Duration(milliseconds: 120);

  /// 短（200ms）：微交互（opacity / scale / 按钮反馈）。
  static const Duration fast = Duration(milliseconds: 200);

  /// 中（260ms）：AnimatedSwitcher / AnimatedContainer / 节切换。
  static const Duration normal = Duration(milliseconds: 260);

  /// 长（420ms）：主题切换 / 进度条 / 大型容器过渡。
  static const Duration slow = Duration(milliseconds: 420);
}

/// 动效曲线。
abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}

/// 图标尺寸规格。
abstract final class AppIconSize {
  static const double xs = 16;

  /// Chip 内联图标。
  static const double sm = 18;

  /// 默认图标尺寸。
  static const double md = 24;
  static const double lg = 32;

  /// Hero / 结果摘要 / 指引大图标。
  static const double xl = 40;
}

/// 布局约束常量。
abstract final class AppLayout {
  /// 内容区最大宽度（居中）。
  static const double maxContentWidth = 1280;

  /// MetricCard 响应式最小宽度。
  static const double metricCardMinWidth = 240;

  /// MetricCard 响应式最大宽度。
  static const double metricCardMaxWidth = 340;

  /// 底部 NavigationBar 预留空间。
  static const double bottomBarReserved = 96;
}
