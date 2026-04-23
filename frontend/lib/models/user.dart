import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class User {
  final String id;
  final String email;
  final String username;

  const User({
    required this.id,
    required this.email,
    required this.username,
  });

  factory User.fromSupabase(supa.User supaUser) => User(
        id: supaUser.id,
        email: supaUser.email ?? '',
        username: supaUser.userMetadata?['username'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
      };
}
