# WORKNMB

**[English](README.en.md) · 简体中文**

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Flutter](https://img.shields.io/badge/Flutter-Material_3-02569B?logo=flutter)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Web-brightgreen)]()
[![Live Demo](https://img.shields.io/badge/Live_Demo-worknmb.eggfine.com-F38020?logo=cloudflare&logoColor=white)](https://worknmb.eggfine.com)

> **Workplace Overall Rating & Key Numeric Metric Benchmark** — 一个定量的工作评分计算器

用 13 个维度量化你当前工作的性价比，通过 `基础分 × 薪资系数` 给出 0–100 的综合评分和 S/A/B/C/D 等级。**支持简体中文 / 日本語 / English 三种语言**，每种 locale 的评分锚点和薪资基准都按当地劳动力市场校准。

**在线体验**：<https://worknmb.eggfine.com>（Cloudflare Pages，每次 push main 自动更新）

---

## 它做什么

这不是"性格测试"，是一个**定量**工具：

- 把工作拆成 13 个可度量的维度（工时 / 通勤 / 加班频率 / 加班补偿 / 休息日 / 午休 / 远程办公 / 年终奖 / 年假 / 环境 / 同事 / 晋升 / 月薪）
- 按"基础分 × 薪资系数"合成 0–100 的综合得分
- 输出 S / A / B / C / D 等级徽章
- 自动挑出得分最低的 3 项，配针对性的改进建议

应用完全本地运行，不上传任何数据。

---

## 评分公式

```
基础分    = 12 道基础题得分平均 × 10             范围 [0, 100]
薪资系数  = clamp(月薪 / 10000, 0.1, 2.5)
总分      = clamp(基础分 × 薪资系数, 0, 100)

等级：
  S  [85, 100]   顶级性价比
  A  [70, 85)    不错
  B  [55, 70)    还行
  C  [40, 55)    勉强
  D  [0,  40)    建议考虑跳槽
```

**数字题怎么打分？** 每道数字题都有 `bestValue`（满分 10）和 `worstValue`（0 分）两个锚点，用户输入后按线性插值得到 0-10 的贡献分。比如工时题 `best=8 小时 / worst=13 小时`，输入 10 小时得 6 分。

**为什么以 10000 元/月为基准？** 一线 / 新一线城市打工人的常见中位数。1k → ×0.1；10k → ×1.0；30k → ×3.0（封顶 ×2.5 防止高薪把分数拉爆）。

---

## 题库（13 题）

按题型分组：

### 数字填空题（7 道，占比最高，追求精确）

| # | 题目 | 单位 | 满分锚点 | 0 分锚点 |
|---|------|------|----------|----------|
| 1 | 每天实际工作时长（含加班）| 小时 | 8 | 13 |
| 2 | 单程通勤时间 | 分钟 | 10 | 90 |
| 3 | 每周加班天数 | 天/周 | 0 | 5 |
| 4 | 午休可用时长 | 分钟 | 90 | 15 |
| 5 | 每周可远程办公天数 | 天/周 | 3 | 0 |
| 6 | 年终奖折合月数 | 个月 | 6 | 0 |
| 7 | 实际可休的年假天数 | 天 | 20 | 5 |

### 单选题（2 道，制度类离散选项）

| # | 题目 | 最高分选项 |
|---|------|------------|
| 8 | 加班是否有补偿 | 不需要加班 / 按 1.5×2×3 倍支付 |
| 9 | 周末休息情况 | 双休 |

### 5 级评分题（3 道，主观体验类）

| # | 题目 | 评级标签 |
|---|------|----------|
| 10 | 工作环境满意度 | 很差 / 不太好 / 一般 / 不错 / 很好 |
| 11 | 同事 / 上下级关系 | 很差 / 不太好 / 一般 / 不错 / 很好 |
| 12 | 职业发展 / 晋升空间 | 无望 / 很少 / 一般 / 清晰 / 很好 |

### 薪资系数题（1 道，乘法修正）

| # | 题目 | 单位 | 基准值 | 系数范围 |
|---|------|------|--------|----------|
| 13 | 税前月薪 | 元 | 10,000 | ×0.1 ~ ×2.5（封顶）|

题目定义于 `lib/features/survey/domain/survey_data.dart`，改动后重启即生效。

---

## UI 特性

### 国际化（i18n）

支持 **3 种语言**：简体中文 / 日本語 / English。进入"设置"页可随时切换，也支持"跟随系统"。

切语言时所有 UI 文字、题目、选项、评分描述、建议文案一起切换，**已作答的题目不会丢失**（题目 ID 在各 locale 间保持一致）。

**CN 版多一道本土化特色题「五险一金」**，所以中国题库是 **14 道题**，日本 / 美国版是 13 道。切到非 CN locale 时这题不显示（但答案保留在内存里，切回 CN 会自动恢复）。

**每个 locale 的评分锚点独立校准**——不是机翻，而是根据当地劳动市场设置不同的"满分 / 0 分"阈值：

| 维度 | 中国（zh）| 日本（ja）| 美国（en）|
|---|---|---|---|
| 月薪基准（1.0 系数）| ¥10,000 | ¥300,000 | $5,000 |
| 工时 best / worst（小时）| 8 / 13 | 8 / 12 | 8 / 11 |
| 通勤 best / worst（分钟）| 10 / 90 | 15 / 90 | 15 / 75 |
| 加班天数 best / worst（天/周）| 0 / 5 | 0 / 4 | 0 / 4 |
| 午休 best / worst（分钟）| 90 / 15 | 60 / 15 | 60 / 15 |
| 远程 best / worst（天/周）| 3 / 0 | 3 / 0 | 4 / 0 |
| 年终奖 best / worst（月）| 6 / 0 | 5 / 0 | 2 / 0 |
| 年假 best / worst（天）| 20 / 5 | 20 / 5 | 25 / 10 |
| **五险一金（独有）** | 5 选项评分 | — | — |

理由举例：
- **中国**: 五险一金足额 vs 按最低基数 vs 只三险 vs 没有，直接拉开 10/5/3/1/0 分。这题在日/美不存在对应制度，所以 locale 独有。
- **日本**: 通勤 15 分钟才算理想（首都圈普遍 1h+）、年终奖 5 个月满分（夏冬賞惯例）、月薪基准 30 万日元（东京正社员中位数）
- **美国**: 工时 11 小时就 0 分（salaried exempt 的现实底线）、远程 4 天满分（WFH 文化最成熟）、PTO 25 天满分（而 10 天视为底线）、奖金 2 个月已是强项（大多数美岗没有年终奖）

### 结果页：梗称号 + 等级渐变背景

根据总分算出的 S/A/B/C/D 等级，结果摘要卡会切换**渐变背景色**和**本土化梗称号**：

| 等级 | 渐变 | 🇨🇳 称号 | 🇯🇵 称号 | 🇺🇸 称号 |
|---|---|---|---|---|
| **S** (≥85) | 金 → 古铜 | 霸道总裁 | 勝ち組エース | Corporate Overlord |
| **A** (70-84) | 翠绿 → 墨绿 | 打工界翘楚 | デキるサラリーマン | LinkedIn Top Voice |
| **B** (55-69) | 琥珀 → 焦糖棕 | 标准牛马 | 普通の会社員 | Cubicle Veteran |
| **C** (40-54) | 砖红 → 深红 | 福报践行者 | 疲弊サラリーマン | TGIF Survivor |
| **D** (<40) | 褐红 → 黑 | 天选打工人 | 社畜最終形態 | Send Help Already |

每个称号还配一句调侃 punchline，比如 S 的中文版："走路带风、喝水都带 KPI，下属见你要鞠躬。"

### 响应式

| 视口宽度 | 布局 |
|---|---|
| `< 840` | 底部 NavigationBar，内容单列 |
| `840 – 1199` | 窄 NavigationRail（88px，只图标）|
| `≥ 1200` | 展开 Rail（240px，带标签）+ 节内双列 |

### Material 3 动态主题

- **3 种色板 seed**：青潮（冷青）、暖岩（暖橘）、森雾（森绿）
- **3 种明暗模式**：浅色 / 深色 / 跟随系统
- 切换实时重绘，不需重启

### 设计令牌

所有视觉原语集中在 `lib/app/theme/design_tokens.dart`，任何 widget 不得出现魔法数字：

- `AppBreakpoints`（600 / 840 / 1200 / 1600）
- `AppSpacing`（8dp 网格：4 / 8 / 12 / 16 / 20 / 24 / 32 / 48）
- `AppRadius`（chip 12 / button 16 / card 24 / hero 28 / pill 999）
- `AppDurations`（instant 120ms / fast 200ms / normal 260ms / slow 420ms）
- `AppIconSize` / `AppLayout` / `AppCurves`

### 三种题型 UI

- **单选题**：`_OptionCard`，选中态带阴影 + 缩放微动效。
- **评分题**：5 个按钮一行，每档带中文标签（如 `很差 / 不太好 / 一般 / 不错 / 很好`）。
- **数字填空题**：条件化 UI，区分两种形态：
  - **薪资题**：大字号 `¥` 前缀 + 千分位实时格式化 + 快捷金额芯片（5k / 10k / 20k / 30k）+ 实时"薪资系数 ×x.xx"反馈
  - **普通数字题**（工时 / 通勤 / 年终奖等）：去掉 `¥` 前缀、允许小数点（如工时可输 8.5）、快捷芯片带单位（`8 小时` / `30 分钟`）+ 实时"当前得分 N/10"反馈

### 结果展示

- **综合评分卡**（featured）：大分数 + 等级徽章（按等级自动切色）+ 公式展开
- **因子贡献卡**：9 个维度各一条进度条，颜色按得分分段：`< 4` 警示红 / `4–7` 中性黄 / `≥ 7` 主题绿
- **薄弱项建议卡**：得分最低 3 项 + 针对性建议

---

## 项目结构

```
lib/
├── main.dart                              入口
├── app/                                   与业务无关的壳
│   ├── app_identity.dart                  品牌名常量（含 repo URL / 预览 URL）
│   ├── survey_app.dart                    MaterialApp 装配（theme + i18n）
│   ├── i18n/                              国际化
│   │   ├── app_locale.dart                AppLocale 枚举（zh / ja / en）
│   │   ├── app_strings.dart               全 UI 文案容器 + InheritedWidget
│   │   ├── strings_zh.dart                中文翻译实例
│   │   ├── strings_ja.dart                日文翻译实例
│   │   └── strings_en.dart                英文翻译实例
│   ├── state/
│   │   └── app_preferences.dart           主题 / 色板 / 语言偏好（ChangeNotifier）
│   ├── theme/
│   │   ├── design_tokens.dart             视觉原语单一事实来源
│   │   ├── text_styles.dart               ThemeData 扩展（bodyMediumMuted 等）
│   │   ├── app_palette.dart               色板枚举 + 等级色 Token
│   │   └── survey_theme.dart              ThemeData 装配
│   └── widgets/                           通用组件
│       ├── app_card.dart                  AppCard（outlined / filled / featured）
│       ├── app_section_header.dart        节标题 + 描述
│       └── responsive.dart                断点判断 helper
└── features/survey/                       业务层
    ├── domain/
    │   ├── survey_data.dart               locale 无关的数据模型 + 评分公式
    │   ├── localized_survey.dart          LocalizedSurvey 容器 + factory
    │   ├── questions_zh.dart              中国题库（¥10k 基准，13 题本地化文案 + 锚点）
    │   ├── questions_ja.dart              日本题库（¥300k 基准）
    │   └── questions_en.dart              美国题库（$5k 基准）
    └── presentation/
        ├── controllers/
        │   └── survey_controller.dart     答题状态 + 评分计算
        ├── pages/
        │   └── survey_home_page.dart      App shell（Rail + NavBar + 页头 + 路由）
        └── widgets/
            ├── common/
            │   └── survey_common_widgets.dart   FadeSlideSwitcher / ValueBar / StatusChip 等
            └── sections/
                ├── home_section.dart              品牌聚焦登陆页
                ├── questionnaire_section.dart     问卷页（支持 3 种题型）
                ├── result_section.dart            结果页（分数 + 等级 + 建议）
                └── settings_section.dart          设置页（外观 + 重置 + 关于）
```

---

## 快速开始

### 环境要求

- **Flutter** `^3.12.0-210.2.beta` 或更新（`pubspec.yaml` 里的 sdk 约束）
- **Dart**（随 Flutter 自带）

### 运行

```bash
# 安装依赖
flutter pub get

# 默认设备
flutter run

# 指定平台
flutter run -d windows
flutter run -d chrome
flutter run -d macos
flutter run -d linux
```

### 验证

```bash
# 静态分析（应为 0 issue）
flutter analyze

# 跑单元 / widget 测试
flutter test

# 代码格式化
dart format lib/ test/
```

### 发布构建

```bash
flutter build windows --release
flutter build web --release
flutter build apk --release
flutter build ipa --release
```

---

## 测试覆盖

`test/widget_test.dart` 覆盖核心流：

1. 启动 app → 落在 Home 登陆页
2. 点击 **开始答题** → 进入问卷页第 1 题（"每天实际工作时长"）
3. 选中第一个选项 → 点击 **下一题**
4. 断言切换到第 2 题（"单程通勤时间"）

这是防核心导航回归的最小安全网；重构后必须保证通过。

---

## 自定义

### 添加 / 修改题目

编辑 `lib/features/survey/domain/survey_data.dart`，题库顺序即答题顺序。

```dart
// —— 单选题 ——
ChoiceQuestion(
  id: 'myQuestion',            // 唯一标识
  category: '分类标签',
  title: '题干？',
  hint: '作答提示。',
  options: [
    QuizOption('选项标题', '选项备注', 10),  // 最后一个参数 = 选中时贡献分 (0-10)
    QuizOption('选项标题', '选项备注', 5),
  ],
),

// —— 5 级评分题 ——
RatingQuestion(
  id: 'myRating',
  category: '分类标签',
  title: '题干？',
  hint: '作答提示。',
  labels: ['很差', '不太好', '一般', '不错', '很好'],  // 必须长度 = maxRating (默认 5)
),

// —— 数字输入题 ——
NumericQuestion(
  id: 'myNumeric',
  category: '分类标签',
  title: '题干？',
  hint: '作答提示。',
  baseline: 60,
  minValue: 0,
  maxValue: 180,
  defaultValue: 60,
  unit: '分钟',
  quickPicks: [30, 60, 90, 120],
  bestValue: 90,        // 对应满分 10
  worstValue: 15,       // 对应 0 分；用 best > worst 表示"越大越好"，反之则"越小越好"
  allowDecimal: false,  // 需要支持 0.5 这种精度时设为 true
  isSalaryMultiplier: false,  // true 时 best/worst 被忽略，此题作为薪资系数参与总分
),
```

### 调整等级阈值

编辑 `survey_data.dart` 里的 `ScoreGrade` 枚举：

```dart
enum ScoreGrade {
  s('S', 85, '顶级性价比'),   // 阈值放宽或收紧在这里改
  a('A', 70, '不错'),
  b('B', 55, '还行'),
  c('C', 40, '勉强'),
  d('D', 0, '建议考虑跳槽');
}
```

### 调整薪资系数边界

```dart
const double salaryCoefficientMin = 0.1;   // 最低系数
const double salaryCoefficientMax = 2.5;   // 封顶系数
```

### 加一套色板

编辑 `lib/app/theme/app_palette.dart`：

```dart
enum AppPalette {
  tide('青潮', '平衡、冷静', Color(0xFF006A6A), Icons.water_drop_rounded),
  ember('暖岩', '行动 / 推动', Color(0xFF9A4521), Icons.local_fire_department_rounded),
  moss('森雾', '安静、深色', Color(0xFF3C6A43), Icons.park_rounded),
  // 加新色板只需加一行
  yourPalette('自选', '描述', Color(0xFFRRGGBB), Icons.your_icon),
}
```

Material 3 会自动从 seedColor 生成完整的浅/深 ColorScheme，无需手写其他颜色。

### 修改改进建议文案

`survey_data.dart` 末尾的 `improvementTips` 映射：

```dart
const Map<String, String> improvementTips = {
  'workHours': '评估工时是否合法，和管理沟通减负…',
  'commute': '搬家 / 就近换工作 / 争取远程…',
  // 'questionId': '改进建议文案',
};
```

键 = 题目 `id`；得分最低的前 3 题会自动在结果页拉取对应建议。

---

## 架构决策

| 主题 | 选择 | 理由 |
|---|---|---|
| 状态管理 | 内置 `ChangeNotifier` | 项目规模不需要 riverpod / bloc |
| 路由 | `AppSection` 枚举 + 单 Scaffold | 无深度导航需求，4 个主页面够用 |
| 网络 | 无 | 题库与评分本地 const；数据隐私天然保证 |
| 第三方 UI | 无 | 只用 Material 内置 + 自定义 Design Tokens |
| 架构分层 | domain ↔ presentation | 参考 Clean Architecture 轻量分层，不强制 use-case |
| 题型 | `sealed class QuizQuestion` | Dart 3 pattern match 做题型分发，编译期穷举检查 |

---

## 发布流程（GitHub Actions）

仓库内置 `.github/workflows/release.yml`，在以下情况自动构建 6 个平台的安装包并发布到 GitHub Release：

**触发方式**

1. **Push 到 main 自动发版**（默认）：每次 push 会自动读取最新 tag、递增 patch（`v1.0.0` → `v1.0.1` → ...）、创建新 tag 并跑完 6 平台构建，发到 Releases 页。
2. **手动控制大版本**：
   ```bash
   git tag v2.0.0
   git push origin v2.0.0
   ```
   推特定 tag 时 workflow 直接用那个作为版本号，不自动递增。
3. **Actions 页面手动触发**：可以输入自定义版本号（留空则自动递增 patch）。

**跳过某次 push 的发版**：commit message 里加上 `skip release` 关键短语（方括号包裹），整个 workflow 会被跳过。适合改 README、调 Actions YAML 这种不需要出正式版的场景。

**流水线流程**

```
test (analyze + flutter test)
   │
   ├─► build-android   ─► APK + AAB
   ├─► build-windows   ─► zip 便携版
   ├─► build-macos     ─► DMG 镜像
   ├─► build-linux     ─► tar.gz 便携版
   ├─► build-web       ─► 静态站点 zip
   └─► build-ios       ─► 未签名 IPA（仅供侧载）
              │
              ▼
          release   → GitHub Release（附带所有资产）
```

预检步骤 `flutter analyze` 和 `flutter test` 必须通过，否则所有构建都不会启动，防止发布坏版本。

**需要的仓库权限**：流水线使用默认 `GITHUB_TOKEN`（已配置 `contents: write`），无需额外 secret。如需为 iOS 做 App Store 分发或 Android 做正式签名，参考 workflow 文件顶部注释与 [Flutter 官方部署文档](https://docs.flutter.dev/deployment)。

**Flutter 通道**：由于 `pubspec.yaml` 依赖 `^3.12.0-210.2.beta`，workflow 默认使用 `beta` 通道。Dart 3.12 进入 stable 后可把 `FLUTTER_CHANNEL` 改为 `stable`。

---

## 版本信息

- **版本**：`1.0.0+1`
- **配置**：见 `pubspec.yaml`
- **依赖**：`flutter` + `cupertino_icons` + `flutter_lints`（dev）

---

## License

本项目采用 [Apache License 2.0](LICENSE) 许可证，详见根目录的 `LICENSE` 文件。

你可以自由地使用、修改、分发本项目的代码，包括商业用途，只需保留原始版权声明与许可证文本。若做了修改需在相应文件中注明更改。

**免责声明**：题库数据与评分规则为示意值，结果仅作参考，不构成专业职业建议或劳动法律咨询。
