import 'app_locale.dart';
import 'app_strings.dart';

final stringsJa = AppStrings(
  locale: AppLocale.ja,
  // App chrome
  appTagline: '仕事のコスパを数値化する',
  brandSubtitle: '職場パフォーマンス診断',
  // Section labels
  sectionHome: 'ホーム',
  sectionQuestionnaire: '質問',
  sectionResult: '結果',
  sectionSettings: '設定',
  // Section descriptions
  homeDescription: '13問であなたの仕事のコスパを数値化します。',
  questionnaireDescription: '自由に戻ったり、ジャンプしたり、回答を修正できます。',
  resultDescriptionLocked: '残りの質問に回答すると、完全な分析結果が表示されます。',
  resultDescriptionUnlocked: '総合スコア・ランク・因子別貢献・改善アドバイスを表示します。',
  settingsDescription: 'テーマ・カラーパレット・言語を変更、または回答をリセットできます。',
  // Home page
  homeIntro:
      '労働時間・通勤・残業・休暇・月給など13の指標で、'
      'あなたの仕事のコスパを数値化します。',
  homeStartButton: '診断を開始',
  homeContinueButton: '続きから回答',
  homeRestartButton: '最初から再診断',
  homeViewResultButton: '結果を見る',
  homeMetaTime: '約 5 分',
  homeMetaFreeEdit: 'いつでも戻って修正可能',
  homeProgressText: (answered, total) => '回答済み $answered / $total',
  // Questionnaire
  quickJumpTitle: '質問へジャンプ',
  progressTitle: '進捗',
  progressPercentDone: (percent, current, total) =>
      '$percent% 完了 · 現在 $current/$total 問目',
  progressCurrentQuestion: '現在の質問',
  progressStatusCategory: (category) => '現在のカテゴリ：$category',
  progressStatusAnswered: (answered) => '回答済み $answered 問',
  answeredChip: '回答済み',
  prevButton: '前の質問',
  nextButton: '次の質問',
  finishToResultButton: 'スコアを見る',
  checkUnansweredButton: '未回答を確認',
  numericQuickPickSalary: 'よく使う金額',
  numericQuickPickOther: 'よくある値',
  numericFeedbackSalaryTitle: (c) => '月給係数 ×${c.toStringAsFixed(2)}',
  numericFeedbackSalaryAtCap: (m) =>
      '上限係数 ×${m.toStringAsFixed(1)} に到達（これ以上は加算されません）',
  numericFeedbackSalaryBaseline: (baseline) => '基準値 $baseline = ×1.00',
  numericFeedbackOtherTitle: (s) => '現在のスコア ${s.toStringAsFixed(1)} / 10',
  numericFeedbackHigherHint: (best, unit, worst) =>
      '$best $unit に近いほど高スコア；$worst $unit を下回ると 0 点',
  numericFeedbackLowerHint: (best, unit, worst) =>
      '$best $unit に近いほど高スコア；$worst $unit を上回ると 0 点',
  ratingSelectHint: '評価を選択してください',
  ratingSelectedPrefix: (label, stars, max) => '選択中：$label（$stars / $max）',
  // Result
  resultLockedTitle: 'スコアは未解放',
  resultLockedBody: (remaining) =>
      '残り $remaining 問が未回答です。'
      '全問回答すると、総合スコア・ランク・因子別貢献・改善アドバイスが表示されます。',
  resultContinueButton: '回答を続ける',
  resultSummaryTitle: 'WORKNMB 総合スコア',
  resultFormulaLabel: '計算式',
  resultFormulaTemplate: (base, coef, total) =>
      '$base ベーススコア × $coef 月給係数 = $total',
  resultSalaryInputTemplate: (salary, baseline, symbol) =>
      '月給：$symbol$salary / 月（基準 $symbol$baseline）',
  resultFactorBreakdownTitle: '因子別貢献',
  resultFactorBreakdownDesc: '各項目は満点 10。色は相対的な貢献度を示し、高いほど健全です。',
  resultSalaryCoefficientLabel: '月給係数',
  resultAdviceTitle: '弱点とアドバイス',
  resultAdviceDesc: 'スコアが低い上位 3 項目 — コスパを下げている主な原因です。',
  resultRestartButton: 'もう一度診断',
  resultHomeButton: 'ホームへ',
  gradeSText: '最高コスパ',
  gradeAText: '良好',
  gradeBText: 'まずまず',
  gradeCText: 'やや物足りない',
  gradeDText: '転職を検討する価値あり',
  // Settings
  appearanceTitle: '外観設定',
  appearanceDescription:
      'テーマとカラーパレットを変更すると、'
      '画面がリアルタイムで再描画されます。',
  themeModeLabel: 'テーマ',
  themeModeLight: 'ライト',
  themeModeDark: 'ダーク',
  themeModeSystem: 'システム',
  paletteLabel: 'カラーパレット',
  paletteTideLabel: 'タイド',
  paletteTideDesc: '落ち着いた青緑、プロフェッショナル',
  paletteEmberLabel: 'エンバー',
  paletteEmberDesc: '温かみのあるオレンジ、行動を促す',
  paletteMossLabel: 'モス',
  paletteMossDesc: '静かな緑、ダークモード向き',
  languageLabel: '言語',
  languageSystem: 'システム',
  languageSectionTitle: '言語 / Language',
  manageTitle: '診断の管理',
  manageDescription: 'すべての回答を削除してホームに戻ります。この操作は取り消せません。',
  manageHasAnswers: (a, t) => '現在 $a / $t 問回答済み',
  manageNoAnswers: 'まだ回答がないため、リセットの必要はありません。',
  manageResetButton: '診断をリセット',
  aboutTitle: 'このアプリについて',
  aboutRepoLabel: 'ソースコード',
  aboutPreviewLabel: 'オンラインデモ',
  // Currency / units
  currencySymbol: '¥',
  unitHour: '時間',
  unitMinute: '分',
  unitDayPerWeek: '日/週',
  unitDay: '日',
  unitMonth: 'ヶ月',
  unitCurrency: '円',
  // Misc
  clipboardFallback: (url) => '開けなかったため、リンクをクリップボードにコピーしました：$url',
);
