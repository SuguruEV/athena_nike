import 'package:athena_nike/providers/group_provider.dart';
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
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: SettingsListTile(
                        title: 'Group Admins',
                        subtitle: 'You, and other Admins in the group',
                        icon: Icons.admin_panel_settings,
                        iconContainerColor: Colors.red,
                        onTap: () {}),
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
