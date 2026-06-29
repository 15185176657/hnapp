import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// 保存用户的语言选择，并持久化到本地。
///
/// 全局语言优先级：**用户手动选择 > 系统语言 > 英文**。
/// [locale] 为 `null` 表示“跟随系统语言”，这是首次启动时的默认行为。
/// 当用户明确选择语言后，会保存并在下次启动时继续使用。
class LocaleController extends ChangeNotifier {
  LocaleController() {
    _restore();
  }

  static const String _storageKey = 'app_locale';

  Locale? _locale;
  SharedPreferences? _prefs;

  /// 用户选择的语言；为 `null` 时表示跟随系统语言。
  Locale? get locale => _locale;

  /// 当前是否跟随系统语言。
  bool get followsSystem => _locale == null;

  Future<void> _restore() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final code = _prefs?.getString(_storageKey);
      if (code != null && code.isNotEmpty) {
        final candidate = Locale(code);
        if (AppLocalizations.isSupported(candidate)) {
          _locale = candidate;
          notifyListeners();
        }
      }
    } catch (error) {
      // 本地存储可能不可用，例如 widget 测试环境。回退到系统语言可以保证
      // 即使没有持久化能力，应用仍然可用。
      debugPrint('LocaleController: could not restore locale ($error).');
    }
  }

  /// 更新当前语言；传入 `null` 表示跟随系统语言。
  Future<void> setLocale(Locale? locale) async {
    if (locale != null && !AppLocalizations.isSupported(locale)) {
      return;
    }
    if (_locale?.languageCode == locale?.languageCode) {
      return;
    }
    _locale = locale;
    notifyListeners();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (locale == null) {
        await _prefs?.remove(_storageKey);
      } else {
        await _prefs?.setString(_storageKey, locale.languageCode);
      }
    } catch (error) {
      debugPrint('LocaleController: could not persist locale ($error).');
    }
  }

  /// 根据设备语言解析最终要渲染的受支持语言。
  ///
  /// 实现语言优先级：先使用用户显式选择，其次使用支持的设备语言，最后回退到英文。
  Locale resolve(Locale? deviceLocale) {
    if (_locale != null) {
      return _locale!;
    }
    if (deviceLocale != null && AppLocalizations.isSupported(deviceLocale)) {
      return Locale(deviceLocale.languageCode);
    }
    return const Locale('en');
  }
}
