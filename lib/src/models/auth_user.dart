import 'package:objectbox/objectbox.dart';

@Entity()
class AuthUser {
  AuthUser({
    this.obxId = 0,
    required this.id,
    required this.email,
    required this.name,
    required this.lastLoginAt,
    this.photoUrl,
  });

  @Id()
  int obxId;

  @Unique()
  String id;
  
  String email;
  String name;
  
  @Property(type: PropertyType.date)
  DateTime lastLoginAt;
  
  String? photoUrl;

  AuthUser copyWith({
    int? obxId,
    String? id,
    String? email,
    String? name,
    DateTime? lastLoginAt,
    String? photoUrl,
  }) {
    return AuthUser(
      obxId: obxId ?? this.obxId,
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
