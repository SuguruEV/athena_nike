import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/align_message_right_widget.dart';
import 'package:athena_nike/widgets/align_message_left_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReactionsContextMenu extends StatefulWidget {
  const ReactionsContextMenu({
    super.key,
    required this.isMyMessage,
    required this.message,
    required this.contactUID,
    required this.groupID,
  });

  final bool isMyMessage;
  final MessageModel message;
  final String contactUID;
  final String groupID;

  @override
  State<ReactionsContextMenu> createState() => _ReactionsContextMenuState();
}

class _ReactionsContextMenuState extends State<ReactionsContextMenu> {
  bool reactionClicked = false;
  int? clickedReactionIndex;
  int? clickedContextMenuIndex;

  Future<void> sendReactionToMessage({
    required String reaction,
    required String messageID,
  }) async {
    // Get the Sender UID
    final senderUID = context.read<AuthenticationProvider>().userModel!.uid;

    await context.read<ChatProvider>().sendReactionToMessage(
          senderUID: senderUID,
          contactUID: widget.contactUID,
          messageID: messageID,
          reaction: reaction,
          groupID: widget.groupID.isNotEmpty,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 20.0,
            left: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: widget.isMyMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final reaction in reactions)
                          FadeInRight(
                            from: 0 + (reactions.indexOf(reaction) * 20),
                            duration: const Duration(milliseconds: 500),
                            child: InkWell(
                              onTap: () async {
                                setState(
                                  () {
                                    reactionClicked = true;
                                    clickedReactionIndex =
                                        reactions.indexOf(reaction);
                                  },
                                );

                                if (reaction == '➕') {
                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () {
                                      Navigator.pop(context, '➕');
                                    },
                                  );
                                } else {
                                  await sendReactionToMessage(
                                    reaction: reaction,
                                    messageID: widget.message.messageID,
                                  ).whenComplete(
                                    () {
                                      Navigator.pop(context);
                                    },
                                  );
                                }

                                // Set Back to False after 500 milliseconds
                                // Future.delayed(
                                //   const Duration(milliseconds: 500),
                                //   () {
                                //     setState(() {
                                //       reactionClicked = false;
                                //     });
                                //   },
                                // );
                              },
                              child: Pulse(
                                infinite: false,
                                duration: const Duration(milliseconds: 500),
                                animate: reactionClicked &&
                                    clickedReactionIndex ==
                                        reactions.indexOf(reaction),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    reaction,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Hero(
                tag: widget.message.messageID,
                child: widget.isMyMessage
                    ? AlignMessageRightWidget(
                        message: widget.message,
                        viewOnly: true,
                        isGroupChat: widget.groupID.isNotEmpty,
                      )
                    : AlignMessageLeftWidget(
                        message: widget.message,
                        viewOnly: true,
                        isGroupChat: widget.groupID.isNotEmpty,
                      ),
              ),
              Align(
                alignment: widget.isMyMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: widget.isMyMessage
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade800,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final menu in contextMenu)
                          InkWell(
                            onTap: () {
                              setState(() {
                                clickedContextMenuIndex =
                                    contextMenu.indexOf(menu);
                              });
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  Navigator.pop(context, menu);
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    menu,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Pulse(
                                    infinite: false,
                                    duration: const Duration(milliseconds: 500),
                                    animate: clickedContextMenuIndex ==
                                        contextMenu.indexOf(menu),
                                    child: Icon(
                                      menu == 'Reply'
                                          ? Icons.reply
                                          : menu == 'Copy'
                                              ? Icons.copy
                                              : Icons.delete,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
