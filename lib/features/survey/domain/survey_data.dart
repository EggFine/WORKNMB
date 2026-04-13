/// WORKNMB 工作评分题库与数据模型。
///
/// 使用 sealed class + pattern matching 支持三种题型：
/// - [ChoiceQuestion]：单选题（加班补偿 / 休息日）
/// - [RatingQuestion]：5 级评分题（工作环境 / 同事关系 / 职业发展）
/// - [NumericQuestion]：数字填空题（工时 / 通勤 / 加班天数 / 午休 / 远程天数 /
///   年终奖 / 年假，以及月薪——月薪同时作为薪资系数参与最终评分）
library;

/// 题目基类。所有题目都具备共同的展示字段。
sealed class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.category,
    required this.title,
    required this.hint,
  });

  /// 稳定的标识符，用于在 [answers] 中做键。
  final String id;

  /// 分类标签（展示于题目徽章）。
  final String category;

  /// 题目主文本。
  final String title;

  /// 题目提示 / 作答指导。
  final String hint;
}

/// 单选题。每个选项附带 0-10 的贡献分。
class ChoiceQuestion extends QuizQuestion {
  const ChoiceQuestion({
    required super.id,
    required super.category,
    required super.title,
    required super.hint,
    required this.options,
  });

  final List<QuizOption> options;
}

/// 5 级评分题。
class RatingQuestion extends QuizQuestion {
  const RatingQuestion({
    required super.id,
    required super.category,
    required super.title,
    required super.hint,
    this.maxRating = 5,
    required this.labels,
  });

  final int maxRating;

  /// 每档评级对应的短描述（长度必须等于 [maxRating]）。
  final List<String> labels;
}

/// 数字输入题。
///
/// 通过 [bestValue] 与 [worstValue] 定义线性评分映射：
/// - 输入值 = [bestValue] → 得分 10
/// - 输入值 = [worstValue] → 得分 0
/// - 之间按线性插值；超出两端 clamp 到 [0, 10]
///
/// 当 [isSalaryMultiplier] 为 true 时，[bestValue]/[worstValue] 被忽略，
/// 此题不计入基础分，而是作为"薪资系数"乘到最终总分上
/// （系数 = 输入值 / [baseline]，封顶 2.5）。
class NumericQuestion extends QuizQuestion {
  const NumericQuestion({
    required super.id,
    required super.category,
    required super.title,
    required super.hint,
    required this.baseline,
    required this.minValue,
    required this.maxValue,
    required this.defaultValue,
    required this.unit,
    required this.quickPicks,
    this.bestValue = 0,
    this.worstValue = 0,
    this.isSalaryMultiplier = false,
    this.allowDecimal = false,
  });

  /// 1.0 系数 / 基准值（薪资题 = 10000；其他题主要用于展示）。
  final double baseline;

  /// 输入允许的最小 / 最大 / 默认值。
  final double minValue;
  final double maxValue;
  final double defaultValue;

  /// 单位后缀（"元" / "小时" / "分钟" / "天/周" 等）。
  final String unit;

  /// 快速选择芯片。
  final List<double> quickPicks;

  /// 对应满分 10 的输入值（非薪资题使用）。
  /// 如果 [bestValue] > [worstValue]：越大越好
  /// 如果 [bestValue] < [worstValue]：越小越好
  final double bestValue;

  /// 对应 0 分的输入值（非薪资题使用）。
  final double worstValue;

  /// 是否作为薪资乘数参与评分。
  final bool isSalaryMultiplier;

  /// 是否允许小数（工时这类要 0.5 精度，月薪这类只能整数）。
  final bool allowDecimal;
}

/// 单选题的选项。
class QuizOption {
  const QuizOption(this.title, this.note, this.score);

  final String title;
  final String note;

  /// 选中此项时该题贡献的分值（0-10）。
  final double score;
}

/// 用户答案。通过 sealed + pattern match 保证类型安全。
sealed class Answer {
  const Answer();
}

/// 单选题的答案：选中的选项索引。
class ChoiceAnswer extends Answer {
  const ChoiceAnswer(this.index);
  final int index;
}

/// 评分题的答案：1-maxRating 的整数（0 表示未选）。
class RatingAnswer extends Answer {
  const RatingAnswer(this.stars);
  final int stars;
}

/// 数字题的答案：用户录入的数值。
class NumericAnswer extends Answer {
  const NumericAnswer(this.value);
  final double value;
}

