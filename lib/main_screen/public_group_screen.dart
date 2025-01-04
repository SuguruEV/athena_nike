import 'package:athena_nike/models/group_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/search_provider.dart';
import 'package:athena_nike/streams/chats_stream.dart';
import 'package:athena_nike/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PublicGroupScreen extends StatefulWidget {
  const PublicGroupScreen({super.key});

  @override
  State<PublicGroupScreen> createState() => _PublicGroupScreenState();
}

class _PublicGroupScreenState extends State<PublicGroupScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return SafeArea(
      child: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return Column(
            children: [
              // Search bar
              SearchBarWidget(
                onChanged: (value) {
                  searchProvider.setSearchQuery(value);
                },
              ),

              Expanded(
                  child: ChatsStream(
                uid: uid,
                groupModel: GroupModel.empty(),
                searchQuery: searchProvider.searchQuery,
              )),
            ],
          );
        },
      ),
    );
  }
}