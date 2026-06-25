import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
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
    return FutureBuilder<List<SolarAlert>>(
      future: AppScope.of(context).demoRepository.fetchAlerts(history: _showHistory),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? const <SolarAlert>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('Alerts', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('Clear actions for low battery, faults and overload.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Current'), icon: Icon(Icons.notifications_active_rounded)),
                ButtonSegment(value: true, label: Text('History'), icon: Icon(Icons.history_rounded)),
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
              const StateMessage(
                icon: Icons.check_circle_rounded,
                title: 'No alerts',
                message: 'The system is running normally. Keep monitoring the battery before night.',
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
    final presentation = _severityPresentation(alert.severity);
    return SectionCard(
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
                label: alert.isResolved ? 'Resolved' : presentation.label,
                icon: alert.isResolved ? Icons.task_alt_rounded : presentation.icon,
                color: alert.isResolved ? AppColors.battery : presentation.color,
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
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Action: ${alert.action}', style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 8),
          Text(_relativeTime(alert.occurredAt), style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

({String label, IconData icon, Color color}) _severityPresentation(AlertSeverity severity) {
  return switch (severity) {
    AlertSeverity.warning => (label: 'Warning', icon: Icons.warning_rounded, color: AppColors.warning),
    AlertSeverity.critical => (label: 'Critical', icon: Icons.report_rounded, color: AppColors.danger),
    AlertSeverity.info => (label: 'Info', icon: Icons.info_rounded, color: AppColors.ocean),
  };
}

String _relativeTime(DateTime time) {
  final difference = DateTime.now().difference(time);
  if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  }
  if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inMinutes}m ago';
}