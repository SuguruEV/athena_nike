import 'dart:io';

import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/group_model.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _editSettings = true;
  bool _approveNewMembers = false;
  bool _requestToJoin = false;
  bool _lockMessages = false;

  GroupModel? _groupModel;
  final List<UserModel> _groupMembersList = [];
  final List<UserModel> _groupAdminsList = [];

  // Firebase Initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  bool get isLoading => _isLoading;
  bool get editSettings => _editSettings;
  bool get approveNewMembers => _approveNewMembers;
  bool get requestToJoin => _requestToJoin;
  bool get lockMessages => _lockMessages;
  GroupModel? get groupModel => _groupModel;
  List<UserModel> get groupMembersList => _groupMembersList;
  List<UserModel> get groupAdminsList => _groupAdminsList;

  // Setters
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  void setEditSettings({required bool value}) {
    _editSettings = value;
    notifyListeners();
  }

  void setApproveNewMembers({required bool value}) {
    _approveNewMembers = value;
    notifyListeners();
  }

  void setRequestToJoin({required bool value}) {
    _requestToJoin = value;
    notifyListeners();
  }

  void setLockMessages({required bool value}) {
    _lockMessages = value;
    notifyListeners();
  }

  void setGroupModel({required GroupModel groupModel}) {
    _groupModel = groupModel;
    notifyListeners();
  }

  void addMemberToGroup({required UserModel groupMember}) {
    _groupMembersList.add(groupMember);
    notifyListeners();
  }

  void addMemberToAdmins({required UserModel groupAdmin}) {
    _groupAdminsList.add(groupAdmin);
    notifyListeners();
  }

  // Remove member from group
  void removeGroupMember({required UserModel groupMember}) {
    _groupMembersList.remove(groupMember);
    // Also remove this member from the admins list if they're an admin
    _groupAdminsList.remove(groupMember);
    notifyListeners();
  }

  // Remove admin from group
  void removeGroupAdmin({required UserModel groupAdmin}) {
    _groupAdminsList.remove(groupAdmin);
    notifyListeners();
  }

  // Clear Group Members List
  Future<void> clearGroupMembersList() async {
    _groupMembersList.clear();
    notifyListeners();
  }

  // Clear Group Admins List
  Future<void> clearGroupAdminsList() async {
    _groupAdminsList.clear();
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

  // Create Group
  Future<void> createGroup({
    required GroupModel groupModel,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    setLoading(value: true);

    try {
      var groupID = const Uuid().v4();
      groupModel.groupID = groupID;

      // Check if the file image is not null
      if (fileImage != null) {
        // Upload the image to Firebase Storage
        final String imageUrl = await storeFileToStorage(file: fileImage, reference: '${Constants.groupImages}/$groupID');

        // Set the group image URL
        groupModel.groupImage = imageUrl;

        // Add the group admins
        groupModel.adminsUIDs = [groupModel.creatorUID, ...getGroupAdminsUIDs()];

        // Add the group members
        groupModel.membersUIDs = [groupModel.creatorUID, ...getGroupMembersUIDs()];

        // Add edit settings
        groupModel.editSettings = editSettings;

        // Add approve new members
        groupModel.approveMembers = approveNewMembers;

        // Add request to join
        groupModel.requestToJoin = requestToJoin;

        // Add lock messages
        groupModel.lockMessages = lockMessages;

        // Add the group to the database
        await _firestore.collection(Constants.groups).doc(groupID).set(groupModel.toMap());

        // Set Loading
        setLoading(value: false);
        // Set onSuccess
        onSuccess();
      }
      
    } catch (e) {
      setLoading(value: false);
      onError(e.toString());
    }
  }
}
