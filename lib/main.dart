import 'package:flutter/material.dart';
import 'package:messagener_app/config/theme/app_theme.dart';
import 'package:messagener_app/data/services/service_locator.dart';
import 'package:messagener_app/presentation/screens/auth/login_screen.dart';
import 'package:messagener_app/router/app_router.dart';

void main() async {
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: getIt<AppRouter>().navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Messagner App',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
