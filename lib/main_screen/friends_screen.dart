import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/providers/search_provider.dart';
import 'package:athena_nike/widgets/friends_list.dart';
import 'package:athena_nike/widgets/my_app_bar.dart';
import 'package:athena_nike/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Friends'),
        onPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search bar
            SearchBarWidget(
              onChanged: (value) {
                context.read<SearchProvider>().setSearchQuery(value);
              },
            ),

            const Expanded(
                child: FriendsList(
              viewType: FriendViewType.friends,
            )),
          ],
        ),
      ),
    );
  }
}
