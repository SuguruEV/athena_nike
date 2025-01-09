import 'package:athena_nike/constants.dart';
import 'package:athena_nike/widgets/bottom_chat_field.dart';
import 'package:athena_nike/widgets/chat_app_bar.dart';
import 'package:athena_nike/widgets/chat_list.dart';
import 'package:athena_nike/widgets/group_chat_app_bar.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // Get arguments passed from the previous screen
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // Get the contactUID from the arguments
    final contactUID = arguments[Constants.contactUID];
    // Get the contactName from the arguments
    final contactName = arguments[Constants.contactName];
    // Get the contactImage from the arguments
    final contactImage = arguments[Constants.contactImage];
    // Get the groupId from the arguments
    final groupID = arguments[Constants.groupID];
    // Check if the groupId is empty - then it's a chat with a friend, else it's a group chat
    final isGroupChat = groupID.isNotEmpty ? true : false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: isGroupChat
            ? GroupChatAppBar(groupID: groupID) // Display group chat app bar
            : ChatAppBar(contactUID: contactUID), // Display individual chat app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Display the chat messages
            Expanded(
              child: ChatList(
                contactUID: contactUID,
                groupID: groupID,
              ),
            ),
            // Input field for sending new messages
            BottomChatField(
              contactUID: contactUID,
              contactName: contactName,
              contactImage: contactImage,
              groupID: groupID,
            ),
          ],
        ),
      ),
    );
  }
}