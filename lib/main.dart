import 'package:flutter/material.dart';
import 'package:messagener_app/config/theme/app_theme.dart';
import 'package:messagener_app/presentation/screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messagner App',
      theme: AppTheme.lightTheme,
      home: LoginScreen(),
    );
  }
}
