import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/demo/demo_repository.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/section_card.dart';

/// Detail page showing battery SOC as a line chart with Day/Week/Month tabs.
class BatteryDetailPage extends StatefulWidget {
  const BatteryDetailPage({super.key});

  @override
  State<BatteryDetailPage> createState() => _BatteryDetailPageState();
}

class _BatteryDetailPageState extends State<BatteryDetailPage> {
  ChartGranularity _granularity = ChartGranularity.day;
  BatteryChartData? _data;
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
          .fetchBatteryChart(_granularity);
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
      appBar: AppBar(title: Text(l10n.detailBatteryTitle)),
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
              _SummaryRow(data: _data!),
              const SizedBox(height: 16),
              _BatterySocChart(data: _data!),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Summary ──────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.data});
  final BatteryChartData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = data.currentSoc < 30 ? AppColors.warning : AppColors.battery;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: l10n.metricBatterySoc,
            value: '${data.currentSoc}%',
            color: color,
            icon: Icons.battery_charging_full_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: l10n.detailBatteryRange,
            value: '${data.minSoc}% – ${data.maxSoc}%',
            color: AppColors.battery,
            icon: Icons.show_chart_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Line chart ───────────────────────────────────────────────────────────────

class _BatterySocChart extends StatelessWidget {
  const _BatterySocChart({required this.data});
  final BatteryChartData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = data.socPoints;
    final labelStep = _labelStep(points.length);

    FlSpot toSpot(ChartPoint p) => FlSpot(p.x, p.y);

    // Draw a red reference line at 20 % to visualise the low-battery threshold.
    const lowThreshold = 20.0;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                maxY: 110,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) {
                    if (v == lowThreshold) {
                      return FlLine(
                        color: AppColors.danger.withAlpha(180),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      );
                    }
                    return FlLine(
                      color: theme.colorScheme.outlineVariant.withAlpha(100),
                      strokeWidth: 1,
                    );
                  },
                  checkToShowHorizontalLine: (v) =>
                      v == lowThreshold ||
                      v == 0 ||
                      v == 50 ||
                      v == 100,
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
                      interval: 25,
                      getTitlesWidget: (v, meta) {
                        if (v > 100) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '${v.toInt()}%',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 10),
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
                        if (v != v.roundToDouble()) {
                          return const SizedBox.shrink();
                        }
                        if (i % labelStep != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            points[i].label,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => theme.colorScheme.surface,
                    tooltipBorder: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${s.y.toStringAsFixed(0)}%',
                        theme.textTheme.bodySmall!,
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: points.map(toSpot).toList(),
                    isCurved: true,
                    color: AppColors.battery,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.battery.withAlpha(35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.danger.withAlpha(180),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).detailBatteryLowThreshold,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
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
