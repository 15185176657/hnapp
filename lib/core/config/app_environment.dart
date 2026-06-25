enum AppEnvironment {
  dev,
  test,
  prod;

  static AppEnvironment fromName(String value) {
    return AppEnvironment.values.firstWhere(
      (environment) => environment.name == value,
      orElse: () => AppEnvironment.dev,
    );
  }
}

class ApiConfig {
  ApiConfig({required this.environment, required this.baseUrl});

  factory ApiConfig.fromDartDefine() {
    const environmentName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'dev',
    );
    const baseUrlOverride = String.fromEnvironment('API_BASE_URL');
    final environment = AppEnvironment.fromName(environmentName);

    return ApiConfig(
      environment: environment,
      baseUrl: baseUrlOverride.isNotEmpty
          ? Uri.parse(baseUrlOverride)
          : Uri.parse(_defaultBaseUrls[environment]!),
    );
  }

  final AppEnvironment environment;
  final Uri baseUrl;

  static const Map<AppEnvironment, String> _defaultBaseUrls = {
    AppEnvironment.dev: 'https://dev-api.offgrid-solar.example.com',
    AppEnvironment.test: 'https://test-api.offgrid-solar.example.com',
    AppEnvironment.prod: 'https://api.offgrid-solar.example.com',
  };
}