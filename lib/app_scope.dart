import 'package:flutter/widgets.dart';

import 'core/api/auth_api.dart';
import 'core/api/api_client.dart';
import 'core/demo/demo_repository.dart';
import 'core/i18n/locale_controller.dart';
import 'core/session/auth_session.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.apiClient,
    required this.authApi,
    required this.authSession,
    required this.demoRepository,
    required this.localeController,
    required super.child,
  });

  final ApiClient apiClient;
  final AuthApi authApi;
  final AuthSession authSession;
  final DemoRepository demoRepository;
  final LocaleController localeController;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return apiClient != oldWidget.apiClient ||
        authApi != oldWidget.authApi ||
        authSession != oldWidget.authSession ||
        demoRepository != oldWidget.demoRepository ||
        localeController != oldWidget.localeController;
  }
}
