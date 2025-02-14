import 'package:athena_nike/enums/enums.dart';

class ChatModel {
  String name;
  String lastMessage;
  String senderUID;
  String contactUID; // doubles as groupID if group
  String image;
  MessageEnum messageType;
  String timeSent;

  // Constructor
  ChatModel({
    required this.name,
    required this.lastMessage,
    required this.senderUID,
    required this.contactUID,
    required this.image,
    required this.messageType,
    required this.timeSent,
  });
}
