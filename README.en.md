# WORKNMB

**English · [简体中文](README.md)**

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Flutter](https://img.shields.io/badge/Flutter-Material_3-02569B?logo=flutter)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Web-brightgreen)]()
[![Live Demo](https://img.shields.io/badge/Live_Demo-worknmb.eggfine.com-F38020?logo=cloudflare&logoColor=white)](https://worknmb.eggfine.com)

> **Workplace Overall Rating & Key Numeric Metric Benchmark** — a quantitative job rating calculator.

Score your current job across 13 weighted dimensions, apply a salary coefficient, and get a 0–100 overall grade (S/A/B/C/D) with actionable improvement suggestions. **Ships with three locales — 简体中文 / 日本語 / English** — each with scoring anchors and salary baselines calibrated to the local labor market.

**Live demo**: <https://worknmb.eggfine.com> (Cloudflare Pages, auto-redeployed on every push to `main`).

---

## What It Does

This is not another personality quiz — it is a **quantitative** tool:

- Breaks a job down into 13 measurable dimensions (work hours, commute, overtime frequency, overtime pay, rest days, lunch break, work-from-home days, annual bonus, paid leave, environment, colleagues, career growth, monthly salary).
- Combines them as `BaseScore × SalaryCoefficient` to produce a 0–100 composite score.
- Displays an S / A / B / C / D grade badge.
- Automatically surfaces the three lowest-scoring factors with context-specific advice.

The app runs entirely on-device; no data is uploaded anywhere.

---

## Scoring Formula

```
BaseScore   = average(12 non-salary factor scores) × 10     range [0, 100]
SalaryCoef  = clamp(monthlySalary / 10000, 0.1, 2.5)
TotalScore  = clamp(BaseScore × SalaryCoef, 0, 100)

Grades:
  S  [85, 100]   excellent ratio
  A  [70, 85)    good
  B  [55, 70)    OK
  C  [40, 55)    mediocre
  D  [0,  40)    consider switching jobs
```

**How are numeric questions scored?** Each numeric question defines a `bestValue` (mapped to score 10) and a `worstValue` (mapped to score 0). The user's input is linearly interpolated between the two anchors and clamped to `[0, 10]`. Example: work-hours best=8, worst=13 → an input of 10 hours scores 6.0.

**Why 10,000 CNY / month as the baseline?** It is a common median for workers in China's tier-1 / new tier-1 cities. 1k → ×0.1; 10k → ×1.0; 30k → ×3.0 (capped at ×2.5 so high salaries cannot dominate the score).

---

## Question Bank (13 questions)

Grouped by question type:

### Numeric inputs (7 questions — for precision)

| # | Question | Unit | Best value (10) | Worst value (0) |
|---|----------|------|-----------------|-----------------|
| 1 | Actual daily work hours (including overtime) | hours | 8 | 13 |
| 2 | One-way commute time | minutes | 10 | 90 |
| 3 | Overtime days per week | days/week | 0 | 5 |
| 4 | Lunch break length | minutes | 90 | 15 |
| 5 | Work-from-home days per week | days/week | 3 | 0 |
| 6 | Annual bonus equivalent | months | 6 | 0 |
| 7 | Actual usable paid leave (statutory + company) | days | 20 | 5 |

### Single-choice (2 questions — discrete policy items)

| # | Question | Top-scoring option |
|---|----------|--------------------|
| 8 | Overtime compensation | No overtime / paid at 1.5×, 2×, 3× |
| 9 | Weekend rest | Full two-day weekend |

### 5-point ratings (3 questions — subjective experience)

| # | Question | Rating labels |
|---|----------|---------------|
| 10 | Work environment satisfaction | Poor / Fair / OK / Good / Great |
| 11 | Colleague / manager relationships | Poor / Fair / OK / Good / Great |
| 12 | Career development / promotion ceiling | Hopeless / Limited / OK / Clear / Great |

### Salary coefficient (1 question — multiplicative)

| # | Question | Unit | Baseline | Coefficient range |
|---|----------|------|----------|-------------------|
| 13 | Pre-tax monthly salary | CNY | 10,000 | ×0.1 to ×2.5 (capped) |

All questions live in `lib/features/survey/domain/survey_data.dart`. Editing the list is the only change needed to customize the survey.

---

## UI Highlights

### Internationalization (i18n)

Three locales are bundled: **简体中文 / 日本語 / English**. Switch anytime in **Settings** or let the app follow the system locale.

Switching a locale re-translates every UI string, question, option, rating label, grade description and improvement tip. **Already-given answers are preserved** — question IDs are shared across locales, so the value you entered for `workHours` in Chinese still scores the same after you switch to English.

**Each locale has its own scoring anchors** — not mechanical translations, but calibrated to the local labor market:

| Dimension | China (zh) | Japan (ja) | USA (en) |
|---|---|---|---|
| Salary baseline (×1.0 coefficient) | ¥10,000 | ¥300,000 | $5,000 |
| Work hours best / worst (h) | 8 / 13 | 8 / 12 | 8 / 11 |
| Commute best / worst (min) | 10 / 90 | 15 / 90 | 15 / 75 |
| Overtime days best / worst (day/wk) | 0 / 5 | 0 / 4 | 0 / 4 |
| Lunch break best / worst (min) | 90 / 15 | 60 / 15 | 60 / 15 |
| WFH best / worst (day/wk) | 3 / 0 | 3 / 0 | 4 / 0 |
| Annual bonus best / worst (mo) | 6 / 0 | 5 / 0 | 2 / 0 |
| PTO best / worst (days) | 20 / 5 | 20 / 5 | 25 / 10 |

Examples of why:
- **Japan**: A 15-minute commute is already exceptional (Tokyo average is 1h+); 5-month bonus is strong (summer + winter 賞与 tradition); baseline 300,000 JPY reflects Tokyo regular-employee median.
- **USA**: 11h is the realistic floor for burnout in salaried-exempt roles; 4-day WFH is the ceiling of hybrid culture; 25 days PTO is the aspirational target and 10 days is the implicit floor; 2-month bonuses are already strong (most US jobs have little or no annual bonus).

### Responsive layout

| Viewport width | Layout |
|---|---|
| `< 840 px` | Bottom NavigationBar, single-column content |
| `840 – 1199 px` | Compact NavigationRail (88 px, icons only) |
| `≥ 1200 px` | Extended Rail (240 px with labels) + two-column content |

### Material 3 dynamic theming

- **3 palette seeds**: `Tide` (cool teal), `Ember` (warm orange), `Moss` (forest green)
- **3 brightness modes**: light / dark / follow system
- Switching instantly repaints the whole app without restart.

### Design tokens

All visual primitives are centralized in `lib/app/theme/design_tokens.dart`. No widget is allowed to hard-code these values:

- `AppBreakpoints` — 600 / 840 / 1200 / 1600
- `AppSpacing` — 8dp grid: 4 / 8 / 12 / 16 / 20 / 24 / 32 / 48
- `AppRadius` — chip 12 / button 16 / card 24 / hero 28 / pill 999
- `AppDurations` — instant 120ms / fast 200ms / normal 260ms / slow 420ms
- `AppIconSize` / `AppLayout` / `AppCurves`

### Three question types, three UIs

- **Choice** — `_OptionCard` with subtle selected-state shadow and scale animation.
- **Rating** — 5 buttons in a row with short Chinese labels (e.g. `Poor / Fair / OK / Good / Great`).
- **Numeric** — conditional UI that adapts to the question:
  - **Salary** — large `¥`-prefixed input with real-time thousands separator, quick-pick chips (5k / 10k / 20k / 30k), and live salary-coefficient display.
  - **Other numerics** (hours, minutes, days, etc.) — no `¥` prefix, decimals allowed where useful (e.g. `8.5` hours), quick-picks include the unit (`8 小时` / `30 分钟`), and the bottom card shows a live `Current score N/10` based on the question's `bestValue` / `worstValue` anchors.

### Result screen

- **Score summary card** (featured): large number + grade badge (color changes per grade) + formula breakdown.
- **Factor contribution card**: one progress bar per dimension, color-coded by score range (`< 4` error / `4–7` neutral / `≥ 7` primary).
- **Advice card**: the three lowest factors with targeted suggestions.

---

## Project Structure

```
lib/
├── main.dart                              entrypoint
├── app/                                   non-business shell
│   ├── app_identity.dart                  brand constants (name, repo URL, preview URL)
│   ├── survey_app.dart                    MaterialApp wiring (theme + i18n)
│   ├── i18n/                              internationalization
│   │   ├── app_locale.dart                AppLocale enum (zh / ja / en)
│   │   ├── app_strings.dart               container for all UI strings + InheritedWidget
│   │   ├── strings_zh.dart                Chinese translations
│   │   ├── strings_ja.dart                Japanese translations
│   │   └── strings_en.dart                English translations
│   ├── state/
│   │   └── app_preferences.dart           theme / palette / locale preferences (ChangeNotifier)
│   ├── theme/
│   │   ├── design_tokens.dart             single source of truth for visual primitives
│   │   ├── text_styles.dart               ThemeData extensions (bodyMediumMuted, etc.)
│   │   ├── app_palette.dart               palette enum + grade-color tokens
│   │   └── survey_theme.dart              ThemeData assembly
│   └── widgets/                           shared widgets
│       ├── app_card.dart                  AppCard (outlined / filled / featured)
│       ├── app_section_header.dart        section title + description
│       └── responsive.dart                breakpoint helpers
└── features/survey/                       feature layer
    ├── domain/
    │   ├── survey_data.dart               locale-agnostic data models + scoring formula
    │   ├── localized_survey.dart          LocalizedSurvey container + factory
    │   ├── questions_zh.dart              CN question bank (¥10k baseline)
    │   ├── questions_ja.dart              JP question bank (¥300k baseline)
    │   └── questions_en.dart              US question bank ($5k baseline)
    └── presentation/
        ├── controllers/
        │   └── survey_controller.dart     answer state + score computation
        ├── pages/
        │   └── survey_home_page.dart      app shell (Rail + NavBar + page header + routing)
        └── widgets/
            ├── common/
            │   └── survey_common_widgets.dart   FadeSlideSwitcher / ValueBar / StatusChip
            └── sections/
                ├── home_section.dart            brand-focused landing page
                ├── questionnaire_section.dart   question page (3 input types)
                ├── result_section.dart          result page (score + grade + advice)
                └── settings_section.dart        settings page (appearance + reset + about)
```

---

## Getting Started

### Requirements

- **Flutter** `^3.12.0-210.2.beta` or newer (see `pubspec.yaml` SDK constraint)
- **Dart** (bundled with Flutter)

### Run

```bash
# Fetch dependencies
flutter pub get

# Default device
flutter run

# Specific platforms
flutter run -d windows
flutter run -d chrome
flutter run -d macos
flutter run -d linux
```

### Verify

```bash
# Static analysis (should report 0 issues)
flutter analyze

# Unit / widget tests
flutter test

# Format all Dart files
dart format lib/ test/
```

### Release builds

```bash
flutter build windows --release
flutter build web --release
flutter build apk --release
flutter build ipa --release
```

---

## Test Coverage

`test/widget_test.dart` covers the critical navigation flow:

1. App boots and lands on the Home page.
2. Tapping **"开始答题"** (Start) moves to the questionnaire page on question 1 (`"每天实际工作时长？"`).
3. Selecting the first option and tapping **"下一题"** (Next) advances to question 2 (`"单程通勤时间？"`).

This is the minimum regression safety net — any refactor must keep it green.

---

## CI / CD

### Multi-platform release (`.github/workflows/release.yml`)

Triggers:

- Push a tag matching `v*` (e.g. `v1.0.0`).
- Manually via **Actions → Run workflow**.

Pipeline:

```
test (flutter analyze + flutter test)
   │
   ├─► build-android   → APK + AAB
   ├─► build-windows   → portable zip
   ├─► build-macos     → DMG image
   ├─► build-linux     → portable tar.gz
   ├─► build-web       → static site zip
   └─► build-ios       → unsigned IPA (sideload only)
              │
              ▼
          release     → GitHub Release with all assets
```

### Web auto-deploy (`.github/workflows/deploy-web.yml`)

Triggers on every push to any branch (plus PRs and `workflow_dispatch`):

- Builds the Flutter web bundle.
- Adds a `_redirects` file so SPA routes fall back to `index.html`.
- Deploys to Cloudflare Pages via `cloudflare/wrangler-action@v3`.
- `main` → production (`worknmb.eggfine.com` / `worknmb.pages.dev`).
- Other branches / PRs → automatic preview URLs with wrangler comments on the PR.

Required repository secrets:

- `CLOUDFLARE_API_TOKEN` — user-level API token with `Account > Cloudflare Pages > Edit`
- `CLOUDFLARE_ACCOUNT_ID` — the 32-char account ID

---

## Customization

### Add or modify a question

Edit `lib/features/survey/domain/survey_data.dart`. Question order equals answering order.

```dart
// —— single-choice question ——
ChoiceQuestion(
  id: 'myQuestion',
  category: 'tag',
  title: 'Prompt?',
  hint: 'Guidance text.',
  options: [
    QuizOption('label', 'note', 10),  // last arg = contribution score (0-10)
    QuizOption('label', 'note', 5),
  ],
),

// —— 5-point rating question ——
RatingQuestion(
  id: 'myRating',
  category: 'tag',
  title: 'Prompt?',
  hint: 'Guidance text.',
  labels: ['Poor', 'Fair', 'OK', 'Good', 'Great'],  // length must equal maxRating (default 5)
),

// —— numeric question ——
NumericQuestion(
  id: 'myNumeric',
  category: 'tag',
  title: 'Prompt?',
  hint: 'Guidance text.',
  baseline: 60,
  minValue: 0,
  maxValue: 180,
  defaultValue: 60,
  unit: 'minutes',
  quickPicks: [30, 60, 90, 120],
  bestValue: 90,        // input that maps to score 10
  worstValue: 15,       // input that maps to score 0; best > worst means "higher is better", reverse for "lower is better"
  allowDecimal: false,  // set true to allow inputs like 8.5
  isSalaryMultiplier: false,  // true makes this the salary coefficient (best/worst ignored, excluded from base score)
),
```

### Tune grade thresholds

Edit the `ScoreGrade` enum in `survey_data.dart`:

```dart
enum ScoreGrade {
  s('S', 85, 'excellent ratio'),
  a('A', 70, 'good'),
  b('B', 55, 'OK'),
  c('C', 40, 'mediocre'),
  d('D', 0,  'consider switching jobs');
}
```

### Adjust salary-coefficient bounds

```dart
const double salaryCoefficientMin = 0.1;   // floor
const double salaryCoefficientMax = 2.5;   // cap
```

### Add a palette

Edit `lib/app/theme/app_palette.dart`:

```dart
enum AppPalette {
  tide('青潮', 'calm & professional', Color(0xFF006A6A), Icons.water_drop_rounded),
  ember('暖岩', 'action-oriented',     Color(0xFF9A4521), Icons.local_fire_department_rounded),
  moss('森雾', 'quiet, dark-friendly', Color(0xFF3C6A43), Icons.park_rounded),
  // Add a new palette by adding a line here
  yourPalette('Custom', 'description', Color(0xFFRRGGBB), Icons.your_icon),
}
```

Material 3 automatically derives the full light/dark ColorScheme from `seedColor` — no other color code required.

### Edit improvement advice

The `improvementTips` map at the end of `survey_data.dart`:

```dart
const Map<String, String> improvementTips = {
  'workHours': 'Check if your hours comply with labor law; renegotiate…',
  'commute': 'Move closer / switch jobs / push for remote work…',
  // 'questionId': 'advice string',
};
```

The key must be the question `id`; the three lowest-scoring factors automatically pull their advice from this map.

---

## Architecture Decisions

| Topic | Choice | Rationale |
|---|---|---|
| State management | built-in `ChangeNotifier` | project scale doesn't warrant riverpod / bloc |
| Routing | `AppSection` enum + single Scaffold | 4 top-level pages, no deep navigation |
| Networking | none | question bank and scoring are local consts; privacy by default |
| 3rd-party UI | none beyond `url_launcher` | Material + design tokens cover everything |
| Layering | domain ↔ presentation | lightweight Clean Architecture, no forced use-case layer |
| Question types | `sealed class QuizQuestion` | Dart 3 pattern matching dispatches on type with compile-time exhaustiveness |

---

## Version Info

- **Version**: `1.0.0+1`
- **Configuration**: see `pubspec.yaml`
- **Dependencies**: `flutter` + `cupertino_icons` + `url_launcher` + `flutter_lints` (dev)

---

## License

This project is released under the [Apache License 2.0](LICENSE). See the `LICENSE` file in the repository root for the full text.

You may freely use, modify, and distribute the code, including commercially, provided you retain the original copyright notice and license text. Any modifications must be noted in the changed files.

**Disclaimer**: Question data and scoring rules are illustrative. Results are for reference only and do not constitute professional career advice or legal guidance about labor rights.
