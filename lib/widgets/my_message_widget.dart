import 'package:athena_nike/models/message_model.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class MyMessageWidget extends StatefulWidget {
  const MyMessageWidget({super.key, required this.message});

  final MessageModel message;

  @override
  State<MyMessageWidget> createState() => _MyMessageWidgetState();
}

class _MyMessageWidgetState extends State<MyMessageWidget> {
  @override
  Widget build(BuildContext context) {
    final time = formatDate(widget.message.timeSent, [hh, ':', nn, ' ',]);

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 30.0,
                  top: 5.0,
                  bottom: 20.0,
                ),
                child: Text(
                  widget.message.message,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
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
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      widget.message.isSeen ? Icons.done_all : Icons.done,
                      size: 15,
                      color:
                          widget.message.isSeen ? Colors.blue : Colors.white60,
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
