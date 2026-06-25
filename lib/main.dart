import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'core/api/api_client.dart';
import 'core/config/app_environment.dart';
import 'core/demo/demo_repository.dart';
import 'core/i18n/app_localizations.dart';
import 'core/i18n/locale_controller.dart';
import 'core/session/auth_session.dart';
import 'core/theme/app_theme.dart';
import 'features/alerts/alerts_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/data/data_page.dart';
import 'features/profile/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthSession _authSession;
  late final DemoRepository _demoRepository;
  late final ApiClient _apiClient;
  late final LocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _authSession = AuthSession()..signInWithDemoToken();
    _demoRepository = DemoRepository();
    _apiClient = ApiClient(
      config: ApiConfig.fromDartDefine(),
      session: _authSession,
    );
    _localeController = LocaleController();
  }

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      apiClient: _apiClient,
      authSession: _authSession,
      demoRepository: _demoRepository,
      localeController: _localeController,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'Off-grid Solar',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
            locale: _localeController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              return _localeController.resolve(deviceLocale);
            },
            home: const SolarShell(),
          );
        },
      ),
    );
  }
}

class SolarShell extends StatefulWidget {
  const SolarShell({super.key});

  @override
  State<SolarShell> createState() => _SolarShellState();
}

class _SolarShellState extends State<SolarShell> {
  int _selectedIndex = 0;

  static const _pages = [
    DashboardPage(),
    DataPage(),
    AlertsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart_rounded),
            label: l10n.navData,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none_rounded),
            selectedIcon: const Icon(Icons.notifications_active_rounded),
            label: l10n.navAlerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.navMine,
          ),
        ],
      ),
    );
  }
}
