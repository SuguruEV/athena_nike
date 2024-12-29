import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/widgets/audio_player_widget.dart';
import 'package:athena_nike/widgets/video_player_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayMessageType extends StatelessWidget {
  const DisplayMessageType({
    super.key,
    required this.message,
    required this.type,
    required this.color,
    required this.isReply,
    this.maxLines,
    this.overflow,
    required this.viewOnly,
  });

  final String message;
  final MessageEnum type;
  final Color color;
  final bool isReply;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    Widget messageToShow() {
      switch (type) {
        case MessageEnum.text:
          return Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 16,
            ),
            maxLines: maxLines,
            overflow: overflow,
          );
        case MessageEnum.image:
          return isReply
              ? const Icon(Icons.image)
              : CachedNetworkImage(
                  imageUrl: message,
                  fit: BoxFit.cover,
                );
        case MessageEnum.video:
          return isReply
              ? const Icon(Icons.video_collection)
              : VideoPlayerWidget(
                  videoUrl: message,
                  color: color,
                );
        case MessageEnum.audio:
          return isReply
              ? const Icon(Icons.audiotrack)
              : AudioPlayerWidget(
                  audioUrl: message,
                  color: color,
                );
        default:
          return Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 16.0,
            ),
            maxLines: maxLines,
            overflow: overflow,
          );
      }
    }

    return messageToShow();
  }
}
