import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:messagener_app/data/models/chat_message.dart';
import 'package:messagener_app/data/services/service_locator.dart';
import 'package:messagener_app/logic/cubits/chat/chat_cubit.dart';
import 'package:messagener_app/logic/cubits/chat/chat_state.dart';
import 'package:messagener_app/presentation/widgets/loading_dots.dart';

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

  bool _isComposing = false;

  //
  @override
  void initState() {
    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.reciverID);
    messageController.addListener(_onTextChanged);
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

  //isTyping{doc yet}

  void _onTextChanged() {
    final isCompoing = messageController.text.isNotEmpty;
    if (isCompoing != _isComposing) {
      setState(() {
        _isComposing = isCompoing;
      });
      if (isCompoing) {
        _chatCubit.startTimer();
      }
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    _chatCubit.leaveChat();
    super.dispose();
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
                BlocBuilder<ChatCubit, ChatState>(
                  bloc: _chatCubit,
                  builder: (context, state) {
                    if (state.isReciverTyping) {
                      return Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            child: const LoadingDots(),
                          ),
                          Text(
                            'Typing',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      );
                    }
                    if (state.isReciverOnline) {
                      return const Text(
                        'Online',
                        style: TextStyle(color: Colors.green, fontSize: 13),
                      );
                    }
                    if (state.reciverLastSeen != null) {
                      final lastSeen = state.reciverLastSeen!.toDate();
                      return Text(
                        'Last seen at ${DateFormat('h:mm a').format(lastSeen)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            bloc: _chatCubit,
            builder: (context, state) {
              if (state.isUserBlocked) {
                return TextButton.icon(
                  onPressed: () async {
                    await _chatCubit.unBlockUser(widget.reciverID);
                  },
                  label: const Text('Unblock'),
                  icon: const Icon(Icons.block),
                );
              }

              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'block') {
                    final bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Are you sure want to block ${widget.reciverName}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Block',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _chatCubit.blockUser(widget.reciverID);
                    }
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem(
                    value: 'block',
                    child: Text('Block User'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      //{doc yet} about block builder
      body: BlocBuilder<ChatCubit, ChatState>(
        bloc: _chatCubit,
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ChatStatus.error) {
            return Center(child: Text(state.error ?? 'Something went wrong!'));
          }
          return Column(
            children: [
              if (state.amIBlocked)
                Container(
                  color: Colors.red.withAlpha(25),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    'You are blocked by ${widget.reciverName}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: state.message.length,
                  itemBuilder: (context, index) {
                    final message = state.message[index];
                    final isMe = message.senderID == _chatCubit.currentUserId;
                    return ChatBubble(message: message, isMe: isMe);
                  },
                ),
              ),
              // Message input field
              if (!state.amIBlocked && !state.isUserBlocked)
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
          );
        },
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
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 15,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(message.timestamp.toDate()),
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 12,
                  ),
                ),
                if (isMe)
                  Icon(
                    Icons.done_all,
                    size: 16,
                    color: message.status == MessageStatus.read
                        ? Colors.blue
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
