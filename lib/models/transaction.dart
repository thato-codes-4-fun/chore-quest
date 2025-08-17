import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 6)
enum TransactionType {
  @HiveField(0)
  choreCompleted,
  @HiveField(1)
  rewardRedeemed,
  @HiveField(2)
  bonus,
  @HiveField(3)
  penalty,
}

@HiveType(typeId: 7)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId; // Kid's ID

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final double amount; // Positive for earnings, negative for spending

  @HiveField(4)
  final double balanceAfter; // Balance after this transaction

  @HiveField(5)
  final String? relatedId; // Chore ID or Reward ID

  @HiveField(6)
  final String? relatedType; // 'chore' or 'reward'

  @HiveField(7)
  final String description;

  @HiveField(8)
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.relatedId,
    this.relatedType,
    required this.description,
    required this.createdAt,
  });

  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    double? balanceAfter,
    String? relatedId,
    String? relatedType,
    String? description,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'amount': amount,
      'balance_after': balanceAfter,
      'related_id': relatedId,
      'related_type': relatedType,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.choreCompleted,
      ),
      amount: (json['amount'] ?? 0.0).toDouble(),
      balanceAfter: (json['balance_after'] ?? 0.0).toDouble(),
      relatedId: json['related_id'],
      relatedType: json['related_type'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, description: $description)';
  }
}
