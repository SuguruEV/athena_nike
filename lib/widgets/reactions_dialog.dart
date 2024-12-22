import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:flutter/material.dart';

class ReactionsDialog extends StatefulWidget {
  const ReactionsDialog({
    super.key,
    required this.uid,
    required this.message,
    required this.onReactionsTap,
    required this.onContextMenuTap,
  });

  final String uid;
  final MessageModel message;
  final Function(String) onReactionsTap;
  final Function(String) onContextMenuTap;

  @override
  State<ReactionsDialog> createState() => _ReactionsDialogState();
}

class _ReactionsDialogState extends State<ReactionsDialog> {
  @override
  Widget build(BuildContext context) {
    final isMyMessage = widget.uid == widget.message.senderUID;
    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
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
                  child: Column(
                    children: [
                      for (final menu in contextMenu)
                        InkWell(
                          onTap: () {
                            widget.onContextMenuTap(menu);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(menu,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    )),
                                Icon(
                                  menu == 'Reply'
                                      ? Icons.reply
                                      : menu == 'Copy'
                                          ? Icons.copy
                                          : Icons.delete,
                                ),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
