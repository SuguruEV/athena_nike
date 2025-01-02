import 'package:athena_nike/constants.dart';
import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/providers/search_provider.dart';
import 'package:athena_nike/widgets/friends_list.dart';
import 'package:athena_nike/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDialogs {
  // animated dialog
  static void showMyAnimatedDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String textAction,
    required Function(bool, String) onActionTap,
    bool editable = false,
    String hintText = '',
  }) {
    TextEditingController controller = TextEditingController(text: hintText);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
              child: AlertDialog(
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
                content: editable
                    ? TextField(
                        controller: controller,
                        maxLength: content == Constants.changeName ? 20 : 500,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: hintText,
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    : Text(
                        content,
                        textAlign: TextAlign.center,
                      ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onActionTap(
                        false,
                        controller.text,
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onActionTap(
                        true,
                        controller.text,
                      );
                    },
                    child: Text(textAction),
                  ),
                ],
              ),
            ));
      },
    );
  }

  // Bottom sheet with a list of all app users to add them to the group
  static void showAddMembersBottomSheet({
    required BuildContext context,
    required List<String> groupMembersUIDs,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PopScope(
          onPopInvoked: (bool didPop) async {
            if (!didPop) return;
            // Do something when the bottom sheet is closed.
            await context
                .read<GroupProvider>()
                .removeTempLists(isAdmins: false);
          },
          child: SizedBox(
            height: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SearchBarWidget(
                          onChanged: (value) {
                            context
                                .read<SearchProvider>()
                                .setSearchQuery(value);
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context
                              .read<GroupProvider>()
                              .updateGroupDataInFireStoreIfNeeded()
                              .whenComplete(() {
                            // close bottom sheet
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 2,
                  color: Colors.grey,
                ),
                Expanded(
                  child: FriendsList(
                    viewType: FriendViewType.groupView,
                    groupMembersUIDs: groupMembersUIDs,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
