import '../core/demo/demo_models.dart';

/// Supported metric identifiers for `/metrics/{deviceId}/{metric}`.
enum MetricApiMetric {
  pvPower('pv-power'),
  loadPower('load-power'),
  batterySoc('battery-soc'),
  generation('generation'),
  consumption('consumption');

  const MetricApiMetric(this.path);
  final String path;
}

/// Raw API point payload: `{timestamp: ISO8601, value: number}`.
class MetricSeriesPoint {
  const MetricSeriesPoint({required this.timestamp, required this.value});

  final DateTime timestamp;
  final double value;
}

/// API response payload model: `{series: [...]}`.
class MetricSeriesResponse {
  const MetricSeriesResponse({required this.series});

  final List<MetricSeriesPoint> series;
}

/// Adapter for mapping API payloads to strongly typed chart points.
abstract final class MetricApiAdapter {
  static MetricSeriesResponse fromPayload(Map<String, dynamic> payload) {
    final rawSeries = payload['series'];
    if (rawSeries is! List) {
      return const MetricSeriesResponse(series: []);
    }
    final series = rawSeries.whereType<Map<String, dynamic>>().map((item) {
      final timestampRaw = item['timestamp']?.toString();
      final parsed = timestampRaw == null ? null : DateTime.tryParse(timestampRaw);
      final value = (item['value'] as num?)?.toDouble();
      if (parsed == null || value == null) {
        return null;
      }
      return MetricSeriesPoint(timestamp: parsed, value: value);
    }).whereType<MetricSeriesPoint>().toList(growable: false);
    return MetricSeriesResponse(series: series);
  }

  static List<ChartPoint> toChartPoints(
    MetricSeriesResponse response,
    ChartGranularity granularity,
  ) {
    return List<ChartPoint>.generate(response.series.length, (index) {
      final point = response.series[index];
      return ChartPoint(
        x: index.toDouble(),
        y: point.value,
        label: _label(point.timestamp, granularity),
      );
    }, growable: false);
  }

  static String _label(DateTime time, ChartGranularity granularity) {
    return switch (granularity) {
      ChartGranularity.day => time.hour.toString().padLeft(2, '0'),
      ChartGranularity.week => _weekday(time.weekday),
      ChartGranularity.month => time.day.toString(),
    };
  }

  static String _weekday(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      DateTime.sunday => 'Sun',
      _ => '',
    };
  }
}
