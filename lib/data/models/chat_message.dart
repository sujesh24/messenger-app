import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum MessageType { text, image, videp }

enum MessageStatus { read, sent }

class ChatMessage {
  final String id;
  final String chatId;
  final String senderID;
  final String reciverId;
  final String content;
  final MessageStatus status;
  final MessageType type;
  final Timestamp timestamp;
  final List<String> readBy;
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderID,
    required this.reciverId,
    required this.content,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    required this.timestamp,
    required this.readBy,
  });

  factory ChatMessage.fromFireStore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      chatId: data['chatRoomId'] ?? '',
      senderID: data['senderID'] ?? '',
      reciverId: data['reciverId'] ?? '',
      content: data['content'] ?? '',
      status: MessageStatus.values.firstWhere(
        (element) => element.toString() == data['status'],
        orElse: () => MessageStatus.sent,
      ),
      type: MessageType.values.firstWhere(
        (element) => element.toString() == data['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatRoomId': chatId,
      'senderID': senderID,
      'reciverId': reciverId,
      'content': content,
      'status': status,
      'type': type,
      'timestamp': timestamp,
      'readBy': readBy,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderID,
    String? reciverId,
    String? content,
    MessageStatus? status,
    MessageType? type,
    Timestamp? timestamp,
    List<String>? readBy,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderID: senderID ?? this.senderID,
      reciverId: reciverId ?? this.reciverId,
      content: content ?? this.content,
      status: status ?? this.status,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
    );
  }
}
