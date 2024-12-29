import 'package:athena_nike/minor_screens/reactions_context_menu.dart';
import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/models/message_reply_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/utilities/hero_dialog_route.dart';
import 'package:athena_nike/widgets/message_widget.dart';
import 'package:athena_nike/widgets/stacked_reactions.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void onContextMenuClicked({
    required String item,
    required MessageModel message,
  }) {
    switch (item) {
      case 'Reply':
        // Set the message reply to true
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          isMe: true,
          messageType: message.messageType,
        );

        context.read<ChatProvider>().setMessageReplyModel(
              messageReply,
            );
        break;
      case 'Copy':
        // Copy message to clipboard
        Clipboard.setData(ClipboardData(text: message.message));
        showSnackBar(context, 'Message copied to clipboard');
        break;
      case 'Delete':
        // Delete the message
        // TODO Delete the message
        // context.read<ChatProvider>().deleteMessage(
        //       userUID: context.read<AuthenticationProvider>().userModel!.uid,
        //       contactUID: widget.contactUID,
        //       messageID: message.messageID,
        //       groupID: widget.groupID,
        //     );
        break;
    }
  }

  void sendReactionToMessage({
    required String reaction,
    required String messageID,
  }) {
    // Get the Sender UID
    final senderUID = context.read<AuthenticationProvider>().userModel!.uid;

    context.read<ChatProvider>().sendReactionToMessage(
          senderUID: senderUID,
          contactUID: widget.contactUID,
          messageID: messageID,
          reaction: reaction,
          groupID: widget.groupID.isNotEmpty,
        );
  }

  void showEmojiContainer({
    required String messageID,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiPicker(onEmojiSelected: (category, emoji) {
          Navigator.pop(context);

          // Add the emoji to the message
          sendReactionToMessage(reaction: emoji.emoji, messageID: messageID);
        }),
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
              final padding1 = element.reactions.isEmpty ? 8.0 : 20.0;
              final padding2 = element.reactions.isEmpty ? 8.0 : 25.0;

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
              return Stack(
                children: [
                  InkWell(
                    onLongPress: () async {
                      // showReactionsDialogue(message: element, isMe: isMe);
                      String? item = await Navigator.of(context).push(
                        HeroDialogRoute(
                          builder: (context) {
                            return ReactionsContextMenu(
                              isMyMessage: isMe,
                              message: element,
                              contactUID: widget.contactUID,
                              groupID: widget.groupID,
                            );
                          },
                        ),
                      );

                      if (item == null) return;

                      if (item == '➕') {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          showEmojiContainer(messageID: element.messageID);
                        });
                      } else {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          onContextMenuClicked(item: item, message: element);
                        });
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 8.0,
                        bottom: isMe ? padding1 : padding2,
                      ),
                      child: Hero(
                        tag: element.messageID,
                        child: MessageWidget(
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
                          isViewOnly: false,
                          isMe: isMe,
                        ),
                      ),
                    ),
                  ),
                  isMe
                      ? Positioned(
                          bottom: 4,
                          right: 90,
                          child: StackedReactionsWidget(
                            message: element,
                            size: 20,
                            onTap: () {},
                          ),
                        )
                      : Positioned(
                          bottom: 0,
                          left: 50,
                          child: StackedReactionsWidget(
                            message: element,
                            size: 20,
                            onTap: () {},
                          ),
                        ),
                ],
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