/// 最终得分的等级划分。
enum ScoreGrade {
  s('S', 85, '顶级性价比'),
  a('A', 70, '不错'),
  b('B', 55, '还行'),
  c('C', 40, '勉强'),
  d('D', 0, '建议考虑跳槽');

  const ScoreGrade(this.label, this.threshold, this.description);

  final String label;

  /// 达到此等级的最低总分（含）。
  final double threshold;

  /// 一句话评价。
  final String description;

  /// 根据 0-100 分数反查等级。
  static ScoreGrade fromScore(double score) {
    for (final grade in ScoreGrade.values) {
      if (score >= grade.threshold) return grade;
    }
    return ScoreGrade.d;
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  题库（13 题：7 数字 + 2 单选 + 3 评分 + 1 薪资系数）
// ════════════════════════════════════════════════════════════════════════════

const questions = <QuizQuestion>[
  // —————————————————————— 时间类（数字填空）——————————————————————
  NumericQuestion(
    id: 'workHours',
    category: '工作时长',
    title: '每天实际工作时长（含加班）？',
    hint: '按最近一个月的平均状态填写，可精确到半小时。',
    baseline: 8,
    minValue: 4,
    maxValue: 16,
    defaultValue: 9,
    unit: '小时',
    quickPicks: [8, 9, 10, 11, 12],
    bestValue: 8, // 8 小时合理
    worstValue: 13, // 13 小时及以上几乎 0 分
    allowDecimal: true,
  ),
  NumericQuestion(
    id: 'commute',
    category: '通勤',
    title: '单程通勤时间？',
    hint: '门到门总时间（含等车 / 换乘），单位分钟。',
    baseline: 30,
    minValue: 0,
    maxValue: 180,
    defaultValue: 40,
    unit: '分钟',
    quickPicks: [15, 30, 45, 60, 90],
    bestValue: 10,
    worstValue: 90,
  ),
  NumericQuestion(
    id: 'overtimeDays',
    category: '加班频率',
    title: '最近一个月平均每周加班几天？',
    hint: '下班时间明显超出规定时间的天数。',
    baseline: 1,
    minValue: 0,
    maxValue: 7,
    defaultValue: 1,
    unit: '天/周',
    quickPicks: [0, 1, 2, 3, 5],
    bestValue: 0,
    worstValue: 5,
    allowDecimal: true,
  ),
  // —————————————————————— 补偿 / 制度类（单选）——————————————————————
  ChoiceQuestion(
    id: 'overtimePay',
    category: '加班补偿',
    title: '加班是否有补偿？',
    hint: '法定加班报酬 / 调休的落实情况。',
    options: [
      QuizOption('不需要加班', '基本不加班，用不上。', 10),
      QuizOption('有加班费（按 1.5 / 2 / 3 倍）', '按法律规定支付。', 9),
      QuizOption('可以调休', '不结算金额但能换假。', 6),
      QuizOption('白嫖 / 无任何补偿', '加班都是免费的。', 0),
    ],
  ),
  ChoiceQuestion(
    id: 'restDays',
    category: '休息日',
    title: '周末休息情况？',
    hint: '法定休息日的实际落实。',
    options: [
      QuizOption('双休', '每周完整 2 天休息。', 10),
      QuizOption('大小周', '每两周 3 天休。', 5),
      QuizOption('单休', '每周只休 1 天。', 2),
      QuizOption('无固定休息', '看排班 / 项目随时被叫走。', 0),
    ],
  ),
  NumericQuestion(
    id: 'lunchBreak',
    category: '午休',
    title: '午休可用时长？',
    hint: '含吃饭 + 休息，按公司实际允许的时长填。',
    baseline: 60,
    minValue: 0,
    maxValue: 180,
    defaultValue: 60,
    unit: '分钟',
    quickPicks: [30, 45, 60, 90, 120],
    bestValue: 90,
    worstValue: 15,
  ),
  // —————————————————————— 福利类（数字填空）——————————————————————
  NumericQuestion(
    id: 'wfhDays',
    category: '远程办公',
    title: '每周可远程办公天数？',
    hint: '公司允许的 WFH / 居家办公天数。',
    baseline: 0,
    minValue: 0,
    maxValue: 5,
    defaultValue: 0,
    unit: '天/周',
    quickPicks: [0, 1, 2, 3, 5],
    bestValue: 3, // 3 天 WFH + 2 天去办公室是当下最优解
    worstValue: 0,
  ),
  NumericQuestion(
    id: 'annualBonus',
    category: '年终奖',
    title: '年终奖约合几个月工资？',
    hint: '折算为基本月薪的月数。没有填 0，不确定按保守估计。',
    baseline: 1,
    minValue: 0,
    maxValue: 24,
    defaultValue: 1,
    unit: '个月',
    quickPicks: [0, 1, 2, 3, 6],
    bestValue: 6,
    worstValue: 0,
    allowDecimal: true,
  ),
  NumericQuestion(
    id: 'annualLeave',
    category: '年假',
    title: '实际可休的年假天数（法定 + 公司福利）？',
    hint: '不是名义上有的天数，是"真的能休完"的天数。',
    baseline: 5,
    minValue: 0,
    maxValue: 30,
    defaultValue: 5,
    unit: '天',
    quickPicks: [5, 10, 15, 20, 25],
    bestValue: 20,
    worstValue: 5,
  ),
  // —————————————————————— 体验类（评分）——————————————————————
  RatingQuestion(
    id: 'environment',
    category: '工作环境',
    title: '工作环境满意度？',
    hint: '硬件条件：工位、设备、办公氛围、通风空调等。',
    labels: ['很差', '不太好', '一般', '不错', '很好'],
  ),
  RatingQuestion(
    id: 'colleagues',
    category: '同事关系',
    title: '和同事 / 上下级的关系？',
    hint: '协作氛围、支持感、信任感。',
    labels: ['很差', '不太好', '一般', '不错', '很好'],
  ),
  RatingQuestion(
    id: 'career',
    category: '职业发展',
    title: '职业发展 / 晋升空间？',
    hint: '学习机会、晋升通道、薪资成长路径。',
    labels: ['无望', '很少', '一般', '清晰', '很好'],
  ),
  // —————————————————————— 薪资系数 ——————————————————————
  NumericQuestion(
    id: 'salary',
    category: '月薪',
    title: '你的税前月薪是多少？',
    hint: '以 10000 元/月 为 1.0 系数，越高得分越高（封顶 ×2.5）。',
    baseline: 10000,
    minValue: 1000,
    maxValue: 100000,
    defaultValue: 8000,
    unit: '元',
    quickPicks: [5000, 8000, 10000, 15000, 20000, 30000],
    isSalaryMultiplier: true,
  ),
];

// ════════════════════════════════════════════════════════════════════════════
//  评分配置
// ════════════════════════════════════════════════════════════════════════════

/// 薪资系数的下限 / 上限（防止极端值把分数拉爆）。
const double salaryCoefficientMin = 0.1;
const double salaryCoefficientMax = 2.5;

/// 薪资系数 = clamp(value / baseline, min, max)。
double salaryCoefficientOf(double value, double baseline) {
  final raw = value / baseline;
  if (raw.isNaN || raw.isInfinite) return salaryCoefficientMin;
  return raw.clamp(salaryCoefficientMin, salaryCoefficientMax);
}

/// 针对某个薄弱因子（得分 < 5）的改进建议。
const Map<String, String> improvementTips = {
  'workHours': '评估工时是否合法，和管理沟通减负；长期超时工作代价远大于短期收益。',
  'commute': '搬家 / 就近换工作 / 争取远程，通勤每少 30 分钟，幸福感显著提升。',
  'overtimeDays': '加班频率高说明人力不足或管理问题，值得做跳槽对比。',
  'overtimePay': '无补偿加班违反《劳动法》，保留证据以备维权或谈判。',
  'restDays': '每周少于一天休息严重违规，是硬性跳槽信号。',
  'lunchBreak': '吃饭都赶时间的公司，健康和专注度都在被透支。',
  'wfhDays': '强制坐班会让通勤成本和体力消耗放大；争取至少每周 1-2 天远程。',
  'annualBonus': '年终奖少说明薪酬结构保守或公司业绩弱，谈薪时用月薪涨幅弥补。',
  'annualLeave': '年假没法真正休完，和"有年假"没区别；把它算进隐性加班。',
  'environment': '硬件条件影响每天 8 小时的基础体验，和 HR 提出改善或评估换岗。',
  'colleagues': '同事关系紧张是最隐性的成本，如果无法改善，考虑跨部门或换团队。',
  'career': '看不到上升通道时，主动找导师 / 外部机会；停留太久成长会停滞。',
  'salary': '薪资远低于市场同岗位时，优先尝试内部谈判，不行就看外部 offer。',
};
