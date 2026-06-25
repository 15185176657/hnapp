import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/demo/demo_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/state_message.dart';
import '../../shared/widgets/status_pill.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  StationOverview? _overview;
  bool _isLoading = true;
  bool _showWeakNetwork = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_overview == null) {
      _loadOverview();
    }
  }

  Future<void> _loadOverview() async {
    final repository = AppScope.of(context).demoRepository;
    setState(() {
      _isLoading = true;
      _showWeakNetwork = false;
    });
    try {
      final overview = await repository.fetchOverview();
      if (!mounted) {
        return;
      }
      setState(() {
        _overview = overview;
        _isLoading = false;
      });
    } on DemoRefreshException {
      if (!mounted) {
        return;
      }
      setState(() {
        _overview = repository.cachedOverview ?? _overview;
        _isLoading = false;
        _showWeakNetwork = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview;
    return RefreshIndicator(
      onRefresh: _loadOverview,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Header(
            selectedScenario: AppScope.of(context).demoRepository.scenario,
            onScenarioChanged: (scenario) {
              AppScope.of(context).demoRepository.setScenario(scenario);
              _loadOverview();
            },
          ),
          const SizedBox(height: 16),
          if (_isLoading && overview == null)
            const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ))
          else if (overview != null) ...[
            if (_showWeakNetwork) ...[
              StateMessage(
                icon: Icons.wifi_off_rounded,
                title: 'Weak network',
                message: 'Showing the latest successful data. Pull down to retry.',
                actionLabel: 'Retry',
                onAction: _loadOverview,
              ),
              const SizedBox(height: 12),
            ],
            _StatusSummary(overview: overview),
            const SizedBox(height: 12),
            _MetricsGrid(overview: overview),
            const SizedBox(height: 12),
            SectionCard(
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Last updated ${_formatTime(overview.lastUpdated)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loadOverview,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.selectedScenario, required this.onScenarioChanged});

  final DemoScenario selectedScenario;
  final ValueChanged<DemoScenario> onScenarioChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Off-grid solar', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Clear power, battery and alert status for daily decisions.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<DemoScenario>(
          initialValue: selectedScenario,
          decoration: const InputDecoration(
            labelText: 'Demo scenario',
            border: OutlineInputBorder(),
          ),
          items: DemoScenario.values.map((scenario) {
            return DropdownMenuItem(
              value: scenario,
              child: Text(_scenarioLabel(scenario)),
            );
          }).toList(),
          onChanged: (scenario) {
            if (scenario != null) {
              onScenarioChanged(scenario);
            }
          },
        ),
      ],
    );
  }
}

class _StatusSummary extends StatelessWidget {
  const _StatusSummary({required this.overview});

  final StationOverview overview;

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(overview.status, overview.isDeviceOnline);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(overview.systemName, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(overview.location, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              StatusPill(label: status.label, icon: status.icon, color: status.color),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            overview.isDeviceOnline
                ? 'System can supply power for about ${overview.remainingHours.toStringAsFixed(1)} hours at the current load.'
                : 'Device is offline. Check the gateway power and signal.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.overview});

  final StationOverview overview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 390;
        final cards = [
          MetricCard(
            label: 'PV power',
            value: overview.pvPowerKw.toStringAsFixed(1),
            unit: 'kW',
            icon: Icons.wb_sunny_rounded,
            color: AppColors.solar,
            caption: 'Current solar output',
          ),
          MetricCard(
            label: 'Load power',
            value: overview.loadPowerKw.toStringAsFixed(1),
            unit: 'kW',
            icon: Icons.home_work_rounded,
            color: AppColors.ocean,
            caption: 'Current home demand',
          ),
          MetricCard(
            label: 'Battery SOC',
            value: overview.batterySoc.toString(),
            unit: '%',
            icon: Icons.battery_charging_full_rounded,
            color: overview.batterySoc < 30 ? AppColors.warning : AppColors.battery,
            caption: 'Remaining battery level',
          ),
          MetricCard(
            label: 'Today generated',
            value: overview.todayGenerationKwh.toStringAsFixed(1),
            unit: 'kWh',
            icon: Icons.bolt_rounded,
            color: AppColors.battery,
            caption: 'Used ${overview.todayConsumptionKwh.toStringAsFixed(1)} kWh today',
          ),
        ];

        return GridView.count(
          crossAxisCount: isNarrow ? 1 : 2,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isNarrow ? 2.15 : 1.08,
          children: cards,
        );
      },
    );
  }
}

({String label, IconData icon, Color color}) _statusPresentation(
  SystemStatus status,
  bool online,
) {
  if (!online) {
    return (label: 'Offline', icon: Icons.cloud_off_rounded, color: AppColors.danger);
  }
  return switch (status) {
    SystemStatus.normal => (label: 'Normal', icon: Icons.check_circle_rounded, color: AppColors.battery),
    SystemStatus.charging => (label: 'Charging', icon: Icons.battery_charging_full_rounded, color: AppColors.battery),
    SystemStatus.discharging => (label: 'Discharging', icon: Icons.electric_bolt_rounded, color: AppColors.ocean),
    SystemStatus.lowBattery => (label: 'Low battery', icon: Icons.battery_alert_rounded, color: AppColors.warning),
    SystemStatus.fault => (label: 'Action needed', icon: Icons.report_rounded, color: AppColors.danger),
  };
}

String _scenarioLabel(DemoScenario scenario) {
  return switch (scenario) {
    DemoScenario.normal => 'Normal operation',
    DemoScenario.lowBattery => 'Low battery',
    DemoScenario.offline => 'Device offline',
    DemoScenario.overload => 'Overload alert',
    DemoScenario.refreshFailed => 'Weak network',
  };
}

String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}