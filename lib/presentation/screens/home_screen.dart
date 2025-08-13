import 'package:flutter/material.dart';
import 'package:messagener_app/data/services/service_locator.dart';
import 'package:messagener_app/logic/cubits/auth_cubit.dart';
import 'package:messagener_app/presentation/screens/auth/login_screen.dart';
import 'package:messagener_app/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await getIt<AuthCubit>().signOut();
              getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text('Welcome to the Home Screen!')),
    );
  }
}
