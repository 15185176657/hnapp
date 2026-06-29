import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/section_card.dart';

enum EnergyMetric { generation, consumption }

/// 单个电量指标详情页，避免从单一卡片进入后又展示其他数据。
class EnergyDetailPage extends StatefulWidget {
  const EnergyDetailPage({super.key, required this.metric});

  final EnergyMetric metric;

  @override
  State<EnergyDetailPage> createState() => _EnergyDetailPageState();
}

class _EnergyDetailPageState extends State<EnergyDetailPage> {
  ChartGranularity _granularity = ChartGranularity.day;
  EnergyChartData? _data;
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
          .fetchEnergyChart(_granularity);
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
                      TextButton(
                        onPressed: _load,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              )
            else if (_data != null) ...[
              _SummaryRow(data: _data!, metric: widget.metric),
              const SizedBox(height: 16),
              _EnergyBarChart(data: _data!, metric: widget.metric),
              const SizedBox(height: 12),
              _Legend(metric: widget.metric),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 概览指标 ─────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.data, required this.metric});

  final EnergyChartData data;
  final EnergyMetric metric;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spec = _energySpec(l10n, data, metric);
    return _SummaryTile(
      label: spec.label,
      value: spec.total.toStringAsFixed(1),
      unit: 'kWh',
      color: spec.color,
      icon: spec.icon,
      sub: '${l10n.detailPeak} ${spec.peak.toStringAsFixed(1)} kWh',
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

// ── 柱状图 ───────────────────────────────────────────────────────────────────

class _EnergyBarChart extends StatelessWidget {
  const _EnergyBarChart({required this.data, required this.metric});

  final EnergyChartData data;
  final EnergyMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final spec = _energySpec(l10n, data, metric);
    final points = spec.points;

    final maxY = points.map((p) => p.y).fold<double>(1, (m, v) => v > m ? v : m);

    final labelStep = _labelStep(points.length);

    final barGroups = List.generate(points.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: points[i].y,
            color: spec.color,
            width: _barWidth(points.length),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });

    return SectionCard(
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: maxY * 1.15,
            barGroups: barGroups,
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
                        v.toStringAsFixed(0),
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
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
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.surface,
                tooltipBorder: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${spec.label}\n${rod.toY.toStringAsFixed(1)} kWh',
                    theme.textTheme.bodySmall!,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _barWidth(int count) {
    if (count <= 10) return 10;
    if (count <= 14) return 7;
    return 4;
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

  final EnergyMetric metric;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spec = _energySpec(l10n, _emptyEnergyData, metric);
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
  double total,
  double peak,
}) _energySpec(AppLocalizations l10n, EnergyChartData data, EnergyMetric metric) {
  return switch (metric) {
    EnergyMetric.generation => (
        label: l10n.legendGeneration,
        color: AppColors.solar,
        icon: Icons.wb_sunny_rounded,
        points: data.generationPoints,
        total: data.totalGenerationKwh,
        peak: data.peakGenerationKwh,
      ),
    EnergyMetric.consumption => (
        label: l10n.legendConsumption,
        color: AppColors.ocean,
        icon: Icons.power_rounded,
        points: data.consumptionPoints,
        total: data.totalConsumptionKwh,
        peak: data.peakConsumptionKwh,
      ),
  };
}

String _metricLabel(AppLocalizations l10n, EnergyMetric metric) {
  return switch (metric) {
    EnergyMetric.generation => l10n.legendGeneration,
    EnergyMetric.consumption => l10n.legendConsumption,
  };
}

const _emptyEnergyData = EnergyChartData(
  granularity: ChartGranularity.day,
  generationPoints: [],
  consumptionPoints: [],
  totalGenerationKwh: 0,
  totalConsumptionKwh: 0,
  peakGenerationKwh: 0,
  peakConsumptionKwh: 0,
);
