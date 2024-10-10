import 'package:athena_nike/constants.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
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
        title: const Text('Chats'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Message $index'),
                );
              },
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Type a message',
              suffixIcon: Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}
