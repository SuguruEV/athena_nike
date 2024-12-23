import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/models/message_reply_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/contact_message_widget.dart';
import 'package:athena_nike/widgets/my_message_widget.dart';
import 'package:athena_nike/widgets/reactions_dialog.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key, required this.contactUID, required this.groupID});

  final String contactUID;
  final String groupID;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // Scroll Controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  showReactionsDialogue({required MessageModel message, required String uid}) {
    showDialog(
      context: context,
      builder: (context) => ReactionsDialog(
        uid: uid,
        message: message,
        onReactionsTap: (reaction) {},
        onContextMenuTap: (item) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current User UID
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return StreamBuilder<List<MessageModel>>(
      stream: context.read<ChatProvider>().getMessagesStream(
            userUID: uid,
            contactUID: widget.contactUID,
            isGroup: widget.groupID,
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

        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No Messages',
              textAlign: TextAlign.center,
              style: GoogleFonts.titilliumWeb(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          );
        }

        // Automatically Scrolls to the bottom on new message
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });

        if (snapshot.hasData) {
          final messagesList = snapshot.data!;
          return GroupedListView<dynamic, DateTime>(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            reverse: true,
            controller: _scrollController,
            elements: messagesList,
            groupBy: (element) {
              return DateTime(
                element.timeSent!.year,
                element.timeSent!.month,
                element.timeSent!.day,
              );
            },
            groupHeaderBuilder: (dynamic groupedByValue) => SizedBox(
              height: 40,
              child: buildDateTime(groupedByValue),
            ),
            itemBuilder: (context, dynamic element) {
              // Set message as seen
              if (!element.isSeen && element.senderUID != uid) {
                context.read<ChatProvider>().setMessageAsSeen(
                      userUID: uid,
                      contactUID: widget.contactUID,
                      messageID: element.messageID,
                      groupID: widget.groupID,
                    );
              }

              // Check if we sent the message
              final isMe = element.senderUID == uid;
              return isMe
                  ? InkWell(
                      onLongPress: () {
                        showReactionsDialogue(message: element, uid: uid);
                      },
                    child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                        ),
                        child: MyMessageWidget(
                          message: element,
                          onRightSwipe: () {
                            // Set the message reply to true
                            final messageReply = MessageReplyModel(
                              message: element.message,
                              senderUID: element.senderUID,
                              senderName: element.senderName,
                              senderImage: element.senderImage,
                              messageType: element.messageType,
                              isMe: isMe,
                            );
                    
                            context.read<ChatProvider>().setMessageReplyModel(
                                  messageReply,
                                );
                          },
                        ),
                      ),
                  )
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                      ),
                      child: ContactMessageWidget(
                        message: element,
                        onRightSwipe: () {
                          // Set the message reply to true
                          final messageReply = MessageReplyModel(
                            message: element.message,
                            senderUID: element.senderUID,
                            senderName: element.senderName,
                            senderImage: element.senderImage,
                            messageType: element.messageType,
                            isMe: isMe,
                          );

                          context.read<ChatProvider>().setMessageReplyModel(
                                messageReply,
                              );
                        },
                      ),
                    );
            },
            groupComparator: (value1, value2) => value2.compareTo(value1),
            itemComparator: (item1, item2) {
              var firstItem = item1.timeSent;
              var secondItem = item2.timeSent;

              return secondItem!.compareTo(firstItem!);
            },
            useStickyGroupSeparators: true,
            floatingHeader: true,
            order: GroupedListOrder.ASC,
          );
        }
        return const Center(
          child: Text('No Messages'),
        );
      },
    );
  }
}
