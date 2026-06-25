import 'demo_models.dart';
import '../../network/metric_api.dart';

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

  // ── Chart data ─────────────────────────────────────────────────────────────

  Future<EnergyChartData> fetchEnergyChart(ChartGranularity granularity) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return switch (granularity) {
      ChartGranularity.day => _energyDay(),
      ChartGranularity.week => _energyWeek(),
      ChartGranularity.month => _energyMonth(),
    };
  }

  Future<PowerChartData> fetchPowerChart(ChartGranularity granularity) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return switch (granularity) {
      ChartGranularity.day => _powerDay(),
      ChartGranularity.week => _powerWeek(),
      ChartGranularity.month => _powerMonth(),
    };
  }

  Future<BatteryChartData> fetchBatteryChart(ChartGranularity granularity) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return switch (granularity) {
      ChartGranularity.day => _batteryDay(),
      ChartGranularity.week => _batteryWeek(),
      ChartGranularity.month => _batteryMonth(),
    };
  }

  Future<MetricChartData> fetchMetricChart(
    MetricSeriesType metric,
    ChartGranularity granularity,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final payload = _metricPayload(metric, granularity);
    final response = MetricApiAdapter.fromPayload(payload);
    final points = MetricApiAdapter.toChartPoints(response, granularity);
    if (points.isEmpty) {
      return MetricChartData(
        granularity: granularity,
        points: const [],
        latest: 0,
        peak: 0,
        average: 0,
      );
    }
    final values = points.map((p) => p.y).toList(growable: false);
    final sum = values.fold<double>(0, (a, b) => a + b);
    return MetricChartData(
      granularity: granularity,
      points: points,
      latest: values.last,
      peak: values.fold<double>(0, (a, b) => b > a ? b : a),
      average: sum / values.length,
    );
  }

  // ── Energy data builders ──────────────────────────────────────────────────

  EnergyChartData _energyDay() {
    final gen = [0.0, 0.0, 0.6, 1.4, 2.3, 3.1, 3.8, 3.2, 2.1, 1.0, 0.6, 0.3];
    final con = [0.9, 1.0, 1.4, 1.7, 2.0, 1.8, 1.6, 1.9, 2.2, 1.7, 1.5, 1.2];
    final labels = ['06','08','10','12','14','16','18','20','22','00','02','04'];
    return _buildEnergyChart(ChartGranularity.day, gen, con, labels);
  }

  EnergyChartData _energyWeek() {
    final gen = [14.2, 18.6, 16.3, 20.1, 17.8, 15.5, 19.2];
    final con = [12.1, 14.2, 13.6, 15.9, 14.8, 13.2, 16.1];
    final labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return _buildEnergyChart(ChartGranularity.week, gen, con, labels);
  }

  EnergyChartData _energyMonth() {
    final gen = [15.1,16.3,18.0,14.2,20.1,19.4,17.8,16.5,21.0,18.6,
                 15.9,17.2,19.8,20.3,16.7,18.1,14.5,17.9,22.0,19.1,
                 16.3,18.7,20.5,17.4,19.2,21.1,18.3,16.8,15.6,17.5];
    final con = [13.2,14.1,15.8,12.6,14.9,16.2,15.1,13.8,16.5,14.2,
                 13.5,14.8,16.1,15.3,13.9,14.6,12.8,15.2,17.1,15.8,
                 13.9,15.4,16.8,14.7,15.9,17.2,15.3,14.1,13.2,14.9];
    final labels = List<String>.generate(30, (i) => (i + 1).toString());
    return _buildEnergyChart(ChartGranularity.month, gen, con, labels);
  }

  EnergyChartData _buildEnergyChart(
    ChartGranularity g,
    List<double> gen,
    List<double> con,
    List<String> labels,
  ) {
    final genPoints = List.generate(
      gen.length,
      (i) => ChartPoint(x: i.toDouble(), y: gen[i], label: labels[i]),
    );
    final conPoints = List.generate(
      con.length,
      (i) => ChartPoint(x: i.toDouble(), y: con[i], label: labels[i]),
    );
    return EnergyChartData(
      granularity: g,
      generationPoints: genPoints,
      consumptionPoints: conPoints,
      totalGenerationKwh: gen.fold(0, (a, b) => a + b),
      totalConsumptionKwh: con.fold(0, (a, b) => a + b),
      peakGenerationKwh: gen.fold<double>(0, (a, b) => b > a ? b : a),
      peakConsumptionKwh: con.fold<double>(0, (a, b) => b > a ? b : a),
    );
  }

  // ── Power data builders ───────────────────────────────────────────────────

  PowerChartData _powerDay() {
    final pv   = [0.0, 0.3, 1.2, 2.8, 3.8, 4.2, 3.9, 3.2, 2.0, 0.8, 0.2, 0.0];
    final load = [1.6, 1.4, 1.8, 2.2, 1.9, 1.7, 1.6, 2.0, 2.3, 1.8, 1.5, 1.6];
    final labels = ['06','08','10','12','14','16','18','20','22','00','02','04'];
    return _buildPowerChart(ChartGranularity.day, pv, load, labels);
  }

  PowerChartData _powerWeek() {
    final pv   = [1.8, 3.2, 2.7, 4.0, 3.5, 2.9, 3.7];
    final load = [1.6, 1.9, 1.7, 2.1, 1.8, 1.7, 2.0];
    final labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return _buildPowerChart(ChartGranularity.week, pv, load, labels);
  }

  PowerChartData _powerMonth() {
    final pv = [2.1,2.8,3.5,2.0,4.0,3.8,3.2,2.9,4.1,3.2,
                2.5,3.0,3.8,4.0,3.1,3.5,2.2,3.3,4.2,3.7,
                2.9,3.4,3.9,3.1,3.7,4.1,3.5,3.0,2.8,3.2];
    final load = [1.6,1.8,2.0,1.5,1.9,2.1,1.9,1.7,2.0,1.8,
                  1.6,1.8,2.0,1.9,1.7,1.8,1.5,1.9,2.2,2.0,
                  1.7,1.9,2.1,1.8,1.9,2.1,1.9,1.7,1.6,1.8];
    final labels = List<String>.generate(30, (i) => (i + 1).toString());
    return _buildPowerChart(ChartGranularity.month, pv, load, labels);
  }

  PowerChartData _buildPowerChart(
    ChartGranularity g,
    List<double> pv,
    List<double> load,
    List<String> labels,
  ) {
    final pvPoints = List.generate(
      pv.length,
      (i) => ChartPoint(x: i.toDouble(), y: pv[i], label: labels[i]),
    );
    final loadPoints = List.generate(
      load.length,
      (i) => ChartPoint(x: i.toDouble(), y: load[i], label: labels[i]),
    );
    final avgPv = pv.fold<double>(0, (a, b) => a + b) / pv.length;
    final avgLoad = load.fold<double>(0, (a, b) => a + b) / load.length;
    return PowerChartData(
      granularity: g,
      pvPowerPoints: pvPoints,
      loadPowerPoints: loadPoints,
      peakPvKw: pv.fold<double>(0, (a, b) => b > a ? b : a),
      peakLoadKw: load.fold<double>(0, (a, b) => b > a ? b : a),
      avgPvKw: avgPv,
      avgLoadKw: avgLoad,
    );
  }

  // ── Battery data builders ─────────────────────────────────────────────────

  BatteryChartData _batteryDay() {
    final soc = [92.0,88.0,80.0,72.0,68.0,74.0,80.0,84.0,80.0,76.0,72.0,78.0];
    final labels = ['06','08','10','12','14','16','18','20','22','00','02','04'];
    return _buildBatteryChart(ChartGranularity.day, soc, labels);
  }

  BatteryChartData _batteryWeek() {
    final soc = [76.0, 82.0, 68.0, 85.0, 79.0, 73.0, 88.0];
    final labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return _buildBatteryChart(ChartGranularity.week, soc, labels);
  }

  BatteryChartData _batteryMonth() {
    final soc = [80.0,78.0,82.0,68.0,85.0,84.0,79.0,76.0,88.0,82.0,
                 73.0,77.0,83.0,86.0,79.0,81.0,70.0,78.0,90.0,85.0,
                 76.0,80.0,84.0,78.0,82.0,87.0,80.0,75.0,72.0,78.0];
    final labels = List<String>.generate(30, (i) => (i + 1).toString());
    return _buildBatteryChart(ChartGranularity.month, soc, labels);
  }

  BatteryChartData _buildBatteryChart(
    ChartGranularity g,
    List<double> soc,
    List<String> labels,
  ) {
    final points = List.generate(
      soc.length,
      (i) => ChartPoint(x: i.toDouble(), y: soc[i], label: labels[i]),
    );
    final minSoc = soc.fold<double>(100, (a, b) => b < a ? b : a).round();
    final maxSoc = soc.fold<double>(0, (a, b) => b > a ? b : a).round();
    return BatteryChartData(
      granularity: g,
      socPoints: points,
      currentSoc: soc.last.round(),
      minSoc: minSoc,
      maxSoc: maxSoc,
    );
  }

  StationOverview? get cachedOverview => _lastOverview;
  EnergyStatistics? get cachedStatistics => _lastStatistics;

  Map<String, dynamic> _metricPayload(
    MetricSeriesType metric,
    ChartGranularity granularity,
  ) {
    final now = DateTime.now();
    final values = _metricValues(metric, granularity);
    final start = switch (granularity) {
      ChartGranularity.day =>
        DateTime(now.year, now.month, now.day, now.hour - values.length + 1),
      ChartGranularity.week => now.subtract(Duration(days: values.length - 1)),
      ChartGranularity.month =>
        DateTime(now.year, now.month, now.day).subtract(Duration(days: values.length - 1)),
    };
    final series = List<Map<String, dynamic>>.generate(values.length, (index) {
      final timestamp = switch (granularity) {
        ChartGranularity.day => start.add(Duration(hours: index)),
        ChartGranularity.week => start.add(Duration(days: index)),
        ChartGranularity.month => start.add(Duration(days: index)),
      };
      return {
        'timestamp': timestamp.toIso8601String(),
        'value': values[index],
      };
    }, growable: false);
    return {'series': series};
  }

  List<double> _metricValues(MetricSeriesType metric, ChartGranularity granularity) {
    return switch ((metric, granularity)) {
      (MetricSeriesType.pvPower, ChartGranularity.day) =>
        [0.0, 0.2, 0.8, 1.7, 2.9, 3.6, 4.1, 3.8, 3.0, 1.8, 0.7, 0.1],
      (MetricSeriesType.pvPower, ChartGranularity.week) =>
        [2.2, 3.4, 2.7, 4.0, 3.6, 2.8, 3.3],
      (MetricSeriesType.pvPower, ChartGranularity.month) =>
        [2.1,2.8,3.5,2.0,4.0,3.8,3.2,2.9,4.1,3.2,2.5,3.0,3.8,4.0,3.1,3.5,2.2,3.3,4.2,3.7,2.9,3.4,3.9,3.1,3.7,4.1,3.5,3.0,2.8,3.2],
      (MetricSeriesType.loadPower, ChartGranularity.day) =>
        [1.4, 1.3, 1.6, 1.9, 1.8, 1.7, 1.6, 1.8, 2.0, 1.7, 1.5, 1.4],
      (MetricSeriesType.loadPower, ChartGranularity.week) =>
        [1.6, 1.9, 1.7, 2.1, 1.8, 1.7, 2.0],
      (MetricSeriesType.loadPower, ChartGranularity.month) =>
        [1.6,1.8,2.0,1.5,1.9,2.1,1.9,1.7,2.0,1.8,1.6,1.8,2.0,1.9,1.7,1.8,1.5,1.9,2.2,2.0,1.7,1.9,2.1,1.8,1.9,2.1,1.9,1.7,1.6,1.8],
      (MetricSeriesType.batterySoc, ChartGranularity.day) =>
        [92.0,88.0,80.0,72.0,68.0,74.0,80.0,84.0,80.0,76.0,72.0,78.0],
      (MetricSeriesType.batterySoc, ChartGranularity.week) =>
        [76.0, 82.0, 68.0, 85.0, 79.0, 73.0, 88.0],
      (MetricSeriesType.batterySoc, ChartGranularity.month) =>
        [80.0,78.0,82.0,68.0,85.0,84.0,79.0,76.0,88.0,82.0,73.0,77.0,83.0,86.0,79.0,81.0,70.0,78.0,90.0,85.0,76.0,80.0,84.0,78.0,82.0,87.0,80.0,75.0,72.0,78.0],
      (MetricSeriesType.todayGeneration, ChartGranularity.day) =>
        [0.0, 0.0, 0.6, 1.4, 2.3, 3.1, 3.8, 3.2, 2.1, 1.0, 0.6, 0.3],
      (MetricSeriesType.todayGeneration, ChartGranularity.week) =>
        [14.2, 18.6, 16.3, 20.1, 17.8, 15.5, 19.2],
      (MetricSeriesType.todayGeneration, ChartGranularity.month) =>
        [15.1,16.3,18.0,14.2,20.1,19.4,17.8,16.5,21.0,18.6,15.9,17.2,19.8,20.3,16.7,18.1,14.5,17.9,22.0,19.1,16.3,18.7,20.5,17.4,19.2,21.1,18.3,16.8,15.6,17.5],
      (MetricSeriesType.todayConsumption, ChartGranularity.day) =>
        [0.9, 1.0, 1.4, 1.7, 2.0, 1.8, 1.6, 1.9, 2.2, 1.7, 1.5, 1.2],
      (MetricSeriesType.todayConsumption, ChartGranularity.week) =>
        [12.1, 14.2, 13.6, 15.9, 14.8, 13.2, 16.1],
      (MetricSeriesType.todayConsumption, ChartGranularity.month) =>
        [13.2,14.1,15.8,12.6,14.9,16.2,15.1,13.8,16.5,14.2,13.5,14.8,16.1,15.3,13.9,14.6,12.8,15.2,17.1,15.8,13.9,15.4,16.8,14.7,15.9,17.2,15.3,14.1,13.2,14.9],
      (MetricSeriesType.totalGeneration, ChartGranularity.day) =>
        [12520,12522,12524,12527,12530,12533,12537,12540,12542,12543,12544,12545],
      (MetricSeriesType.totalGeneration, ChartGranularity.week) =>
        [12725,12744,12761,12781,12800,12818,12840],
      (MetricSeriesType.totalGeneration, ChartGranularity.month) =>
        [12210,12226,12244,12258,12278,12297,12315,12332,12353,12371,12387,12404,12424,12444,12461,12479,12493,12511,12533,12552,12568,12587,12607,12624,12643,12664,12682,12699,12715,12733],
      (MetricSeriesType.totalConsumption, ChartGranularity.day) =>
        [10680,10681,10683,10685,10687,10688,10690,10692,10694,10695,10696,10698],
      (MetricSeriesType.totalConsumption, ChartGranularity.week) =>
        [10824,10838,10852,10868,10883,10896,10912],
      (MetricSeriesType.totalConsumption, ChartGranularity.month) =>
        [10362,10376,10392,10405,10420,10436,10451,10465,10481,10495,10508,10523,10539,10554,10568,10583,10596,10612,10629,10645,10659,10674,10691,10706,10722,10739,10754,10768,10781,10796],
      (MetricSeriesType.generation, ChartGranularity.day) =>
        [0.0, 0.0, 0.6, 1.4, 2.3, 3.1, 3.8, 3.2, 2.1, 1.0, 0.6, 0.3],
      (MetricSeriesType.generation, ChartGranularity.week) =>
        [14.2, 18.6, 16.3, 20.1, 17.8, 15.5, 19.2],
      (MetricSeriesType.generation, ChartGranularity.month) =>
        [15.1,16.3,18.0,14.2,20.1,19.4,17.8,16.5,21.0,18.6,15.9,17.2,19.8,20.3,16.7,18.1,14.5,17.9,22.0,19.1,16.3,18.7,20.5,17.4,19.2,21.1,18.3,16.8,15.6,17.5],
      (MetricSeriesType.consumption, ChartGranularity.day) =>
        [0.9, 1.0, 1.4, 1.7, 2.0, 1.8, 1.6, 1.9, 2.2, 1.7, 1.5, 1.2],
      (MetricSeriesType.consumption, ChartGranularity.week) =>
        [12.1, 14.2, 13.6, 15.9, 14.8, 13.2, 16.1],
      (MetricSeriesType.consumption, ChartGranularity.month) =>
        [13.2,14.1,15.8,12.6,14.9,16.2,15.1,13.8,16.5,14.2,13.5,14.8,16.1,15.3,13.9,14.6,12.8,15.2,17.1,15.8,13.9,15.4,16.8,14.7,15.9,17.2,15.3,14.1,13.2,14.9],
    };
  }

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