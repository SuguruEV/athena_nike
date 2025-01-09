import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/utilities/my_dialogs.dart';
import 'package:flutter/material.dart';

class GroupMembersCard extends StatefulWidget {
  const GroupMembersCard({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin;
  final GroupProvider groupProvider;

  @override
  State<GroupMembersCard> createState() => _GroupMembersCardState();
}

class _GroupMembersCardState extends State<GroupMembersCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          FutureBuilder<List<UserModel>>(
            future: widget.groupProvider.getGroupMembersDataFromFirestore(
              isAdmin: false,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No members'),
                );
              }
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final member = snapshot.data![index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: GlobalMethods.userImageWidget(
                          imageUrl: member.image, radius: 40, onTap: () {}),
                      title: Text(member.name),
                      subtitle: Text(member.aboutMe),
                      trailing: widget.groupProvider.groupModel.adminsUIDs
                              .contains(member.uid)
                          ? const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.orangeAccent,
                            )
                          : const SizedBox(),
                      onTap: !widget.isAdmin
                          ? null
                          : () {
                              // Show dialog to remove member
                              MyDialogs.showMyAnimatedDialog(
                                context: context,
                                title: 'Remove Member',
                                content:
                                    'Are you sure you want to remove ${member.name} from the group?',
                                textAction: 'Remove',
                                onActionTap: (value, updatedText) async {
                                  if (value) {
                                    // Remove member from group
                                    await widget.groupProvider
                                        .removeGroupMember(
                                      groupMember: member,
                                    );

                                    setState(() {});
                                  }
                                },
                              );
                            },
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}