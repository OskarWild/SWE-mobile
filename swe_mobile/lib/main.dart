import 'package:flutter/material.dart';
import 'package:swe_mobile/pages/auth/auth.dart'; // TODO: make auth
import 'package:swe_mobile/pages/home.dart'; // TODO: make HomePage
import 'package:swe_mobile/utils/authService.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Foodie App',
      home: true ? const HomePage() : const AuthPage(), // AuthService.isLoggedIn()
    );
  }
}
