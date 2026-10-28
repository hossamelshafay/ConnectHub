import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_state.dart';
import 'package:connecthub/features/profile/presentation/widgets/edit_profile_app_bar.dart';
import 'package:connecthub/features/profile/presentation/widgets/edit_profile_avatar_picker.dart';
import 'package:connecthub/features/profile/presentation/widgets/edit_profile_field.dart';
import 'package:connecthub/features/profile/presentation/widgets/edit_profile_image_sheet.dart';
import 'package:connecthub/features/profile/presentation/widgets/edit_profile_remove_photo_tile.dart';
import 'package:connecthub/features/profile/presentation/widgets/edit_social_links_section.dart';
import 'package:connecthub/features/profile/presentation/widgets/social_icons.dart';

/// Redesigned Edit Profile View:
/// - AppBar with Back button, centered title, and "Save" pill button.
/// - Centered profile photo with camera button.
/// - Form fields: Name, Headline, Bio (with 200 character counter), Location (with pin icon).
/// - Extensible Links section for all supported social platforms + custom links.
/// - "Remove Photo" card at the bottom.
class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;

  // Map of text controllers for each standard social link platform
  final Map<String, TextEditingController> _socialControllers = {};

  // List of key-value pairs for user-defined custom links
  final List<MapEntry<TextEditingController, TextEditingController>>
      _customLinkControllers = [];

  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  bool _isPhotoRemoved = false;
  String? _initialProfileImage;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    final state = cubit.state;

    String initialName = '';
    String initialUsername = '';
    String initialHeadline = '';
    String initialBio = '';
    String initialLocation = '';
    SocialLinksModel initialLinks = const SocialLinksModel();

    if (state is ProfileLoaded) {
      initialName = state.displayName;
      initialUsername = state.username.replaceAll('@', '');
      initialHeadline = state.headline;
      initialBio = state.bio;
      initialLocation = state.location;
      initialLinks = state.socialLinks;
      _initialProfileImage = state.profileImage;
    }

    _nameController = TextEditingController(text: initialName);
    _usernameController = TextEditingController(text: initialUsername);
    _headlineController = TextEditingController(text: initialHeadline);
    _bioController = TextEditingController(text: initialBio);
    _locationController = TextEditingController(text: initialLocation);

    // Initialize standard platform controllers
    for (final meta in SocialPlatformRegistry.all) {
      String val = '';
      switch (meta.key) {
        case 'github':
          val = initialLinks.github ?? '';
          break;
        case 'linkedin':
          val = initialLinks.linkedin ?? '';
          break;
        case 'website':
          val = initialLinks.website ?? '';
          break;
        case 'instagram':
          val = initialLinks.instagram ?? '';
          break;
        case 'twitter':
          val = initialLinks.twitter ?? '';
          break;
        case 'facebook':
          val = initialLinks.facebook ?? '';
          break;
        case 'behance':
          val = initialLinks.behance ?? '';
          break;
        case 'dribbble':
          val = initialLinks.dribbble ?? '';
          break;
        case 'medium':
          val = initialLinks.medium ?? '';
          break;
        case 'youtube':
          val = initialLinks.youtube ?? '';
          break;
        case 'tiktok':
          val = initialLinks.tiktok ?? '';
          break;
        case 'discord':
          val = initialLinks.discord ?? '';
          break;
        case 'telegram':
          val = initialLinks.telegram ?? '';
          break;
      }
      _socialControllers[meta.key] = TextEditingController(text: val);
    }

    // Initialize custom links controllers
    initialLinks.customLinks.forEach((k, v) {
      _customLinkControllers.add(MapEntry(
        TextEditingController(text: k),
        TextEditingController(text: v),
      ));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    for (final c in _socialControllers.values) {
      c.dispose();
    }
    for (final pair in _customLinkControllers) {
      pair.key.dispose();
      pair.value.dispose();
    }
    super.dispose();
  }

  void _addCustomLink() {
    setState(() {
      _customLinkControllers.add(MapEntry(
        TextEditingController(),
        TextEditingController(),
      ));
    });
  }

  void _removeCustomLink(int index) {
    if (index >= 0 && index < _customLinkControllers.length) {
      setState(() {
        final pair = _customLinkControllers.removeAt(index);
        pair.key.dispose();
        pair.value.dispose();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _isPhotoRemoved = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.surfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    final hasExistingPhoto = !_isPhotoRemoved &&
        _initialProfileImage != null &&
        _initialProfileImage!.isNotEmpty;
    final canRemove = _selectedImageBytes != null || hasExistingPhoto;

    showEditProfileImagePickerSheet(
      context: context,
      canRemove: canRemove,
      onPickSource: _pickImage,
      onRemove: _handleRemovePhoto,
    );
  }

  void _handleRemovePhoto() {
    setState(() {
      _selectedImageBytes = null;
      _isPhotoRemoved = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo marked for removal. Tap Save to apply.'),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
      );
    }
  }

  SocialLinksModel _collectSocialLinks() {
    final custom = <String, String>{};
    for (final pair in _customLinkControllers) {
      final key = pair.key.text.trim();
      final val = pair.value.text.trim();
      if (key.isNotEmpty && val.isNotEmpty) {
        custom[key] = val;
      }
    }

    return SocialLinksModel(
      github: _socialControllers['github']?.text.trim(),
      linkedin: _socialControllers['linkedin']?.text.trim(),
      website: _socialControllers['website']?.text.trim(),
      instagram: _socialControllers['instagram']?.text.trim(),
      twitter: _socialControllers['twitter']?.text.trim(),
      facebook: _socialControllers['facebook']?.text.trim(),
      behance: _socialControllers['behance']?.text.trim(),
      dribbble: _socialControllers['dribbble']?.text.trim(),
      medium: _socialControllers['medium']?.text.trim(),
      youtube: _socialControllers['youtube']?.text.trim(),
      tiktok: _socialControllers['tiktok']?.text.trim(),
      discord: _socialControllers['discord']?.text.trim(),
      telegram: _socialControllers['telegram']?.text.trim(),
      customLinks: custom,
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final socialLinks = _collectSocialLinks();

    final success = await context.read<ProfileCubit>().updateProfile(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim().isNotEmpty
              ? _usernameController.text.trim()
              : _nameController.text.trim().toLowerCase().replaceAll(' ', '_'),
          headline: _headlineController.text.trim(),
          bio: _bioController.text.trim(),
          location: _locationController.text.trim(),
          socialLinks: socialLinks,
          imageBytes: _selectedImageBytes,
          removePhoto: _isPhotoRemoved,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.success, width: 1),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = _isPhotoRemoved ? null : _initialProfileImage;
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'User';

    final hasPhoto = _selectedImageBytes != null ||
        (currentImage != null && currentImage.isNotEmpty);

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.surfaceVariant,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.error, width: 1),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: EditProfileAppBar(
          isSaving: _isSaving,
          onSave: _handleSave,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Circular Profile Photo with Camera Badge ───────────
                  EditProfileAvatarPicker(
                    selectedImageBytes: _selectedImageBytes,
                    fallbackName: name,
                    currentImageUrl: currentImage,
                    onTap: _showImagePickerSheet,
                  ),

                  const SizedBox(height: 24),

                  // ── Name Field ─────────────────────────────────────────
                  EditProfileField(
                    label: 'Name',
                    controller: _nameController,
                    hintText: 'Enter your name',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Name cannot be empty';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Headline Field ─────────────────────────────────────
                  EditProfileField(
                    label: 'Headline',
                    controller: _headlineController,
                    hintText: 'e.g. AI Engineer',
                  ),

                  const SizedBox(height: 16),

                  // ── Bio Field with Character Counter (125/200) ─────────
                  EditProfileField(
                    label: 'Bio',
                    controller: _bioController,
                    hintText: 'Write something about yourself...',
                    maxLines: 3,
                    maxLength: 200,
                  ),

                  const SizedBox(height: 16),

                  // ── Location Field with Map Pin Icon ───────────────────
                  EditProfileField(
                    label: 'Location',
                    controller: _locationController,
                    hintText: 'City, Country',
                    prefixIcon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 22),

                  // ── Social & Custom Links Section ──────────────────────
                  EditSocialLinksSection(
                    controllers: _socialControllers,
                    customLinkControllers: _customLinkControllers,
                    onAddCustomLink: _addCustomLink,
                    onRemoveCustomLink: _removeCustomLink,
                  ),

                  const SizedBox(height: 24),

                  // ── Remove Photo Card ──────────────────────────────────
                  if (hasPhoto) ...[
                    EditProfileRemovePhotoTile(
                      onTap: _handleRemovePhoto,
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
