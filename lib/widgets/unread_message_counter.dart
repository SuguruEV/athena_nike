import 'package:athena_nike/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnreadMessageCounter extends StatelessWidget {
  const UnreadMessageCounter({
    super.key,
    required this.uid,
    required this.contactUID,
  });

  final String uid;
  final String contactUID;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: context.read<ChatProvider>().getUnreadMessagesStream(
            userID: uid,
            contactUID: contactUID,
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
    );
  }
}