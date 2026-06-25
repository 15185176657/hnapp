import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/state_message.dart';
import '../../shared/widgets/status_pill.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<List<SolarAlert>>(
      future: AppScope.of(context).demoRepository.fetchAlerts(history: _showHistory),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? const <SolarAlert>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(l10n.alertsTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(l10n.alertsSubtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.segmentCurrent), icon: const Icon(Icons.notifications_active_rounded)),
                ButtonSegment(value: true, label: Text(l10n.segmentHistory), icon: const Icon(Icons.history_rounded)),
              ],
              selected: {_showHistory},
              onSelectionChanged: (selection) => setState(() => _showHistory = selection.first),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState != ConnectionState.done)
              const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ))
            else if (alerts.isEmpty)
              StateMessage(
                icon: Icons.check_circle_rounded,
                title: l10n.noAlertsTitle,
                message: l10n.noAlertsMessage,
              )
            else
              ...alerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AlertCard(alert: alert),
              )),
          ],
        );
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final SolarAlert alert;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final presentation = _severityPresentation(l10n, alert.severity);
    final accent = alert.isResolved ? AppColors.battery : presentation.color;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: SectionCard(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                key: const Key('alertAccentBar'),
                width: 4,
                color: accent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(alert.title, style: Theme.of(context).textTheme.titleMedium),
                          ),
                          StatusPill(
                            label: alert.isResolved ? l10n.resolved : presentation.label,
                            icon: alert.isResolved ? Icons.task_alt_rounded : presentation.icon,
                            color: accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(alert.message, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(l10n.actionPrefix(alert.action), style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      const SizedBox(height: 8),
                      Text(_relativeTime(l10n, alert.occurredAt), style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

({String label, IconData icon, Color color}) _severityPresentation(
  AppLocalizations l10n,
  AlertSeverity severity,
) {
  return switch (severity) {
    AlertSeverity.warning => (label: l10n.severityWarning, icon: Icons.warning_rounded, color: AppColors.warning),
    AlertSeverity.critical => (label: l10n.severityCritical, icon: Icons.report_rounded, color: AppColors.danger),
    AlertSeverity.info => (label: l10n.severityInfo, icon: Icons.info_rounded, color: AppColors.ocean),
  };
}

String _relativeTime(AppLocalizations l10n, DateTime time) {
  final difference = DateTime.now().difference(time);
  if (difference.inDays > 0) {
    return l10n.daysAgo(difference.inDays);
  }
  if (difference.inHours > 0) {
    return l10n.hoursAgo(difference.inHours);
  }
  return l10n.minutesAgo(difference.inMinutes);
}
