import 'dart:io';
import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/utilities/assets_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          ? CachedNetworkImageProvider(imageUrl)
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

// Pick Video From Gallery
Future<File?> pickVideo({
  required Function(String) onFail,
}) async {
  File? fileVideo;
  try {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) {
      onFail('No Video Selected');
    } else {
      fileVideo = File(pickedFile.path);
    }
  } catch (e) {
    onFail(e.toString());
  }

  return fileVideo;
}

Center buildDateTime(groupedByValue) {
  return Center(
    child: Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          formatDate(groupedByValue.timeSent, [dd, ' ', M, ',', yyyy]),
          textAlign: TextAlign.center,
          style: GoogleFonts.titilliumWeb(
            fontWeight: FontWeight.bold,
          ),
        ), // optional
      ),
    ),
  );
}

Widget messageToShow({
  required MessageEnum type,
  required String message,
}) {
  switch (type) {
    case MessageEnum.text:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    case MessageEnum.image:
      return const Row(
        children: [
          Icon(
            Icons.image_outlined,
          ),
          SizedBox(width: 10),
          Text(
            'Image',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.video:
      return const Row(
        children: [
          Icon(
            Icons.video_library_outlined,
          ),
          SizedBox(width: 10),
          Text(
            'Video',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.audio:
      return const Row(
        children: [
          Icon(
            Icons.audiotrack_outlined,
          ),
          SizedBox(width: 10),
          Text(
            'Audio',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );

    default:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
  }
}

// Default list of emoji for reactions and plus sign at the end for more emoji
// like, love, haha, wow, sad, angry, and plus sign
List<String> reactions = [
  '😍',
  '😂',
  '😮',
  '😢',
  '😡',
  '👍',
  '➕',
];

// List of contextMenu for reply, copy and delete
List<String> contextMenu = [
  'Reply',
  'Copy',
  'Delete',
];
