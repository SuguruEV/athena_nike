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

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  // Firebase initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send text message to Firestore
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

      // Check if it's a message reply and add the replied message to the message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      // Create the message model
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

      // Check if it's a group message and send to group else send to contact
      if (groupID.isNotEmpty) {
        // Handle group message
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

        // Set loading to false
        setLoading(false);
        onSuccess();
        // Set message reply model to null
        setMessageReplyModel(null);
      } else {
        // Handle contact message
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSuccess: onSuccess,
          onError: onError,
        );

        // Set message reply model to null
        setMessageReplyModel(null);
      }
    } catch (e) {
      // Set loading to false
      setLoading(false);
      onError(e.toString());
    }
  }

  // Send file message to Firestore
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

      // Check if it's a message reply and add the replied message to the message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      // Upload file to Firebase Storage
      final ref =
          '${Constants.chatFiles}/${messageType.name}/${sender.uid}/$contactUID/$messageID';
      String fileUrl =
          await GlobalMethods.storeFileToStorage(file: file, reference: ref);

      // Create the message model
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: fileUrl,
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

      // Check if it's a group message and send to group else send to contact
      if (groupID.isNotEmpty) {
        // Handle group message
        await _firestore
            .collection(Constants.groups)
            .doc(groupID)
            .collection(Constants.messages)
            .doc(messageID)
            .set(messageModel.toMap());

        // Update the last message for the group
        await _firestore.collection(Constants.groups).doc(groupID).update({
          Constants.lastMessage: fileUrl,
          Constants.timeSent: DateTime.now().millisecondsSinceEpoch,
          Constants.senderUID: sender.uid,
          Constants.messageType: messageType.name,
        });

        // Set loading to false
        setLoading(false);
        onSuccess();
        // Set message reply model to null
        setMessageReplyModel(null);
      } else {
        // Handle contact message
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSuccess: onSuccess,
          onError: onError,
        );

        // Set message reply model to null
        setMessageReplyModel(null);
      }
    } catch (e) {
      // Set loading to false
      setLoading(false);
      onError(e.toString());
    }
  }

  // Handle contact message
  Future<void> handleContactMessage({
    required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // Create the contact message model
      final contactMessageModel = messageModel.copyWith(
        userId: messageModel.senderUID,
      );

      // Initialize last message for the sender
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

      // Initialize last message for the contact
      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      // Send message to sender's Firestore location
      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageModel.messageID)
          .set(messageModel.toMap());

      // Send message to contact's Firestore location
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .collection(Constants.messages)
          .doc(messageModel.messageID)
          .set(contactMessageModel.toMap());

      // Send the last message to sender's Firestore location
      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .set(senderLastMessage.toMap());

      // Send the last message to contact's Firestore location
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .set(contactLastMessage.toMap());

      // Call onSuccess
      // Set loading to false
      setLoading(false);
      onSuccess();
    } on FirebaseException catch (e) {
      // Set loading to false
      setLoading(false);
      onError(e.message ?? e.toString());
    } catch (e) {
      // Set loading to false
      setLoading(false);
      onError(e.toString());
    }
  }

// Send reaction to a message
  Future<void> sendReactionToMessage({
    required String senderUID,
    required String contactUID,
    required String messageID,
    required String reaction,
    required bool groupID,
  }) async {
    // Set loading to true
    setLoading(true);
    // A reaction is saved as senderUID=reaction
    String reactionToAdd = '$senderUID=$reaction';

    try {
      // Check if it's a group message
      if (groupID) {
        // Get the reaction list from Firestore
        final messageData = await _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageID)
            .get();

        // Add the message data to messageModel
        final message = MessageModel.fromMap(messageData.data()!);

        // Check if the reaction list is empty
        if (message.reactions.isEmpty) {
          // Add the reaction to the message
          await _firestore
              .collection(Constants.groups)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageID)
              .update({
            Constants.reactions: FieldValue.arrayUnion([reactionToAdd])
          });
        } else {
          // Get UIDs list from reactions list
          final uids = message.reactions.map((e) => e.split('=')[0]).toList();

          // Check if the reaction is already added
          if (uids.contains(senderUID)) {
            // Get the index of the reaction
            final index = uids.indexOf(senderUID);
            // Replace the reaction
            message.reactions[index] = reactionToAdd;
          } else {
            // Add the reaction to the list
            message.reactions.add(reactionToAdd);
          }

          // Update the message
          await _firestore
              .collection(Constants.groups)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageID)
              .update({Constants.reactions: message.reactions});
        }
      } else {
        // Handle contact message
        // Get the reaction list from Firestore
        final messageData = await _firestore
            .collection(Constants.users)
            .doc(senderUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageID)
            .get();

        // Add the message data to messageModel
        final message = MessageModel.fromMap(messageData.data()!);

        // Check if the reaction list is empty
        if (message.reactions.isEmpty) {
          // Add the reaction to the message
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
          // Get UIDs list from reactions list
          final uids = message.reactions.map((e) => e.split('=')[0]).toList();

          // Check if the reaction is already added
          if (uids.contains(senderUID)) {
            // Get the index of the reaction
            final index = uids.indexOf(senderUID);
            // Replace the reaction
            message.reactions[index] = reactionToAdd;
          } else {
            // Add the reaction to the list
            message.reactions.add(reactionToAdd);
          }

          // Update the message in sender's Firestore location
          await _firestore
              .collection(Constants.users)
              .doc(senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageID)
              .update({Constants.reactions: message.reactions});

          // Update the message in contact's Firestore location
          await _firestore
              .collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(senderUID)
              .collection(Constants.messages)
              .doc(messageID)
              .update({Constants.reactions: message.reactions});
        }
      }

      // Set loading to false
      setLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }

