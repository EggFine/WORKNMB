import 'package:flutter/material.dart';

import '../../features/survey/domain/survey_data.dart';

enum AppPalette {
  tide('青潮', '平衡、冷静、偏专业', Color(0xFF006A6A), Icons.water_drop_rounded),
  ember(
    '暖岩',
    '更强调行动和推动感',
    Color(0xFF9A4521),
    Icons.local_fire_department_rounded,
  ),
  moss('森雾', '更安静，适合深色界面', Color(0xFF3C6A43), Icons.park_rounded);

  const AppPalette(this.label, this.description, this.seedColor, this.icon);

  final String label;
  final String description;
  final Color seedColor;
  final IconData icon;
}

/// 评分等级徽章的语义色令牌。
///
/// 映射策略（基于 Material 3 ColorScheme 语义 token，保证主题切换跟随）：
/// - S（顶级）: `primary`，最强势的品牌色
/// - A（不错）: `tertiary`，偏次一级的强调色
/// - B（还行）: `secondary`，中性色
/// - C（勉强）: `error.withValues(alpha:0.8)`，弱警示
/// - D（跳槽）: `error`，强警示
abstract final class GradeColorTokens {
  static Color colorFor(ColorScheme scheme, ScoreGrade grade) {
    return switch (grade) {
      ScoreGrade.s => scheme.primary,
      ScoreGrade.a => scheme.tertiary,
      ScoreGrade.b => scheme.secondary,
      ScoreGrade.c => Color.alphaBlend(
        scheme.error.withValues(alpha: 0.75),
        scheme.surface,
      ),
      ScoreGrade.d => scheme.error,
    };
  }
}

/// 结果卡片的渐变背景色。
///
/// 色彩语义（从最差到最好）：
/// - D 褐红 → 黑（像烧焦的余烬，暗示职业被透支）
/// - C 砖红 → 深红（警示）
/// - B 橙 → 焦糖棕（中性偏暖）
/// - A 翠绿 → 墨绿（健康）
/// - S 金 → 古铜（奖杯般的奢华感）
///
/// 所有颜色都选择了能配合白色文字的深度，不需要额外的文字对比处理。
abstract final class GradeBackgroundTokens {
  /// 返回 2 色的 LinearGradient 颜色列表（topLeft → bottomRight）。
  static List<Color> gradientFor(ScoreGrade grade) {
    return switch (grade) {
      ScoreGrade.s => const [Color(0xFFC9A227), Color(0xFF3B2900)], // 金 → 古铜
      ScoreGrade.a => const [Color(0xFF2E9558), Color(0xFF0F4F2C)], // 翠绿 → 墨绿
      ScoreGrade.b => const [Color(0xFFD97706), Color(0xFF7C2D12)], // 琥珀 → 焦糖棕
      ScoreGrade.c => const [Color(0xFFB42318), Color(0xFF5C0E0E)], // 砖红 → 深红
      ScoreGrade.d => const [Color(0xFF450A0A), Color(0xFF0F0303)], // 褐红 → 黑
    };
  }

  /// 渐变卡上文字的颜色（恒定白色，所有渐变都为深色确保对比度）。
  static const Color onGradient = Color(0xFFFFFFFF);

  /// 渐变卡上次要文字的颜色（白色 85% 透明）。
  static Color onGradientMuted = const Color(
    0xFFFFFFFF,
  ).withValues(alpha: 0.78);

  /// 渐变卡上内嵌次级容器（公式说明）的背景色。
  static Color innerPanel = const Color(0xFF000000).withValues(alpha: 0.24);
}
