import 'package:flutter/material.dart';

import 'package:messagener_app/data/models/chat_room_model.dart';
import 'package:messagener_app/data/repositories/chat_repository.dart';
import 'package:messagener_app/data/services/service_locator.dart';

class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.chat,
    required this.currentUserID,
    required this.onTap,
  });
  final ChatRoomModel chat;
  final String currentUserID;
  final VoidCallback onTap;

  String _getOtherUserNAme() {
    final otherUSerId = chat.participants.firstWhere(
      (id) => id != currentUserID,
      orElse: () => '', // Add this line to prevent StateError
    );

    if (otherUSerId.isEmpty) return 'Unknown';

    final name = chat.participantNames?[otherUSerId] ?? 'Unknown';
    return name.isNotEmpty ? name : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final otherUserName = _getOtherUserNAme();
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
        child: Text(
          otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'U',
        ),
      ),
      title: Text(
        otherUserName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600]),
      ),
      onTap: onTap,
      //stream builder
      //if has no data return sized box otherwise return container
      trailing: StreamBuilder<int>(
        stream: getIt<ChatRepository>().getUnreadCount(chat.id, currentUserID),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == 0) {
            return const SizedBox();
          }
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              snapshot.data.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
