import 'app_locale.dart';
import 'app_strings.dart';

final stringsZh = AppStrings(
  locale: AppLocale.zh,
  // App chrome
  appTagline: '量化你的工作性价比',
  brandSubtitle: '工作场景角色评测',
  // Section labels
  sectionHome: '首页',
  sectionQuestionnaire: '问卷',
  sectionResult: '结果',
  sectionSettings: '设置',
  // Section descriptions
  homeDescription: '用 13 道题量化你当前工作的性价比。',
  questionnaireDescription: '按题完成评测，可随时返回、跳转并修正答案。',
  resultDescriptionLocked: '你还差几题没有完成，继续答题后即可查看完整分析。',
  resultDescriptionUnlocked: '结果页会展示综合评分、等级、各因子贡献与薄弱项建议。',
  settingsDescription: '调整主题模式、色板和语言，或清除现有答案从头开始。',
  // Home page
  homeIntro:
      '用 13 个维度量化你当前工作的性价比，'
      '包含工时、通勤、加班、休息、月薪等关键指标。',
  homeStartButton: '开始答题',
  homeContinueButton: '继续答题',
  homeRestartButton: '重新开始答题',
  homeViewResultButton: '查看我的结果',
  homeMetaTime: '约 5 分钟',
  homeMetaFreeEdit: '可随时返回调整',
  homeProgressText: (answered, total) => '已完成 $answered / $total',
  // Questionnaire
  quickJumpTitle: '跳转到题目',
  progressTitle: '完成进度',
  progressPercentDone: (percent, current, total) =>
      '$percent% 已完成 · 当前第 $current/$total 题',
  progressCurrentQuestion: '当前题目',
  progressStatusCategory: (category) => '当前分类：$category',
  progressStatusAnswered: (answered) => '已答 $answered 题',
  answeredChip: '已作答',
  prevButton: '上一题',
  nextButton: '下一题',
  finishToResultButton: '查看评分',
  checkUnansweredButton: '检查未答题',
  numericQuickPickSalary: '快捷金额',
  numericQuickPickOther: '常见值',
  numericFeedbackSalaryTitle: (c) => '薪资系数 ×${c.toStringAsFixed(2)}',
  numericFeedbackSalaryAtCap: (m) =>
      '已达到封顶系数 ×${m.toStringAsFixed(1)}（薪资越高不再继续加成）',
  numericFeedbackSalaryBaseline: (baseline) => '基准值 $baseline = ×1.00',
  numericFeedbackOtherTitle: (s) => '当前得分 ${s.toStringAsFixed(1)} / 10',
  numericFeedbackHigherHint: (best, unit, worst) =>
      '越接近 $best $unit 得分越高；低于 $worst $unit 得 0 分',
  numericFeedbackLowerHint: (best, unit, worst) =>
      '越接近 $best $unit 得分越高；高于 $worst $unit 得 0 分',
  ratingSelectHint: '请选择一个评级',
  ratingSelectedPrefix: (label, stars, max) => '已选：$label（$stars / $max）',
  // Result
  resultLockedTitle: '评分尚未解锁',
  resultLockedBody: (remaining) =>
      '还剩 $remaining 道题未完成。'
      '完成所有题目后，会展示综合评分、等级、因子贡献和薄弱项建议。',
  resultContinueButton: '继续答题',
  resultSummaryTitle: 'WORKNMB 综合评分',
  resultFormulaLabel: '评分公式',
  resultFormulaTemplate: (base, coef, total) =>
      '$base 基础分 × $coef 薪资系数 = $total',
  resultSalaryInputTemplate: (salary, baseline, symbol) =>
      '月薪输入：$symbol$salary / 月（基准 $symbol$baseline）',
  resultFactorBreakdownTitle: '因子贡献',
  resultFactorBreakdownDesc: '每个维度满分 10，颜色代表相对贡献，值越高越健康。',
  resultSalaryCoefficientLabel: '月薪系数',
  resultAdviceTitle: '薄弱项与建议',
  resultAdviceDesc: '得分最低的 3 项 — 通常也是性价比被拉低的元凶。',
  resultRestartButton: '重新测试',
  resultHomeButton: '返回首页',
  gradeSText: '顶级性价比',
  gradeAText: '不错',
  gradeBText: '还行',
  gradeCText: '勉强',
  gradeDText: '建议考虑跳槽',
  // Settings
  appearanceTitle: '外观设置',
  appearanceDescription: '主题和色板会实时重绘 WORKNMB，用来快速验证不同视觉语义下的层级和可读性。',
  themeModeLabel: '主题模式',
  themeModeLight: '浅色',
  themeModeDark: '深色',
  themeModeSystem: '系统',
  paletteLabel: '动态色板',
  paletteTideLabel: '青潮',
  paletteTideDesc: '平衡、冷静、偏专业',
  paletteEmberLabel: '暖岩',
  paletteEmberDesc: '更强调行动和推动感',
  paletteMossLabel: '森雾',
  paletteMossDesc: '更安静，适合深色界面',
  languageLabel: '语言',
  languageSystem: '系统',
  languageSectionTitle: '语言 / Language',
  manageTitle: '测试管理',
  manageDescription: '清除当前所有答案，回到首页从头开始。这个动作不可撤销。',
  manageHasAnswers: (a, t) => '当前已答 $a / $t 题',
  manageNoAnswers: '当前没有已答题目，暂无需重置。',
  manageResetButton: '重置测试',
  aboutTitle: '关于',
  aboutRepoLabel: '源码仓库',
  aboutPreviewLabel: '在线预览',
  // Currency / units
  currencySymbol: '¥',
  unitHour: '小时',
  unitMinute: '分钟',
  unitDayPerWeek: '天/周',
  unitDay: '天',
  unitMonth: '个月',
  unitCurrency: '元',
  // Misc
  clipboardFallback: (url) => '无法直接打开，已复制链接到剪贴板：$url',
);
