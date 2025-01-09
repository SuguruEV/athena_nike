import 'dart:io';
import 'package:athena_nike/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athena_nike/providers/authentication_provider.dart';

class DisplayUserImage extends StatelessWidget {
  const DisplayUserImage({
    super.key,
    required this.radius,
    required this.onPressed,
    this.finalFileImage,
  });

  final double radius;
  final VoidCallback onPressed;
  final File? finalFileImage;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    final String imageUrl = authProvider.userModel?.image ?? '';

    return Stack(
      children: [
        // Display the user's image or a default image if none is provided
        CircleAvatar(
          radius: radius,
          backgroundImage: finalFileImage == null
              ? (imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage(AssetsManager.userImage)) as ImageProvider
              : FileImage(finalFileImage!),
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