import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/widgets/contact_message_widget.dart';
import 'package:athena_nike/widgets/my_message_widget.dart';
import 'package:athena_nike/widgets/swipe_to_widget.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.onRightSwipe,
    required this.isViewOnly,
    required this.isMe,
  });

  final MessageModel message;
  final Function() onRightSwipe;
  final bool isViewOnly;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return isMe
        ? isViewOnly
            ? MyMessageWidget(
                message: message,
              )
            : SwipeToWidget(
                onRightSwipe: onRightSwipe,
                message: message,
                isMe: isMe,
              )
        : isViewOnly
            ? ContactMessageWidget(
                message: message,
              )
            : SwipeToWidget(
                onRightSwipe: onRightSwipe,
                message: message,
                isMe: isMe,
              );
  }
}
