import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:messagener_app/data/repositories/chat_repository.dart';
import 'package:messagener_app/logic/cubits/chat/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final String currentUserId;
  final ChatRepository _chatRepository;
  bool _isInChat = false;

  StreamSubscription? _messgaeSubscription;
  StreamSubscription? _onlineStatusSubscription;
  StreamSubscription? _typingSubscription;
  Timer? typingTimer;

  ChatCubit({
    required this.currentUserId,
    required ChatRepository chatRepository,
  }) : _chatRepository = chatRepository,
       super(const ChatState());

  // create or get  chat room
  void enterChat(String reciverId) async {
    _isInChat = true;
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

      //subscribe to message updates
      _subscribeToMessage(chatRoom.id);
      _subscribeToOnlineStatus(reciverId);
      _subscribeToTypingStatus(chatRoom.id);

      await _chatRepository.updateUserStatus(currentUserId, true);
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

  //fill
  void _subscribeToMessage(String chatRoomId) {
    _messgaeSubscription?.cancel();
    _messgaeSubscription = _chatRepository
        .getMessage(chatRoomId)
        .listen(
          (message) {
            if (_isInChat) {
              _markMessageAsRead(chatRoomId);
            }
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

  //mark message as read
  Future<void> _markMessageAsRead(String chatRoomId) async {
    try {
      await _chatRepository.markMessageAsRead(chatRoomId, currentUserId);
    } catch (_) {}
  }

  Future<void> leaveChat() async {
    _isInChat = false;
  }

  //online status{doc yet}
  void _subscribeToOnlineStatus(String userId) {
    _onlineStatusSubscription?.cancel();
    _onlineStatusSubscription = _chatRepository
        .getUserOnlineStatus(userId)
        .listen((status) {
          final isOnline = status["isOnline"] as bool;
          final lastSeen = status["lastSeen"] as Timestamp?;
          //to do state
          emit(
            state.copyWith(
              isReciverOnline: isOnline,
              reciverLastSeen: lastSeen,
            ),
          );
        }, onError: (_) {});
  }

  //typing timer

  void startTimer() {
    if (state.chatRoomId == null) return;
    typingTimer?.cancel();
    _updateTypingStatus(true);
    typingTimer = Timer(const Duration(seconds: 3), () {
      _updateTypingStatus(false);
    });
  }

  //update typing status in cubit{doc yet}

  Future<void> _updateTypingStatus(bool isTyping) async {
    if (state.chatRoomId == null) return;

    try {
      await _chatRepository.updateTypingStatus(
        currentUserId,
        state.chatRoomId!,
        isTyping,
      );
    } catch (_) {}
  }

  //typing status{doc yet}
  void _subscribeToTypingStatus(String chatRoomId) {
    _typingSubscription?.cancel();
    _typingSubscription = _chatRepository.getTypingStatus(chatRoomId).listen((
      status,
    ) {
      final isTyping = status['isTyping'] as bool;
      final typingUserId = status['typingUserId'];
      emit(
        state.copyWith(
          isReciverTyping: isTyping && typingUserId != currentUserId,
        ),
      );
    }, onError: (_) {});
  }
}
