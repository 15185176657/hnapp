import 'package:flutter/widgets.dart';

import 'core/api/api_client.dart';
import 'core/demo/demo_repository.dart';
import 'core/session/auth_session.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.apiClient,
    required this.authSession,
    required this.demoRepository,
    required super.child,
  });

  final ApiClient apiClient;
  final AuthSession authSession;
  final DemoRepository demoRepository;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return apiClient != oldWidget.apiClient ||
        authSession != oldWidget.authSession ||
        demoRepository != oldWidget.demoRepository;
  }
}