import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/demo/demo_repository.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/state_message.dart';
import '../../shared/widgets/status_pill.dart';
import '../detail/metric_detail_page.dart';

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
    final l10n = AppLocalizations.of(context);
    final overview = _overview;
    return RefreshIndicator(
      onRefresh: _loadOverview,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                title: l10n.weakNetworkTitle,
                message: l10n.weakNetworkMessage,
                actionLabel: l10n.retry,
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
                  Icon(
                    Icons.schedule_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.lastUpdated(_formatTime(overview.lastUpdated)),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loadOverview,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.refresh),
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dashboardTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          l10n.dashboardSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        // The demo scenario switcher is a development-only aid and must not be
        // visible in release builds.
        if (kDebugMode) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<DemoScenario>(
            initialValue: selectedScenario,
            decoration: InputDecoration(
              labelText: l10n.demoScenario,
              border: const OutlineInputBorder(),
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
      ],
    );
  }
}

class _StatusSummary extends StatelessWidget {
  const _StatusSummary({required this.overview});

  final StationOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = _statusPresentation(l10n, overview.status, overview.isDeviceOnline);
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
          _BatteryBar(soc: overview.batterySoc),
          const SizedBox(height: 16),
          Text(
            overview.isDeviceOnline
                ? l10n.remainingHours(overview.remainingHours.toStringAsFixed(1))
                : l10n.deviceOfflineHint,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _BatteryBar extends StatelessWidget {
  const _BatteryBar({required this.soc});

  final int soc;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = soc < 15
        ? AppColors.danger
        : (soc < 30 ? AppColors.warning : AppColors.battery);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.battery_charging_full_rounded, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.metricBatterySoc,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              '$soc%',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (soc / 100).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.overview});

  final StationOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 390;
        final cards = [
          MetricCard(
            label: l10n.metricPvPower,
            value: overview.pvPowerKw.toStringAsFixed(1),
            unit: 'kW',
            icon: Icons.wb_sunny_rounded,
            color: AppColors.solar,
            caption: l10n.metricPvPowerCaption,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MetricDetailPage(
                  metric: MetricSeriesType.pvPower,
                  title: l10n.metricPvPower,
                  unit: 'kW',
                  color: AppColors.solar,
                  icon: Icons.wb_sunny_rounded,
                ),
              ),
            ),
          ),
          MetricCard(
            label: l10n.metricLoadPower,
            value: overview.loadPowerKw.toStringAsFixed(1),
            unit: 'kW',
            icon: Icons.home_work_rounded,
            color: AppColors.ocean,
            caption: l10n.metricLoadPowerCaption,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MetricDetailPage(
                  metric: MetricSeriesType.loadPower,
                  title: l10n.metricLoadPower,
                  unit: 'kW',
                  color: AppColors.ocean,
                  icon: Icons.home_work_rounded,
                ),
              ),
            ),
          ),
          MetricCard(
            label: l10n.metricBatterySoc,
            value: overview.batterySoc.toString(),
            unit: '%',
            icon: Icons.battery_charging_full_rounded,
            color: overview.batterySoc < 30 ? AppColors.warning : AppColors.battery,
            caption: l10n.metricBatterySocCaption,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MetricDetailPage(
                  metric: MetricSeriesType.batterySoc,
                  title: l10n.metricBatterySoc,
                  unit: '%',
                  color: overview.batterySoc < 30 ? AppColors.warning : AppColors.battery,
                  icon: Icons.battery_charging_full_rounded,
                ),
              ),
            ),
          ),
          MetricCard(
            label: l10n.metricTodayGenerated,
            value: overview.todayGenerationKwh.toStringAsFixed(1),
            unit: 'kWh',
            icon: Icons.bolt_rounded,
            color: AppColors.battery,
            caption: l10n.todayUsedCaption(overview.todayConsumptionKwh.toStringAsFixed(1)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MetricDetailPage(
                  metric: MetricSeriesType.generation,
                  title: l10n.metricTodayGenerated,
                  unit: 'kWh',
                  color: AppColors.battery,
                  icon: Icons.bolt_rounded,
                ),
              ),
            ),
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
  AppLocalizations l10n,
  SystemStatus status,
  bool online,
) {
  if (!online) {
    return (label: l10n.statusOffline, icon: Icons.cloud_off_rounded, color: AppColors.danger);
  }
  return switch (status) {
    SystemStatus.normal => (label: l10n.statusNormal, icon: Icons.check_circle_rounded, color: AppColors.battery),
    SystemStatus.charging => (label: l10n.statusCharging, icon: Icons.battery_charging_full_rounded, color: AppColors.battery),
    SystemStatus.discharging => (label: l10n.statusDischarging, icon: Icons.electric_bolt_rounded, color: AppColors.ocean),
    SystemStatus.lowBattery => (label: l10n.statusLowBattery, icon: Icons.battery_alert_rounded, color: AppColors.warning),
    SystemStatus.fault => (label: l10n.statusActionNeeded, icon: Icons.report_rounded, color: AppColors.danger),
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
