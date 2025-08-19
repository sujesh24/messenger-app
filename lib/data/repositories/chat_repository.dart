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
      currentUserId: currentUsedData?['name']?.toString() ?? '',
      otherUserId: otherUsedData?['name']?.toString() ?? '',
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
}
