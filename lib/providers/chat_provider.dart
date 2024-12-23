import 'dart:io';

import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/last_message_model.dart';
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
    // Set loading to true
    setLoading(true);
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
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSuccess: onSuccess,
          onError: onError,
        );

        // Set Message reply model to null
        setMessageReplyModel(null);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  // Send File Message To Firestore
  Future<void> sendFileMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required File file,
    required MessageEnum messageType,
    required String groupID,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    // Set loading to true
    setLoading(true);

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

      // 2. Upload the file to firebase storage
      final ref =
          '${Constants.chatFiles}/${messageType.name}/${sender.uid}/$contactUID/$messageID';
      String fileURL = await storeFileToStorage(file: file, reference: ref);

      // 3. Update/Set the messagemodel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: fileURL,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageID: messageID,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
      );

      // 4. Check if its a group message and send to group else send to contact
      if (groupID.isNotEmpty) {
        // Handle Group Message
      } else {
        // Handle Contact Message
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSuccess: onSuccess,
          onError: onError,
        );

        // Set Message reply model to null
        setMessageReplyModel(null);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> handleContactMessage({
    required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required Function onSuccess,
    required Function(String p1) onError,
  }) async {
    try {
      // 0. Contact MessageModel
      final contactMessageModel = messageModel.copyWith(
        userID: messageModel.senderUID,
      );

      // 1. Initialize last message for the sender
      final senderLastMessage = LastMessageModel(
        senderUID: messageModel.senderUID,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        message: messageModel.message,
        messageType: messageModel.messageType,
        timeSent: messageModel.timeSent,
        isSeen: false,
      );

      // 2. Initialize last message for the contact
      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      // 3. Send Message to Sender Firestore Location
      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageModel.messageID)
          .set(messageModel.toMap());

      // 4. Send Message to Contact Firestore Location
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .collection(Constants.messages)
          .doc(messageModel.messageID)
          .set(contactMessageModel.toMap());

      // 5. Send the Last message to sender firestore location
      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .set(senderLastMessage.toMap());

      // 6. Send the last message to contact firestore location
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .set(contactLastMessage.toMap());

      // Run Transaction
      // await _firestore.runTransaction(
      //   (transaction) async {
      //     // 3. Send Message to Sender Firestore Location
      //     transaction.set(
      //       _firestore
      //           .collection(Constants.users)
      //           .doc(messageModel.senderUID)
      //           .collection(Constants.chats)
      //           .doc(contactUID)
      //           .collection(Constants.messages)
      //           .doc(messageModel.messageID),
      //       messageModel.toMap(),
      //     );

      //     transaction.set(
      //       _firestore
      //           .collection(Constants.users)
      //           .doc(contactUID)
      //           .collection(Constants.chats)
      //           .doc(messageModel.senderUID)
      //           .collection(Constants.messages)
      //           .doc(messageModel.messageID),
      //       contactMessageModel.toMap(),
      //     );

      //     // 5. Send the Last message to sender firestore location
      //     transaction.set(
      //       _firestore
      //           .collection(Constants.users)
      //           .doc(messageModel.senderUID)
      //           .collection(Constants.chats)
      //           .doc(contactUID),
      //       senderLastMessage.toMap(),
      //     );

      //     // 6. Send the last message to contact firestore location
      //     transaction.set(
      //       _firestore
      //           .collection(Constants.users)
      //           .doc(contactUID)
      //           .collection(Constants.chats)
      //           .doc(messageModel.senderUID),
      //       contactLastMessage.toMap(),
      //     );
      //   },
      // );

      // 7. Call onSuccess
      // Set loading to false
      setLoading(false);
      onSuccess();
    } on FirebaseException catch (e) {
      setLoading(false);
      onError(e.message ?? e.toString());
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  // Set Message as seen
  Future<void> setMessageAsSeen({
    required String userUID,
    required String contactUID,
    required String messageID,
    required String groupID,
  }) async {
    try {
      // 1. Check if its a group message
      if (groupID.isNotEmpty) {
        // Handle Group Message
      } else {
        // Handle Contact Message
        // 2. Update the current message as seen
        await _firestore
            .collection(Constants.users)
            .doc(userUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageID)
            .update({Constants.isSeen: true});
        // 3. Update the contact message as seen
        await _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(userUID)
            .collection(Constants.messages)
            .doc(messageID)
            .update({Constants.isSeen: true});
        // 4. Update the last message as seen for current user
        await _firestore
            .collection(Constants.users)
            .doc(userUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .update({Constants.isSeen: true});
        // 5. Update the last message as seen for contact user
        await _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(userUID)
            .update({Constants.isSeen: true});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Get ChatsList stream
  Stream<List<LastMessageModel>> getChatsListStream(String userId) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .orderBy(Constants.timeSent, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LastMessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Stream messages from chat collection
  Stream<List<MessageModel>> getMessagesStream({
    required String userUID,
    required String contactUID,
    required String isGroup,
  }) {
    if (isGroup.isNotEmpty) {
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      });
    } else {
      return _firestore
          .collection(Constants.users)
          .doc(userUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      });
    }
  }

  // Store file to storage and return file url
  Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    UploadTask uploadTask =
        _firebaseStorage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }
}
