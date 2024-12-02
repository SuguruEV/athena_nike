import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/models/message_reply_model.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isLoading;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setMessageReplyModel(MessageReplyModel? messageReplyModel) {
    _messageReplyModel = messageReplyModel;
    notifyListeners();
  }

  // Firebase Initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Send Text Message To Firestore
  Future<void> sendTextMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required String groupID,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      var messageID = const Uuid().v4();

      // 1. Check if its a message reply and add the replied message to the message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      // 2. Update/Set the messagemodel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: message,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageID: messageID,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
      );

      // 3. Check if its a group message and send to group else send to contact
      if (groupID.isNotEmpty) {
        // Handle Group Message
      } else {
        // Handle Contact Message
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}
