import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/survey/presentation/pages/survey_home_page.dart';
import 'app_identity.dart';
import 'i18n/app_locale.dart';
import 'i18n/app_strings.dart';
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
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final appLocale = preferences.resolveLocale(systemLocale);
        final strings = AppStrings.forLocale(appLocale);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: appShortName,
          themeMode: preferences.themeMode,
          theme: SurveyTheme.light(preferences.palette),
          darkTheme: SurveyTheme.dark(preferences.palette),
          themeAnimationCurve: AppCurves.emphasized,
          themeAnimationDuration: AppDurations.slow,
          // 国际化：用户偏好 locale 覆盖系统 locale（否则 Flutter Material chrome 跟随系统）
          locale: appLocale.locale,
          supportedLocales: AppLocale.values.map((v) => v.locale).toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AppStringsScope(
            strings: strings,
            child: SurveyHomePage(preferences: preferences),
          ),
        );
      },
    );
  }
}
