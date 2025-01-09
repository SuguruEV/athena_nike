import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/streams/data_repository.dart';
import 'package:athena_nike/widgets/friend_widget.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';

class AllUsersList extends StatelessWidget {
  const AllUsersList({
    super.key,
    required this.userID,
    required this.searchQuery,
  });

  final String userID;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return FirestorePagination(
      limit: 20,
      isLive: true,
      query: DataRepository.getUsersQuery(
        userID: userID,
      ),
      itemBuilder: (context, documentSnapshot, index) {
        // Get the document data at index
        final documnets = documentSnapshot[index];

        // Get user data
        final user =
            UserModel.fromMap(documnets.data()! as Map<String, dynamic>);

        // Apply search filter, if item does not match search query, return empty widget
        if (!user.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          return const SizedBox.shrink();
        }

        // Hide the current user's data from the list
        if (user.uid == userID) {
          return const SizedBox.shrink();
        }

        return FriendWidget(friend: user, viewType: FriendViewType.allUsers);
      },
      initialLoader: const Center(
        child: CircularProgressIndicator(),
      ),
      onEmpty: const Center(
        child: Text('No Users Yet'),
      ),
      bottomLoader: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}