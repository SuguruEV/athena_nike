import 'dart:io';

import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/widgets/friend_widget.dart';
import 'package:athena_nike/widgets/settings_list_tile.dart';
import 'package:athena_nike/widgets/settings_switch_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  // Retrieve the names of the group admins
  String getGroupAdminsNames({
    required GroupProvider groupProvider,
    required String uid,
  }) {
    // Check if there are group members
    if (groupProvider.groupMembersList.isEmpty) {
      return 'To assign admin roles, please add group members in the previous screen';
    } else {
      List<String> groupAdminsNames = [];

      // Get the list of group admins
      List<UserModel> groupAdminsList = groupProvider.groupAdminsList;

      // Map the list of group admins to their names
      List<String> groupAdminsNamesList = groupAdminsList.map((groupAdmin) {
        return groupAdmin.uid == uid ? 'You' : groupAdmin.name;
      }).toList();

      // Add these names to the groupAdminsNames list
      groupAdminsNames.addAll(groupAdminsNamesList);
      return groupAdminsNames.length == 2
          ? '${groupAdminsNames[0]} and ${groupAdminsNames[1]}'
          : groupAdminsNames.length > 2
              ? '${groupAdminsNames.sublist(0, groupAdminsNames.length - 1).join(', ')} and ${groupAdminsNames.last}'
              : 'You';
    }
  }

  // Determine the color for the admins container
  Color getAdminsContainerColor({
    required GroupProvider groupProvider,
  }) {
    // Check if there are group members
    if (groupProvider.groupMembersList.isEmpty) {
      return Theme.of(context).disabledColor;
    } else {
      return Theme.of(context).cardColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the list of group admins
    List<UserModel> groupAdminsList =
        context.read<GroupProvider>().groupAdminsList;

    // Get the current user's UID
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Group Settings'),
        leading: IconButton(
          onPressed: () {
            // Remove temporary lists and navigate back
            context
                .read<GroupProvider>()
                .removeTempLists(isAdmins: true)
                .whenComplete(() {
              Navigator.pop(context);
            });
          },
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
        ),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: Column(
              children: [
                // Switch to enable or disable editing group settings
                SettingsSwitchListTile(
                  title: 'Edit Group Settings',
                  subtitle:
                      'Only admins can change group info, name, image, and description',
                  icon: Icons.edit,
                  containerColor: Colors.green,
                  value: groupProvider.groupModel.editSettings,
                  onChanged: (value) {
                    groupProvider.setEditSettings(value: value);
                  },
                ),
                const SizedBox(height: 10),
                // Switch to enable or disable approval of new members
                SettingsSwitchListTile(
                  title: 'Approve New Members',
                  subtitle:
                      'New members will be added only after admin approval',
                  icon: Icons.approval,
                  containerColor: Colors.blue,
                  value: groupProvider.groupModel.approveMembers,
                  onChanged: (value) {
                    groupProvider.setApproveNewMembers(value: value);
                  },
                ),
                const SizedBox(height: 10),
                // Switch to enable or disable request to join
                groupProvider.groupModel.approveMembers
                    ? SettingsSwitchListTile(
                        title: 'Request to Join',
                        subtitle:
                            'Request incoming members to join the group before viewing group content',
                        icon: Icons.request_page,
                        containerColor: Colors.orange,
                        value: groupProvider.groupModel.requestToJoin,
                        onChanged: (value) {
                          groupProvider.setRequestToJoin(value: value);
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 10),
                // Switch to enable or disable locking messages
                SettingsSwitchListTile(
                  title: 'Lock Messages',
                  subtitle:
                      'Only admins can send messages, other members can only read messages',
                  icon: Icons.lock,
                  containerColor: Colors.blueAccent,
                  value: groupProvider.groupModel.lockMessages,
                  onChanged: (value) {
                    groupProvider.setLockMessages(value: value);
                  },
                ),
                const SizedBox(height: 10),
                // Display group admins
                Card(
                  color: getAdminsContainerColor(groupProvider: groupProvider),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: SettingsListTile(
                      title: 'Group Admins',
                      subtitle: getGroupAdminsNames(
                          groupProvider: groupProvider, uid: uid),
                      icon: Icons.admin_panel_settings,
                      iconContainerColor: Colors.red,
                      onTap: () {
                        // Check if there are group members
                        if (groupProvider.groupMembersList.isEmpty) {
                          return;
                        }
                        groupProvider.setEmptyTemps();
                        // Show bottom sheet to select admins
                        showBottomSheet(
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Select Group Admins',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            groupProvider
                                                .updateGroupDataInFireStoreIfNeeded()
                                                .whenComplete(() {
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: const Text(
                                            'Done',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: groupProvider
                                            .groupMembersList.length,
                                        itemBuilder: (context, index) {
                                          final friend = groupProvider
                                              .groupMembersList[index];
                                          return FriendWidget(
                                            friend: friend,
                                            viewType: FriendViewType.groupView,
                                            isAdminView: true,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}