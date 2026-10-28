import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

class PhotoSourceSheet extends StatelessWidget {
  final VoidCallback onGallerySelected;
  final VoidCallback onCameraSelected;

  const PhotoSourceSheet({
    super.key,
    required this.onGallerySelected,
    required this.onCameraSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onGallerySelected,
    required VoidCallback onCameraSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => PhotoSourceSheet(
        onGallerySelected: () {
          Navigator.pop(ctx);
          onGallerySelected();
        },
        onCameraSelected: () {
          Navigator.pop(ctx);
          onCameraSelected();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text('Choose Profile Photo', style: AppTextStyles.headline3),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
              ),
              title: Text('Choose from Gallery', style: AppTextStyles.body1),
              onTap: onGallerySelected,
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              ),
              title: Text('Take a Photo', style: AppTextStyles.body1),
              onTap: onCameraSelected,
            ),
          ],
        ),
      ),
    );
  }
}
