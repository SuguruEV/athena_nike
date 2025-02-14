import 'package:athena_nike/models/chat_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/unread_message_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    required this.chatModel,
    required this.isGroup,
    required this.onTap,
  });

  final ChatModel chatModel;
  final bool isGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return ListTile(
      leading: GlobalMethods.userImageWidget(
        imageUrl: chatModel.image,
        radius: 40,
        onTap: () {},
      ),
      contentPadding: EdgeInsets.zero,
      title: Text(chatModel.name),
      subtitle: Row(
        children: [
          // Display "You:" if the current user is the sender
          uid == chatModel.senderUID
              ? const Text(
                  'You:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          const SizedBox(width: 5),
          // Display the last message
          GlobalMethods.messageToShow(
            type: chatModel.messageType,
            message: chatModel.lastMessage,
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the time the message was sent
            Text(chatModel.timeSent),
            // Display the unread message counter
            UnreadMessageCounter(
              uid: uid,
              contactUID: chatModel.contactUID,
              isGroup: isGroup,
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}