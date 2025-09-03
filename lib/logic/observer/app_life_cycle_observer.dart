import 'package:flutter/material.dart';

import 'package:messagener_app/data/repositories/chat_repository.dart';

class AppLifeCycleObserver extends WidgetsBindingObserver {
  final String userId;
  final ChatRepository chatRepository;
  AppLifeCycleObserver({required this.userId, required this.chatRepository});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        chatRepository.updateUserStatus(userId, false);
        break;

      case AppLifecycleState.resumed:
        chatRepository.updateUserStatus(userId, true);
        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }
}
