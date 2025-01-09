import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/utilities/my_dialogs.dart';
import 'package:athena_nike/widgets/add_members.dart';
import 'package:athena_nike/widgets/exit_group_card.dart';
import 'package:athena_nike/widgets/group_members_card.dart';
import 'package:athena_nike/widgets/info_details_card.dart';
import 'package:athena_nike/widgets/my_app_bar.dart';
import 'package:athena_nike/widgets/settings_and_media.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupInformationScreen extends StatefulWidget {
  const GroupInformationScreen({super.key});

  @override
  State<GroupInformationScreen> createState() => _GroupInformationScreenState();
}

class _GroupInformationScreenState extends State<GroupInformationScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    bool isMember =
        context.read<GroupProvider>().groupModel.membersUIDs.contains(uid);
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        bool isAdmin = groupProvider.groupModel.adminsUIDs.contains(uid);

        return groupProvider.isSloading
            ? const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Saving Image, Please wait...')
                    ],
                  ),
                ),
              )
            : Scaffold(
                appBar: MyAppBar(
                  title: const Text('Group Information'),
                  onPressed: () => Navigator.pop(context),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 10.0),
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Display group information details
                      InfoDetailsCard(
                        groupProvider: groupProvider,
                        isAdmin: isAdmin,
                      ),
                      const SizedBox(height: 10),
                      // Display group settings and media
                      SettingsAndMedia(
                        groupProvider: groupProvider,
                        isAdmin: isAdmin,
                      ),
                      const SizedBox(height: 20),
                      // Button to add new members to the group
                      AddMembers(
                        groupProvider: groupProvider,
                        isAdmin: isAdmin,
                        onPressed: () {
                          groupProvider.setEmptyTemps();
                          // Show bottom sheet to add members
                          MyDialogs.showAddMembersBottomSheet(
                            context: context,
                            groupMembersUIDs:
                                groupProvider.groupModel.membersUIDs,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Display group members and exit group option if the user is a member
                      isMember
                          ? Column(
                              children: [
                                GroupMembersCard(
                                  isAdmin: isAdmin,
                                  groupProvider: groupProvider,
                                ),
                                const SizedBox(height: 10),
                                ExitGroupCard(
                                  uid: uid,
                                )
                              ],
                            )
                          : const SizedBox(),
                    ],
                  )),
                ),
              );
      },
    );
  }
}