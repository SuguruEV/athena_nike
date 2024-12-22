import 'package:athena_nike/constants.dart';
import 'package:athena_nike/widgets/audio_player_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayMessageType extends StatelessWidget {
  const DisplayMessageType({
    super.key,
    required this.message,
    required this.type,
    required this.color,
    this.maxLines,
    this.overflow,
  });

  final String message;
  final MessageEnum type;
  final Color color;
  final int? maxLines;
  final TextOverflow? overflow;

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
          return CachedNetworkImage(
            imageUrl: message,
            fit: BoxFit.cover,
          );
        case MessageEnum.video:
          return Image.network(
            message,
            fit: BoxFit.cover,
          );
        case MessageEnum.audio:
          return AudioPlayerWidget(audioUrl: message);
        default:
          return Text(
            message,
            style: const TextStyle(
              color: Colors.white,
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
