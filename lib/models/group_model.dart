import 'package:athena_nike/constants.dart';
import 'package:athena_nike/enums/enums.dart';

class GroupModel {
  String creatorUID;
  String groupName;
  String groupDescription;
  String groupImage;
  String groupID;
  String lastMessage;
  String senderUID;
  MessageEnum messageType;
  String messageID;
  DateTime timeSent;
  DateTime createdAt;
  bool isPrivate;
  bool editSettings;
  bool approveMembers;
  bool lockMessages;
  bool requestToJoin;
  List<String> membersUIDs;
  List<String> adminsUIDs;
  List<String> awaitingApprovalUIDs;

  GroupModel({
    required this.creatorUID,
    required this.groupName,
    required this.groupDescription,
    required this.groupImage,
    required this.groupID,
    required this.lastMessage,
    required this.senderUID,
    required this.messageType,
    required this.messageID,
    required this.timeSent,
    required this.createdAt,
    required this.isPrivate,
    required this.editSettings,
    required this.approveMembers,
    required this.lockMessages,
    required this.requestToJoin,
    required this.membersUIDs,
    required this.adminsUIDs,
    required this.awaitingApprovalUIDs,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.creatorUID: creatorUID,
      Constants.groupName: groupName,
      Constants.groupDescription: groupDescription,
      Constants.groupImage: groupImage,
      Constants.groupID: groupID,
      Constants.lastMessage: lastMessage,
      Constants.senderUID: senderUID,
      Constants.messageType: messageType.name,
      Constants.messageID: messageID,
      Constants.timeSent: timeSent.millisecondsSinceEpoch,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
      Constants.isPrivate: isPrivate,
      Constants.editSettings: editSettings,
      Constants.approveMembers: approveMembers,
      Constants.lockMessages: lockMessages,
      Constants.requestToJoin: requestToJoin,
      Constants.membersUIDs: membersUIDs,
      Constants.adminsUIDs: adminsUIDs,
      Constants.awaitingApprovalUIDs: awaitingApprovalUIDs,
    };
  }

  // from map
  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      creatorUID: map[Constants.creatorUID] ?? '',
      groupName: map[Constants.groupName] ?? '',
      groupDescription: map[Constants.groupDescription] ?? '',
      groupImage: map[Constants.groupImage] ?? '',
      groupID: map[Constants.groupID] ?? '',
      lastMessage: map[Constants.lastMessage] ?? '',
      senderUID: map[Constants.senderUID] ?? '',
      messageType: map[Constants.messageType].toString().toMessageEnum(),
      messageID: map[Constants.messageID] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(
          map[Constants.timeSent] ?? DateTime.now().millisecondsSinceEpoch),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map[Constants.createdAt] ?? DateTime.now().millisecondsSinceEpoch),
      isPrivate: map[Constants.isPrivate] ?? false,
      editSettings: map[Constants.editSettings] ?? false,
      approveMembers: map[Constants.approveMembers] ?? false,
      lockMessages: map[Constants.lockMessages] ?? false,
      requestToJoin: map[Constants.requestToJoin] ?? false,
      membersUIDs: List<String>.from(map[Constants.membersUIDs] ?? []),
      adminsUIDs: List<String>.from(map[Constants.adminsUIDs] ?? []),
      awaitingApprovalUIDs:
          List<String>.from(map[Constants.awaitingApprovalUIDs] ?? []),
    );
  }

  // Initial empty group constructor
  GroupModel.empty({bool isPrivate = false})
      : this(
          creatorUID: '',
          groupName: '',
          groupDescription: '',
          groupImage: '',
          groupID: '',
          lastMessage: '',
          senderUID: '',
          messageType: MessageEnum.text,
          messageID: '',
          timeSent: DateTime.now(),
          createdAt: DateTime.now(),
          isPrivate: isPrivate,
          editSettings: false,
          approveMembers: false,
          lockMessages: false,
          requestToJoin: false,
          membersUIDs: [],
          adminsUIDs: [],
          awaitingApprovalUIDs: [],
        );
}
