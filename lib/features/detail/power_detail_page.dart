import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/section_card.dart';

enum PowerMetric { pv, load }

/// 单个功率指标详情页，按来源只展示一条趋势线。
class PowerDetailPage extends StatefulWidget {
  const PowerDetailPage({super.key, required this.metric});

  final PowerMetric metric;

  @override
  State<PowerDetailPage> createState() => _PowerDetailPageState();
}

class _PowerDetailPageState extends State<PowerDetailPage> {
  ChartGranularity _granularity = ChartGranularity.day;
  PowerChartData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AppScope.of(context)
          .demoRepository
          .fetchPowerChart(_granularity);
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
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
    return Scaffold(
      appBar: AppBar(title: Text(_metricLabel(l10n, widget.metric))),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _GranularityToggle(
              current: _granularity,
              onChanged: _setGranularity,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48),
                      const SizedBox(height: 12),
                      Text(l10n.errorLoadingData),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _load, child: Text(l10n.retry)),
                    ],
                  ),
                ),
              )
            else if (_data != null) ...[
              _SummaryRow(data: _data!, metric: widget.metric),
              const SizedBox(height: 16),
              _PowerLineChart(data: _data!, metric: widget.metric),
              const SizedBox(height: 12),
              _Legend(metric: widget.metric),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 概览 ─────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.data, required this.metric});

  final PowerChartData data;
  final PowerMetric metric;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spec = _powerSpec(l10n, data, metric);
    return _SummaryTile(
      label: spec.label,
      value: spec.avg.toStringAsFixed(1),
      unit: 'kW',
      color: spec.color,
      icon: spec.icon,
      sub: '${l10n.detailPeak} ${spec.peak.toStringAsFixed(1)} kW',
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.sub,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final String sub;

  @override
  Widget build(BuildContext context) {
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
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleLarge,
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: ' $unit',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ── 折线图 ───────────────────────────────────────────────────────────────────

class _PowerLineChart extends StatelessWidget {
  const _PowerLineChart({required this.data, required this.metric});

  final PowerChartData data;
  final PowerMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final spec = _powerSpec(l10n, data, metric);
    final points = spec.points;

    final maxY = points.map((p) => p.y).fold<double>(1, (m, v) => v > m ? v : m);

    final labelStep = _labelStep(points.length);

    FlSpot toSpot(ChartPoint p) => FlSpot(p.x, p.y);

    return SectionCard(
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            maxY: maxY * 1.15,
            minY: 0,
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
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, meta) {
                    if (v == 0 || v == meta.max) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        v.toStringAsFixed(1),
                        style:
                            theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                        textAlign: TextAlign.right,
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
                    if (i < 0 || i >= points.length) {
                      return const SizedBox.shrink();
                    }
                    if (v != v.roundToDouble()) return const SizedBox.shrink();
                    if (i % labelStep != 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        points[i].label,
                        style:
                            theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.surface,
                tooltipBorder:
                    BorderSide(color: theme.colorScheme.outlineVariant),
                getTooltipItems: (spots) => spots.map((s) {
                  return LineTooltipItem(
                    '${spec.label}\n${s.y.toStringAsFixed(2)} kW',
                    theme.textTheme.bodySmall!,
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: points.map(toSpot).toList(),
                isCurved: true,
                color: spec.color,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: spec.color.withAlpha(30),
                ),
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

// ── 时间粒度切换 ─────────────────────────────────────────────────────────────

class _GranularityToggle extends StatelessWidget {
  const _GranularityToggle({required this.current, required this.onChanged});
  final ChartGranularity current;
  final ValueChanged<ChartGranularity> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<ChartGranularity>(
      segments: [
        ButtonSegment(
          value: ChartGranularity.day,
          label: Text(l10n.granularityDay),
        ),
        ButtonSegment(
          value: ChartGranularity.week,
          label: Text(l10n.granularityWeek),
        ),
        ButtonSegment(
          value: ChartGranularity.month,
          label: Text(l10n.granularityMonth),
        ),
      ],
      selected: {current},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

// ── 图例 ─────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend({required this.metric});

  final PowerMetric metric;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spec = _powerSpec(l10n, _emptyPowerData, metric);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendDot(color: spec.color, label: spec.label),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

({
  String label,
  Color color,
  IconData icon,
  List<ChartPoint> points,
  double avg,
  double peak,
}) _powerSpec(AppLocalizations l10n, PowerChartData data, PowerMetric metric) {
  return switch (metric) {
    PowerMetric.pv => (
        label: l10n.metricPvPower,
        color: AppColors.solar,
        icon: Icons.wb_sunny_rounded,
        points: data.pvPowerPoints,
        avg: data.avgPvKw,
        peak: data.peakPvKw,
      ),
    PowerMetric.load => (
        label: l10n.metricLoadPower,
        color: AppColors.ocean,
        icon: Icons.home_work_rounded,
        points: data.loadPowerPoints,
        avg: data.avgLoadKw,
        peak: data.peakLoadKw,
      ),
  };
}

String _metricLabel(AppLocalizations l10n, PowerMetric metric) {
  return switch (metric) {
    PowerMetric.pv => l10n.metricPvPower,
    PowerMetric.load => l10n.metricLoadPower,
  };
}

const _emptyPowerData = PowerChartData(
  granularity: ChartGranularity.day,
  pvPowerPoints: [],
  loadPowerPoints: [],
  peakPvKw: 0,
  peakLoadKw: 0,
  avgPvKw: 0,
  avgLoadKw: 0,
);
