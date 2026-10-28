import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/presentation/widgets/auth_step_indicator.dart';
import 'package:connecthub/features/auth/presentation/widgets/avatar_picker_circle.dart';
import 'package:connecthub/features/auth/presentation/widgets/photo_source_sheet.dart';
import 'package:connecthub/features/auth/presentation/views/welcome_success_view.dart';
import 'package:connecthub/features/profile/data/repos/profile_repo_imp.dart';

class PhotoPickView extends StatefulWidget {
  const PhotoPickView({super.key});

  @override
  State<PhotoPickView> createState() => _PhotoPickViewState();
}

class _PhotoPickViewState extends State<PhotoPickView> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedBytes;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _selectedBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: $e'),
            backgroundColor: AppColors.surfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        );
      }
    }
  }

  void _showSourceSheet() {
    PhotoSourceSheet.show(
      context,
      onGallerySelected: () => _pickImage(ImageSource.gallery),
      onCameraSelected: () => _pickImage(ImageSource.camera),
    );
  }


  Future<void> _saveAndContinue() async {
    if (_selectedBytes != null) {
      setState(() => _isUploading = true);
      try {
        final profileRepo = ProfileRepoImp();
        final url = await profileRepo.uploadProfileBytes(_selectedBytes!);
        if (url != null) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await profileRepo.updateProfile(
              name: user.displayName ?? '',
              username: '',
              bio: '',
              profileImageUrl: url,
            );
          }
        }
      } catch (_) {
        // Continue even if avatar upload had an issue
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
    _goToWelcomeSuccess();
  }

  void _goToWelcomeSuccess() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const WelcomeSuccessView(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AuthStepIndicator(currentStep: 3, totalSteps: 3),
                ],
              ),
              const Spacer(flex: 1),

              AvatarPickerCircle(
                selectedBytes: _selectedBytes,
                displayName: FirebaseAuth.instance.currentUser?.displayName ?? 'U',
                onTap: _showSourceSheet,
              ),
              const SizedBox(height: 28),

              Text('Add a Profile Photo', style: AppTextStyles.headline1),
              const SizedBox(height: 10),
              Text(
                'Help colleagues and collaborators recognize you',
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              PrimaryButton(
                text: _selectedBytes != null ? 'Continue' : 'Choose Photo',
                isLoading: _isUploading,
                onPressed: _selectedBytes != null
                    ? _saveAndContinue
                    : _showSourceSheet,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _goToWelcomeSuccess,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Skip for now',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
