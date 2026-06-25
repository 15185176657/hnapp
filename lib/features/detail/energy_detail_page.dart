import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/demo/demo_repository.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/section_card.dart';

/// Detail page showing a single energy metric (generation or consumption) as a
/// bar chart with Day/Week/Month granularity tabs.
class EnergyDetailPage extends StatefulWidget {
  const EnergyDetailPage({super.key, this.metric = EnergyMetric.generation});

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
    final title = widget.metric == EnergyMetric.generation
        ? l10n.detailGenerationTitle
        : l10n.detailConsumptionTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
              _SummaryTile(data: _data!, metric: widget.metric),
              const SizedBox(height: 16),
              _EnergyBarChart(data: _data!, metric: widget.metric),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Summary metrics ─────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.data, required this.metric});
  final EnergyChartData data;
  final EnergyMetric metric;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isGen = metric == EnergyMetric.generation;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGen ? Icons.wb_sunny_rounded : Icons.power_rounded,
                color: isGen ? AppColors.solar : AppColors.ocean,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isGen ? l10n.legendGeneration : l10n.legendConsumption,
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
                TextSpan(
                  text: isGen
                      ? data.totalGenerationKwh.toStringAsFixed(1)
                      : data.totalConsumptionKwh.toStringAsFixed(1),
                ),
                TextSpan(
                  text: ' kWh',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.detailPeak} ${isGen ? data.peakGenerationKwh.toStringAsFixed(1) : data.peakConsumptionKwh.toStringAsFixed(1)} kWh',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── Bar chart ────────────────────────────────────────────────────────────────

class _EnergyBarChart extends StatelessWidget {
  const _EnergyBarChart({required this.data, required this.metric});
  final EnergyChartData data;
  final EnergyMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGen = metric == EnergyMetric.generation;
    final points = isGen ? data.generationPoints : data.consumptionPoints;
    final color = isGen ? AppColors.solar : AppColors.ocean;

    final maxY = points
        .map((p) => p.y)
        .fold<double>(1, (m, v) => v > m ? v : m);

    final labelStep = _labelStep(points.length);

    final barGroups = List.generate(points.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: points[i].y,
            color: color,
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
                  final label = isGen
                      ? AppLocalizations.of(context).legendGeneration
                      : AppLocalizations.of(context).legendConsumption;
                  return BarTooltipItem(
                    '$label\n${rod.toY.toStringAsFixed(1)} kWh',
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

// ── Granularity toggle ───────────────────────────────────────────────────────

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
