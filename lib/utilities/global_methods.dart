import 'dart:io';

import 'package:athena_nike/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Show Snack Bar Method
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

Widget userImageWidget({
  required String imageUrl,
  required double radius,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : const AssetImage(AssetsManager.userImage) as ImageProvider,
    ),
  );
}

// Pick Image From Gallery Or Camera
Future<File?> pickImage({
  required bool fromCamera,
  required Function(String) onFail,
}) async {
  File? fileImage;
  if (fromCamera) {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        onFail('No Image Selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  } else {
    // Pick Image From Gallery
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        onFail('No Image Selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  }

  return fileImage;
}
