import 'package:athena_nike/models/group_model.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:flutter/material.dart';

class GroupProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _editSettings = true;
  bool _approveNewMembers = false;
  bool _requestToJoin = false;
  bool _lockMessages = false;

  GroupModel? _groupModel;
  final List<UserModel> _groupMembersList = [];
  final List<UserModel> _groupAdminsList = [];

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
    notifyListeners();
  }

  // Remove admin from group
  void removeGroupAdmin({required UserModel groupAdmin}) {
    _groupAdminsList.remove(groupAdmin);
    notifyListeners();
  }
}