import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/api/api_client.dart';
import 'core/config/app_environment.dart';
import 'core/demo/demo_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _authSession = AuthSession()..signInWithDemoToken();
    _demoRepository = DemoRepository();
    _apiClient = ApiClient(
      config: ApiConfig.fromDartDefine(),
      session: _authSession,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      apiClient: _apiClient,
      authSession: _authSession,
      demoRepository: _demoRepository,
      child: MaterialApp(
        title: 'Off-grid Solar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SolarShell(),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Monitor'),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Data',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_active_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Mine',
          ),
        ],
      ),
    );
  }
}
