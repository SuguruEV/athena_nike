import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/models/message_reply_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/streams/data_repository.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/utilities/my_dialogs.dart';
import 'package:athena_nike/widgets/align_message_left_widget.dart';
import 'package:athena_nike/widgets/align_message_right_widget.dart';
import 'package:athena_nike/widgets/date_widget.dart';
import 'package:athena_nike/widgets/message_widget.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.contactUID,
    required this.groupID,
  });

  final String contactUID;
  final String groupID;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // Scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    if (_scrollController.hasClients) _scrollController.dispose();
    super.dispose();
  }

  // Handle context menu actions
  void onContextMenyClicked(
      {required String item, required MessageModel message}) {
    switch (item) {
      case 'Reply':
        // Set the message reply to true
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          messageType: message.messageType,
          isMe: true,
        );

        context.read<ChatProvider>().setMessageReplyModel(messageReply);
        break;
      case 'Copy':
        // Copy message to clipboard
        Clipboard.setData(ClipboardData(text: message.message));
        GlobalMethods.showSnackBar(context, 'Message copied to clipboard');
        break;
      case 'Delete':
        final currentUserId =
            context.read<AuthenticationProvider>().userModel!.uid;
        final groupProvider = context.read<GroupProvider>();

        if (widget.groupID.isNotEmpty) {
          if (groupProvider.isSenderOrAdmin(
              message: message, uid: currentUserId)) {
            showDeletBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: true,
            );
            return;
          } else {
            showDeletBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: false,
            );
            return;
          }
        }
        showDeletBottomSheet(
          message: message,
          currentUserId: currentUserId,
          isSenderOrAdmin: true,
        );
        break;
    }
  }

  // Show delete bottom sheet
  void showDeletBottomSheet({
    required MessageModel message,
    required String currentUserId,
    required bool isSenderOrAdmin,
  }) {
    MyDialogs.deletionBottomSheet(
      context: context,
      message: message,
      currentUserId: currentUserId,
      isSenderOrAdmin: isSenderOrAdmin,
      contactUID: widget.contactUID,
      groupID: widget.groupID,
    );
  }

  // Send reaction to message
  void sendReactionToMessage(
      {required String reaction, required String messageID}) {
    // Get the sender uid
    final senderUID = context.read<AuthenticationProvider>().userModel!.uid;

    context.read<ChatProvider>().sendReactionToMessage(
          senderUID: senderUID,
          contactUID: widget.contactUID,
          messageID: messageID,
          reaction: reaction,
          groupID: widget.groupID.isNotEmpty,
        );
  }

  // Show emoji container
  void showEmojiContainer({required String messageID}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context);
            // Add emoji to message
            sendReactionToMessage(
              reaction: emoji.emoji,
              messageID: messageID,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current user uid
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return FirestorePagination(
      limit: 20,
      isLive: true,
      reverse: true,
      controller: _scrollController,
      query: DataRepository.getMessagesQuery(
        userID: uid,
        contactUID: widget.contactUID,
        isGroup: widget.groupID.isNotEmpty,
      ),
      itemBuilder: (context, documentSnapshot, index) {
        // Chat provider
        final chatProvider = context.read<ChatProvider>();
        // Get the message data at index
        final message = MessageModel.fromMap(
            documentSnapshot[index].data()! as Map<String, dynamic>);

        // Check if we sent the last message
        final isMe = message.senderUID == uid;

        // If the deletedBy contains the current user id then don't show the message
        if (message.deletedBy.contains(uid)) {
          return const SizedBox.shrink();
        }

        // Date header logic here
        Widget? dateHeader;
        if (index < documentSnapshot.length - 1) {
          final nextMessage = MessageModel.fromMap(
            documentSnapshot[index + 1].data()! as Map<String, dynamic>,
          );

          if (!GlobalMethods.isSameDay(
            message.timeSent,
            nextMessage.timeSent,
          )) {
            dateHeader = DateWidget(message: message);
          }
        } else if (index == documentSnapshot.length - 1) {
          dateHeader = DateWidget(message: message);
        }

        // Check if it's group chat
        if (widget.groupID.isNotEmpty) {
          chatProvider.setMessageStatus(
            currentUserId: uid,
            contactUID: widget.contactUID,
            messageID: message.messageID,
            isSeenByList: message.isSeenBy,
            isGroupChat: widget.groupID.isNotEmpty,
          );
        } else {
          if (!message.isSeen && message.senderUID != uid) {
            chatProvider.setMessageStatus(
              currentUserId: uid,
              contactUID: widget.contactUID,
              messageID: message.messageID,
              isSeenByList: message.isSeenBy,
              isGroupChat: widget.groupID.isNotEmpty,
            );
          }
        }

        return Column(
          children: [
            if (dateHeader != null) dateHeader,
            GestureDetector(
              onLongPress: () async {
                Navigator.of(context).push(
                  HeroDialogRoute(builder: (context) {
                    return ReactionsDialogWidget(
                      id: message.messageID,
                      messageWidget: isMe
                          ? AlignMessageRightWidget(
                              message: message,
                              viewOnly: true,
                              isGroupChat: widget.groupID.isNotEmpty,
                            )
                          : AlignMessageLeftWidget(
                              message: message,
                              viewOnly: true,
                              isGroupChat: widget.groupID.isNotEmpty,
                            ),
                      onReactionTap: (reaction) {
                        if (reaction == '➕') {
                          showEmojiContainer(
                            messageID: message.messageID,
                          );
                        } else {
                          sendReactionToMessage(
                            reaction: reaction,
                            messageID: message.messageID,
                          );
                        }
                      },
                      onContextMenuTap: (item) {
                        onContextMenyClicked(
                          item: item.label,
                          message: message,
                        );
                      },
                      widgetAlignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                    );
                  }),
                );
              },
              child: Hero(
                tag: message.messageID,
                child: MessageWidget(
                  message: message,
                  onRightSwipe: () {
                    // Set the message reply to true
                    final messageReply = MessageReplyModel(
                      message: message.message,
                      senderUID: message.senderUID,
                      senderName: message.senderName,
                      senderImage: message.senderImage,
                      messageType: message.messageType,
                      isMe: isMe,
                    );

                    context
                        .read<ChatProvider>()
                        .setMessageReplyModel(messageReply);
                  },
                  isMe: isMe,
                  isGroupChat: widget.groupID.isNotEmpty,
                ),
              ),
            ),
          ],
        );
      },
      initialLoader: const Center(
        child: CircularProgressIndicator(),
      ),
      onEmpty: Center(
        child: Text(
          'Start a conversation',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
              fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      bottomLoader: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}