import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _currentUser = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
        },
      );

      if (response.user != null) {
        _currentUser = response.user;
      }
      
      return response;
    } catch (e) {
      _error = e.toString();
      print('Auth signup error: $e');
      rethrow; // Re-throw the error so the signup screen can handle it
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
      }
    } catch (e) {
      _error = e.toString();
      rethrow; // Re-throw so the UI can handle it
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signOut();
      _currentUser = null;
      
      // Note: Cache clearing should be handled by the UI layer
      // after successful sign out
    } catch (e) {
      _error = e.toString();
      rethrow; // Re-throw so the UI can handle it
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  User? get sessionUser => _supabase.auth.currentUser;
  
  Session? get currentSession => _supabase.auth.currentSession;
}
