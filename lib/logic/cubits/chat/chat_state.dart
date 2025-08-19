import 'package:equatable/equatable.dart';

enum ChatStatus { inital, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus? status;
  final String? chatRoomId;
  final String? reciverId;
  final String? error;
  const ChatState({
    this.status = ChatStatus.inital,
    this.chatRoomId,
    this.reciverId,
    this.error,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? chatRoomId,
    String? reciverId,
    String? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      reciverId: reciverId ?? this.reciverId,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, chatRoomId, reciverId, error];
}
