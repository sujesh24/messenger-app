import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:messagener_app/data/models/chat_message.dart';

enum ChatStatus { inital, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus? status;
  final String? chatRoomId;
  final String? reciverId;
  final String? error;
  final List<ChatMessage> message;
  final bool isReciverOnline;
  final bool isReciverTyping;
  final Timestamp? reciverLastSeen;
  final bool hasMoreMessages;
  final bool isLoadingMore;
  final bool isUserBlocked;
  final bool amIBlocked;
  const ChatState({
    this.status = ChatStatus.inital,
    this.chatRoomId,
    this.reciverId,
    this.error,
    this.message = const [],
    this.isReciverOnline = false,
    this.isReciverTyping = false,
    this.reciverLastSeen,
    this.hasMoreMessages = true,
    this.isLoadingMore = false,
    this.isUserBlocked = false,
    this.amIBlocked = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? chatRoomId,
    String? reciverId,
    String? error,
    List<ChatMessage>? message,
    bool? isReciverOnline,
    bool? isReciverTyping,
    Timestamp? reciverLastSeen,
    bool? hasMoreMessages,
    bool? isLoadingMore,
    bool? isUserBlocked,
    bool? amIBlocked,
  }) {
    return ChatState(
      status: status ?? this.status,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      reciverId: reciverId ?? this.reciverId,
      error: error ?? this.error,
      message: message ?? this.message,
      isReciverOnline: isReciverOnline ?? this.isReciverOnline,
      isReciverTyping: isReciverTyping ?? this.isReciverTyping,
      reciverLastSeen: reciverLastSeen ?? this.reciverLastSeen,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isUserBlocked: isUserBlocked ?? this.isUserBlocked,
      amIBlocked: amIBlocked ?? this.amIBlocked,
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      chatRoomId,
      reciverId,
      error,
      message,
      isReciverOnline,
      isReciverTyping,
      reciverLastSeen,
      hasMoreMessages,
      isLoadingMore,
      isUserBlocked,
      amIBlocked,
    ];
  }
}
