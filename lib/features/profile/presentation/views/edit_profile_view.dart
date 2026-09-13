import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_state.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    final state = cubit.state;

    String initialName = '';
    String initialUsername = '';
    String initialBio = '';

    if (state is ProfileLoaded) {
      initialName = state.displayName;
      initialUsername = state.username.replaceAll('@', '');
      initialBio = state.bio;
    }

    _nameController = TextEditingController(text: initialName);
    _usernameController = TextEditingController(text: initialUsername);
    _bioController = TextEditingController(text: initialBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Change Profile Photo', style: AppTextStyles.headline3),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_rounded,
                        color: AppColors.primary),
                  ),
                  title: const Text('Choose from Gallery',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.accent),
                  ),
                  title: const Text('Take a Photo',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error),
                    ),
                    title: const Text('Remove Selected Photo',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final success = await context.read<ProfileCubit>().updateProfile(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          bio: _bioController.text.trim(),
          imageFile: _selectedImage,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Photo with Edit Badge
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: _buildAvatarPreview(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePickerSheet,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showImagePickerSheet,
                    child: Text(
                      'Change photo',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Display Name Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Display Name',
                      style: AppTextStyles.body2
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Enter your name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Display name cannot be empty';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Username Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Username',
                      style: AppTextStyles.body2
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _usernameController,
                    hintText: 'username',
                    prefixIcon: Icons.alternate_email_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Username cannot be empty';
                      }
                      if (val.trim().contains(' ')) {
                        return 'Username cannot contain spaces';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Bio Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bio',
                      style: AppTextStyles.body2
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _bioController,
                    hintText: 'Write something about yourself...',
                    prefixIcon: Icons.edit_note_rounded,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 36),

                  // Save Changes Button
                  PrimaryButton(
                    text: 'Save Changes',
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 110,
        height: 110,
      );
    }

    final state = context.read<ProfileCubit>().state;
    String? currentImage;
    String name = 'User';

    if (state is ProfileLoaded) {
      currentImage = state.profileImage;
      name = state.displayName;
    }

    if (currentImage != null && currentImage.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: currentImage,
        fit: BoxFit.cover,
        width: 110,
        height: 110,
        errorWidget: (_, _, _) => _fallback(name),
      );
    }

    return _fallback(name);
  }

  Widget _fallback(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
