import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messagener_app/data/models/chat_message.dart';
import 'package:messagener_app/data/models/chat_room_model.dart';
import 'package:messagener_app/data/services/base_repository.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get _chatRoom => firestore.collection('chatRooms');
  CollectionReference getChatRoomMessages(String chatRoomId) {
    return _chatRoom.doc(chatRoomId).collection('messages');
  }

  Future<ChatRoomModel> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final users = [currentUserId, otherUserId]..sort();
    final roomId = users.join('_');

    final roomDoc = await _chatRoom.doc(roomId).get();

    if (roomDoc.exists) {
      return ChatRoomModel.fromFireStore(roomDoc);
    }

    final currentUsedData =
        (await firestore.collection('users').doc(currentUserId).get()).data();
    final otherUsedData =
        (await firestore.collection('users').doc(otherUserId).get()).data();

    final participantNames = {
      currentUserId: currentUsedData?['fullName']?.toString() ?? '',
      otherUserId: otherUsedData?['fullName']?.toString() ?? '',
    };

    final newRoom = ChatRoomModel(
      id: roomId,
      participants: users,
      participantNames: participantNames,
      lastReadTime: {
        currentUserId: Timestamp.now(),
        otherUserId: Timestamp.now(),
      },
    );

    await _chatRoom.doc(roomId).set(newRoom.toMap());
    return newRoom;
  }

  // send messages

  Future<void> sendMessages({
    required String chatRoomId,
    required String receiverId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    //batch
    final batch = firestore.batch();

    //get message sub collection
    final messageRef = getChatRoomMessages(chatRoomId);
    final messageDoc = messageRef.doc();

    //send chat messages
    final message = ChatMessage(
      id: messageDoc.id,
      chatId: chatRoomId,
      senderID: senderId,
      reciverId: receiverId,
      content: content,
      timestamp: Timestamp.now(),
      readBy: [senderId],
      type: type,
    );

    //add messages to sub collection
    batch.set(messageDoc, message.toMap());
    //update chatroom
    batch.update(_chatRoom.doc(chatRoomId), {
      'lastMessage': content,
      'lastMessageSenderId': senderId,
      'lastMessageTime': Timestamp.now(),
    });
    await batch.commit();
  }

  //get messages{doc yet}
  Stream<List<ChatMessage>> getMessage(
    String chatRoomId, {
    DocumentSnapshot? lastDocument,
  }) {
    var query = getChatRoomMessages(
      chatRoomId,
    ).orderBy('timestamp', descending: true).limit(20);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => ChatMessage.fromFireStore(doc)).toList(),
    );
  }

  //get more messages{doc yet}
  Future<List<ChatMessage>> getMoreMessage(
    String chatRoomId, {
    required DocumentSnapshot lastDocument,
  }) async {
    final query = getChatRoomMessages(chatRoomId)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(20);

    final snapshot = await query.get();

    return snapshot.docs.map((doc) => ChatMessage.fromFireStore(doc)).toList();
  }

  //recent chat rooms{doc yet}
  Stream<List<ChatRoomModel>> getChatRoooms(String userID) {
    return _chatRoom
        .where('participants', arrayContains: userID)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRoomModel.fromFireStore(doc))
              .toList(),
        );
  }

  //get unread message count{doc yet}
  Stream<int> getUnreadCount(String chatRoomId, String userId) {
    return getChatRoomMessages(chatRoomId)
        .where('reciverId', isEqualTo: userId)
        .where('status', isEqualTo: MessageStatus.sent.toString())
        .snapshots()
        .map((snapshots) => snapshots.docs.length);
  }
}
