import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_cubit.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_state.dart';
import 'package:connecthub/features/post/presentation/widgets/edit_post_image_section.dart';
import 'package:connecthub/features/post/presentation/widgets/edit_post_top_bar.dart';
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

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  EditPostTopBar(
                    isSubmitting: isSubmitting,
                    onSave: () {
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
                  ),
                  Divider(color: AppColors.divider, height: 1),
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
                          EditPostImageSection(
                            newImage: _newImage,
                            initialImageUrl: widget.initialImageUrl,
                            removeCurrentImage: _removeCurrentImage,
                            onPickImage: _pickImage,
                            onRemoveImage: _removeImage,
                          ),
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
