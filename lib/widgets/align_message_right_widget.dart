import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/widgets/display_message_type.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class AlignMessageRightWidget extends StatelessWidget {
  const AlignMessageRightWidget({
    super.key,
    required this.message,
    this.viewOnly = false,
    required this.isGroupChat,
  });

  final MessageModel message;
  final bool viewOnly;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ', am]);
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
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          color: Colors.deepPurple,
          child: Stack(
            children: [
              Padding(
                padding: message.messageType == MessageEnum.text
                    ? const EdgeInsets.fromLTRB(10, 5, 20, 20)
                    : const EdgeInsets.fromLTRB(5, 5, 5, 25),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isReplying) ...{
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
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
                                  viewOnly: viewOnly,
                                )
                              ],
                            ),
                          ),
                        )
                      }
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
