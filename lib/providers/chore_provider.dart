import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> loadChores({String? userId, UserRole? userRole}) async {
    try {
      _isLoading = true;
      notifyListeners();

      List<Map<String, dynamic>> response;
      
      if (userRole == UserRole.parent) {
        // Load all chores assigned by this parent
        response = await _supabase
            .from(SupabaseConstants.choresTable)
            .select()
            .eq('assigned_by_id', userId!)
            .order('created_at', ascending: false);
      } else if (userRole == UserRole.kid) {
        // Load all chores assigned to this kid
        response = await _supabase
            .from(SupabaseConstants.choresTable)
            .select()
            .eq('assignee_id', userId!)
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
      notifyListeners();
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
      notifyListeners();

      final now = DateTime.now();
      final chore = Chore(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateChoreStatus(String choreId, ChoreStatus status) async {
    try {
      _isLoading = true;
      notifyListeners();

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

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
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
}
