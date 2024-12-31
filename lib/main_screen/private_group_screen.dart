import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/group_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrivateGroupScreen extends StatefulWidget {
  const PrivateGroupScreen({super.key});

  @override
  State<PrivateGroupScreen> createState() => _PrivateGroupScreenState();
}

class _PrivateGroupScreenState extends State<PrivateGroupScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              onChanged: (value) {},
            ),
          ),

          // Stream Builder for private groups
          StreamBuilder<List<GroupModel>>(
            stream: context
                .read<GroupProvider>()
                .getPrivateGroupsStream(userID: uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occurred'),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No private groups found'),
                );
              }
              return Expanded(
                  child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final chat = snapshot.data![index];
                  final dateTime =
                            formatDate(chat.timeSent, [hh, ':', nn, ' ', am]);
                        // Check if we sent the last message
                        final isMe = chat.senderUID == uid;
                        final lastMessage =
                            isMe ? 'You: ${chat.lastMessage}' : chat.lastMessage;
                  return ListTile(
                          leading: userImageWidget(
                            imageUrl: chat.groupImage,
                            radius: 40,
                            onTap: () {},
                          ),
                          contentPadding: EdgeInsets.zero,
                          title: Text(chat.groupName),
                          subtitle: messageToShow(
                            type: chat.messageType,
                            message: lastMessage,
                          ),
                          trailing: Text(dateTime),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Constants.chatScreen,
                              arguments: {
                                Constants.contactUID: chat.groupID,
                                Constants.contactName: chat.groupName,
                                Constants.contactImage: chat.groupImage,
                                Constants.groupID: chat.groupID,
                              },
                            );
                          },
                        );
                },
              ));
            },
          )
        ],
      ),
    );
  }
}
