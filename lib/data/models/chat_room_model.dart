import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final Timestamp? lastMessageTime;
  final Map<String, Timestamp>? lastReadTime;
  final Map<String, String>? participantNames;
  final bool isTyping;
  final String? typingUserId;
  final bool isCallActive;

  const ChatRoomModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    Map<String, Timestamp>? lastReadTime,
    Map<String, String>? participantNames,
    this.isTyping = false,
    this.typingUserId,
    this.isCallActive = false,
  }) : lastReadTime = lastReadTime ?? const {},
       participantNames = participantNames ?? const {};

  //factory

  factory ChatRoomModel.fromFireStore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: data['id'],
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageTime: data['lastMessageTime'],
      lastReadTime: Map<String, Timestamp>.from(data['lastReadTime'] ?? {}),
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? {},
      ),
      isTyping: data['isTyping'] ?? false,
      typingUserId: data['typingUserId'],
      isCallActive: data['isCallActive'] ?? false,
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime,
      'lastReadTime': lastReadTime,
      'participantNames': participantNames,
      'isTyping': isTyping,
      'typingUserId': typingUserId,
      'isCallActive': isCallActive,
    };
  }
}
