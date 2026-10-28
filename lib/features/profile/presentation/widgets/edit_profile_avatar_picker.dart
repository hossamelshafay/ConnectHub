import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/user_avatar.dart';

/// Centered circular profile avatar picker matching Mockup Screen 3:
/// - Large circular avatar with fine metallic border.
/// - Circular camera button positioned at bottom right.
class EditProfileAvatarPicker extends StatelessWidget {
  final Uint8List? selectedImageBytes;
  final String fallbackName;
  final String? currentImageUrl;
  final VoidCallback onTap;

  const EditProfileAvatarPicker({
    super.key,
    required this.selectedImageBytes,
    required this.fallbackName,
    required this.currentImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cameraBtnBg = AppColors.isDark
        ? const Color(0xFF2E2B27)
        : const Color(0xFFEFE8DE);
    final cameraBtnBorder = AppColors.isDark
        ? const Color(0x50FFFFFF)
        : const Color(0xFFDFD6C8);
    final cameraIconColor = AppColors.isDark
        ? AppColors.primary
        : const Color(0xFF5A4D3F);

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.isDark
                    ? const Color(0x35FFFFFF)
                    : const Color(0xFFE2D9CC),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: selectedImageBytes != null
                  ? Image.memory(
                      selectedImageBytes!,
                      fit: BoxFit.cover,
                      width: 91,
                      height: 91,
                    )
                  : UserAvatar(
                      name: fallbackName,
                      imageUrl: currentImageUrl,
                      size: 91,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cameraBtnBg,
                  border: Border.all(
                    color: cameraBtnBorder,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: cameraIconColor,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
