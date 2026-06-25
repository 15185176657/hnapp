import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hnapp/core/config/app_environment.dart';
import 'package:hnapp/core/i18n/app_localizations.dart';
import 'package:hnapp/core/i18n/locale_controller.dart';
import 'package:hnapp/main.dart';

void main() {
  setUp(() {
    // Provide an empty preferences store so the LocaleController can run
    // without the real platform channel during tests.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('MVP app renders and switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Off-grid solar'), findsOneWidget);
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

  test('ApiConfig uses dart-define override or dev default', () {
    final config = ApiConfig.fromDartDefine();
    const environmentName = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const override = String.fromEnvironment('API_BASE_URL');

    expect(config.environment, AppEnvironment.fromName(environmentName));
    if (override.isEmpty) {
      expect(config.baseUrl.toString(), contains('${config.environment.name}-api'));
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

    // Unknown languages fall back to the English table.
    const unknown = AppLocalizations(Locale('fr'));
    expect(unknown.navHome, 'Home');
  });

  test('LocaleController applies user > system > English priority', () async {
    final controller = LocaleController();

    // No user choice + unsupported system language -> English fallback.
    expect(controller.resolve(const Locale('fr')), const Locale('en'));
    // No user choice + supported system language -> that language.
    expect(controller.resolve(const Locale('th')), const Locale('th'));

    // Explicit user choice overrides the system language.
    await controller.setLocale(const Locale('vi'));
    expect(controller.followsSystem, isFalse);
    expect(controller.resolve(const Locale('th')), const Locale('vi'));

    // Clearing the choice returns to following the system language.
    await controller.setLocale(null);
    expect(controller.followsSystem, isTrue);
    expect(controller.resolve(const Locale('id')), const Locale('id'));

    controller.dispose();
  });
}
