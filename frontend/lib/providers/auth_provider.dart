import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;
  final StorageService _storage;

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _hasSeenOnboarding = false;

  AuthProvider({AuthService? auth, StorageService? storage})
      : _auth = auth ?? AuthService(supabaseClient),
        _storage = storage ?? StorageService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<void> bootstrap() async {
    _hasSeenOnboarding = await _storage.getHasSeenOnboarding();
    final supaUser = _auth.currentUser;
    if (supaUser != null) _user = User.fromSupabase(supaUser);
    _auth.authStateChanges.listen((state) {
      _user = state.session?.user != null
          ? User.fromSupabase(state.session!.user)
          : null;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _auth.signIn(email, password);
      _user = response.user != null ? User.fromSupabase(response.user!) : null;
      _error = null;
    } on supa.AuthException catch (e) {
      _error = e.message;
      _user = null;
    } catch (e, st) {
      developer.log('login falló', name: 'AuthProvider', error: e, stackTrace: st);
      _error = 'Inicio de sesión falló';
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String username, String password) async {
    _setLoading(true);
    try {
      final response = await _auth.signUp(email, password, username);
      _user = response.user != null ? User.fromSupabase(response.user!) : null;
      _error = null;
    } on supa.AuthException catch (e) {
      _error = e.message;
      _user = null;
    } catch (e, st) {
      developer.log('register falló', name: 'AuthProvider', error: e, stackTrace: st);
      _error = 'Registro falló';
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    _error = 'Google Sign-In no implementado aún';
    notifyListeners();
  }

  Future<void> loginWithApple() async {
    _error = 'Apple Sign-In no implementado aún';
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    _hasSeenOnboarding = true;
    await _storage.setHasSeenOnboarding(true);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
