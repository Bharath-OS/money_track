import 'package:flutter/material.dart';
import '../../data/user.dart';

class UserViewModel extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = true;

  AppUser? get currentUser => _currentUser;
  set setCurrentUser(AppUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Update user when auth state changes
  void updateUser(AppUser? newUser) {
    _currentUser = newUser;
    _isLoading = false;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear user on logout
  void clearUser() {
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
