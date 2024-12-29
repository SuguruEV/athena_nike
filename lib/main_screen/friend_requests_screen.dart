import 'package:athena_nike/constants.dart';
import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/widgets/app_bar_back_button.dart';
import 'package:athena_nike/widgets/friends_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: AppBarBackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: const Text('Friend Requests'),
        ),
        body: Column(
          children: [
            // Cupertino Search Bar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(
                color: Colors.white,
              ),
              onChanged: (value) {
                print(value);
              },
            ),

            const Expanded(
              child: FriendsList(
                viewType: FriendViewType.friendRequests,
              ),
            )
          ],
        ));
  }
}
