import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/demo/demo_repository.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/simple_bar_chart.dart';
import '../../shared/widgets/state_message.dart';
import '../detail/energy_detail_page.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  EnergyStatistics? _statistics;
  bool _isLoading = true;
  bool _showWeakNetwork = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statistics == null) {
      _loadStatistics();
    }
  }

  Future<void> _loadStatistics() async {
    final repository = AppScope.of(context).demoRepository;
    setState(() {
      _isLoading = true;
      _showWeakNetwork = false;
    });
    try {
      final statistics = await repository.fetchStatistics();
      if (!mounted) {
        return;
      }
      setState(() {
        _statistics = statistics;
        _isLoading = false;
      });
    } on DemoRefreshException {
      if (!mounted) {
        return;
      }
      setState(() {
        _statistics = repository.cachedStatistics ?? _statistics;
        _isLoading = false;
        _showWeakNetwork = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statistics = _statistics;
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(l10n.dataTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            l10n.dataSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_isLoading && statistics == null)
            const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ))
          else if (statistics != null) ...[
            if (_showWeakNetwork) ...[
              StateMessage(
                icon: Icons.wifi_off_rounded,
                title: l10n.savedDataTitle,
                message: l10n.savedDataMessage,
                actionLabel: l10n.retry,
                onAction: _loadStatistics,
              ),
              const SizedBox(height: 12),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 390;
                return GridView.count(
                  crossAxisCount: isNarrow ? 1 : 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isNarrow ? 2.25 : 1.12,
                  children: [
                    MetricCard(
                      label: l10n.metricTodayGenerated,
                      value: statistics.todayGenerationKwh.toStringAsFixed(1),
                      unit: 'kWh',
                      icon: Icons.wb_sunny_rounded,
                      color: AppColors.solar,
                      caption: l10n.monthCaption(statistics.monthGenerationKwh.toStringAsFixed(0)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EnergyDetailPage(metric: EnergyMetric.generation),
                        ),
                      ),
                    ),
                    MetricCard(
                      label: l10n.metricTodayUsed,
                      value: statistics.todayConsumptionKwh.toStringAsFixed(1),
                      unit: 'kWh',
                      icon: Icons.power_rounded,
                      color: AppColors.ocean,
                      caption: l10n.monthCaption(statistics.monthConsumptionKwh.toStringAsFixed(0)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EnergyDetailPage(metric: EnergyMetric.consumption),
                        ),
                      ),
                    ),
                    MetricCard(
                      label: l10n.metricTotalGenerated,
                      value: statistics.totalGenerationKwh.toStringAsFixed(0),
                      unit: 'kWh',
                      icon: Icons.auto_graph_rounded,
                      color: AppColors.battery,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EnergyDetailPage(metric: EnergyMetric.generation),
                        ),
                      ),
                    ),
                    MetricCard(
                      label: l10n.metricTotalUsed,
                      value: statistics.totalConsumptionKwh.toStringAsFixed(0),
                      unit: 'kWh',
                      icon: Icons.insights_rounded,
                      color: AppColors.warning,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EnergyDetailPage(metric: EnergyMetric.consumption),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EnergyDetailPage(metric: EnergyMetric.generation),
                ),
              ),
              borderRadius: BorderRadius.circular(16),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.todayTrend, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(l10n.todayTrendSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SimpleBarChart(
                      primaryValues: statistics.hourlyGeneration,
                      secondaryValues: statistics.hourlyConsumption,
                      labels: _hourLabels(statistics.hourlyGeneration.length),
                    ),
                    const SizedBox(height: 12),
                    const _Legend(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Builds evenly spaced hour-of-day markers for the daily trend chart so each
/// bar group can be tied back to a time. The demo dataset spans roughly the
/// daylight window, sampled every two hours.
List<String> _hourLabels(int count) {
  return List<String>.generate(count, (index) {
    final hour = (6 + index * 2) % 24;
    return hour.toString();
  });
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(color: AppColors.solar, label: l10n.legendGeneration),
        _LegendItem(color: AppColors.ocean, label: l10n.legendConsumption),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

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
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
