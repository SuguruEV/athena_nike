import 'dart:developer';
import 'dart:io';
import 'package:athena_nike/constants.dart';
import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/group_model.dart';
import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupProvider extends ChangeNotifier {
  bool _isSloading = false;

  GroupModel _groupModel = GroupModel(
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
    isPrivate: true,
    editSettings: true,
    approveMembers: false,
    lockMessages: false,
    requestToJoin: false,
    membersUIDs: [],
    adminsUIDs: [],
    awaitingApprovalUIDs: [],
  );
  List<UserModel> _groupMembersList = [];
  List<UserModel> _groupAdminsList = [];

  List<UserModel> _tempGroupMembersList = [];
  List<UserModel> _tempGoupAdminsList = [];

  List<String> _tempGroupMemberUIDs = [];
  List<String> _tempGroupAdminUIDs = [];

  List<UserModel> _tempRemovedAdminsList = [];
  List<UserModel> _tempRemovedMembersList = [];

  List<String> _tempRemovedMemberUIDs = [];
  List<String> _tempRemovedAdminsUIDs = [];

  bool _isSaved = false;

  // Getters
  bool get isSloading => _isSloading;
  GroupModel get groupModel => _groupModel;
  List<UserModel> get groupMembersList => _groupMembersList;
  List<UserModel> get groupAdminsList => _groupAdminsList;

  // Firebase initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Set loading state
  void setIsSloading({required bool value}) {
    _isSloading = value;
    notifyListeners();
  }

  // Set edit settings
  void setEditSettings({required bool value}) {
    _groupModel.editSettings = value;
    notifyListeners();
    // Return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupID.isEmpty) return;
    updateGroupDataInFireStore();
  }

  // Set approve new members
  void setApproveNewMembers({required bool value}) {
    _groupModel.approveMembers = value;
    notifyListeners();
    // Return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupID.isEmpty) return;
    updateGroupDataInFireStore();
  }

  // Set request to join
  void setRequestToJoin({required bool value}) {
    _groupModel.requestToJoin = value;
    notifyListeners();
    // Return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupID.isEmpty) return;
    updateGroupDataInFireStore();
  }

  // Set lock messages
  void setLockMessages({required bool value}) {
    _groupModel.lockMessages = value;
    notifyListeners();
    // Return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupID.isEmpty) return;
    updateGroupDataInFireStore();
  }

  // Update group settings in Firestore
  Future<void> updateGroupDataInFireStore() async {
    try {
      await _firestore
          .collection(Constants.groups)
          .doc(_groupModel.groupID)
          .update(groupModel.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  // Set the temporary lists to empty
  Future<void> setEmptyTemps() async {
    _isSaved = false;
    _tempGoupAdminsList = [];
    _tempGroupMembersList = [];
    _tempGroupMembersList = [];
    _tempGroupMembersList = [];
    _tempGroupMemberUIDs = [];
    _tempGroupAdminUIDs = [];
    _tempRemovedMemberUIDs = [];
    _tempRemovedAdminsUIDs = [];
    _tempRemovedMembersList = [];
    _tempRemovedAdminsList = [];

    notifyListeners();
  }

  // Remove temporary lists members from members list
  Future<void> removeTempLists({required bool isAdmins}) async {
    if (_isSaved) return;
    if (isAdmins) {
      // Check if the temporary admins list is not empty
      if (_tempGoupAdminsList.isNotEmpty) {
        // Remove the temporary admins from the main list of admins
        _groupAdminsList.removeWhere((admin) =>
            _tempGoupAdminsList.any((tempAdmin) => tempAdmin.uid == admin.uid));
        _groupModel.adminsUIDs.removeWhere((adminUid) =>
            _tempGroupAdminUIDs.any((tempUid) => tempUid == adminUid));
        notifyListeners();
      }

      // Check if the temporary removed list is not empty
      if (_tempRemovedAdminsList.isNotEmpty) {
        // Add the temporary admins to the main list of admins
        _groupAdminsList.addAll(_tempRemovedAdminsList);
        _groupModel.adminsUIDs.addAll(_tempRemovedAdminsUIDs);
        notifyListeners();
      }
    } else {
      // Check if the temporary members list is not empty
      if (_tempGroupMembersList.isNotEmpty) {
        // Remove the temporary members from the main list of members
        _groupMembersList.removeWhere((member) => _tempGroupMembersList
            .any((tempMember) => tempMember.uid == member.uid));
        _groupModel.membersUIDs.removeWhere((memberUid) =>
            _tempGroupMemberUIDs.any((tempUid) => tempUid == memberUid));
        notifyListeners();
      }

      // Check if the temporary removed list is not empty
      if (_tempRemovedMembersList.isNotEmpty) {
        // Add the temporary members to the main list of members
        _groupMembersList.addAll(_tempRemovedMembersList);
        _groupModel.membersUIDs.addAll(_tempGroupMemberUIDs);
        notifyListeners();
      }
    }
  }

  // Check if there was a change in group members - if there was a member added or removed
  Future<void> updateGroupDataInFireStoreIfNeeded() async {
    _isSaved = true;
    notifyListeners();
    await updateGroupDataInFireStore();
  }

  // Add a group member
  void addMemberToGroup({required UserModel groupMember}) {
    _groupMembersList.add(groupMember);
    _groupModel.membersUIDs.add(groupMember.uid);
    // Add data to temporary lists
    _tempGroupMembersList.add(groupMember);
    _tempGroupMemberUIDs.add(groupMember.uid);
    notifyListeners();
  }

  // Add a member as an admin
  void addMemberToAdmins({required UserModel groupAdmin}) {
    _groupAdminsList.add(groupAdmin);
    _groupModel.adminsUIDs.add(groupAdmin.uid);
    // Add data to temporary lists
    _tempGoupAdminsList.add(groupAdmin);
    _tempGroupAdminUIDs.add(groupAdmin.uid);
    notifyListeners();
  }

  // Update group image
  void setGroupImage(String groupImage) {
    _groupModel.groupImage = groupImage;
    notifyListeners();
  }

  // Set group name
  void setGroupName(String groupName) {
    _groupModel.groupName = groupName;
    notifyListeners();
  }

  // Set group description
  void setGroupDescription(String groupDescription) {
    _groupModel.groupDescription = groupDescription;
    notifyListeners();
  }

  // Set group model
  Future<void> setGroupModel({required GroupModel groupModel}) async {
    log('groupChat Provider: ${groupModel.groupName}');
    _groupModel = groupModel;
    notifyListeners();
  }

  // Remove member from group
  Future<void> removeGroupMember({required UserModel groupMember}) async {
    _groupMembersList.remove(groupMember);
    // Also remove this member from admins list if they are an admin
    _groupAdminsList.remove(groupMember);
    _groupModel.membersUIDs.remove(groupMember.uid);

    // Remove from temporary lists
    _tempGroupMembersList.remove(groupMember);
    _tempGroupAdminUIDs.remove(groupMember.uid);

    // Add this member to the list of removed members
    _tempRemovedMembersList.add(groupMember);
    _tempRemovedMemberUIDs.add(groupMember.uid);

    notifyListeners();

    // Return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupID.isEmpty) return;
    updateGroupDataInFireStore();
  }

  // Remove admin from group
  void removeGroupAdmin({required UserModel groupAdmin}) {
    _groupAdminsList.remove(groupAdmin);
    _groupModel.adminsUIDs.remove(groupAdmin.uid);
    // Remove from temporary lists
    _tempGroupAdminUIDs.remove(groupAdmin.uid);
    _groupModel.adminsUIDs.remove(groupAdmin.uid);

    // Add the removed admins to temporary removed lists
    _tempRemovedAdminsList.add(groupAdmin);
    _tempRemovedAdminsUIDs.add(groupAdmin.uid);
    notifyListeners();

    // Return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupID.isEmpty) return;
    updateGroupDataInFireStore();
  }

  // Get a list of group members data from Firestore
  Future<List<UserModel>> getGroupMembersDataFromFirestore({
    required bool isAdmin,
  }) async {
    try {
      List<UserModel> membersData = [];

      // Get the list of membersUIDs
      List<String> membersUIDs =
          isAdmin ? _groupModel.adminsUIDs : _groupModel.membersUIDs;

      for (var uid in membersUIDs) {
        var user = await _firestore.collection(Constants.users).doc(uid).get();
        membersData.add(UserModel.fromMap(user.data()!));
      }

      return membersData;
    } catch (e) {
      return [];
    }
  }

  // Update the groupMembersList
  Future<void> updateGroupMembersList() async {
    _groupMembersList.clear();

    _groupMembersList
        .addAll(await getGroupMembersDataFromFirestore(isAdmin: false));

    notifyListeners();
  }

  // Update the groupAdminsList
  Future<void> updateGroupAdminsList() async {
    _groupAdminsList.clear();

    _groupAdminsList
        .addAll(await getGroupMembersDataFromFirestore(isAdmin: true));

    notifyListeners();
  }

  // Clear group members list
  Future<void> clearGroupMembersList() async {
    _groupMembersList.clear();
    _groupAdminsList.clear();
    _groupModel = GroupModel(
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
      isPrivate: true,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoin: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );
    notifyListeners();
  }

  // Get a list of UIDs from group members list
  List<String> getGroupMembersUIDs() {
    return _groupMembersList.map((e) => e.uid).toList();
  }

  // Get a list of UIDs from group admins list
  List<String> getGroupAdminsUIDs() {
    return _groupAdminsList.map((e) => e.uid).toList();
  }

  // Stream group data
  Stream<DocumentSnapshot> groupStream({required String groupID}) {
    return _firestore.collection(Constants.groups).doc(groupID).snapshots();
  }

  // Stream users data from Firestore
  streamGroupMembersData({required List<String> membersUIDs}) {
    return Stream.fromFuture(Future.wait<DocumentSnapshot>(
      membersUIDs.map<Future<DocumentSnapshot>>((uid) async {
        return await _firestore.collection(Constants.users).doc(uid).get();
      }),
    ));
  }

  // Create group
  Future<void> createGroup({
    required GroupModel newGroupModel,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    setIsSloading(value: true);

    try {
      var groupID = const Uuid().v4();
      newGroupModel.groupID = groupID;

      // Check if the file image is null
      if (fileImage != null) {
        // Upload image to Firebase Storage
        final String imageUrl = await GlobalMethods.storeFileToStorage(
            file: fileImage, reference: '${Constants.groupImages}/$groupID');
        newGroupModel.groupImage = imageUrl;
      }

      // Add the group admins
      newGroupModel.adminsUIDs = [
        newGroupModel.creatorUID,
        ...getGroupAdminsUIDs()
      ];

      // Add the group members
      newGroupModel.membersUIDs = [
        newGroupModel.creatorUID,
        ...getGroupMembersUIDs()
      ];

      // Update the global groupModel
      setGroupModel(groupModel: newGroupModel);

      // Add group to Firebase
      await _firestore
          .collection(Constants.groups)
          .doc(groupID)
          .set(groupModel.toMap());

      // Set loading to false
      setIsSloading(value: false);
      // Call onSuccess
      onSuccess();
    } catch (e) {
      setIsSloading(value: false);
      onFail(e.toString());
    }
  }

  // Get a stream of all private groups that contain the userId
  Stream<List<GroupModel>> getPrivateGroupsStream({required String userId}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.membersUIDs, arrayContains: userId)
        .where(Constants.isPrivate, isEqualTo: true)
        .snapshots()
        .asyncMap((event) {
      List<GroupModel> groups = [];
      for (var group in event.docs) {
        groups.add(GroupModel.fromMap(group.data()));
      }

      return groups;
    });
  }

  // Get a stream of all public groups
  Stream<List<GroupModel>> getPublicGroupsStream({required String userId}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.isPrivate, isEqualTo: false)
        .snapshots()
        .asyncMap((event) {
      List<GroupModel> groups = [];
      for (var group in event.docs) {
        groups.add(GroupModel.fromMap(group.data()));
      }

      return groups;
    });
  }

  // Change group type
  void changeGroupType() {
    _groupModel.isPrivate = !_groupModel.isPrivate;
    notifyListeners();
    updateGroupDataInFireStore();
  }

  // Send request to join group
  Future<void> sendRequestToJoinGroup({
    required String groupID,
    required String uid,
    required String groupName,
    required String groupImage,
  }) async {
    await _firestore.collection(Constants.groups).doc(groupID).update({
      Constants.awaitingApprovalUIDs: FieldValue.arrayUnion([uid])
    });
  }

  // Accept request to join group
  Future<void> acceptRequestToJoinGroup({
    required String groupID,
    required String friendID,
  }) async {
    await _firestore.collection(Constants.groups).doc(groupID).update({
      Constants.membersUIDs: FieldValue.arrayUnion([friendID]),
      Constants.awaitingApprovalUIDs: FieldValue.arrayRemove([friendID])
    });

    _groupModel.awaitingApprovalUIDs.remove(friendID);
    _groupModel.membersUIDs.add(friendID);
    notifyListeners();
  }

  // Check if the user is the sender or an admin
  bool isSenderOrAdmin({required MessageModel message, required String uid}) {
    if (message.senderUID == uid) {
      return true;
    } else if (_groupModel.adminsUIDs.contains(uid)) {
      return true;
    } else {
      return false;
    }
  }

  // Exit group
  Future<void> exitGroup({
    required String uid,
  }) async {
    // Check if the user is an admin of the group
    bool isAdmin = _groupModel.adminsUIDs.contains(uid);

    await _firestore
        .collection(Constants.groups)
        .doc(_groupModel.groupID)
        .update({
      Constants.membersUIDs: FieldValue.arrayRemove([uid]),
      Constants.adminsUIDs:
          isAdmin ? FieldValue.arrayRemove([uid]) : _groupModel.adminsUIDs,
    });

    // Remove the user from group members list
    _groupMembersList.removeWhere((element) => element.uid == uid);
    // Remove the user from group members UID
    _groupModel.membersUIDs.remove(uid);
    if (isAdmin) {
      // Remove the user from group admins list
      _groupAdminsList.removeWhere((element) => element.uid == uid);
      // Remove the user from group admins UID
      _groupModel.adminsUIDs.remove(uid);
    }
    notifyListeners();
  }
}