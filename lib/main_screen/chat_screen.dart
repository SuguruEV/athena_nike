import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:athena_nike/widgets/bottom_chat_field.dart';
import 'package:athena_nike/widgets/chat_app_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // Current User UID
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    // Get Arguments Passed From Previous Screen
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // Get ContactUID From Arguments
    final contactUID = arguments[Constants.contactUID];
    // Get ContactName From Arguments
    final contactName = arguments[Constants.contactName];
    // Get ContactImage From Arguments
    final contactImage = arguments[Constants.contactImage];
    // Get GroupID From Arguments
    final groupID = arguments[Constants.groupID];
    // Check If GroupID is Empty - Then It's A Chat With A User
    final isGroupChat = groupID.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactUID: contactUID),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: context.read<ChatProvider>().getMessagesStream(
                      userUID: uid,
                      contactUID: contactUID,
                      isGroup: groupID,
                    ),
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
                    final messagesList = snapshot.data!;
                    return ListView.builder(
                      itemCount: messagesList.length,
                      itemBuilder: (context, index) {
                        final message = messagesList[index];
                        final dateTime = formatDate(
                            message.timeSent, [hh, ':', nn, ' ', am]);
                        final isMe = message.senderUID == uid;
                        return Card(
                          color: isMe
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                          child: ListTile(
                            title: Text(
                              message.message,
                              style: TextStyle(
                                color: isMe
                                    ? Theme.of(context).cardColor
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                            subtitle: Text(
                              dateTime,
                              style: TextStyle(
                                color: isMe
                                    ? Theme.of(context).cardColor
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('No Messages'),
                  );
                },
              ),
            ),
            BottomChatField(
              contactUID: contactUID,
              contactName: contactName,
              contactImage: contactImage,
              groupID: groupID,
            )
          ],
        ),
      ),
    );
  }
}
