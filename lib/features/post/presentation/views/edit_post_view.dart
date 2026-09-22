import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_cubit.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_state.dart';
import 'package:connecthub/features/search/presentation/widgets/mention_autocomplete_overlay.dart';

class EditPostView extends StatefulWidget {
  final String postId;
  final String initialTitle;
  final String initialDescription;
  final String? initialImageUrl;
  final String? initialDeleteHash;

  const EditPostView({
    super.key,
    required this.postId,
    required this.initialTitle,
    required this.initialDescription,
    this.initialImageUrl,
    this.initialDeleteHash,
  });

  @override
  State<EditPostView> createState() => _EditPostViewState();
}

class _EditPostViewState extends State<EditPostView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  File? _newImage;
  bool _removeCurrentImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _newImage = File(pickedFile.path);
          _removeCurrentImage = false;
        });
      }
    } catch (_) {}
  }

  void _removeImage() {
    setState(() {
      _newImage = null;
      _removeCurrentImage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostActionCubit(),
      child: BlocConsumer<PostActionCubit, PostActionState>(
        listener: (context, state) {
          if (state is PostActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is PostActionNoChanges) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.textSecondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is PostActionPostNotFound) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is PostActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<PostActionCubit>();
          final isSubmitting = state is PostActionLoading;

          final hasExistingImage =
              widget.initialImageUrl != null &&
              widget.initialImageUrl!.isNotEmpty &&
              !_removeCurrentImage &&
              _newImage == null;

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.close,
                                color: AppColors.textPrimary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('Edit Post', style: AppTextStyles.headline2),
                        const Spacer(),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    cubit.updatePost(
                                      postId: widget.postId,
                                      title: _titleController.text,
                                      description: _descriptionController.text,
                                      newImage: _newImage,
                                      removeImage: _removeCurrentImage,
                                      oldDeleteHash: widget.initialDeleteHash,
                                      oldDescription: widget.initialDescription,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: _titleController,
                            hintText: 'Post title',
                            prefixIcon: Icons.title,
                          ),
                          const SizedBox(height: 16),
                          MentionAutocompleteOverlay(
                            controller: _descriptionController,
                            showAbove: false,
                            child: CustomTextField(
                              controller: _descriptionController,
                              hintText:
                                  'What\'s on your mind? (Type @ to mention)',
                              maxLines: 6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Image', style: AppTextStyles.body2),
                          const SizedBox(height: 12),
                          if (_newImage != null)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _newImage!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: _removeImage,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else if (hasExistingImage)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.initialImageUrl!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: _removeImage,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                _ImageOption(
                                  icon: Icons.photo_library_outlined,
                                  label: 'Gallery',
                                  onTap: () =>
                                      _pickImage(ImageSource.gallery),
                                ),
                                const SizedBox(width: 12),
                                _ImageOption(
                                  icon: Icons.camera_alt_outlined,
                                  label: 'Camera',
                                  onTap: () =>
                                      _pickImage(ImageSource.camera),
                                ),
                              ],
                            ),
                          if (hasExistingImage) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _pickImage(ImageSource.gallery),
                                  icon: const Icon(
                                      Icons.photo_library_outlined,
                                      size: 16),
                                  label: const Text('Change Image'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                        color: AppColors.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                TextButton.icon(
                                  onPressed: _removeImage,
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16, color: AppColors.error),
                                  label: const Text('Remove Image',
                                      style: TextStyle(
                                          color: AppColors.error)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImageOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}
