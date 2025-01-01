import 'package:athena_nike/models/group_model.dart';
import 'package:athena_nike/models/last_message_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/unread_message_counter.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    required this.chat,
    this.group,
    required this.isGroup,
    required this.onTap,
  });

  final LastMessageModel? chat;
  final GroupModel? group;
  final bool isGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final lastMessage = chat != null ? chat!.message : group!.lastMessage;
    final senderUID = chat != null ? chat!.senderUID : group!.senderUID;

    final timeSent = chat != null ? chat!.timeSent : group!.timeSent;
    final dateTime = formatDate(timeSent, [hh, ':', nn, ' ', am]);

    final imageURL = chat != null ? chat!.contactImage : group!.groupImage;

    final name = chat != null ? chat!.contactName : group!.groupName;

    final contactUID = chat != null ? chat!.contactUID : group!.groupID;

    final messageType = chat != null ? chat!.messageType : group!.messageType;

    return ListTile(
      leading: userImageWidget(
        imageUrl: imageURL,
        radius: 40,
        onTap: () {},
      ),
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Row(
        children: [
          uid == senderUID
              ? const Text(
                  'You',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          messageToShow(
            type: messageType,
            message: lastMessage,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dateTime),
          UnreadMessageCounter(uid: uid, contactUID: contactUID)
        ],
      ),
      onTap: onTap,
    );
  }
}
