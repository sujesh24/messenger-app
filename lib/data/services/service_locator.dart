import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messagener_app/data/repositories/auth_respoitory.dart';
import 'package:messagener_app/data/repositories/chat_repository.dart';
import 'package:messagener_app/data/repositories/contact_repositoy.dart';
import 'package:messagener_app/firebase_options.dart';
import 'package:messagener_app/logic/cubits/auth/auth_cubit.dart';
import 'package:messagener_app/logic/cubits/chat/chat_cubit.dart';
import 'package:messagener_app/router/app_router.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => AuthRepository());
  getIt.registerLazySingleton(() => ContactRepository());
  getIt.registerLazySingleton(
    () => AuthCubit(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => ChatCubit(
      currentUserId: getIt<FirebaseAuth>().currentUser!.uid,
      chatRepository: ChatRepository(),
    ),
  );
}
