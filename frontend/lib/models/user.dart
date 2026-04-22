class User {
  final int id;
  final String email;
  final String username;
  final String access_token;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.access_token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final inner = json['user'] is Map ? json['user'] as Map : null;
    final id = (inner?['id'] ?? json['id'] ?? 0) as int;
    final email = (inner?['email'] ?? json['email'] ?? '') as String;
    final username = (inner?['username'] ?? json['username'] ?? '') as String;
    final token = (json['access_token'] ?? '') as String;
    return User(id: id, email: email, username: username, access_token: token);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'access_token': access_token,
      };
}
