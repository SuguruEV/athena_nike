import 'package:athena_nike/enums/enums.dart';
import 'package:flutter/material.dart';

class GroupTypeListTile extends StatelessWidget {
  GroupTypeListTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  GroupType value;
  GroupType? groupValue;
  final Function(GroupType?) onChanged;

  @override
  Widget build(BuildContext context) {
    // Capitalise the first letter of the title
    final capitalisedTitle = title[0].toUpperCase() + title.substring(1);
    return RadioListTile(
      value: value,
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.grey[200],
      contentPadding: EdgeInsets.zero,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(
        capitalisedTitle,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
