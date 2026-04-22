import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _hasSeenOnboarding = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<void> bootstrap() async {
    _hasSeenOnboarding = await _storage.getHasSeenOnboarding();
    await checkToken();
  }

  Future<void> _persistUser(Map<String, dynamic> response, {String? fallbackEmail}) async {
    final user = User.fromJson(response);
    await _storage.saveToken(user.access_token);
    await _storage.saveUsername(user.username);
    _user = User(
      id: user.id,
      email: user.email.isNotEmpty ? user.email : (fallbackEmail ?? ''),
      username: user.username,
      access_token: user.access_token,
    );
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      developer.log('login intento · $email · baseUrl=${_apiClient.dio.options.baseUrl}',
          name: 'AuthProvider');
      final response = await _apiClient.login(email, password);
      await _persistUser(response, fallbackEmail: email);
      _error = null;
    } catch (e, st) {
      developer.log('login falló: $e', name: 'AuthProvider', error: e, stackTrace: st);
      _error = _clean(e.toString());
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String username, String password) async {
    _setLoading(true);
    try {
      developer.log('register intento · $email · $username', name: 'AuthProvider');
      final response = await _apiClient.register(email, username, password);
      await _persistUser(response, fallbackEmail: email);
      _error = null;
    } catch (e, st) {
      developer.log('register falló: $e', name: 'AuthProvider', error: e, stackTrace: st);
      _error = _clean(e.toString());
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    await _oauthMock('google');
  }

  Future<void> loginWithApple() async {
    await _oauthMock('apple');
  }

  Future<void> _oauthMock(String provider) async {
    _setLoading(true);
    try {
      developer.log('oauth $provider intento', name: 'AuthProvider');
      final response = await _apiClient.oauthLogin(provider, 'mock-id-token');
      await _persistUser(response);
      _error = null;
    } catch (e, st) {
      developer.log('oauth $provider falló: $e', name: 'AuthProvider', error: e, stackTrace: st);
      _error = _clean(e.toString());
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _storage.clearToken();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<void> checkToken() async {
    _setLoading(true);
    try {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        final username = await _storage.getUsername() ?? '';
        _user = User(id: 0, email: '', username: username, access_token: token);
      } else {
        _user = null;
      }
      _error = null;
    } catch (e) {
      _error = _clean(e.toString());
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markOnboardingSeen() async {
    _hasSeenOnboarding = true;
    await _storage.setHasSeenOnboarding(true);
    notifyListeners();
  }

  String _clean(String raw) {
    final prefix = 'Exception: ';
    return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
