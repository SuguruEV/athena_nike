import 'package:athena_nike/models/message_model.dart';
import 'package:flutter/material.dart';

class StackedReactionsWidget extends StatelessWidget {
  const StackedReactionsWidget({
    super.key,
    required this.message,
    required this.size,
    required this.onTap,
  });

  final MessageModel message;
  final double size;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    // If reactions are greater than 5, get the first 5 reactions
    final reactionsToShow =
        message.reactions.length > 5 ? message.reactions.sublist(0, 5) : message.reactions;
    // Remaining Reactions
    final remainingReactions = message.reactions.length - reactionsToShow.length;
    final allReactions = reactionsToShow
        .asMap()
        .map((index, reaction) {
          final value = Container(
            margin: EdgeInsets.only(left: index * 20.0),
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipOval(
              child: Text(
                reaction,
                style: TextStyle(fontSize: size),
              ),
            ),
          );
          return MapEntry(index, value);
        })
        .values
        .toList();
    return GestureDetector(
      onTap: () => onTap(),
      child: Row(
        children: [
          Stack(
            children: allReactions,
          ),
          // Show this only if there are more than 5 reactions
          if (remainingReactions > 0) ...{
            Positioned(
              left: 100,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade500,
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      '+$remainingReactions',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ),
            )
          }
        ],
      ),
    );
  }
}
