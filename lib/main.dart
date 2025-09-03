import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messagener_app/config/theme/app_theme.dart';
import 'package:messagener_app/data/repositories/chat_repository.dart';
import 'package:messagener_app/data/services/service_locator.dart';
import 'package:messagener_app/logic/cubits/auth/auth_cubit.dart';
import 'package:messagener_app/logic/cubits/auth/auth_state.dart';
import 'package:messagener_app/logic/observer/app_life_cycle_observer.dart';
import 'package:messagener_app/presentation/home/home_screen.dart';
import 'package:messagener_app/presentation/screens/auth/login_screen.dart';
import 'package:messagener_app/router/app_router.dart';

void main() async {
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLifeCycleObserver? _lifeCycleObserver;
  @override
  void initState() {
    getIt<AuthCubit>().stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user != null) {
        //if alredy exits
        if (_lifeCycleObserver != null) {
          WidgetsBinding.instance.removeObserver(_lifeCycleObserver!);
        }

        _lifeCycleObserver = AppLifeCycleObserver(
          userId: state.user!.uid,
          chatRepository: getIt<ChatRepository>(),
        );
        WidgetsBinding.instance.addObserver(_lifeCycleObserver!);

        //remove if logedout and observer exits
      } else {
        if (_lifeCycleObserver != null) {
          WidgetsBinding.instance.removeObserver(_lifeCycleObserver!);
          _lifeCycleObserver = null;
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_lifeCycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifeCycleObserver!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: getIt<AppRouter>().navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Messagner App',
      theme: AppTheme.lightTheme,
      home: BlocBuilder<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        builder: (context, state) {
          if (state.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.status == AuthStatus.authenticated) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
