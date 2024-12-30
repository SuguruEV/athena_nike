import 'package:athena_nike/constants.dart';
import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendWidget extends StatelessWidget {
  const FriendWidget({
    super.key,
    required this.friend,
    required this.viewType,
  });

  final UserModel friend;
  final FriendViewType viewType;

  @override
  Widget build(BuildContext context) {

    bool getValue() {
      return context.watch<GroupProvider>().groupMembersList.contains(friend);
    }

    return ListTile(
      minLeadingWidth: 0.0,
      contentPadding: const EdgeInsets.only(
        left: -10,
      ),
      leading: userImageWidget(
        imageUrl: friend.image,
        radius: 40,
        onTap: () {},
      ),
      title: Text(friend.name),
      subtitle: Text(
        friend.aboutMe,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: viewType == FriendViewType.friendRequests
          ? ElevatedButton(
              onPressed: () async {
                // Accept friend request
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(friendID: friend.uid)
                    .whenComplete(() {
                  showSnackBar(
                    context,
                    'You are now friends with ${friend.name}',
                  );
                });
              },
              child: const Text('Accept'),
            )
          : viewType == FriendViewType.groupView
              ? Checkbox(
                  value: getValue(),
                  onChanged: (value) {
                    // Check The Check Box
                    if (value == true) {
                      context
                          .read<GroupProvider>()
                          .setGroupMembersList(groupMember: friend);
                    } else {
                      context
                          .read<GroupProvider>()
                          .removeGroupMember(groupMember: friend);
                    }
                  },
                )
              : null,
      onTap: () {
        if (viewType == FriendViewType.friends) {
          // Navigate To Chat Screen With The Following Arguments
          // 1. Friend Name 2. Friend UID 3. Friend Image 4. GroupID with an empty String
          Navigator.pushNamed(
            context,
            Constants.chatScreen,
            arguments: {
              Constants.contactUID: friend.uid,
              Constants.contactName: friend.name,
              Constants.contactImage: friend.image,
              Constants.groupID: '',
            },
          );
        } else if (viewType == FriendViewType.allUsers) {
          // Navigate to this user's profile screen
          Navigator.pushNamed(
            context,
            Constants.profileScreen,
            arguments: friend.uid,
          );
        } else {
          null;
        }
      },
    );
  }
}
