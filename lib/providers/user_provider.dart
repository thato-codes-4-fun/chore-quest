import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/models.dart';
import '../constants/constants.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Box<User> _userBox = Hive.box<User>('users');
  
  User? _currentUser;
  List<User> _familyMembers = [];
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  List<User> get familyMembers => _familyMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser != null) {
      try {
        // Always load fresh data from Supabase to ensure we have the latest user info
        final response = await _supabase
            .from(SupabaseConstants.usersTable)
            .select()
            .eq('id', supabaseUser.id)
            .single();
        
        _currentUser = User.fromJson(response);
        
        // Cache in Hive
        await _userBox.put(_currentUser!.id, _currentUser!);
        
        // Load family members
        await loadFamilyMembers();
        
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } catch (e) {
        // User profile doesn't exist yet (might be during signup)
        print('User profile not found: ${e.toString()}');
        _currentUser = null;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } else {
      _currentUser = null;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> clearCacheAndRefresh() async {
    try {
      _isLoading = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      // Clear current user and family members
      _currentUser = null;
      _familyMembers = [];
      
      // Clear Hive cache
      await _userBox.clear();
      
      // Reload current user
      await _loadCurrentUser();
      
    } catch (e) {
      _error = e.toString();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } finally {
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> clearAllCache() async {
    try {
      _isLoading = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      // Clear current user and family members
      _currentUser = null;
      _familyMembers = [];
      
      // Clear Hive cache
      await _userBox.clear();
      
    } catch (e) {
      _error = e.toString();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } finally {
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> loadFamilyMembers() async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      // Defer notifyListeners to avoid build phase conflicts
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      if (_currentUser!.role == UserRole.parent) {
        // Load all kids for this parent
        final response = await _supabase
            .from(SupabaseConstants.usersTable)
            .select()
            .eq('parent_id', _currentUser!.id)
            .eq('role', UserRole.kid.name);

        _familyMembers = response.map((json) => User.fromJson(json)).toList();
      } else {
        // Load parent for this kid
        if (_currentUser!.parentId != null) {
          final response = await _supabase
              .from(SupabaseConstants.usersTable)
              .select()
              .eq('id', _currentUser!.parentId!)
              .single();

          final parent = User.fromJson(response);
          _familyMembers = [parent];
        }
      }

      // Cache in Hive
      for (final user in _familyMembers) {
        await _userBox.put(user.id, user);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Defer notifyListeners
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required UserRole role,
    String? parentId,
  }) async {
    try {
      _isLoading = true;
      // Defer notifyListeners to avoid build phase conflicts
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      // Wait a bit for auth state to settle
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the current Supabase Auth user
      final supabaseUser = _supabase.auth.currentUser;
      print('Current Supabase user: ${supabaseUser?.id}');
      
      if (supabaseUser == null) {
        // Try to get the session
        final session = _supabase.auth.currentSession;
        print('Current session: ${session?.user.id}');
        
        if (session?.user != null) {
          // Use session user if currentUser is null
          final now = DateTime.now();
          final user = User(
            id: session!.user.id,
            name: name,
            email: email,
            role: role,
            parentId: parentId,
            createdAt: now,
            updatedAt: now,
          );

          // Save to Supabase
          print('Inserting user into database: ${user.toJson()}');
          await _supabase
              .from(SupabaseConstants.usersTable)
              .insert(user.toJson());

          // Save to Hive
          await _userBox.put(user.id, user);

          // Update current user
          _currentUser = user;

          // Load family members if this is a parent
          if (role == UserRole.parent) {
            await loadFamilyMembers();
          }

          // Defer notifyListeners
          SchedulerBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
          return;
        }
        
        throw Exception('No authenticated user found. Please try signing up again.');
      }

      final now = DateTime.now();
      final user = User(
        id: supabaseUser.id, // Use Supabase Auth user ID
        name: name,
        email: email,
        role: role,
        parentId: parentId,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Supabase
      print('Inserting user into database: ${user.toJson()}');
      await _supabase
          .from(SupabaseConstants.usersTable)
          .insert(user.toJson());

      // Save to Hive
      await _userBox.put(user.id, user);

      // Update current user
      _currentUser = user;

      // Load family members if this is a parent
      if (role == UserRole.parent) {
        await loadFamilyMembers();
      }

      // Defer notifyListeners
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      print('Error creating user: $e');
      // Defer notifyListeners
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow; // Re-throw to handle in the UI
    } finally {
      _isLoading = false;
      // Defer notifyListeners
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> updateUser(User user) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      // Update in Supabase
      await _supabase
          .from(SupabaseConstants.usersTable)
          .update(updatedUser.toJson())
          .eq('id', user.id);

      // Update in Hive
      await _userBox.put(user.id, updatedUser);

      // Update in memory
      if (_currentUser?.id == user.id) {
        _currentUser = updatedUser;
      }

      final index = _familyMembers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _familyMembers[index] = updatedUser;
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

  Future<void> updateBalance(String userId, double newBalance) async {
    try {
      final user = _userBox.get(userId);
      if (user != null) {
        final updatedUser = user.copyWith(balance: newBalance);
        await updateUser(updatedUser);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> userProfileExists(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.usersTable)
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshCurrentUser() async {
    await _loadCurrentUser();
  }

  Future<void> createUserWithId({
    required String userId,
    required String name,
    required String email,
    required UserRole role,
    String? parentId,
  }) async {
    try {
      _isLoading = true;
      // Defer notifyListeners to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final now = DateTime.now();
      final user = User(
        id: userId,
        name: name,
        email: email,
        role: role,
        parentId: parentId,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Supabase
      print('Inserting user into database with ID: ${user.toJson()}');
      await _supabase
          .from(SupabaseConstants.usersTable)
          .insert(user.toJson());

      // Save to Hive
      await _userBox.put(user.id, user);

      // Update current user
      _currentUser = user;

      // Load family members if this is a parent
      if (role == UserRole.parent) {
        await loadFamilyMembers();
      }

      // Defer notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      print('Error creating user with ID: $e');
      // Defer notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    } finally {
      _isLoading = false;
      // Defer notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}
