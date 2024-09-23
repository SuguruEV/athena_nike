import 'dart:io';

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

// Pick Image From Gallery Or Camera
Future<File?> pickImage({
  required bool fromCamera,
  required Function(String) onFail,
}) async {
  File? fileImage;
  if(fromCamera) {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if(pickedFile == null) {
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
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(pickedFile == null) {
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
