import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/user_model.dart';
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
  String getGroupAdminNames({
    required GroupProvider groupProvider,
  }) {
    // Check if there are group members
    if (groupProvider.groupMembersList.isEmpty) {
      return 'Please add members to the group to assign Admins roles';
    } else {
      List<String> groupAdminNames = ['You'];

      // Get the list of group members
      List<UserModel> groupAdminsList = groupProvider.groupAdminsList;

      // Get a list of naames from the group admins list
      List<String> groupAdminNamesList =
          groupAdminsList.map((groupAdmin) => groupAdmin.name).toList();

      // Add the names to the groupAdminNames list
      groupAdminNames.addAll(groupAdminNamesList);

      // If there are just two, separate them with 'and', else separate them with a comma and the last one with 'and'
      // if (groupAdminsList.length == 1) {
      //   return groupAdminNames.first;
      // } else if (groupAdminNames.length == 2) {
      //   return groupAdminNames.join(' and ');
      // } else {
      //   return '${groupAdminNames.sublist(0, groupAdminNames.length - 1).join(', ')} and ${groupAdminNames.last}';
      // }
      return groupAdminNames.length == 2
          ? '${groupAdminNames[0]} and ${groupAdminNames[1]}'
          : groupAdminNames.length > 2
              ? '${groupAdminNames.sublist(0, groupAdminNames.length - 1).join(', ')} and ${groupAdminNames.last}'
              : groupAdminNames.first;
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Group Settings'),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 10.0,
            ),
            child: Column(
              children: [
                SettingsSwitchListTile(
                  title: 'Edit Group Settings',
                  subtitle:
                      'Only Admins can change the group info, name, image and description',
                  icon: Icons.edit,
                  containerColor: Colors.green,
                  value: groupProvider.editSettings,
                  onChanged: (value) {
                    groupProvider.setEditSettings(value: value);
                  },
                ),
                const SizedBox(height: 10),
                SettingsSwitchListTile(
                  title: 'Approve New Members',
                  subtitle:
                      'New Members will need to be approved by Admins before they can join the group',
                  icon: Icons.approval,
                  containerColor: Colors.blue,
                  value: groupProvider.approveNewMembers,
                  onChanged: (value) {
                    groupProvider.setApproveNewMembers(value: value);
                  },
                ),
                const SizedBox(height: 10),
                groupProvider.approveNewMembers
                    ? SettingsSwitchListTile(
                        title: 'Request to Join',
                        subtitle:
                            'Request incoming members to send a request to join the group',
                        icon: Icons.request_page,
                        containerColor: Colors.orange,
                        value: groupProvider.requestToJoin,
                        onChanged: (value) {
                          groupProvider.setRequestToJoin(value: value);
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 10),
                SettingsSwitchListTile(
                  title: 'Lock Messages',
                  subtitle:
                      'Only Admins can send messages in the group, other members can only read',
                  icon: Icons.lock,
                  containerColor: Colors.deepPurple,
                  value: groupProvider.lockMessages,
                  onChanged: (value) {
                    groupProvider.setLockMessages(value: value);
                  },
                ),
                const SizedBox(height: 10),
                Card(
                  color: getAdminsContainerColor(groupProvider: groupProvider),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: SettingsListTile(
                      title: 'Group Admins',
                      subtitle:
                          getGroupAdminNames(groupProvider: groupProvider),
                      icon: Icons.admin_panel_settings,
                      iconContainerColor: Colors.red,
                      onTap: () {
                        // Check if there are group members
                        if (groupProvider.groupMembersList.isEmpty) {
                          return;
                        }
                        // Show Bottom Sheet to Select Admins
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
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Done',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                    )
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
