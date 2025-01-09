import 'package:athena_nike/providers/group_provider.dart';
import 'package:flutter/material.dart';

class AddMembers extends StatelessWidget {
  const AddMembers({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
    required this.onPressed,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Display the number of group members
        Text(
          '${groupProvider.groupMembersList.length} members',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // If the user is not an admin, show an empty SizedBox
        !isAdmin
            ? const SizedBox()
            : Row(
                children: [
                  // Display "Add Members" text
                  const Text(
                    'Add Members',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Display a button to add members
                  CircleAvatar(
                    child: IconButton(
                      onPressed: onPressed,
                      icon: const Icon(Icons.person_add),
                    ),
                  )
                ],
              )
      ],
    );
  }
}