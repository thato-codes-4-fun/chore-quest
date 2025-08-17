import 'package:hive/hive.dart';

part 'reward.g.dart';

@HiveType(typeId: 4)
enum RewardType {
  @HiveField(0)
  shortTerm,
  @HiveField(1)
  longTerm,
}

@HiveType(typeId: 5)
class Reward extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double cost; // Points/Rands cost

  @HiveField(4)
  final RewardType type;

  @HiveField(5)
  final String kidId; // Which kid this reward is for

  @HiveField(6)
  final String createdById; // Parent's ID

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final DateTime? targetDate; // For long-term goals

  @HiveField(9)
  final double? progress; // Current progress (0.0 to 1.0)

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.type,
    required this.kidId,
    required this.createdById,
    this.isActive = true,
    this.targetDate,
    this.progress = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  Reward copyWith({
    String? id,
    String? name,
    String? description,
    double? cost,
    RewardType? type,
    String? kidId,
    String? createdById,
    bool? isActive,
    DateTime? targetDate,
    double? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      type: type ?? this.type,
      kidId: kidId ?? this.kidId,
      createdById: createdById ?? this.createdById,
      isActive: isActive ?? this.isActive,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost,
      'type': type.name,
      'kid_id': kidId,
      'created_by_id': createdById,
      'is_active': isActive,
      'target_date': targetDate?.toIso8601String(),
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      cost: (json['cost'] ?? 0.0).toDouble(),
      type: RewardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RewardType.shortTerm,
      ),
      kidId: json['kid_id'],
      createdById: json['created_by_id'],
      isActive: json['is_active'] ?? true,
      targetDate: json['target_date'] != null 
          ? DateTime.parse(json['target_date']) 
          : null,
      progress: (json['progress'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  String toString() {
    return 'Reward(id: $id, name: $name, type: $type, cost: $cost)';
  }
}
