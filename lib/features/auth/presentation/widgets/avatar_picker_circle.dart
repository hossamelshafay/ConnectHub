import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';

class AvatarPickerCircle extends StatelessWidget {
  final Uint8List? selectedBytes;
  final String displayName;
  final VoidCallback onTap;

  const AvatarPickerCircle({
    super.key,
    required this.selectedBytes,
    required this.displayName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: selectedBytes != null
                    ? AppColors.primary
                    : AppColors.glassBorder,
                width: 2,
              ),
              boxShadow: [
                if (selectedBytes != null)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: ClipOval(
              child: selectedBytes != null
                  ? Image.memory(
                      selectedBytes!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : UserAvatar(
                      name: displayName,
                      size: 120,
                    ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.background,
                width: 2.5,
              ),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
