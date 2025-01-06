

import 'package:athena_nike/models/chat_model.dart';
import 'package:athena_nike/models/group_model.dart';
import 'package:athena_nike/streams/data_repository.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/chat_widget.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';

class ChatsStream extends StatelessWidget {
  const ChatsStream({
    super.key,
    required this.uid,
    this.groupModel,
    this.searchQuery = '',
    this.limit = 20,
    this.isLive = true,
  });

  final String uid;
  final GroupModel? groupModel;
  final String searchQuery;
  final int limit;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return FirestorePagination(
      limit: limit,
      isLive: isLive,
      query:
          DataRepository.getChatsListQuery(userID: uid, groupModel: groupModel),
      itemBuilder: (context, documentSnapshot, index) {
        // Get the document data at index
        final documnets = documentSnapshot[index];

        // Get chat data from document
        final (ChatModel chatModel, GroupModel? newGModel) =
            GlobalMethods.getChatData(
                documnets: documnets, groupModel: groupModel);

        // Apply search filter, if item does not match search query, return empty widget
        if (!chatModel.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          // Check if this is the last item and no items matched the search
          if (index == documentSnapshot.length - 1 &&
              !documentSnapshot.any((doc) {
                final (chatModel, newGModel) = GlobalMethods.getChatData(
                    documnets: documnets, groupModel: groupModel);
                return chatModel.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
              })) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No Matches Found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        return ChatWidget(
          chatModel: chatModel,
          isGroup: groupModel != null,
          onTap: () => GlobalMethods.navigateToChatScreen(
            context: context,
            uid: uid,
            chatModel: chatModel,
            groupModel: newGModel,
          ),
        );
      },
      initialLoader: const Center(
        child: CircularProgressIndicator(),
      ),
      onEmpty: const Center(
        child: Text('No Chats Yet'),
      ),
      bottomLoader: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}