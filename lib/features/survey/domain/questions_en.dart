import 'localized_survey.dart';
import 'survey_data.dart';

/// US-market tuned 13-question survey.
///
/// Calibration notes:
///   - Salary baseline: 5,000 USD / month (US median individual income ~$60k/yr)
///   - Work hours: 8h ideal, 11h = 0 (US salaried exempt workers often pull
///     10-11h; much past that is burnout territory)
///   - Commute: 15 min ideal, 75 min = 0 (US median car commute is ~27 min)
///   - PTO: 25 days ideal, 10 days = 0 (legally 0 in US but norms are 10-25)
///   - Bonus: 2 months ideal, 0 = 0 (US bonuses are rarer/smaller than in
///     Japan and China; 2 months is already strong)
///   - WFH: 4 days ideal (hybrid/remote culture is strongest in the US)
final surveyEn = LocalizedSurvey(
  questions: const <QuizQuestion>[
    NumericQuestion(
      id: 'workHours',
      category: 'Work hours',
      title: 'Actual daily work hours (incl. overtime)?',
      hint: 'Average of the last month. Half-hour precision allowed.',
      baseline: 8,
      minValue: 4,
      maxValue: 16,
      defaultValue: 8.5,
      unit: 'h',
      quickPicks: [8, 9, 10, 11],
      bestValue: 8,
      worstValue: 11,
      allowDecimal: true,
    ),
    NumericQuestion(
      id: 'commute',
      category: 'Commute',
      title: 'One-way commute time?',
      hint: 'Door to door (including wait / transfer), in minutes.',
      baseline: 30,
      minValue: 0,
      maxValue: 180,
      defaultValue: 30,
      unit: 'min',
      quickPicks: [10, 20, 30, 45, 60],
      bestValue: 15,
      worstValue: 75,
    ),
    NumericQuestion(
      id: 'overtimeDays',
      category: 'Overtime freq.',
      title: 'Average overtime days per week (last month)?',
      hint: 'Days you stayed significantly past normal hours.',
      baseline: 1,
      minValue: 0,
      maxValue: 7,
      defaultValue: 1,
      unit: 'day/wk',
      quickPicks: [0, 1, 2, 3, 5],
      bestValue: 0,
      worstValue: 4,
      allowDecimal: true,
    ),
    ChoiceQuestion(
      id: 'overtimePay',
      category: 'Overtime pay',
      title: 'Is overtime compensated?',
      hint: 'Actual compensation practice for extra hours.',
      options: [
        QuizOption('No overtime needed', 'Basically never stay late.', 10),
        QuizOption(
          'Paid overtime (1.5x or time-and-a-half)',
          'Hourly workers, per FLSA rules.',
          9,
        ),
        QuizOption(
          'Comp time / flex time',
          'Not paid but you get hours back.',
          6,
        ),
        QuizOption(
          'Unpaid / "just part of the job"',
          'Salaried-exempt default.',
          0,
        ),
      ],
    ),
    ChoiceQuestion(
      id: 'restDays',
      category: 'Weekends',
      title: 'Weekend / rest-day situation?',
      hint: 'Actual weekly schedule.',
      options: [
        QuizOption(
          'Full two-day weekend (Sat + Sun)',
          'Classic 9-to-5 Mon-Fri.',
          10,
        ),
        QuizOption('Occasional weekend work', 'Monthly at most.', 6),
        QuizOption(
          'Regular 6-day week',
          'Work at least one weekend day most weeks.',
          2,
        ),
        QuizOption('No fixed schedule', 'On call / shift-based any time.', 0),
      ],
    ),
    NumericQuestion(
      id: 'lunchBreak',
      category: 'Lunch break',
      title: 'Lunch break available?',
      hint: 'Food + rest time actually allowed by the company.',
      baseline: 30,
      minValue: 0,
      maxValue: 120,
      defaultValue: 30,
      unit: 'min',
      quickPicks: [15, 30, 45, 60, 90],
      bestValue: 60,
      worstValue: 15,
    ),
    NumericQuestion(
      id: 'wfhDays',
      category: 'Remote work',
      title: 'Work-from-home days per week?',
      hint: 'How many days you can actually work remotely.',
      baseline: 2,
      minValue: 0,
      maxValue: 5,
      defaultValue: 2,
      unit: 'day/wk',
      quickPicks: [0, 1, 2, 3, 5],
      bestValue: 4,
      worstValue: 0,
    ),
    NumericQuestion(
      id: 'annualBonus',
      category: 'Annual bonus',
      title: 'Annual bonus in months of salary?',
      hint: 'Total bonus / equity vest / 13th-cheque. Put 0 if none.',
      baseline: 1,
      minValue: 0,
      maxValue: 12,
      defaultValue: 1,
      unit: 'mo',
      quickPicks: [0, 1, 2, 3, 4],
      bestValue: 2,
      worstValue: 0,
      allowDecimal: true,
    ),
    NumericQuestion(
      id: 'annualLeave',
      category: 'PTO',
      title: 'Usable PTO days per year?',
      hint: 'What you can actually take off (vacation + personal + sick).',
      baseline: 15,
      minValue: 0,
      maxValue: 40,
      defaultValue: 15,
      unit: 'days',
      quickPicks: [10, 15, 20, 25, 30],
      bestValue: 25,
      worstValue: 10,
    ),
    RatingQuestion(
      id: 'environment',
      category: 'Environment',
      title: 'Work environment satisfaction?',
      hint: 'Desk, equipment, office vibe, HVAC, and other hardware.',
      labels: ['Awful', 'Poor', 'OK', 'Good', 'Great'],
    ),
    RatingQuestion(
      id: 'colleagues',
      category: 'Team',
      title: 'Relationship with coworkers / manager?',
      hint: 'Collaboration vibe, trust, support.',
      labels: ['Awful', 'Poor', 'OK', 'Good', 'Great'],
    ),
    RatingQuestion(
      id: 'career',
      category: 'Career growth',
      title: 'Career growth / promotion ceiling?',
      hint:
          'Learning opportunities, promotion path, salary growth track record.',
      labels: ['Stuck', 'Scarce', 'OK', 'Clear', 'Great'],
    ),
    NumericQuestion(
      id: 'salary',
      category: 'Salary',
      title: 'Pre-tax monthly salary?',
      hint: r'$5,000 / month = ×1.0 coefficient. Caps at ×2.5.',
      baseline: 5000,
      minValue: 1000,
      maxValue: 50000,
      defaultValue: 5000,
      unit: 'USD',
      quickPicks: [3000, 5000, 7500, 10000, 15000],
      isSalaryMultiplier: true,
    ),
  ],
  improvementTips: const <String, String>{
    'workHours':
        'Sustained long hours correlate with burnout and drop in output quality. '
        'Negotiate scope with your manager, or shop around.',
    'commute':
        'Every 30 minutes shaved off the commute is a major life-quality win. '
        'Move closer, switch to hybrid, or target a remote role.',
    'overtimeDays':
        'Frequent overtime usually signals understaffing or weak planning. '
        'Worth benchmarking against external offers.',
    'overtimePay':
        'FLSA non-exempt workers are legally entitled to overtime pay. '
        'If you are non-exempt and unpaid, document and escalate.',
    'restDays':
        'Less than a full weekend off is a strong burnout signal. '
        'Prioritize recovery — your productivity depends on it.',
    'lunchBreak':
        'No real lunch break erodes focus and health. '
        'Block the time on your calendar if you have to.',
    'wfhDays':
        'Mandatory full-office in 2026 costs you commute hours and flexibility. '
        'Ask for at least 1-2 days of hybrid.',
    'annualBonus':
        'Low bonuses often mean compensation is structured conservatively. '
        'Counter-negotiate on base, equity or RSU refresh cycles.',
    'annualLeave':
        'Unlimited PTO that nobody uses is worse than 15 days that you actually take. '
        'Track your usage; if < 10 days/year, that is a red flag.',
    'environment':
        'Bad hardware and space tax your focus every single day. '
        'Escalate to facilities / manager or consider a team change.',
    'colleagues':
        'Interpersonal friction is the most hidden cost. '
        'If the team dynamic is not fixable, internal transfer is a real option.',
    'career':
        'No visible growth path in ~18 months = start looking. '
        'Find a mentor or external role to reset trajectory.',
    'salary':
        'If you are meaningfully below market for your role, '
        'renegotiate internally first, then test the market.',
  },
  gradeDescriptions: const <String, String>{
    'S': 'Elite ratio',
    'A': 'Solid',
    'B': 'OK',
    'C': 'Below par',
    'D': 'Seriously consider leaving',
  },
);
