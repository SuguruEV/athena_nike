import 'dart:io';

import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/app_bar_back_button.dart';
import 'package:athena_nike/widgets/display_user_image.dart';
import 'package:athena_nike/widgets/friends_list.dart';
import 'package:athena_nike/widgets/group_type_list_tile.dart';
import 'package:athena_nike/widgets/settings_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  // Group Name Controller
  final TextEditingController groupNameController = TextEditingController();
  // Group Description Controller
  final TextEditingController groupDescriptionController =
      TextEditingController();

  File? finalFileImage;
  String userImage = '';

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );
    // Crop image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

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
      } else {}
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Create Group'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DisplayUserImage(
                  finalFileImage: finalFileImage,
                  radius: 60,
                  onPressed: () {
                    showBottomSheet();
                  },
                ),
                const SizedBox(width: 10),
                buildGroupType(),
              ],
            ),

            const SizedBox(height: 10),

            // TextField for group name
            TextField(
              controller: groupNameController,
              maxLength: 25,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Group Name',
                label: Text('Group Name'),
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // TextField for group description
            TextField(
              controller: groupDescriptionController,
              maxLength: 100,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Group Description',
                label: Text('Group Description'),
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

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
                    // Navigate to GroupSettingsScreen
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text('Select Group Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),

            const SizedBox(height: 10),

            // Cuppertino Search Bar
            CupertinoSearchTextField(
              onChanged: (value) {},
            ),

            const SizedBox(height: 10),

            const Expanded(
              child: FriendsList(
                viewType: FriendViewType.groupView,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        )
      ],
    );
  }
}
