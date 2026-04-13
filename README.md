# WORKNMB

**[English](README.en.md) · 简体中文**

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Flutter](https://img.shields.io/badge/Flutter-Material_3-02569B?logo=flutter)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Web-brightgreen)]()
[![Live Demo](https://img.shields.io/badge/Live_Demo-worknmb.eggfine.com-F38020?logo=cloudflare&logoColor=white)](https://worknmb.eggfine.com)

> **Workplace Overall Rating & Key Numeric Metric Benchmark** — 一个定量的工作评分计算器

用 10 个维度量化你当前工作的性价比，通过 `基础分 × 薪资系数` 给出 0–100 的综合评分和 S/A/B/C/D 等级。

**在线体验**：https://worknmb.eggfine.com（Cloudflare Pages，每次 push main 自动更新）

---

## 它做什么

这不是"性格测试"，是一个**定量**工具：

- 把工作拆成 10 个可度量的维度（工时 / 通勤 / 加班 / 加班费 / 休息日 / 午休 / 环境 / 同事 / 晋升 / 月薪）
- 按"基础分 × 薪资系数"合成 0–100 的综合得分
- 输出 S / A / B / C / D 等级徽章
- 自动挑出得分最低的 3 项，配针对性的改进建议

应用完全本地运行，不上传任何数据。

---

## 评分公式

```
基础分    = 9 道基础题得分平均 × 10              范围 [0, 100]
薪资系数  = clamp(月薪 / 10000, 0.1, 2.5)
总分      = clamp(基础分 × 薪资系数, 0, 100)

等级：
  S  [85, 100]   顶级性价比
  A  [70, 85)    不错
  B  [55, 70)    还行
  C  [40, 55)    勉强
  D  [0,  40)    建议考虑跳槽
```

**为什么以 10000 元/月为基准？** 一线 / 新一线城市打工人的常见中位数。1k → ×0.1；10k → ×1.0；30k → ×3.0（封顶 ×2.5 防止高薪把分数拉爆）。

---

## 题库（10 题）

| # | 题目 | 类型 | 作用 |
|---|------|------|------|
| 1 | 每天实际工作时长（含加班）| 4 选 1 | 基础分 |
| 2 | 单程通勤时间 | 4 选 1 | 基础分 |
| 3 | 加班频率 | 4 选 1 | 基础分 |
| 4 | 加班是否有补偿 | 4 选 1 | 基础分 |
| 5 | 周末休息情况（双休 / 大小周 / 单休 / 无）| 4 选 1 | 基础分 |
| 6 | 午休可休时长 | 4 选 1 | 基础分 |
| 7 | 工作环境（硬件 / 氛围）| 5 级评分 | 基础分 |
| 8 | 同事 / 上下级关系 | 5 级评分 | 基础分 |
| 9 | 职业发展 / 晋升空间 | 5 级评分 | 基础分 |
| 10 | 税前月薪 | **数字输入** | **薪资系数** |

题目定义于 `lib/features/survey/domain/survey_data.dart`，改动后重启即生效。

---

## UI 特性

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

- **单选题**：`_OptionCard`，选中态带阴影 + 缩放微动效
- **评分题**：5 个按钮一行，每档带中文标签（如 `很差 / 不太好 / 一般 / 不错 / 很好`）
- **数字题**（月薪）：大字号货币输入 + 千分位实时格式化 + 快捷金额芯片（5k / 10k / 20k / 30k）+ 实时显示薪资系数

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
│   ├── app_identity.dart                  品牌名常量
│   ├── survey_app.dart                    MaterialApp 装配
│   ├── state/
│   │   └── app_preferences.dart           主题 / 色板偏好（ChangeNotifier）
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
    │   └── survey_data.dart               题库 + 评分规则 + 建议文案
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
  baseline: 10000,
  minValue: 1000,
  maxValue: 100000,
  defaultValue: 8000,
  unit: '元',
  quickPicks: [5000, 10000, 20000],
  isSalaryMultiplier: false,  // true 表示此题作为最终得分的系数（基础分不计入）
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

1. 推送形如 `v1.2.3` 的 tag：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. 在 GitHub 仓库 Actions 页面点击 **Run workflow**，手动输入版本号。

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
