import 'dart:io';

import 'package:athena_nike/constants.dart';
import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/models/group_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/group_provider.dart';
import 'package:athena_nike/providers/search_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/display_user_image.dart';
import 'package:athena_nike/widgets/friends_list.dart';
import 'package:athena_nike/widgets/group_type_list_tile.dart';
import 'package:athena_nike/widgets/my_app_bar.dart';
import 'package:athena_nike/widgets/search_bar_widget.dart';
import 'package:athena_nike/widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  // Controller for group name input
  final TextEditingController groupNameController = TextEditingController();
  // Controller for group description input
  final TextEditingController groupDescriptionController = TextEditingController();
  File? finalFileImage;
  String userImage = '';

  // Select image from camera or gallery
  void selectImage(bool fromCamera) async {
    finalFileImage = await GlobalMethods.pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        GlobalMethods.showSnackBar(context, message);
      },
    );

    // Crop the selected image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  // Close the bottom sheet
  void popContext() {
    Navigator.pop(context);
  }

  // Crop the selected image
  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      }
    }
  }

  // Show bottom sheet for image selection
  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                selectImage(true);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
            ),
            ListTile(
              onTap: () {
                selectImage(false);
              },
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    super.dispose();
  }

  GroupType groupValue = GroupType.private;

  // Create a new group
  void createGroup() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final groupProvider = context.read<GroupProvider>();
    // Check if the group name is empty
    if (groupNameController.text.isEmpty) {
      GlobalMethods.showSnackBar(context, 'Please enter a group name');
      return;
    }

    // Check if the group name is less than 3 characters
    if (groupNameController.text.length < 3) {
      GlobalMethods.showSnackBar(context, 'Group name must be at least 3 characters');
      return;
    }

    // Check if the group description is empty
    if (groupDescriptionController.text.isEmpty) {
      GlobalMethods.showSnackBar(context, 'Please enter a group description');
      return;
    }

    GroupModel groupModel = GroupModel(
      creatorUID: uid,
      groupName: groupNameController.text,
      groupDescription: groupDescriptionController.text,
      groupImage: '',
      groupID: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageID: '',
      timeSent: DateTime.now(),
      createdAt: DateTime.now(),
      isPrivate: groupValue == GroupType.private ? true : false,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoin: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );

    // Create the group
    groupProvider.createGroup(
      newGroupModel: groupModel,
      fileImage: finalFileImage,
      onSuccess: () {
        GlobalMethods.showSnackBar(context, 'Group created successfully');
        Navigator.pop(context);
      },
      onFail: (error) {
        GlobalMethods.showSnackBar(context, error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Create Group'),
        onPressed: () => Navigator.pop(context),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: context.watch<GroupProvider>().isSloading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      onPressed: () {
                        // Create the group
                        createGroup();
                      },
                      icon: const Icon(Icons.check)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Display user image with option to change
                  DisplayUserImage(
                    finalFileImage: finalFileImage,
                    radius: 60,
                    onPressed: () {
                      showBottomSheet();
                    },
                  ),
                  const SizedBox(width: 10),
                  // Display group type selection
                  buildGroupType(),
                ],
              ),
              const SizedBox(height: 20),
              // TextField for group name
              TextField(
                controller: groupNameController,
                maxLength: 25,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Enter group name',
                  label: Text('Group Name'),
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // TextField for group description
              TextField(
                controller: groupDescriptionController,
                maxLength: 100,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Enter group description',
                  label: Text('Group Description'),
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Group settings option
              Card(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: SettingsListTile(
                      title: 'Group Settings',
                      icon: Icons.settings,
                      iconContainerColor: Colors.deepPurple,
                      onTap: () {
                        // Navigate to group settings screen
                        Navigator.pushNamed(
                            context, Constants.groupSettingsScreen);
                      }),
                ),
              ),
              const SizedBox(height: 20),
              // Title for selecting group members
              const Text(
                'Select Group Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Search bar for finding friends
              SearchBarWidget(
                onChanged: (value) {
                  context.read<SearchProvider>().setSearchQuery(value);
                },
              ),
              const SizedBox(height: 10),
              // Display list of friends to select as group members
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: const FriendsList(
                  viewType: FriendViewType.groupView,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the group type selection widgets
  Column buildGroupType() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.private.name,
            value: GroupType.private,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.public.name,
            value: GroupType.public,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
      ],
    );
  }
}