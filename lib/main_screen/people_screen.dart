import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/widgets/friend_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          // Cupertino Search Bar
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              placeholder: 'Search',
            ),
          ),
          // List Of Users
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: context
                  .read<AuthenticationProvider>()
                  .getAllUsersStream(userID: currentUser.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No Users Found',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.titilliumWeb(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    final data = UserModel.fromMap(document.data()! as Map<String, dynamic>);

                    return FriendWidget(friend: data, viewType: FriendViewType.allUsers);

                    // ListTile(
                    //   leading: userImageWidget(
                    //     imageUrl: data[Constants.image],
                    //     radius: 40,
                    //     onTap: () {},
                    //   ),
                    //   title: Text(data[Constants.name]),
                    //   subtitle: Text(
                    //     data[Constants.aboutMe],
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    //   onTap: () {
                    //     // Navigate to This User's Profile
                    //     Navigator.pushNamed(
                    //       context,
                    //       Constants.profileScreen,
                    //       arguments: document.id,
                    //     );
                    //   },
                    // );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}
