enum SystemStatus { normal, charging, discharging, lowBattery, fault }

/// Time granularity used on detail chart pages.
enum ChartGranularity { day, week, month }

/// A single (x-index, y-value, label) triple for chart series.
class ChartPoint {
  const ChartPoint({required this.x, required this.y, required this.label});

  /// Horizontal position (0-based index aligned with [label]).
  final double x;
  final double y;

  /// Short axis label, e.g. "08", "Mon", "01".
  final String label;
}

/// Energy (generation + consumption) chart payload for a given granularity.
class EnergyChartData {
  const EnergyChartData({
    required this.granularity,
    required this.generationPoints,
    required this.consumptionPoints,
    required this.totalGenerationKwh,
    required this.totalConsumptionKwh,
    required this.peakGenerationKwh,
    required this.peakConsumptionKwh,
  });

  final ChartGranularity granularity;
  final List<ChartPoint> generationPoints;
  final List<ChartPoint> consumptionPoints;
  final double totalGenerationKwh;
  final double totalConsumptionKwh;
  final double peakGenerationKwh;
  final double peakConsumptionKwh;
}

/// Power flow (PV + load) chart payload for a given granularity.
class PowerChartData {
  const PowerChartData({
    required this.granularity,
    required this.pvPowerPoints,
    required this.loadPowerPoints,
    required this.peakPvKw,
    required this.peakLoadKw,
    required this.avgPvKw,
    required this.avgLoadKw,
  });

  final ChartGranularity granularity;
  final List<ChartPoint> pvPowerPoints;
  final List<ChartPoint> loadPowerPoints;
  final double peakPvKw;
  final double peakLoadKw;
  final double avgPvKw;
  final double avgLoadKw;
}

/// Battery SOC chart payload for a given granularity.
class BatteryChartData {
  const BatteryChartData({
    required this.granularity,
    required this.socPoints,
    required this.currentSoc,
    required this.minSoc,
    required this.maxSoc,
  });

  final ChartGranularity granularity;
  final List<ChartPoint> socPoints;
  final int currentSoc;
  final int minSoc;
  final int maxSoc;
}

enum AlertSeverity { warning, critical, info }

/// Stable identifier for a demo alert so its title/message/action can be
/// localized at display time instead of carrying hardcoded English text.
enum AlertKind { lowBattery, overload, controllerTemperature }

class StationOverview {
  const StationOverview({
    required this.systemName,
    required this.location,
    required this.pvPowerKw,
    required this.loadPowerKw,
    required this.batterySoc,
    required this.remainingHours,
    required this.todayGenerationKwh,
    required this.todayConsumptionKwh,
    required this.status,
    required this.isDeviceOnline,
    required this.lastUpdated,
  });

  final String systemName;
  final String location;
  final double pvPowerKw;
  final double loadPowerKw;
  final int batterySoc;
  final double remainingHours;
  final double todayGenerationKwh;
  final double todayConsumptionKwh;
  final SystemStatus status;
  final bool isDeviceOnline;
  final DateTime lastUpdated;
}

class EnergyStatistics {
  const EnergyStatistics({
    required this.todayGenerationKwh,
    required this.monthGenerationKwh,
    required this.totalGenerationKwh,
    required this.todayConsumptionKwh,
    required this.monthConsumptionKwh,
    required this.totalConsumptionKwh,
    required this.hourlyGeneration,
    required this.hourlyConsumption,
  });

  final double todayGenerationKwh;
  final double monthGenerationKwh;
  final double totalGenerationKwh;
  final double todayConsumptionKwh;
  final double monthConsumptionKwh;
  final double totalConsumptionKwh;
  final List<double> hourlyGeneration;
  final List<double> hourlyConsumption;
}

class SolarAlert {
  const SolarAlert({
    required this.kind,
    required this.severity,
    required this.occurredAt,
    required this.isResolved,
  });

  final AlertKind kind;
  final AlertSeverity severity;
  final DateTime occurredAt;
  final bool isResolved;
}

class DeviceInfo {
  const DeviceInfo({
    required this.serialNumber,
    required this.capacityKw,
    required this.batteryCapacityKwh,
    required this.firmwareVersion,
  });

  final String serialNumber;
  final double capacityKw;
  final double batteryCapacityKwh;
  final String firmwareVersion;
}