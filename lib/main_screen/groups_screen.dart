import 'package:athena_nike/constants.dart';
import 'package:athena_nike/main_screen/private_group_screen.dart';
import 'package:athena_nike/main_screen/public_group_screen.dart';
import 'package:flutter/material.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // TabBar for switching between private and public groups
          title: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              // Tab for private groups
              Tab(
                text: Constants.private.toUpperCase(),
              ),
              // Tab for public groups
              Tab(
                text: Constants.public.toUpperCase(),
              ),
            ],
          ),
        ),
        // TabBarView to display the corresponding screen for each tab
        body: const TabBarView(children: [
          PrivateGroupScreen(),
          PublicGroupScreen(),
        ]),
      ),
    );
  }
}