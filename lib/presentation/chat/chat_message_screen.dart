import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messagener_app/data/models/chat_message.dart';
import 'package:messagener_app/data/services/service_locator.dart';
import 'package:messagener_app/logic/cubits/chat/chat_cubit.dart';

class ChatMessageScreen extends StatefulWidget {
  const ChatMessageScreen({
    super.key,
    required this.reciverID,
    required this.reciverName,
  });
  final String reciverID;
  final String reciverName;

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  late final ChatCubit _chatCubit;

  //
  @override
  void initState() {
    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.reciverID);
    super.initState();
  }

  Future<void> _handleSendMessage() async {
    final message = messageController.text.trim();
    messageController.clear();
    await _chatCubit.sendMessage(
      content: message,
      recviverId: widget.reciverID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
              child: Text(widget.reciverName[0].toUpperCase()),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.reciverName),
                const Text(
                  'Online',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return ChatBubble(
                  message: ChatMessage(
                    id: '4848848',
                    chatId: '123456',
                    senderID: '654321',
                    reciverId: '123456',
                    content: 'Hello there this is me!',
                    timestamp: Timestamp.now(),
                    readBy: [],
                  ),
                  isMe: true,
                );
              },
            ),
          ),
          // Message input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_emotions,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onTap: () {
                          //
                        },
                        controller: messageController,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        // maxLines: null,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          hintText: 'type a message',
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: _handleSendMessage,
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//chat bubble
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  // final bool showTime;
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    // required this.showTime
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '8:05AM',
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
                Icon(
                  Icons.done_all,
                  size: 16,
                  color: message.status == MessageStatus.read
                      ? Colors.red
                      : Colors.white70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
