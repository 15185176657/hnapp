import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/setting_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _language = 'English';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return FutureBuilder<DeviceInfo>(
      future: scope.demoRepository.fetchDeviceInfo(),
      builder: (context, snapshot) {
        final device = snapshot.data;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('My system', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('Account, device, language and alert preferences.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                children: [
                  SettingTile(
                    icon: Icons.account_circle_rounded,
                    title: scope.authSession.isSignedIn ? 'Demo account signed in' : 'Not signed in',
                    subtitle: 'Phone/email OTP placeholder for demo',
                    trailing: FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          scope.authSession.isSignedIn
                              ? scope.authSession.signOut()
                              : scope.authSession.signInWithDemoToken();
                        });
                      },
                      child: Text(scope.authSession.isSignedIn ? 'Sign out' : 'Sign in'),
                    ),
                  ),
                  const Divider(),
                  SettingTile(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Bind device',
                    subtitle: device == null ? 'Scan QR code or enter SN' : 'SN ${device.serialNumber}',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showSnack(context, 'Device binding flow is reserved for API integration.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (device != null)
              SectionCard(
                child: Column(
                  children: [
                    _InfoRow(label: 'PV capacity', value: '${device.capacityKw.toStringAsFixed(1)} kW'),
                    _InfoRow(label: 'Battery capacity', value: '${device.batteryCapacityKwh.toStringAsFixed(1)} kWh'),
                    _InfoRow(label: 'Firmware', value: device.firmwareVersion),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                children: [
                  SettingTile(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    subtitle: _language,
                    trailing: DropdownButton<String>(
                      value: _language,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'English', child: Text('English')),
                        DropdownMenuItem(value: 'Thai', child: Text('Thai')),
                        DropdownMenuItem(value: 'Vietnamese', child: Text('Vietnamese')),
                        DropdownMenuItem(value: 'Indonesian', child: Text('Indonesian')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _language = value);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  SettingTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Alert notifications',
                    subtitle: 'Low battery, faults and overload',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) => setState(() => _notificationsEnabled = value),
                    ),
                  ),
                  const Divider(),
                  SettingTile(
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy and user agreement',
                    subtitle: 'Reserved page for launch preparation',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showSnack(context, 'Agreement page placeholder.'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}