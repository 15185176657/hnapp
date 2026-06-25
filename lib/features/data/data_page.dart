import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/demo/demo_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/simple_bar_chart.dart';
import '../../shared/widgets/state_message.dart';

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
    final statistics = _statistics;
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Energy data', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Generation and consumption trends for daily energy planning.',
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
                title: 'Latest saved data',
                message: 'The app kept your previous chart because the refresh failed.',
                actionLabel: 'Retry',
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
                      label: 'Today generated',
                      value: statistics.todayGenerationKwh.toStringAsFixed(1),
                      unit: 'kWh',
                      icon: Icons.wb_sunny_rounded,
                      color: AppColors.solar,
                      caption: 'Month ${statistics.monthGenerationKwh.toStringAsFixed(0)} kWh',
                    ),
                    MetricCard(
                      label: 'Today used',
                      value: statistics.todayConsumptionKwh.toStringAsFixed(1),
                      unit: 'kWh',
                      icon: Icons.power_rounded,
                      color: AppColors.ocean,
                      caption: 'Month ${statistics.monthConsumptionKwh.toStringAsFixed(0)} kWh',
                    ),
                    MetricCard(
                      label: 'Total generated',
                      value: statistics.totalGenerationKwh.toStringAsFixed(0),
                      unit: 'kWh',
                      icon: Icons.auto_graph_rounded,
                      color: AppColors.battery,
                    ),
                    MetricCard(
                      label: 'Total used',
                      value: statistics.totalConsumptionKwh.toStringAsFixed(0),
                      unit: 'kWh',
                      icon: Icons.insights_rounded,
                      color: AppColors.warning,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today trend', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Solar generation vs. home consumption', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  SimpleBarChart(
                    primaryValues: statistics.hourlyGeneration,
                    secondaryValues: statistics.hourlyConsumption,
                  ),
                  const SizedBox(height: 12),
                  const _Legend(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _LegendItem(color: AppColors.solar, label: 'Generation'),
        _LegendItem(color: AppColors.ocean, label: 'Consumption'),
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