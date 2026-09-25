import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_controller.dart';
import 'models.dart';

/// Persists the user's triggers and their checklist templates locally
/// (localStorage on web via shared_preferences).
class TriggerRepository {
  static const _prefsKey = 'neurowire_triggers_v2';

  Future<List<Trigger>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      // Use WidgetsBinding (not dart:ui's PlatformDispatcher.instance directly) so
      // widget tests can override the detected locale via tester.platformDispatcher.
      final locale = LocaleController.resolveSystemLocale(WidgetsBinding.instance.platformDispatcher.locales);
      final defaults = defaultTriggers(locale);
      await save(defaults);
      return defaults;
    }
    final decoded = jsonDecode(raw) as List;
    return [
      for (var i = 0; i < decoded.length; i++)
        Trigger.fromJson(decoded[i] as Map<String, dynamic>, fallbackIndex: i),
    ];
  }

  Future<void> save(List<Trigger> triggers) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(triggers.map((t) => t.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }
}
