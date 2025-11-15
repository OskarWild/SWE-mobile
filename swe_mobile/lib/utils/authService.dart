import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String baseUrl = 'https://backend-api/url';

  static Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String userType,
    String? name,
    String? companyName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'userType': userType,
          'name': name,
          'companyName': companyName,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        
        await saveSessionLocally(
          userId: data['user']['id'],
          userType: data['user']['userType'],
          authToken: data['token'],
          email: data['user']['email'],
          name: data['user']['name'],
        );
        
        return data;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      print('Registration error: $e'); // Delete on prod airing
      return null;
    }
  }

  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        await saveSessionLocally(
          userId: data['user']['id'],
          userType: data['user']['userType'],
          authToken: data['token'],
          email: data['user']['email'],
          name: data['user']['name'],
        );
        
        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e'); // Delete on prod airing
      return null;
    }
  }

  static Future<void> saveSessionLocally({
    required String userId,
    required String userType,
    required String authToken,
    String? email,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('userType', userType);
    
    if (email != null) await prefs.setString('email', email);
    if (name != null) await prefs.setString('name', name);
    
    // Store token securely
    await _storage.write(key: 'authToken', value: authToken);
  }

  // Check if user is logged in (local check)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Validate token with backend
  static Future<bool> validateToken() async {
    try {
      final token = await getAuthToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Get user type (consumer or supplier)
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  // Get user email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Get user name
  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'authToken');
  }

  // Get authorization header (for API calls)
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // Fetch user profile from backend
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final headers = await getAuthHeaders();
      final userId = await getUserId();

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  // Update user profile on backend
  static Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final headers = await getAuthHeaders();
      final userId = await getUserId();

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        // Update local cache
        final prefs = await SharedPreferences.getInstance();
        if (updates['name'] != null) {
          await prefs.setString('name', updates['name']);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Update user profile error: $e');
      return false;
    }
  }

  // Logout - clear local data and notify backend
  static Future<void> logout() async {
    try {
      final headers = await getAuthHeaders();
      
      // Notify backend (optional, for token invalidation)
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );
    } catch (e) {
      print('Logout backend error: $e');
    } finally {
      // Clear local storage regardless of backend response
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _storage.deleteAll();
    }
  }

  // Refresh auth token
  static Future<bool> refreshToken() async {
    try {
      final token = await getAuthToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'authToken', value: data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }
}