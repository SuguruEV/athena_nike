import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/widgets/friends_list.dart';
import 'package:athena_nike/widgets/my_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key, this.groupID = ''});

  final String groupID;

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Requests'),
        onPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // cupertinosearchbar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                print(value);
              },
            ),

            Expanded(
                child: FriendsList(
              viewType: FriendViewType.friendRequests,
              groupID: widget.groupID,
            )),
          ],
        ),
      ),
    );
  }
}
