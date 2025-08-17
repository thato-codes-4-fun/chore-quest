import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
enum UserRole {
  @HiveField(0)
  parent,
  @HiveField(1)
  kid,
}

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final UserRole role;

  @HiveField(4)
  final String? parentId; // For kids, this links to their parent

  @HiveField(5)
  final double balance; // Points/Rands balance

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.parentId,
    this.balance = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? parentId,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      parentId: parentId ?? this.parentId,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'parent_id': parentId,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.kid,
      ),
      parentId: json['parent_id'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      avatarUrl: json['avatar_url'],
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, balance: $balance)';
  }
}
