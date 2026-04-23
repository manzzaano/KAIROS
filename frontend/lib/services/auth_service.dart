import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthService {
  final supa.SupabaseClient client;
  AuthService(this.client);

  supa.User? get currentUser => client.auth.currentUser;

  Stream<supa.AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<supa.AuthResponse> signIn(String email, String password) =>
      client.auth.signInWithPassword(email: email, password: password);

  Future<supa.AuthResponse> signUp(
          String email, String password, String username) =>
      client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

  Future<void> signOut() => client.auth.signOut();
}
