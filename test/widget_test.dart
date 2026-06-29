import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hnapp/core/config/app_environment.dart';
import 'package:hnapp/core/i18n/app_localizations.dart';
import 'package:hnapp/core/i18n/locale_controller.dart';
import 'package:hnapp/main.dart';

void main() {
  setUp(() {
    // 提供空的偏好存储，让 LocaleController 在测试中不依赖真实平台通道。
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('MVP app renders and switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    await _completeLogin(tester);

    expect(find.text('Off-grid solar'), findsNothing);
    expect(find.text('PV power'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Mine'), findsOneWidget);

    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();
    expect(find.text('Energy data'), findsOneWidget);

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    expect(find.text('Low battery'), findsOneWidget);
  });

  testWidgets('Power detail shows only the selected metric', (
    WidgetTester tester,
  ) async {
    await _pumpSignedInApp(tester);

    await tester.tap(find.text('PV power'));
    await tester.pumpAndSettle();
    expect(find.text('PV power'), findsWidgets);
    expect(find.text('Load power'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load power'));
    await tester.pumpAndSettle();
    expect(find.text('Load power'), findsWidgets);
    expect(find.text('PV power'), findsNothing);
  });

  testWidgets('Alerts page does not overflow on first narrow-screen entry', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpSignedInApp(tester);
    _expectNoFlutterException(tester);
    await tester.tap(find.text('Alerts'));
    await tester.pump();
    _expectNoFlutterException(tester);
    await tester.pumpAndSettle();

    _expectNoFlutterException(tester);
    expect(find.text('Low battery'), findsOneWidget);
  });

  testWidgets('All tabs fit on a compact phone viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpSignedInApp(tester);
    _expectNoFlutterException(tester);

    for (final tab in ['Data', 'Alerts', 'Mine', 'Home']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      _expectNoFlutterException(tester, reason: 'Tab $tab overflowed');
    }
  });

  test('ApiConfig uses dart-define override or dev default', () {
    final config = ApiConfig.fromDartDefine();
    const environmentName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'dev',
    );
    const override = String.fromEnvironment('API_BASE_URL');

    expect(config.environment, AppEnvironment.fromName(environmentName));
    if (override.isEmpty) {
      expect(
        config.baseUrl.toString(),
        contains('${config.environment.name}-api'),
      );
    } else {
      expect(config.baseUrl.toString(), override);
    }
  });

  test('AppLocalizations resolves translations with English fallback', () {
    const en = AppLocalizations(Locale('en'));
    const zh = AppLocalizations(Locale('zh'));
    const th = AppLocalizations(Locale('th'));

    expect(en.navHome, 'Home');
    expect(zh.navHome, '首页');
    expect(th.navData, 'ข้อมูล');
    expect(en.remainingHours('9.5'), contains('9.5'));
    expect(zh.actionPrefix('check'), contains('check'));

    // 未知语言会回退到英文文案表。
    const unknown = AppLocalizations(Locale('fr'));
    expect(unknown.navHome, 'Home');
  });

  test('LocaleController applies user > system > English priority', () async {
    final controller = LocaleController();

    // 没有用户选择且系统语言不支持时，回退到英文。
    expect(controller.resolve(const Locale('fr')), const Locale('en'));
    // 没有用户选择且系统语言受支持时，使用系统语言。
    expect(controller.resolve(const Locale('th')), const Locale('th'));

    // 用户显式选择优先于系统语言。
    await controller.setLocale(const Locale('vi'));
    expect(controller.followsSystem, isFalse);
    expect(controller.resolve(const Locale('th')), const Locale('vi'));

    // 清除用户选择后，重新跟随系统语言。
    await controller.setLocale(null);
    expect(controller.followsSystem, isTrue);
    expect(controller.resolve(const Locale('id')), const Locale('id'));

    controller.dispose();
  });
}

Future<void> _pumpSignedInApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp(initiallySignedIn: true));
  await tester.pumpAndSettle();
  _expectNoFlutterException(
    tester,
    reason: 'Initial signed-in page overflowed',
  );
}

Future<void> _completeLogin(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).first, 'demo@example.com');
  await tester.tap(find.widgetWithText(OutlinedButton, 'Send code'));
  await tester.pumpAndSettle();
  _expectNoFlutterException(tester, reason: 'Sending login code overflowed');
  await tester.enterText(find.byType(TextField).last, '123456');
  tester.testTextInput.hide();
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
  _expectNoFlutterException(tester, reason: 'Completing login overflowed');
}

void _expectNoFlutterException(WidgetTester tester, {String? reason}) {
  final exception = tester.takeException();
  if (exception == null) {
    return;
  }
  final diagnostics = exception is FlutterError
      ? exception.toStringDeep()
      : exception.toString();
  fail(reason == null ? diagnostics : '$reason\n$diagnostics');
}
