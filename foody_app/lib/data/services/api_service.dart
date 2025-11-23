import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foody_app/core/constants/app_constants.dart';
import 'package:foody_app/data/models/product_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  String? _token;

  // Get headers with token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }
  
  // Initialize token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }
  
  // Save token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }
  
  // Clear token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }
  
  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Register
  Future<Map<String, dynamic>> register(String name, String surname, String email, String businessName, String businessType, String password, String userType) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'surname': surname,
          'email': email,
          'businessType': businessType,
          'businessName': businessName,
          'password': password,
          'userType': userType
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Get products with filters
  Future<List<ProductModel>> getProducts({String? userId, String? search, String? categoryId, String? sortBy}) async {
    try {
      String url = '${AppConstants.baseUrl}${AppConstants.itemsEndpoint}';
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null) {
        queryParams['category'] = categoryId;
      }
      if (sortBy != null) {
        queryParams['sort'] = sortBy;
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get single product by ID
    Future<ProductModel> getProduct(String productId) async {
      try {
        final response = await http.get(
          Uri.parse('${AppConstants.baseUrl}${AppConstants.itemsEndpoint}$productId'),
          headers: _headers,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return ProductModel.fromJson(data);
        } else if (response.statusCode == 404) {
          throw Exception('Product not found');
        } else {
          throw Exception('Failed to load product');
        }
      } catch (e) {
        throw Exception('Network error: $e');
      }
    }

  // Update product
    Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> productData) async {
      try {
        final response = await http.put(
          Uri.parse('${AppConstants.baseUrl}${AppConstants.itemsEndpoint}$productId'),
          headers: _headers,
          body: jsonEncode(productData),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {'success': true, 'data': data};
        } else if (response.statusCode == 403) {
          return {'success': false, 'message': 'You can only update your own items'};
        } else if (response.statusCode == 404) {
          return {'success': false, 'message': 'Product not found'};
        } else {
          return {'success': false, 'message': 'Failed to update product'};
        }
      } catch (e) {
        return {'success': false, 'message': 'Network error: $e'};
      }
    }

  // Delete product
    Future<Map<String, dynamic>> deleteProduct(String productId) async {
      try {
        final response = await http.delete(
          Uri.parse('${AppConstants.baseUrl}${AppConstants.itemsEndpoint}$productId'),
          headers: _headers,
        );

        if (response.statusCode == 204) {
          return {'success': true, 'message': 'Product deleted successfully'};
        } else if (response.statusCode == 403) {
          return {'success': false, 'message': 'You can only delete your own items'};
        } else if (response.statusCode == 404) {
          return {'success': false, 'message': 'Product not found'};
        } else {
          return {'success': false, 'message': 'Failed to delete product'};
        }
      } catch (e) {
        return {'success': false, 'message': 'Network error: $e'};
      }
    }

    // Create order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.categoriesEndpoint}'),
        headers: _headers,
        body: jsonEncode(orderData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to create order'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Get user orders
  Future<List<dynamic>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.ordersEndpoint}'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get order by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.ordersEndpoint}$orderId/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load order');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Cancel order
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.baseUrl}/orders/$orderId/'),
        headers: _headers,
        body: jsonEncode({'status': 'cancelled'}),
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to cancel order'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}