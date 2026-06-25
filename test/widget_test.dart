import 'package:flutter_test/flutter_test.dart';
import 'package:hnapp/core/config/app_environment.dart';

import 'package:hnapp/main.dart';

void main() {
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
}
