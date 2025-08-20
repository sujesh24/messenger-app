import 'package:equatable/equatable.dart';

import 'package:messagener_app/data/models/chat_message.dart';

enum ChatStatus { inital, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus? status;
  final String? chatRoomId;
  final String? reciverId;
  final String? error;
  final List<ChatMessage> message;
  const ChatState({
    this.status = ChatStatus.inital,
    this.chatRoomId,
    this.reciverId,
    this.error,
    this.message = const [],
  });

  ChatState copyWith({
    ChatStatus? status,
    String? chatRoomId,
    String? reciverId,
    String? error,
    List<ChatMessage>? message,
  }) {
    return ChatState(
      status: status ?? this.status,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      reciverId: reciverId ?? this.reciverId,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props {
    return [status, chatRoomId, reciverId, error, message];
  }
}
