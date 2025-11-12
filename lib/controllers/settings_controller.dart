import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  SettingsState({
    required this.languageCode,
    required this.notifications,
    required this.privacyFlags,
    required this.audioQuality,
  });

  final String languageCode;
  final bool notifications;
  final Map<String, bool> privacyFlags;
  final int audioQuality;

  SettingsState copyWith({
    String? languageCode,
    bool? notifications,
    Map<String, bool>? privacyFlags,
    int? audioQuality,
  }) {
    return SettingsState(
      languageCode: languageCode ?? this.languageCode,
      notifications: notifications ?? this.notifications,
      privacyFlags: privacyFlags ?? this.privacyFlags,
      audioQuality: audioQuality ?? this.audioQuality,
    );
  }
}

class SettingsController extends ChangeNotifier {
  SettingsController({required SettingsState state}) : _state = state;

  static const _langKey = 'language';

  SettingsState _state;

  SettingsState get state => _state;

  Future<void> setLanguage(String code) async {
    _state = _state.copyWith(languageCode: code);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  void setNotifications(bool value) {
    _state = _state.copyWith(notifications: value);
    notifyListeners();
  }

  void togglePrivacy(String key, bool value) {
    final next = Map<String, bool>.from(_state.privacyFlags)..[key] = value;
    _state = _state.copyWith(privacyFlags: next);
    notifyListeners();
  }

  void setAudioQuality(int kbps) {
    _state = _state.copyWith(audioQuality: kbps);
    notifyListeners();
  }

  static Future<SettingsController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_langKey) ?? 'en';
    return SettingsController(
      state: SettingsState(
        languageCode: lang,
        notifications: true,
        privacyFlags: {
          'searchable': true,
          'share_stats': false,
          'allow_messages': true,
        },
        audioQuality: 96,
      ),
    );
  }
}
