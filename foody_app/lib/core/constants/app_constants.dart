class AppConstants {
  // API Base URL - замени на свой backend URL
  static const String baseUrl = 'http://localhost:8000/api';
  static const String wsUrl = 'ws://localhost:8080/ws'; // 10.0.2.2:8080/ws';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String itemsEndpoint = '/items/';
  static const String categoriesEndpoint = '/categories/';
  static const String ordersEndpoint = '/orders/';
  static const String mainPageEndpoint = '/main-page';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  
  // App Info
  static const String appName = 'SCP Platform';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
}