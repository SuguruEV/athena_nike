import 'package:athena_nike/main_screen/group_settings_screen.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';

class SettingsAndMedia extends StatelessWidget {
  const SettingsAndMedia({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            SettingsListTile(
              title: 'Media',
              icon: Icons.image,
              iconContainerColor: Colors.blueAccent,
              onTap: () {
                // Navigate to media screen
              },
            ),
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
            ),
            SettingsListTile(
              title: 'Group Settings',
              icon: Icons.settings,
              iconContainerColor: Colors.blueAccent,
              onTap: () {
                if (!isAdmin) {
                  // Show snackbar if the user is not an admin
                  GlobalMethods.showSnackBar(
                      context, 'Only admin can change group settings');
                } else {
                  groupProvider.updateGroupAdminsList().whenComplete(() {
                    // Navigate to group settings screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GroupSettingsScreen(),
                      ),
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}