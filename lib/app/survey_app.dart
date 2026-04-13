import 'package:flutter/material.dart';

import '../features/survey/presentation/pages/survey_home_page.dart';
import 'app_identity.dart';
import 'state/app_preferences.dart';
import 'theme/design_tokens.dart';
import 'theme/survey_theme.dart';

class SurveyApp extends StatefulWidget {
  const SurveyApp({super.key});

  @override
  State<SurveyApp> createState() => _SurveyAppState();
}

class _SurveyAppState extends State<SurveyApp> {
  final preferences = AppPreferences();

  @override
  void dispose() {
    preferences.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: preferences,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: appShortName,
          themeMode: preferences.themeMode,
          theme: SurveyTheme.light(preferences.palette),
          darkTheme: SurveyTheme.dark(preferences.palette),
          themeAnimationCurve: AppCurves.emphasized,
          themeAnimationDuration: AppDurations.slow,
          home: SurveyHomePage(preferences: preferences),
        );
      },
    );
  }
}
