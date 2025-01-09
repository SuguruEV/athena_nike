import 'dart:io';
import 'package:athena_nike/utilities/assets_manager.dart';
import 'package:flutter/material.dart';

class DisplayUserImage extends StatelessWidget {
  const DisplayUserImage({
    super.key,
    required this.finalFileImage,
    required this.radius,
    required this.onPressed,
  });

  final File? finalFileImage;
  final double radius;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Display the user's image or a default image if none is provided
        CircleAvatar(
          radius: radius,
          backgroundImage: finalFileImage == null
              ? const AssetImage(AssetsManager.userImage)
              : FileImage(File(finalFileImage!.path)) as ImageProvider,
        ),
        // Display a camera icon for updating the image
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: onPressed,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}