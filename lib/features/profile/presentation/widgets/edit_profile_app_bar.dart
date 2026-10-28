import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';

/// Premium AppBar for Edit Profile screen with Back button and Save pill.
class EditProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const EditProfileAppBar({
    super.key,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final saveBtnBg = AppColors.isDark
        ? AppColors.primary
        : const Color(0xFFA67C52);
    final saveBtnTextColor = AppColors.isDark
        ? Colors.black
        : Colors.white;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Center(
        child: AppIconButton(
          icon: Icons.arrow_back_ios_new,
          size: 18,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Edit Profile',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: GestureDetector(
              onTap: isSaving ? null : onSave,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 7.5,
                ),
                decoration: BoxDecoration(
                  color: saveBtnBg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: saveBtnBg.withValues(alpha: 0.30),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(saveBtnTextColor),
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: saveBtnTextColor,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
