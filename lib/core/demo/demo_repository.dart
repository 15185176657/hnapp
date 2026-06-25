import 'demo_models.dart';

enum DemoScenario { normal, lowBattery, offline, overload, refreshFailed }

class DemoRepository {
  DemoRepository();

  DemoScenario _scenario = DemoScenario.normal;
  StationOverview? _lastOverview;
  EnergyStatistics? _lastStatistics;

  DemoScenario get scenario => _scenario;

  void setScenario(DemoScenario scenario) {
    _scenario = scenario;
  }

  Future<StationOverview> fetchOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (_scenario == DemoScenario.refreshFailed && _lastOverview != null) {
      throw const DemoRefreshException();
    }
    final overview = _overviewForScenario(_scenario);
    _lastOverview = overview;
    return overview;
  }

  Future<EnergyStatistics> fetchStatistics() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (_scenario == DemoScenario.refreshFailed && _lastStatistics != null) {
      throw const DemoRefreshException();
    }
    final statistics = EnergyStatistics(
      todayGenerationKwh: 18.6,
      monthGenerationKwh: 426.2,
      totalGenerationKwh: 12840.5,
      todayConsumptionKwh: 14.2,
      monthConsumptionKwh: 371.8,
      totalConsumptionKwh: 10912.7,
      hourlyGeneration: const [0, 0, 0.6, 1.4, 2.3, 3.1, 3.8, 3.2, 2.1, 1.0],
      hourlyConsumption: const [0.9, 1.0, 1.4, 1.7, 2.0, 1.8, 1.6, 1.9, 2.2, 1.7],
    );
    _lastStatistics = statistics;
    return statistics;
  }

  Future<List<SolarAlert>> fetchAlerts({required bool history}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return [
      SolarAlert(
        title: 'Low battery',
        message: 'Battery is below 25%. Reduce high-power appliances.',
        action: 'Turn off heavy loads and check charging.',
        severity: AlertSeverity.warning,
        occurredAt: now.subtract(const Duration(minutes: 18)),
        isResolved: false,
      ),
      SolarAlert(
        title: 'Overload detected',
        message: 'Load is close to inverter limit.',
        action: 'Move washing machine or pump to daytime use.',
        severity: AlertSeverity.critical,
        occurredAt: now.subtract(const Duration(hours: 2)),
        isResolved: history,
      ),
      if (history)
        SolarAlert(
          title: 'Controller temperature high',
          message: 'Device cooled down after ventilation improved.',
          action: 'Keep the controller area clear.',
          severity: AlertSeverity.info,
          occurredAt: now.subtract(const Duration(days: 1, hours: 4)),
          isResolved: true,
        ),
    ];
  }

  Future<DeviceInfo> fetchDeviceInfo() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const DeviceInfo(
      serialNumber: 'SEA-OFFGRID-2408',
      capacityKw: 5.5,
      batteryCapacityKwh: 12.8,
      firmwareVersion: 'v1.8.2',
    );
  }

  StationOverview? get cachedOverview => _lastOverview;
  EnergyStatistics? get cachedStatistics => _lastStatistics;

  StationOverview _overviewForScenario(DemoScenario scenario) {
    final now = DateTime.now();
    return switch (scenario) {
      DemoScenario.lowBattery => StationOverview(
        systemName: 'Home Solar Station',
        location: 'Chiang Mai, Thailand',
        pvPowerKw: 0.8,
        loadPowerKw: 1.9,
        batterySoc: 21,
        remainingHours: 2.4,
        todayGenerationKwh: 7.8,
        todayConsumptionKwh: 12.1,
        status: SystemStatus.lowBattery,
        isDeviceOnline: true,
        lastUpdated: now,
      ),
      DemoScenario.offline => StationOverview(
        systemName: 'Home Solar Station',
        location: 'Chiang Mai, Thailand',
        pvPowerKw: 0,
        loadPowerKw: 0,
        batterySoc: 64,
        remainingHours: 0,
        todayGenerationKwh: 13.4,
        todayConsumptionKwh: 10.6,
        status: SystemStatus.fault,
        isDeviceOnline: false,
        lastUpdated: now.subtract(const Duration(minutes: 42)),
      ),
      DemoScenario.overload => StationOverview(
        systemName: 'Home Solar Station',
        location: 'Chiang Mai, Thailand',
        pvPowerKw: 3.4,
        loadPowerKw: 5.2,
        batterySoc: 47,
        remainingHours: 1.8,
        todayGenerationKwh: 16.9,
        todayConsumptionKwh: 18.5,
        status: SystemStatus.fault,
        isDeviceOnline: true,
        lastUpdated: now,
      ),
      DemoScenario.refreshFailed || DemoScenario.normal => StationOverview(
        systemName: 'Home Solar Station',
        location: 'Chiang Mai, Thailand',
        pvPowerKw: 3.2,
        loadPowerKw: 1.6,
        batterySoc: 76,
        remainingHours: 9.5,
        todayGenerationKwh: 18.6,
        todayConsumptionKwh: 14.2,
        status: SystemStatus.charging,
        isDeviceOnline: true,
        lastUpdated: now,
      ),
    };
  }
}

class DemoRefreshException implements Exception {
  const DemoRefreshException();
}