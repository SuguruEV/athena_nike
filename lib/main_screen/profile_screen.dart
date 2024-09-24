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
        title: const Text('Profile'),
        actions: [
          currentUser.uid == uid
              ?
              // Logout Button
              IconButton(
                  onPressed: () {
                    //context.read<AuthenticationProvider>().logout();
                  },
                  icon: const Icon(Icons.logout),
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

  Widget buildElevatedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.titilliumWeb(
            fontWeight: FontWeight.bold,
          ),
        ),
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
        onPressed: () {
          // Navigate to Friends Screen
        },
      );
    } else {
      if (currentUser.uid != userModel.uid) {
        return buildElevatedButton(
          label: 'Send Friend Request',
          onPressed: () async {
            // Add Friend
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }
}
