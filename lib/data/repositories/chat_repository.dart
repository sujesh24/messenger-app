import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messagener_app/data/models/chat_message.dart';
import 'package:messagener_app/data/models/chat_room_model.dart';
import 'package:messagener_app/data/models/user_model.dart';
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

  //get messages
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

  //get more messages
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

  //recent chat rooms
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

  //get unread message count
  Stream<int> getUnreadCount(String chatRoomId, String userId) {
    return getChatRoomMessages(chatRoomId)
        .where('reciverId', isEqualTo: userId)
        .where('status', isEqualTo: MessageStatus.sent.toString())
        .snapshots()
        .map((snapshots) => snapshots.docs.length);
  }

  //mark message as read
  Future<void> markMessageAsRead(String chatRoomId, String userId) async {
    try {
      final batch = firestore.batch();
      final unreadMessages = await getChatRoomMessages(chatRoomId)
          .where('reciverId', isEqualTo: userId)
          .where('status', isEqualTo: MessageStatus.sent.toString())
          .get();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
          'status': MessageStatus.read.toString(),
        });
      }
      await batch.commit();
    } catch (_) {}
  }

  //online status and last seen{doc yet}
  Stream<Map<String, dynamic>> getUserOnlineStatus(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map((
      snapshots,
    ) {
      final data = snapshots.data();
      return {
        'isOnline': data?['isOnline'] ?? false,
        'lastSeen': data?['lastSeen'],
      };
    });
  }

  //update online {doc yet}

  Future<void> updateUserStatus(String userId, bool isOnline) async {
    await firestore.collection('users').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

  //update isTyping{doc yet}
  Future<void> updateTypingStatus(
    String userId,
    String chatRoomId,
    bool isTyping,
  ) async {
    final doc = await _chatRoom.doc(chatRoomId).get();
    if (!doc.exists) {
      return;
    }
    if (doc.exists) {
      await _chatRoom.doc(chatRoomId).update({
        'isTyping': isTyping,
        'typingUserId': isTyping ? userId : null,
      });
    }
  }

  // isTyping status{doc yet}
  Stream<Map<String, dynamic>> getTypingStatus(String chatRoomId) {
    return _chatRoom.doc(chatRoomId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return {'isTyping': false, 'typingUserId': null};
      }
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        'isTyping': data['isTyping'] ?? false,
        'typingUserId': data['typingUserId'],
      };
    });
  }

  //block and unblock{doc yet}

  Future<void> blockUser(String currentUserId, String otherUserId) async {
    final userRef = firestore.collection('users').doc(currentUserId);
    await userRef.update({
      'blockedUsers': FieldValue.arrayUnion([otherUserId]),
    });
  }

  Future<void> unBlockUser(String currentUUserId, String otherUserId) async {
    final userRef = firestore.collection('users').doc(currentUUserId);
    await userRef.update({
      'blockedUsers': FieldValue.arrayRemove([otherUserId]),
    });
  }

  //check block or unblock
  Stream<bool> isUserBlocked(String currentUserId, String otherUSerId) {
    return firestore.collection('users').doc(currentUserId).snapshots().map((
      doc,
    ) {
      final userData = UserModel.fromFirestore(doc);
      return userData.blockedUsers.contains(otherUSerId);
    });
  }

  Stream<bool> imIBlocked(String currentUserId, String otherUserId) {
    return firestore.collection('users').doc(otherUserId).snapshots().map((
      doc,
    ) {
      final userData = UserModel.fromFirestore(doc);
      return userData.blockedUsers.contains(currentUserId);
    });
  }
}
