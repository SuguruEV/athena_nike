import 'package:athena_nike/models/last_message_model.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    required this.chat,
    required this.uid,
    required this.onTap,
  });

  final LastMessageModel chat;
  final String uid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateTime = formatDate(chat.timeSent, [hh, ':', nn, ' ', am]);
    // Check if we sent the last message
    final isMe = chat.senderUID == uid;
    final lastMessage = isMe ? 'You: ${chat.message}' : chat.message;

    return ListTile(
      leading: userImageWidget(
        imageUrl: chat.contactImage,
        radius: 40,
        onTap: () {},
      ),
      contentPadding: EdgeInsets.zero,
      title: Text(chat.contactName),
      subtitle: messageToShow(
        type: chat.messageType,
        message: lastMessage,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dateTime),
          StreamBuilder<int>(
            stream: context.read<ChatProvider>().getUnreadMessagesStream(
                  userID: uid,
                  contactUID: chat.contactUID,
                  isGroup: false,
                ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SizedBox();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              final unreadMessages = snapshot.data!;
              return unreadMessages > 0
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(
                        10,
                        5,
                        10,
                        5,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 1,
                              blurRadius: 6.0,
                              offset: Offset(0, 1),
                            ),
                          ]),
                      child: Text(
                        unreadMessages.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox();
            },
          )
        ],
      ),
      onTap: onTap,
    );
  }
}