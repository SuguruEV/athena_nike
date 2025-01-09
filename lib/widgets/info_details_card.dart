import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/utilities/my_dialogs.dart';
import 'package:athena_nike/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InfoDetailsCard extends StatelessWidget {
  const InfoDetailsCard({
    super.key,
    this.groupProvider,
    this.isAdmin,
    this.userModel,
  });

  final GroupProvider? groupProvider;
  final bool? isAdmin;
  final UserModel? userModel;

  @override
  Widget build(BuildContext context) {
    // Get current user
    final authProvider = context.read<AuthenticationProvider>();
    final userModel = authProvider.userModel;

    if (userModel == null) {
      return Center(
        child: Text('User not found'),
      );
    }

    final uid = userModel.uid;
    final phoneNumber = userModel.phoneNumber;

    // Get profile image
    final profileImage = this.userModel != null
        ? this.userModel!.image
        : groupProvider!.groupModel.groupImage;
    // Get profile name
    final profileName = this.userModel != null
        ? this.userModel!.name
        : groupProvider!.groupModel.groupName;

    // Get group description
    final aboutMe = this.userModel != null
        ? this.userModel!.aboutMe
        : groupProvider!.groupModel.groupDescription;

    // Determine if it's a group
    final isGroup = this.userModel != null ? false : true;

    // Widget to get edit options
    Widget getEditWidget(
      String title,
      String content,
    ) {
      if (isGroup) {
        // Check if user is admin
        if (isAdmin!) {
          return InkWell(
            onTap: () {
              MyDialogs.showMyAnimatedDialog(
                context: context,
                title: title,
                content: content,
                textAction: "Change",
                onActionTap: (value, updatedText) async {
                  if (value) {
                    if (content == Constants.changeName) {
                      final name = await authProvider.updateName(
                        isGroup: isGroup,
                        id: isGroup ? groupProvider!.groupModel.groupID : uid,
                        newName: updatedText,
                        oldName: profileName,
                      );
                      if (isGroup) {
                        if (name == 'Invalid name.') return;
                        groupProvider!.setGroupName(name);
                      }
                    } else {
                      final desc = await authProvider.updateStatus(
                        isGroup: isGroup,
                        id: isGroup ? groupProvider!.groupModel.groupID : uid,
                        newDesc: updatedText,
                        oldDesc: aboutMe,
                      );
                      if (isGroup) {
                        if (desc == 'Invalid description.') return;
                        groupProvider!.setGroupName(desc);
                      }
                    }
                  }
                },
                editable: true,
                hintText:
                    content == Constants.changeName ? profileName : aboutMe,
              );
            },
            child: const Icon(Icons.edit_rounded),
          );
        } else {
          return const SizedBox();
        }
      } else {
        if (this.userModel != null && this.userModel!.uid != uid) {
          return const SizedBox();
        }

        return InkWell(
          onTap: () {
            MyDialogs.showMyAnimatedDialog(
              context: context,
              title: title,
              content: content,
              textAction: "Change",
              onActionTap: (value, updatedText) {
                if (value) {
                  if (content == Constants.changeName) {
                    authProvider.updateName(
                      isGroup: isGroup,
                      id: isGroup ? groupProvider!.groupModel.groupID : uid,
                      newName: updatedText,
                      oldName: profileName,
                    );
                  } else {
                    authProvider.updateStatus(
                      isGroup: isGroup,
                      id: isGroup ? groupProvider!.groupModel.groupID : uid,
                      newDesc: updatedText,
                      oldDesc: aboutMe,
                    );
                  }
                }
              },
              editable: true,
              hintText: content == Constants.changeName ? profileName : aboutMe,
            );
          },
          child: const Icon(Icons.edit_rounded),
        );
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlobalMethods.userImageWidget(
                    imageUrl: profileImage,
                    fileImage: authProvider.finalFileImage,
                    radius: 50,
                    onTap: () {
                      authProvider.showBottomSheet(
                          context: context,
                          onSuccess: () async {
                            if (isGroup) {
                              groupProvider!.setIsSloading(value: true);
                            }

                            String imageUrl = await authProvider.updateImage(
                              isGroup: isGroup,
                              id: isGroup
                                  ? groupProvider!.groupModel.groupID
                                  : uid,
                            );

                            if (isGroup) {
                              groupProvider!.setIsSloading(value: false);
                              if (imageUrl == 'Error') return;
                              groupProvider!.setGroupImage(imageUrl);
                            }
                          });
                    }),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            profileName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          getEditWidget(
                            'Change Name',
                            Constants.changeName,
                          ),
                        ],
                      ),
                      // Display phone number
                      this.userModel != null && uid == this.userModel!.uid
                          ? Text(
                              phoneNumber,
                              style: GoogleFonts.titilliumWeb(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),
                      this.userModel != null
                          ? ProfileStatusWidget(
                              userModel: this.userModel!,
                              currentUser: authProvider.userModel!,
                            )
                          : GroupStatusWidget(
                              isAdmin: isAdmin!,
                              groupProvider: groupProvider!,
                            ),

                      const SizedBox(height: 10),
                    ],
                  ),
                )
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(this.userModel != null ? 'About Me' : 'Group Description',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                getEditWidget(
                  'Change Status',
                  Constants.changeDesc,
                ),
              ],
            ),
            Text(
              aboutMe,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}