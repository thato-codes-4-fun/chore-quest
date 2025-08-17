import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../constants/constants.dart';

class ChoreProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Box<Chore> _choreBox = Hive.box<Chore>('chores');
  
  List<Chore> _chores = [];
  bool _isLoading = false;
  String? _error;

  List<Chore> get chores => _chores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Chore> getChoresByStatus(ChoreStatus status) {
    return _chores.where((chore) => chore.status == status).toList();
  }

  List<Chore> getChoresByAssignee(String assigneeId) {
    return _chores.where((chore) => chore.assigneeId == assigneeId).toList();
  }

  List<Chore> getChoresByAssigner(String assignerId) {
    return _chores.where((chore) => chore.assignedById == assignerId).toList();
  }

  String _generateUUID() {
    return const Uuid().v4();
  }

  Future<void> loadChores({String? userId, UserRole? userRole}) async {
    try {
      _isLoading = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      List<Map<String, dynamic>> response;
      
      if (userRole == UserRole.parent) {
        // Load all chores assigned by this parent
        response = await _supabase
            .from(SupabaseConstants.choresTable)
            .select()
            .eq('assigned_by', userId!)
            .order('created_at', ascending: false);
      } else if (userRole == UserRole.kid) {
        // Load all chores assigned to this kid
        response = await _supabase
            .from(SupabaseConstants.choresTable)
            .select()
            .eq('assigned_to', userId!)
            .order('created_at', ascending: false);
      } else {
        // Load all chores (for admin or debugging)
        response = await _supabase
            .from(SupabaseConstants.choresTable)
            .select()
            .order('created_at', ascending: false);
      }

      _chores = response.map((json) => Chore.fromJson(json)).toList();

      // Cache in Hive
      for (final chore in _chores) {
        await _choreBox.put(chore.id, chore);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> createChore({
    required String name,
    required String description,
    required double value,
    required String assigneeId,
    required String assignedById,
  }) async {
    try {
      _isLoading = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final now = DateTime.now();
      final chore = Chore(
        id: _generateUUID(),
        name: name,
        description: description,
        value: value,
        assigneeId: assigneeId,
        assignedById: assignedById,
        assignedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Supabase
      await _supabase
          .from(SupabaseConstants.choresTable)
          .insert(chore.toJson());

      // Save to Hive
      await _choreBox.put(chore.id, chore);

      // Add to memory
      _chores.add(chore);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow; // Re-throw the error so the UI can handle it
    } finally {
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> updateChoreStatus(String choreId, ChoreStatus status) async {
    try {
      _isLoading = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final choreIndex = _chores.indexWhere((c) => c.id == choreId);
      if (choreIndex == -1) return;

      final chore = _chores[choreIndex];
      final now = DateTime.now();

      Chore updatedChore;
      switch (status) {
        case ChoreStatus.completed:
          updatedChore = chore.copyWith(
            status: status,
            completedAt: now,
            updatedAt: now,
          );
          break;
        case ChoreStatus.approved:
          updatedChore = chore.copyWith(
            status: status,
            approvedAt: now,
            updatedAt: now,
          );
          break;
        default:
          updatedChore = chore.copyWith(
            status: status,
            updatedAt: now,
          );
      }

      // Update in Supabase
      await _supabase
          .from(SupabaseConstants.choresTable)
          .update(updatedChore.toJson())
          .eq('id', choreId);

      // Update in Hive
      await _choreBox.put(choreId, updatedChore);

      // Update in memory
      _chores[choreIndex] = updatedChore;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow; // Re-throw the error so the UI can handle it
    } finally {
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> addProofImage(String choreId, String imageUrl) async {
    try {
      final choreIndex = _chores.indexWhere((c) => c.id == choreId);
      if (choreIndex == -1) return;

      final chore = _chores[choreIndex];
      final updatedChore = chore.copyWith(
        proofImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      // Update in Supabase
      await _supabase
          .from(SupabaseConstants.choresTable)
          .update(updatedChore.toJson())
          .eq('id', choreId);

      // Update in Hive
      await _choreBox.put(choreId, updatedChore);

      // Update in memory
      _chores[choreIndex] = updatedChore;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void clearError() {
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> completeChore(String choreId, {String? imageUrl, String? notes}) async {
    try {
      // Find the chore
      final choreIndex = _chores.indexWhere((c) => c.id == choreId);
      if (choreIndex == -1) {
        throw Exception('Chore not found');
      }

      final chore = _chores[choreIndex];
      
      // Check if chore is in assigned status
      if (chore.status != ChoreStatus.assigned) {
        throw Exception('Chore is not in assigned status');
      }

      // Update chore status to completed with image URL and notes
      final updatedChore = chore.copyWith(
        status: ChoreStatus.completed,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        proofImageUrl: imageUrl,
        notes: notes,
      );

      // Update in Supabase
      await _supabase
          .from(SupabaseConstants.choresTable)
          .update(updatedChore.toJson())
          .eq('id', choreId);

      // Update in Hive
      await _choreBox.put(choreId, updatedChore);

      // Update in memory
      _chores[choreIndex] = updatedChore;

      // Get user's current balance
      final userResponse = await _supabase
          .from(SupabaseConstants.usersTable)
          .select('balance')
          .eq('id', chore.assigneeId)
          .single();

      final currentBalance = (userResponse['balance'] ?? 0.0).toDouble();
      
      // Calculate new balance
      final newBalance = currentBalance + chore.value;

      // Update user's balance
      await _supabase
          .from(SupabaseConstants.usersTable)
          .update({'balance': newBalance})
          .eq('id', chore.assigneeId);

      // Create transaction record
      final now = DateTime.now();
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: chore.assigneeId,
        type: TransactionType.choreCompleted,
        amount: chore.value, // Positive because points are earned
        balanceAfter: newBalance,
        relatedId: choreId,
        relatedType: 'chore',
        description: 'Completed: ${chore.name}',
        createdAt: now,
      );

      // Save transaction to database
      await _supabase
          .from(SupabaseConstants.transactionsTable)
          .insert(transaction.toJson());

      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

    } catch (e) {
      _error = e.toString();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  Future<void> resubmitChore(String choreId, {String? imageUrl, String? notes}) async {
    try {
      // Find the chore
      final choreIndex = _chores.indexWhere((c) => c.id == choreId);
      if (choreIndex == -1) {
        throw Exception('Chore not found');
      }

      final chore = _chores[choreIndex];
      
      // Check if chore is in rejected status
      if (chore.status != ChoreStatus.rejected) {
        throw Exception('Chore is not in rejected status');
      }

      // Update chore status back to assigned with new image URL and notes
      final updatedChore = chore.copyWith(
        status: ChoreStatus.assigned,
        updatedAt: DateTime.now(),
        proofImageUrl: imageUrl,
        notes: notes,
      );

      // Update in Supabase
      await _supabase
          .from(SupabaseConstants.choresTable)
          .update(updatedChore.toJson())
          .eq('id', choreId);

      // Update in Hive
      await _choreBox.put(choreId, updatedChore);

      // Update in memory
      _chores[choreIndex] = updatedChore;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

    } catch (e) {
      _error = e.toString();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }
}
