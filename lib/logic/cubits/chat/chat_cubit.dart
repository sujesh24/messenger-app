import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:messagener_app/data/repositories/chat_repository.dart';
import 'package:messagener_app/logic/cubits/chat/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final String currentUserId;
  final ChatRepository _chatRepository;

  StreamSubscription? _messgaeSubscription; //{doc yet}

  ChatCubit({
    required this.currentUserId,
    required ChatRepository chatRepository,
  }) : _chatRepository = chatRepository,
       super(const ChatState());

  // create or get  chat room
  void enterChat(String reciverId) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final chatRoom = await _chatRepository.getOrCreateChatRoom(
        currentUserId,
        reciverId,
      );
      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          chatRoomId: chatRoom.id,
          reciverId: reciverId,
        ),
      );
      _subscribeToMessage(chatRoom.id); //{doc yet}
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: "failed to create a chat room $e",
        ),
      );
    }
  }

  // send messages
  Future<void> sendMessage({
    required String content,
    required String recviverId,
  }) async {
    if (state.chatRoomId == null) return;
    try {
      await _chatRepository.sendMessages(
        chatRoomId: state.chatRoomId!,
        receiverId: recviverId,
        senderId: currentUserId,

        content: content,
      );
    } catch (e) {
      log(e.toString());
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: "failed to send message $e",
        ),
      );
    }
  }

  //fill{doc yet}
  void _subscribeToMessage(String chatRoomId) {
    _messgaeSubscription?.cancel();
    _messgaeSubscription = _chatRepository
        .getMessage(chatRoomId)
        .listen(
          (message) {
            emit(state.copyWith(message: message, error: null));
          },
          onError: (error) {
            emit(
              state.copyWith(
                error: "Failed to load messages",
                status: ChatStatus.error,
              ),
            );
          },
        );
  }
}
