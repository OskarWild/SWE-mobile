class AppConstants {
  // API Base URL
  static const String baseUrl = 'http://localhost:8000/api';
  static const String wsUrl = 'ws://localhost:8080/ws'; // 'ws://10.0.2.2:8080/ws' for android
  
  // API Endpoints
  static const String loginEndpoint = '/auth/token/';
  static const String registerEndpoint = '/auth/register/';
  static const String itemsEndpoint = '/items/';
  static const String categoriesEndpoint = '/categories/';
  static const String ordersEndpoint = '/orders/';
  static const String linkEndpoint = '/requests/';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userTypeKey = 'user_type';
  
  // App Info
  static const String appName = 'SCP Platform';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
}