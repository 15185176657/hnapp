import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/state_message.dart';

class MetricDetailPage extends StatefulWidget {
  const MetricDetailPage({
    super.key,
    required this.metric,
    required this.title,
    required this.unit,
    required this.color,
    required this.icon,
  });

  final MetricSeriesType metric;
  final String title;
  final String unit;
  final Color color;
  final IconData icon;

  @override
  State<MetricDetailPage> createState() => _MetricDetailPageState();
}

class _MetricDetailPageState extends State<MetricDetailPage> {
  ChartGranularity _granularity = ChartGranularity.day;
  MetricChartData? _data;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final data = await AppScope.of(context).demoRepository.fetchMetricChart(
        widget.metric,
        _granularity,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _setGranularity(ChartGranularity g) {
    if (_granularity == g) return;
    setState(() => _granularity = g);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = _data;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _GranularityToggle(current: _granularity, onChanged: _setGranularity),
            const SizedBox(height: 16),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(l10n.loading),
                  ],
                ),
              )
            else if (_hasError)
              StateMessage(
                icon: Icons.error_outline_rounded,
                title: l10n.errorLoadingData,
                message: widget.title,
                actionLabel: l10n.retry,
                onAction: _load,
              )
            else if (data == null || data.points.isEmpty)
              StateMessage(
                icon: Icons.show_chart_rounded,
                title: l10n.noData,
                message: widget.title,
                actionLabel: l10n.retry,
                onAction: _load,
              )
            else ...[
              _Summary(
                title: widget.title,
                unit: widget.unit,
                icon: widget.icon,
                color: widget.color,
                data: data,
              ),
              const SizedBox(height: 16),
              _MetricLineChart(data: data, unit: widget.unit, color: widget.color),
            ],
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.title,
    required this.unit,
    required this.icon,
    required this.color,
    required this.data,
  });

  final String title;
  final String unit;
  final IconData icon;
  final Color color;
  final MetricChartData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${data.latest.toStringAsFixed(1)} $unit',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.detailPeak}: ${data.peak.toStringAsFixed(1)} $unit · ${l10n.detailAvg}: ${data.average.toStringAsFixed(1)} $unit',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MetricLineChart extends StatelessWidget {
  const _MetricLineChart({
    required this.data,
    required this.unit,
    required this.color,
  });

  final MetricChartData data;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = data.points;
    final labelStep = _labelStep(points.length);
    final maxY = points.map((p) => p.y).fold<double>(1, (m, v) => v > m ? v : m);

    return SectionCard(
      child: SizedBox(
        height: 230,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY * 1.15,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(
                color: theme.colorScheme.outlineVariant.withAlpha(100),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, meta) {
                    if (v == 0 || v == meta.max) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        v.toStringAsFixed(0),
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= points.length || v != v.roundToDouble()) {
                      return const SizedBox.shrink();
                    }
                    if (i % labelStep != 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        points[i].label,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.surface,
                tooltipBorder: BorderSide(color: theme.colorScheme.outlineVariant),
                getTooltipItems: (spots) {
                  return spots
                      .map(
                        (s) => LineTooltipItem(
                          '${s.y.toStringAsFixed(1)} $unit',
                          theme.textTheme.bodySmall!,
                        ),
                      )
                      .toList(growable: false);
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: points.map((p) => FlSpot(p.x, p.y)).toList(growable: false),
                isCurved: true,
                color: color,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: color.withAlpha(36)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _labelStep(int count) {
    if (count <= 12) return 1;
    if (count <= 14) return 2;
    return 5;
  }
}

class _GranularityToggle extends StatelessWidget {
  const _GranularityToggle({required this.current, required this.onChanged});

  final ChartGranularity current;
  final ValueChanged<ChartGranularity> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<ChartGranularity>(
      segments: [
        ButtonSegment(value: ChartGranularity.day, label: Text(l10n.granularityDay)),
        ButtonSegment(value: ChartGranularity.week, label: Text(l10n.granularityWeek)),
        ButtonSegment(value: ChartGranularity.month, label: Text(l10n.granularityMonth)),
      ],
      selected: {current},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
