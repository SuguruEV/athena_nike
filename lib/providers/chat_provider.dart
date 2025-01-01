import 'dart:io';

import 'package:athena_nike/constants.dart';
import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/last_message_model.dart';
import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/models/message_reply_model.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/utilities/global_methods.dart';
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
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
      );

      // 3. Check if its a group message and send to group else send to contact
      if (groupID.isNotEmpty) {
        // Handle Group Message
        await _firestore
            .collection(Constants.groups)
            .doc(groupID)
            .collection(Constants.messages)
            .doc(messageID)
            .set(messageModel.toMap());

        // Update the last message for the group
        await _firestore.collection(Constants.groups).doc(groupID).update({
          Constants.lastMessage: message,
          Constants.timeSent: DateTime.now().millisecondsSinceEpoch,
          Constants.senderUID: sender.uid,
          Constants.messageType: messageType.name,
        });

        setLoading(true);

        // Set message reply model to null
        setMessageReplyModel(null);
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
      setLoading(true);
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
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
      );

      // 4. Check if its a group message and send to group else send to contact
      if (groupID.isNotEmpty) {
        // Handle Group Message

        await _firestore
            .collection(Constants.groups)
            .doc(groupID)
            .collection(Constants.messages)
            .doc(messageID)
            .set(messageModel.toMap());

        // Update the last message for the group
        await _firestore.collection(Constants.groups).doc(groupID).update({
          Constants.lastMessage: fileURL,
          Constants.timeSent: DateTime.now().millisecondsSinceEpoch,
          Constants.senderUID: sender.uid,
          Constants.messageType: messageType.name,
        });

        setLoading(true);

        // Set message reply model to null
        setMessageReplyModel(null);
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
      setLoading(true);
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

  // Send Reaction to Message
  Future<void> sendReactionToMessage({
    required String senderUID,
    required String contactUID,
    required String messageID,
    required String reaction,
    required bool groupID,
  }) async {
    // Set Loading to true
    setLoading(true);
    // A reaction is saved as senderUID-reaction
    final reactionToAdd = '$senderUID-$reaction';

    try {
      // 1. Check if its a group message
      if (groupID) {
        // Handle group message
        // 2. Get the reaction list from firestore
        final messageData = await _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageID)
            .get();

        // 3. Add the message data to messageModel
        final message = MessageModel.fromMap(messageData.data()!);

        // 4. Check if the reaction list is empty
        if (message.reactions.isEmpty) {
          // 5. Add the reaction to the message
          await _firestore
              .collection(Constants.groups)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageID)
              .update({
            Constants.reactions: FieldValue.arrayUnion([reactionToAdd])
          });
        } else {
          // 6. Get UIDs list from reactions list
          final uids = message.reactions.map((e) => e.split('-')[0]).toList();

          // 7. Check if the reaction is already added
          if (uids.contains(senderUID)) {
            // 8. Get the index of the reaction
            final index = uids.indexOf(senderUID);
            // 9. Replace the reaction
            message.reactions[index] = reactionToAdd;
          } else {
            // 10. Add the reaction to the list
            message.reactions.add(reactionToAdd);
          }

          // 11. Update the message reactions
          await _firestore
              .collection(Constants.groups)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageID)
              .update({
            Constants.reactions: message.reactions,
          });
        }
      } else {
        // Handle contact message
        // 2. Get the reaction list from firestore
        final messageData = await _firestore
            .collection(Constants.users)
            .doc(senderUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageID)
            .get();

        // 3. Add the message data to messageModel
        final message = MessageModel.fromMap(messageData.data()!);

        // 4. Check if the reaction list is empty
        if (message.reactions.isEmpty) {
          // 5. Add the reaction to the message
          await _firestore
              .collection(Constants.users)
              .doc(senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageID)
              .update({
            Constants.reactions: FieldValue.arrayUnion([reactionToAdd])
          });
        } else {
          // 6. Get UIDs list from reactions list
          final uids = message.reactions.map((e) => e.split('-')[0]).toList();

          // 7. Check if the reaction is already added
          if (uids.contains(senderUID)) {
            // 8. Get the index of the reaction
            final index = uids.indexOf(senderUID);
            // 9. Replace the reaction
            message.reactions[index] = reactionToAdd;
          } else {
            // 10. Add the reaction to the list
            message.reactions.add(reactionToAdd);
          }

          // 11. Update the message reactions
          await _firestore
              .collection(Constants.users)
              .doc(senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageID)
              .update({
            Constants.reactions: message.reactions,
          });

          // 12. Update the last message reactions
          await _firestore
              .collection(Constants.users)
              .doc(senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .update({
            Constants.reactions: message.reactions,
          });
        }
      }

      // Set Loading to false
      setLoading(false);
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

  // Stream the unread messages for this user
  Stream<int> getUnreadMessagesStream({
    required String userID,
    required String contactUID,
    required bool isGroup,
  }) {
    // 1. Check if it's a group message
    if (isGroup) {
      // Handle Group Message
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .asyncMap(
        (event) {
          int count = 0;
          for (var doc in event.docs) {
            final message = MessageModel.fromMap(doc.data());
            if (!message.isSeenBy.contains(userID)) {
              count++;
            }
          }
          return count;
        },
      );
    } else {
      // Handle Contact Message
      return _firestore
          .collection(Constants.users)
          .doc(userID)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .where(Constants.isSeen, isEqualTo: false)
          .where(Constants.senderUID, isNotEqualTo: userID)
          .snapshots()
          .map((event) => event.docs.length);
    }
  }
}
