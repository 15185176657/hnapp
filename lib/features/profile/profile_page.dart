import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/demo/demo_models.dart';
import '../../core/i18n/app_localizations.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/setting_tile.dart';

/// 下拉框里的哨兵值，表示“跟随系统语言”。
const String _systemLanguageValue = 'system';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<DeviceInfo>(
      future: scope.demoRepository.fetchDeviceInfo(),
      builder: (context, snapshot) {
        final device = snapshot.data;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              l10n.profileTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.profileSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                children: [
                  SettingTile(
                    icon: Icons.account_circle_rounded,
                    title: scope.authSession.isSignedIn
                        ? l10n.accountSignedIn
                        : l10n.accountNotSignedIn,
                    subtitle: l10n.otpPlaceholder,
                    trailing: FilledButton.tonal(
                      onPressed: () {
                        scope.authSession.signOut();
                      },
                      child: Text(l10n.signOut),
                    ),
                  ),
                  const Divider(),
                  SettingTile(
                    icon: Icons.qr_code_scanner_rounded,
                    title: l10n.bindDevice,
                    subtitle: device == null
                        ? l10n.bindDeviceHintEmpty
                        : l10n.bindDeviceHintSerial(device.serialNumber),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showSnack(context, l10n.bindingReserved),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (device != null)
              SectionCard(
                child: Column(
                  children: [
                    _InfoRow(
                      label: l10n.pvCapacity,
                      value: '${device.capacityKw.toStringAsFixed(1)} kW',
                    ),
                    _InfoRow(
                      label: l10n.batteryCapacity,
                      value:
                          '${device.batteryCapacityKwh.toStringAsFixed(1)} kWh',
                    ),
                    _InfoRow(
                      label: l10n.firmware,
                      value: device.firmwareVersion,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                children: [
                  SettingTile(
                    icon: Icons.language_rounded,
                    title: l10n.language,
                    subtitle: _languageSubtitle(l10n, scope),
                    trailing: _LanguageDropdown(),
                  ),
                  const Divider(),
                  SettingTile(
                    icon: Icons.notifications_active_rounded,
                    title: l10n.alertNotifications,
                    subtitle: l10n.alertNotificationsSubtitle,
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                    ),
                  ),
                  const Divider(),
                  SettingTile(
                    icon: Icons.privacy_tip_rounded,
                    title: l10n.privacyTitle,
                    subtitle: l10n.privacySubtitle,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showSnack(context, l10n.privacyPlaceholder),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _languageSubtitle(AppLocalizations l10n, AppScope scope) {
    final locale = scope.localeController.locale;
    if (locale == null) {
      return l10n.languageSystemDefault;
    }
    return AppLocalizations.nativeName(locale.languageCode);
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LanguageDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = scope.localeController;
    final currentValue =
        controller.locale?.languageCode ?? _systemLanguageValue;

    return DropdownButton<String>(
      value: currentValue,
      underline: const SizedBox.shrink(),
      items: [
        DropdownMenuItem(
          value: _systemLanguageValue,
          child: Text(l10n.languageSystemDefault),
        ),
        ...AppLocalizations.supportedLocales.map((locale) {
          return DropdownMenuItem(
            value: locale.languageCode,
            child: Text(AppLocalizations.nativeName(locale.languageCode)),
          );
        }),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }
        if (value == _systemLanguageValue) {
          controller.setLocale(null);
        } else {
          controller.setLocale(Locale(value));
        }
      },
    );
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
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
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
