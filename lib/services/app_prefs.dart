import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales del dispositivo (no sensibles): si ya se vio el
/// onboarding y si las notificaciones están activadas.
class AppPrefs {
  static const _kOnboardingDone = 'onboarding_done';
  static const _kNotificationsEnabled = 'notifications_enabled';

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingDone) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, true);
  }

  Future<bool> notificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsEnabled, value);
  }
}
