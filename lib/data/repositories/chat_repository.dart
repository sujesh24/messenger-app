import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messagener_app/data/models/chat_room_model.dart';
import 'package:messagener_app/data/services/base_repository.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get _chatRoom => firestore.collection('chatRooms');

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
}
