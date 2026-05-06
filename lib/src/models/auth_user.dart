class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String name;
  final String? photoUrl;

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'photoUrl': photoUrl};
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
