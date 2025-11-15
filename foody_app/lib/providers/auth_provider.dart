import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/services/api_service.dart';
import '../core/constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Initialize - check if user is already logged in
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    await _apiService.init();
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.userIdKey);
    final userName = prefs.getString(AppConstants.userNameKey);
    final userEmail = prefs.getString(AppConstants.userEmailKey);
    
    if (userId != null && userName != null && userEmail != null) {
      _user = UserModel(
        id: userId,
        name: userName,
        email: userEmail,
        role: 'consumer',
      );
      _isAuthenticated = true;
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _apiService.login(email, password);
      
      if (result['success'] == true) {
        final userData = result['data'];
        _user = UserModel.fromJson(userData['user'] ?? userData);
        _isAuthenticated = true;
        
        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userIdKey, _user!.id);
        await prefs.setString(AppConstants.userNameKey, _user!.name);
        await prefs.setString(AppConstants.userEmailKey, _user!.email);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Register
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _apiService.register(name, email, password);
      
      if (result['success'] == true) {
        final userData = result['data'];
        _user = UserModel.fromJson(userData['user'] ?? userData);
        _isAuthenticated = true;
        
        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userIdKey, _user!.id);
        await prefs.setString(AppConstants.userNameKey, _user!.name);
        await prefs.setString(AppConstants.userEmailKey, _user!.email);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    
    await _apiService.clearToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}