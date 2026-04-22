import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  StorageService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _onboardingKey = 'has_seen_onboarding';
  static const String _usernameKey = 'auth_username';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _p() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  void _log(String msg) => developer.log(msg, name: 'Storage');

  Future<void> saveToken(String token) async {
    final prefs = await _p();
    final ok = await prefs.setString(_tokenKey, token);
    _log('saveToken · len=${token.length} · ok=$ok');
  }

  Future<String?> getToken() async {
    final prefs = await _p();
    final t = prefs.getString(_tokenKey);
    return (t == null || t.isEmpty) ? null : t;
  }

  Future<void> clearToken() async {
    final prefs = await _p();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    _log('clearToken');
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await _p();
    await prefs.setBool(_onboardingKey, value);
  }

  Future<bool> getHasSeenOnboarding() async {
    final prefs = await _p();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> saveUsername(String username) async {
    final prefs = await _p();
    await prefs.setString(_usernameKey, username);
  }

  Future<String?> getUsername() async {
    final prefs = await _p();
    return prefs.getString(_usernameKey);
  }
}
