import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/app_bar_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    // Get User Data from Arguments
    final String uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.titilliumWeb(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          currentUser.uid == uid
              ?
              // Logout Button
              IconButton(
                  onPressed: () {
                    // Navigate to the settings screen with the UID as an argument
                    Navigator.pushNamed(
                      context,
                      Constants.settingsScreen,
                      arguments: uid,
                    );
                  },
                  icon: const Icon(Icons.settings),
                )
              : const SizedBox(),
        ],
      ),
      body: StreamBuilder(
        stream: context.read<AuthenticationProvider>().userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                Center(
                  child: userImageWidget(
                    imageUrl: userModel.image,
                    radius: 60,
                    onTap: () {
                      // Navigate To User Profile with UID as Arguments
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userModel.name,
                  style: GoogleFonts.titilliumWeb(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userModel.phoneNumber,
                  style: GoogleFonts.titilliumWeb(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                buildFriendsButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),
                const SizedBox(height: 10),
                buildFriendRequestButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'About Me',
                      style: GoogleFonts.titilliumWeb(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                Text(
                  userModel.aboutMe,
                  style: GoogleFonts.titilliumWeb(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildFriendRequestButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendRequestsUIDs.isNotEmpty) {
      return buildElevatedButton(
        label: 'View Friend Requests',
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Theme.of(context).buttonTheme.colorScheme!.primary,
        textColor: Colors.white,
        onPressed: () {
          // Navigate to Friend Requests Screen
        },
      );
    } else {
      // Not in our Profile
      return const SizedBox.shrink();
    }
  }

  Widget buildFriendsButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid && userModel.friendsUIDs.isNotEmpty) {
      return buildElevatedButton(
        label: 'View Friends',
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).primaryColor,
        onPressed: () {
          // Navigate to Friends Screen
        },
      );
    } else {
      if (currentUser.uid != userModel.uid) {
        // Show Cancel Friend Request Button if The User has Sent a Friend Request
        // Else Show Send Friend Request Button
        if (userModel.friendRequestsUIDs.contains(currentUser.uid)) {
          // Show Send Friend Request Button
          return buildElevatedButton(
            onPressed: () async {
              await context
                  .read<AuthenticationProvider>()
                  .cancelFriendRequest(friendID: userModel.uid)
                  .whenComplete(() {
                showSnackBar(context, 'Friend Request Cancelled');
              });
            },
            label: 'Cancel Friend Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).primaryColor,
          );
        } else if (userModel.sentFriendRequestsUIDs.contains(currentUser.uid)) {
          return buildElevatedButton(
            onPressed: () async {
              await context
                  .read<AuthenticationProvider>()
                  .acceptFriendRequest(friendID: userModel.uid)
                  .whenComplete(() {
                showSnackBar(
                    context, 'You are now friends with ${userModel.name}');
              });
            },
            label: 'Accept Friend Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).primaryColor,
          );
        } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildElevatedButton(
                onPressed: () async {
                  // Show Unfriend Dialog To Ask User if they want to unfriend
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text(
                              'Unfriend',
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              'Are you sure you want to unfriend ${userModel.name}?',
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
                                  // Remove Friend
                                  await context
                                      .read<AuthenticationProvider>()
                                      .removeFriend(friendID: userModel.uid)
                                      .whenComplete(() {
                                    showSnackBar(
                                        context, 'You are no longer friends');
                                  });
                                },
                                child: const Text('Unfriend'),
                              ),
                            ],
                          ));
                },
                label: 'Unfriend',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor:
                    Theme.of(context).buttonTheme.colorScheme!.primary,
                textColor: Colors.white,
              ),
              buildElevatedButton(
                onPressed: () async {
                  // Navigate to Chat Screen
                },
                label: 'Chat',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          );
        } else {
          return buildElevatedButton(
            onPressed: () async {
              await context
                  .read<AuthenticationProvider>()
                  .sendFriendRequest(friendID: userModel.uid)
                  .whenComplete(() {
                showSnackBar(context, 'Friend Request Sent');
              });
            },
            label: 'Send Friend Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).primaryColor,
          );
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget buildElevatedButton({
    required String label,
    required VoidCallback onPressed,
    required double width,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
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
}