// Stream the unread messages for this user
  Stream<int> getUnreadMessagesStream({
    required String userId,
    required String contactUID,
    required bool isGroup,
  }) {
    // Check if it's a group message
    if (isGroup) {
      // Handle group message
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .asyncMap((event) {
        int count = 0;
        for (var doc in event.docs) {
          final message = MessageModel.fromMap(doc.data());
          if (!message.isSeenBy.contains(userId)) {
            count++;
          }
        }
        return count;
      });
    } else {
      // Handle contact message
      return _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .where(Constants.isSeen, isEqualTo: false)
          .where(Constants.senderUID, isNotEqualTo: userId)
          .snapshots()
          .map((event) => event.docs.length);
    }
  }

// Set message status
  Future<void> setMessageStatus({
    required String currentUserId,
    required String contactUID,
    required String messageID,
    required List<String> isSeenByList,
    required bool isGroupChat,
  }) async {
    // Check if it's a group chat
    if (isGroupChat) {
      if (isSeenByList.contains(currentUserId)) {
        return;
      } else {
        // Add the current user to the seenByList in all messages
        await _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageID)
            .update({
          Constants.isSeenBy: FieldValue.arrayUnion([currentUserId]),
        });
      }
    } else {
      // Handle contact message
      // Update the current message as seen
      await _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageID)
          .update({Constants.isSeen: true});
      // Update the contact message as seen
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .collection(Constants.messages)
          .doc(messageID)
          .update({Constants.isSeen: true});

      // Update the last message as seen for current user
      await _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .update({Constants.isSeen: true});

      // Update the last message as seen for contact
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .update({Constants.isSeen: true});
    }
  }

// Delete message
  Future<void> deleteMessage({
    required String currentUserId,
    required String contactUID,
    required String messageID,
    required String messageType,
    required bool isGroupChat,
    required bool deleteForEveryone,
  }) async {
    // Set loading to true
    setLoading(true);

    // Check if it's a group chat
    if (isGroupChat) {
      // Handle group message
      await _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageID)
          .update({
        Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
      });

      // If delete for everyone and message type is not text, delete the file from storage
      if (deleteForEveryone) {
        // Get all group members' UIDs and put them in deletedBy list
        final groupData =
            await _firestore.collection(Constants.groups).doc(contactUID).get();

        final List<String> groupMembers =
            List<String>.from(groupData.data()![Constants.membersUIDs]);

        // Update the message as deleted for everyone
        await _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageID)
            .update({Constants.deletedBy: FieldValue.arrayUnion(groupMembers)});

        if (messageType != MessageEnum.text.name) {
          // Delete the file from storage
          await deleteFileFromStorage(
            currentUserId: currentUserId,
            contactUID: contactUID,
            messageID: messageID,
            messageType: messageType,
          );
        }
      }

      // Set loading to false
      setLoading(false);
    } else {
      // Handle contact message
      // Update the current message as deleted
      await _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageID)
          .update({
        Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
      });

      // Check if delete for everyone, then return if false
      if (!deleteForEveryone) {
        // Set loading to false
        setLoading(false);
        return;
      }

      // Update the contact message as deleted
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .collection(Constants.messages)
          .doc(messageID)
          .update({
        Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
      });

      // Delete the file from storage
      if (messageType != MessageEnum.text.name) {
        await deleteFileFromStorage(
          currentUserId: currentUserId,
          contactUID: contactUID,
          messageID: messageID,
          messageType: messageType,
        );
      }

      // Set loading to false
      setLoading(false);
    }
  }

// Delete file from storage
  Future<void> deleteFileFromStorage({
    required String currentUserId,
    required String contactUID,
    required String messageID,
    required String messageType,
  }) async {
    final firebaseStorage = FirebaseStorage.instance;
    // Delete the file from storage
    await firebaseStorage
        .ref(
            '${Constants.chatFiles}/$messageType/$currentUserId/$contactUID/$messageID')
        .delete();
  }

// Stream the last message collection
  Stream<QuerySnapshot> getLastMessageStream({
    required String userId,
    required String groupID,
  }) {
    return groupID.isNotEmpty
        ? _firestore
            .collection(Constants.groups)
            .where(Constants.membersUIDs, arrayContains: userId)
            .snapshots()
        : _firestore
            .collection(Constants.users)
            .doc(userId)
            .collection(Constants.chats)
            .snapshots();
  }
}
