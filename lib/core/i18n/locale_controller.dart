import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// Holds the user's language choice and persists it locally.
///
/// Priority rule applied across the app: **user selection > system language >
/// English**. A `null` [locale] means "follow the system language", which is
/// the default on first launch. When the user picks a language explicitly it is
/// stored and reused on the next launch.
class LocaleController extends ChangeNotifier {
  LocaleController() {
    _restore();
  }

  static const String _storageKey = 'app_locale';

  Locale? _locale;
  SharedPreferences? _prefs;

  /// The user-selected locale, or `null` to follow the system language.
  Locale? get locale => _locale;

  /// Whether the app is currently following the system language.
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
      // Storage may be unavailable (for example in widget tests). Falling back
      // to the system language keeps the app usable without persistence.
      debugPrint('LocaleController: could not restore locale ($error).');
    }
  }

  /// Updates the active language. Pass `null` to follow the system language.
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

  /// Resolves which supported locale to render given the device locales.
  ///
  /// Implements the priority rule: explicit user choice first, then the first
  /// device locale we support, then English as the guaranteed fallback.
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
