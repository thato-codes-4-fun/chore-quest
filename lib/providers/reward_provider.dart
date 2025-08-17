import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../constants/constants.dart';

class RewardProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Box<Reward> _rewardBox = Hive.box<Reward>('rewards');
  
  List<Reward> _rewards = [];
  bool _isLoading = false;
  String? _error;

  List<Reward> get rewards => _rewards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Reward> getRewardsByType(RewardType type) {
    return _rewards.where((reward) => reward.type == type).toList();
  }

  List<Reward> getRewardsByKid(String kidId) {
    return _rewards.where((reward) => reward.kidId == kidId).toList();
  }

  List<Reward> getActiveRewards() {
    return _rewards.where((reward) => reward.isActive).toList();
  }

  Future<void> loadRewards({String? kidId, String? createdById}) async {
    try {
      _isLoading = true;
      notifyListeners();

      List<Map<String, dynamic>> response;
      
      if (kidId != null) {
        // Load rewards for a specific kid
        response = await _supabase
            .from(SupabaseConstants.rewardsTable)
            .select()
            .eq('kid_id', kidId)
            .order('created_at', ascending: false);
      } else if (createdById != null) {
        // Load rewards created by a specific parent
        response = await _supabase
            .from(SupabaseConstants.rewardsTable)
            .select()
            .eq('created_by_id', createdById)
            .order('created_at', ascending: false);
      } else {
        // Load all rewards
        response = await _supabase
            .from(SupabaseConstants.rewardsTable)
            .select()
            .order('created_at', ascending: false);
      }

      _rewards = response.map((json) => Reward.fromJson(json)).toList();

      // Cache in Hive
      for (final reward in _rewards) {
        await _rewardBox.put(reward.id, reward);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReward({
    required String name,
    required String description,
    required double cost,
    required RewardType type,
    required String kidId,
    required String createdById,
    DateTime? targetDate,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      final reward = Reward(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        cost: cost,
        type: type,
        kidId: kidId,
        createdById: createdById,
        targetDate: targetDate,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Supabase
      await _supabase
          .from(SupabaseConstants.rewardsTable)
          .insert(reward.toJson());

      // Save to Hive
      await _rewardBox.put(reward.id, reward);

      // Add to memory
      _rewards.add(reward);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReward(Reward reward) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedReward = reward.copyWith(updatedAt: DateTime.now());

      // Update in Supabase
      await _supabase
          .from(SupabaseConstants.rewardsTable)
          .update(updatedReward.toJson())
          .eq('id', reward.id);

      // Update in Hive
      await _rewardBox.put(reward.id, updatedReward);

      // Update in memory
      final index = _rewards.indexWhere((r) => r.id == reward.id);
      if (index != -1) {
        _rewards[index] = updatedReward;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRewardProgress(String rewardId, double progress) async {
    try {
      final rewardIndex = _rewards.indexWhere((r) => r.id == rewardId);
      if (rewardIndex == -1) return;

      final reward = _rewards[rewardIndex];
      final updatedReward = reward.copyWith(
        progress: progress,
        updatedAt: DateTime.now(),
      );

      // Update in Supabase
      await _supabase
          .from(SupabaseConstants.rewardsTable)
          .update(updatedReward.toJson())
          .eq('id', rewardId);

      // Update in Hive
      await _rewardBox.put(rewardId, updatedReward);

      // Update in memory
      _rewards[rewardIndex] = updatedReward;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleRewardActive(String rewardId) async {
    try {
      final rewardIndex = _rewards.indexWhere((r) => r.id == rewardId);
      if (rewardIndex == -1) return;

      final reward = _rewards[rewardIndex];
      final updatedReward = reward.copyWith(
        isActive: !reward.isActive,
        updatedAt: DateTime.now(),
      );

      // Update in Supabase
      await _supabase
          .from(SupabaseConstants.rewardsTable)
          .update(updatedReward.toJson())
          .eq('id', rewardId);

      // Update in Hive
      await _rewardBox.put(rewardId, updatedReward);

      // Update in memory
      _rewards[rewardIndex] = updatedReward;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> redeemReward(String rewardId, String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Find the reward
      final rewardIndex = _rewards.indexWhere((r) => r.id == rewardId);
      if (rewardIndex == -1) {
        throw Exception('Reward not found');
      }

      final reward = _rewards[rewardIndex];
      
      // Check if reward is active
      if (!reward.isActive) {
        throw Exception('Reward is not available');
      }

      // Get user's current balance
      final userResponse = await _supabase
          .from(SupabaseConstants.usersTable)
          .select('balance')
          .eq('id', userId)
          .single();

      final currentBalance = (userResponse['balance'] ?? 0.0).toDouble();
      
      // Check if user has enough points
      if (currentBalance < reward.cost) {
        throw Exception('Insufficient points');
      }

      // Calculate new balance
      final newBalance = currentBalance - reward.cost;

      // Update user's balance
      await _supabase
          .from(SupabaseConstants.usersTable)
          .update({'balance': newBalance})
          .eq('id', userId);

      // Create transaction record
      final now = DateTime.now();
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: TransactionType.rewardRedeemed,
        amount: -reward.cost, // Negative because points are spent
        balanceAfter: newBalance,
        relatedId: rewardId,
        relatedType: 'reward',
        description: 'Redeemed: ${reward.name}',
        createdAt: now,
      );

      // Save transaction to database
      await _supabase
          .from(SupabaseConstants.transactionsTable)
          .insert(transaction.toJson());

      // Mark reward as redeemed (optional - you might want to keep it active for multiple redemptions)
      final updatedReward = reward.copyWith(
        isActive: false, // Mark as redeemed
        updatedAt: now,
      );

      // Update reward in database
      await _supabase
          .from(SupabaseConstants.rewardsTable)
          .update(updatedReward.toJson())
          .eq('id', rewardId);

      // Update in memory
      _rewards[rewardIndex] = updatedReward;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
