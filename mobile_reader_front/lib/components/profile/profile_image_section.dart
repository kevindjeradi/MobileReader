// profile_image_section.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_reader_front/components/generics/custom_circle_avatar.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/services/api.dart';
import 'package:mobile_reader_front/views/profile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ProfileImageSection extends StatelessWidget {
  const ProfileImageSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _changeProfileImage(context, userProvider),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          CustomCircleAvatar(
            radius: 80.0,
            imagePath: userProvider.profileImage.isNotEmpty
                ? '${ProfileState.baseUrl}${userProvider.profileImage}'
                : 'https://via.placeholder.com/150',
          ),
          Positioned(
            bottom: -10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                userProvider.username,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.camera_alt,
              color: theme.colorScheme.primary,
              size: 24.0,
            ),
          ),
        ],
      ),
    );
  }

  void _changeProfileImage(
      BuildContext context, UserProvider userProvider) async {
    var status = await Permission.photos.status;
    if (status.isDenied) {
      if (context.mounted) {
        showCustomSnackBar(
            context,
            "Veuillez autoriser l'accès aux photos pour continuer",
            SnackBarType.info);
        status = await Permission.photos.request();
      }
    }
    if (status.isGranted) {
      // Use the image_picker to pick an image
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File image = File(pickedFile.path);

        // Use the setUserProfileImage to upload the image
        await Api().setUserProfileImage(image).then((response) {
          String newImageUrl = response['profileImage'];
          String finalImageUrl = newImageUrl;

          // Update the userProvider with the new image URL
          userProvider.updateProfileImage(finalImageUrl);

          showCustomSnackBar(
            context,
            "Profile image updated successfully!",
            SnackBarType.success,
          );
        }).catchError((error) {
          showCustomSnackBar(
            context,
            "Error updating profile image: $error",
            SnackBarType.error,
          );
        });
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        showCustomSnackBar(
            context,
            "Vous devez autoriser l'accès aux photos pour continuer",
            SnackBarType.info);
      }

      openAppSettings();
    }
  }
}
