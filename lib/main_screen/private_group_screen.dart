import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/group_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/widgets/chat_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrivateGroupScreen extends StatefulWidget {
  const PrivateGroupScreen({super.key});

  @override
  State<PrivateGroupScreen> createState() => _PrivateGroupScreenState();
}

class _PrivateGroupScreenState extends State<PrivateGroupScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              onChanged: (value) {},
            ),
          ),

          // Stream Builder for private groups
          StreamBuilder<List<GroupModel>>(
            stream: context
                .read<GroupProvider>()
                .getPrivateGroupsStream(userId: uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occurred'),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No private groups found'),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final groupModel = snapshot.data![index];
                    return ChatWidget(
                      group: groupModel,
                      isGroup: true,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/chat_screen',
                          arguments: {
                            Constants.contactUID: groupModel.groupID,
                            Constants.groupName: groupModel.groupName,
                            Constants.groupImage: groupModel.groupImage,
                            Constants.groupID: groupModel.groupID,
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
