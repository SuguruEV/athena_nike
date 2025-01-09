import 'package:athena_nike/constants.dart';
import 'package:athena_nike/main_screen/friend_requests_screen.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/utilities/my_dialogs.dart';

class GroupStatusWidget extends StatelessWidget {
  const GroupStatusWidget({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin;
  final GroupProvider groupProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: !isAdmin
              ? null
              : () {
                  // Show dialog to change group type
                  MyDialogs.showMyAnimatedDialog(
                    context: context,
                    title: 'Change Group Type',
                    content:
                        'Are you sure you want to change the group type to ${groupProvider.groupModel.isPrivate ? 'Public' : 'Private'}?',
                    textAction: 'Change',
                    onActionTap: (value, updatedText) {
                      if (value) {
                        // Change group type
                        groupProvider.changeGroupType();
                      }
                    },
                  );
                },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.deepPurple : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              groupProvider.groupModel.isPrivate ? 'Private' : 'Public',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GetRequestWidget(
          groupProvider: groupProvider,
          isAdmin: isAdmin,
        ),
      ],
    );
  }
}

class ProfileStatusWidget extends StatelessWidget {
  const ProfileStatusWidget({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FriendsButton(
            currentUser: currentUser,
            userModel: userModel,
          ),
          const SizedBox(width: 10),
          FriendRequestButton(
            currentUser: currentUser,
            userModel: userModel,
          ),
        ],
      ),
    );
  }
}

class FriendsButton extends StatefulWidget {
  const FriendsButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  _FriendsButtonState createState() => _FriendsButtonState();
}

class _FriendsButtonState extends State<FriendsButton> {
  @override
  Widget build(BuildContext context) {
    // Friends button
    Widget buildFriendsButton() {
      if (widget.currentUser.uid == widget.userModel.uid &&
          widget.userModel.friendsUIDs.isNotEmpty) {
        return MyElevatedButton(
          onPressed: () {
            // Navigate to friends screen
            Navigator.pushNamed(
              context,
              Constants.friendsScreen,
            );
          },
          label: 'Friends',
          width: MediaQuery.of(context).size.width * 0.4,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary,
        );
      } else {
        if (widget.currentUser.uid != widget.userModel.uid) {
          // Show cancel friend request button if the user sent us friend request
          // Else show send friend request button
          if (widget.userModel.friendRequestsUIDs.contains(widget.currentUser.uid)) {
            // Show send friend request button
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .cancelFriendRequest(friendID: widget.userModel.uid)
                    .whenComplete(() {
                  if (mounted) {
                    GlobalMethods.showSnackBar(
                        context, 'Friend request cancelled');
                  }
                });
              },
              label: 'Cancel Request',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (widget.userModel.sentFriendRequestsUIDs
              .contains(widget.currentUser.uid)) {
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(friendID: widget.userModel.uid)
                    .whenComplete(() {
                  if (mounted) {
                    GlobalMethods.showSnackBar(
                        context, 'You are now friends with ${widget.userModel.name}');
                  }
                });
              },
              label: 'Accept Friend',
              width: MediaQuery.of(context).size.width * 0.4,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (widget.userModel.friendsUIDs.contains(widget.currentUser.uid)) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyElevatedButton(
                  onPressed: () async {
                    // Show unfriend dialog to ask the user if he is sure to unfriend
                    // Create a dialog to confirm logout
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Unfriend',
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          'Are you sure you want to unfriend ${widget.userModel.name}?',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              // Remove friend
                              await context
                                  .read<AuthenticationProvider>()
                                  .removeFriend(friendID: widget.userModel.uid)
                                  .whenComplete(() {
                                if (mounted) {
                                  GlobalMethods.showSnackBar(
                                      context, 'You are no longer friends');
                                }
                              });
                             },
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                  },
                  label: 'Unfriend',
                  width: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: Colors.deepPurple,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 10),
                MyElevatedButton(
                  onPressed: () async {
                    // Navigate to chat screen
                    // Navigate to chat screen with the following arguments
                    // 1. friend uid 2. friend name 3. friend image 4. groupId with an empty string
                    Navigator.pushNamed(context, Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: widget.userModel.uid,
                          Constants.contactName: widget.userModel.name,
                          Constants.contactImage: widget.userModel.image,
                          Constants.groupID: ''
                        });
                  },
                  label: 'Chat',
                  width: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: Theme.of(context).cardColor,
                  textColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          } else {
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .sendFriendRequest(friendID: widget.userModel.uid)
                    .whenComplete(() {
                  if (mounted) {
                    GlobalMethods.showSnackBar(context, 'Friend request sent');
                  }
                });
              },
              label: 'Send Request',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          }
        } else {
          return const SizedBox.shrink();
        }
      }
    }

    return buildFriendsButton();
  }
}

class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    // Friend request button
    Widget buildFriendRequestButton() {
      if (currentUser.uid == userModel.uid &&
          userModel.friendRequestsUIDs.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.orangeAccent,
            child: IconButton(
              onPressed: () {
                // Navigate to friend requests screen
                Navigator.pushNamed(
                  context,
                  Constants.friendRequestsScreen,
                );
              },
              icon: const Icon(
                Icons.person_add,
                color: Colors.black,
              ),
            ),
          ),
        );
      } else {
        // Not in our profile
        return const SizedBox.shrink();
      }
    }

    return buildFriendRequestButton();
  }
}

class GetRequestWidget extends StatelessWidget {
  const GetRequestWidget({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    // Get request widget
    Widget getRequestWidget() {
      // Check if user is admin
      if (isAdmin) {
        // Check if there is any request
        if (groupProvider.groupModel.awaitingApprovalUIDs.isNotEmpty) {
          return InkWell(
            onTap: () {
              // Navigate to add members screen
              // Navigate to friend requests screen
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FriendRequestScreen(
                  groupID: groupProvider.groupModel.groupID,
                );
              }));
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orangeAccent,
              child: Icon(
                Icons.person_add,
                color: Colors.white,
                size: 15,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      } else {
        return const SizedBox();
      }
    }

    return getRequestWidget();
  }
}

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.width,
    required this.backgroundColor,
    required this.textColor,
  });

  final VoidCallback onPressed;
  final String label;
  final double width;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    Widget buildElevatedButton() {
      return SizedBox(
        //width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.titilliumWeb(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return buildElevatedButton();
  }
}