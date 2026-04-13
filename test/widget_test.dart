import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worknmb/app/app_identity.dart';
import 'package:worknmb/main.dart';

void main() {
  testWidgets('登陆页点击开始答题后可从第一题切到第二题', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const SurveyApp());
    await tester.pumpAndSettle();

    // 默认落在登陆页，应看到品牌名与主 CTA
    expect(find.text(appShortName), findsWidgets);
    expect(find.text('开始答题'), findsOneWidget);

    // 点击开始答题，进入问卷页，应显示第一题（工作时长）
    await tester.tap(find.text('开始答题'));
    await tester.pumpAndSettle();

    expect(find.text('每天实际工作时长（含加班）？'), findsOneWidget);

    // 选第一个选项并下一题
    await tester.tap(find.text('≤ 8 小时'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();

    // 第二题：通勤时间
    expect(find.text('单程通勤时间？'), findsOneWidget);
  });
}
