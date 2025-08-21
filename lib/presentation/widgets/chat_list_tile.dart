//chat room model as chat
//cuurent userid
//callback ontap method

import 'package:flutter/material.dart';

import 'package:messagener_app/data/models/chat_room_model.dart';

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
    );
    final name = chat.participantNames![otherUSerId] ?? 'Unknown';
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
      trailing: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Text('3'),
      ),
    );
  }
}
