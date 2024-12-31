
import 'dart:developer';

import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/last_message_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Cupertino Search Bar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(
                color: Colors.white,
              ),
              onChanged: (value) {
                print(value);
              },
            ),

            Expanded(
              child: StreamBuilder<List<LastMessageModel>>(
                stream: context.read<ChatProvider>().getChatsListStream(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    final chatsList = snapshot.data!;
                    return ListView.builder(
                      itemCount: chatsList.length,
                      itemBuilder: (context, index) {
                        final chat = chatsList[index];

                        return UserWidget(
                          chat: chat,
                          uid: uid,
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('No chats yet'),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UserWidget extends StatelessWidget {
  const UserWidget({
    super.key,
    required this.chat,
    required this.uid,
  });

  final LastMessageModel chat;
  final String uid;

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
              log('Unread Messages: $unreadMessages');
              return unreadMessages > 0
                  ? Container(
                      padding: const EdgeInsets.all(5),
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
      onTap: () {
        Navigator.pushNamed(
          context,
          Constants.chatScreen,
          arguments: {
            Constants.contactUID: chat.contactUID,
            Constants.contactName: chat.contactName,
            Constants.contactImage: chat.contactImage,
            Constants.groupID: '',
          },
        );
      },
    );
  }
}
