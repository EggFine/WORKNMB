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
