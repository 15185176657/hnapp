enum SystemStatus { normal, charging, discharging, lowBattery, fault }

enum AlertSeverity { warning, critical, info }

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
    required this.title,
    required this.message,
    required this.action,
    required this.severity,
    required this.occurredAt,
    required this.isResolved,
  });

  final String title;
  final String message;
  final String action;
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