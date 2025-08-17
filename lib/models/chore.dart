import 'package:hive/hive.dart';

part 'chore.g.dart';

@HiveType(typeId: 2)
enum ChoreStatus {
  @HiveField(0)
  assigned,
  @HiveField(1)
  completed,
  @HiveField(2)
  approved,
  @HiveField(3)
  rejected,
}

@HiveType(typeId: 3)
class Chore extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double value; // Points/Rands value

  @HiveField(4)
  final String assigneeId; // Kid's ID

  @HiveField(5)
  final String assignedById; // Parent's ID

  @HiveField(6)
  final ChoreStatus status;

  @HiveField(7)
  final DateTime assignedAt;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final DateTime? approvedAt;

  @HiveField(10)
  final String? proofImageUrl; // Optional photo proof

  @HiveField(11)
  final String? notes; // Parent's notes or kid's notes

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime updatedAt;

  Chore({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.assigneeId,
    required this.assignedById,
    this.status = ChoreStatus.assigned,
    required this.assignedAt,
    this.completedAt,
    this.approvedAt,
    this.proofImageUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Chore copyWith({
    String? id,
    String? name,
    String? description,
    double? value,
    String? assigneeId,
    String? assignedById,
    ChoreStatus? status,
    DateTime? assignedAt,
    DateTime? completedAt,
    DateTime? approvedAt,
    String? proofImageUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chore(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      assigneeId: assigneeId ?? this.assigneeId,
      assignedById: assignedById ?? this.assignedById,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'value': value,
      'assignee_id': assigneeId,
      'assigned_by_id': assignedById,
      'status': status.name,
      'assigned_at': assignedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'proof_image_url': proofImageUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Chore.fromJson(Map<String, dynamic> json) {
    return Chore(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      value: (json['value'] ?? 0.0).toDouble(),
      assigneeId: json['assignee_id'],
      assignedById: json['assigned_by_id'],
      status: ChoreStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChoreStatus.assigned,
      ),
      assignedAt: DateTime.parse(json['assigned_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      approvedAt: json['approved_at'] != null 
          ? DateTime.parse(json['approved_at']) 
          : null,
      proofImageUrl: json['proof_image_url'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  String toString() {
    return 'Chore(id: $id, name: $name, status: $status, value: $value)';
  }
}
