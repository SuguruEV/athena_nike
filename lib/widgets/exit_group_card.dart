import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/utilities/global_methods_temp.dart';
import 'package:athena_nike/utilities/my_dialogs.dart';
import 'package:athena_nike/widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExitGroupCard extends StatelessWidget {
  const ExitGroupCard({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SettingsListTile(
          title: 'Exit Group',
          icon: Icons.exit_to_app,
          iconContainerColor: Colors.red,
          onTap: () {
            // exit group
            MyDialogs.showMyAnimatedDialog(
              context: context,
              title: 'Exit Group',
              content: 'Are you sure you want to exit the group?',
              textAction: 'Exit',
              onActionTap: (value, updatedText) async {
                if (value) {
                  // exit group
                  final groupProvider = context.read<GroupProvider>();
                  await groupProvider.exitGroup(uid: uid).whenComplete(() {
                    GlobalMethods.showSnackBar(
                        context, 'You have exited the group');
                    // navigate to first screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }
}