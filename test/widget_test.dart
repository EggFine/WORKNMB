import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worknmb/app/app_identity.dart';
import 'package:worknmb/main.dart';

void main() {
  testWidgets('登陆页点击开始答题后可从第一题切到第二题（zh locale）', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    // 固定到中文 locale，保证断言稳定
    tester.platformDispatcher.localeTestValue = const Locale('zh', 'CN');
    tester.platformDispatcher.localesTestValue = const <Locale>[
      Locale('zh', 'CN'),
    ];
    addTearDown(() {
      tester.platformDispatcher.clearLocaleTestValue();
      tester.platformDispatcher.clearLocalesTestValue();
    });

    await tester.pumpWidget(const SurveyApp());
    await tester.pumpAndSettle();

    // 默认落在登陆页，应看到品牌名与主 CTA
    expect(find.text(appShortName), findsWidgets);
    expect(find.text('开始答题'), findsOneWidget);

    // 点击开始答题，进入问卷页第 1 题：每天实际工作时长
    await tester.tap(find.text('开始答题'));
    await tester.pumpAndSettle();

    expect(find.text('每天实际工作时长（含加班）？'), findsOneWidget);

    // 第 1 题是数字填空题：点击快捷芯片"8 小时"作答
    await tester.tap(find.text('8 小时'));
    await tester.pumpAndSettle();

    // 点击"下一题"切到第 2 题
    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();

    // 第 2 题：单程通勤时间
    expect(find.text('单程通勤时间？'), findsOneWidget);
  });
}
