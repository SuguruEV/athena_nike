import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/widgets/display_message_type.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({
    super.key,
    required this.message,
  });

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [
      hh,
      ':',
      nn,
      ' ',
      am,
    ]);
    final isReplying = message.repliedTo.isNotEmpty;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        child: Card(
          elevation: 5,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          color: Colors.deepPurple,
          child: Stack(
            children: [
              Padding(
                padding: message.messageType == MessageEnum.text
                    ? const EdgeInsets.fromLTRB(
                        10.0,
                        5.0,
                        20.0,
                        20.0,
                      )
                    : const EdgeInsets.fromLTRB(
                        5.0,
                        5.0,
                        5.0,
                        25.0,
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isReplying) ...{
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColorDark
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                message.repliedTo,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DisplayMessageType(
                                message: message.repliedMessage,
                                type: message.repliedMessageType,
                                color: Colors.white,
                                isReply: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    },
                    DisplayMessageType(
                      message: message.message,
                      type: message.messageType,
                      color: Colors.white,
                      isReply: false,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      message.isSeen ? Icons.done_all : Icons.done,
                      size: 15,
                      color: message.isSeen ? Colors.blue : Colors.white60,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
