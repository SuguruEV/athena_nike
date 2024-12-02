import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/last_message_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
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
                        // Check if we sent the last message
                        final isMe = chat.senderUID == uid;
                        final lastMessage = isMe ? 'You: ${chat.message}' : chat.message;

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(chat.contactImage),
                          ),
                          title: Text(chat.contactName),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(chat.timeSent.toString()),
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
