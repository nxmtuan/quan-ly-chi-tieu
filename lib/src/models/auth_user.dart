class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.lastLoginAt,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String name;
  final DateTime lastLoginAt;
  final String? photoUrl;

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? lastLoginAt,
    String? photoUrl,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      lastLoginAt:
          DateTime.tryParse(json['lastLoginAt'] as String? ?? '') ??
          DateTime.now(),
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
