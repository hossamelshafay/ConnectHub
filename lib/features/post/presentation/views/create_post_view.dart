import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/create_post_cubit.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/create_post_state.dart';
import 'package:connecthub/features/post/presentation/widgets/create_post_image_section.dart';
import 'package:connecthub/features/post/presentation/widgets/create_post_top_bar.dart';
import 'package:connecthub/features/search/presentation/widgets/mention_autocomplete_overlay.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, CreatePostCubit cubit) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a post title'),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.warning, width: 1),
          ),
        ),
      );
      return;
    }
    cubit.createPost(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatePostCubit(),
      child: BlocConsumer<CreatePostCubit, CreatePostState>(
        listener: (context, state) {
          if (state is CreatePostSuccess) {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Post shared successfully'),
                backgroundColor: AppColors.surfaceVariant,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.success, width: 1),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is CreatePostError) {
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
        builder: (context, state) {
          final cubit = context.read<CreatePostCubit>();
          final isSubmitting = state is CreatePostSubmitting;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: DarkGlassBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    CreatePostTopBar(
                      isSubmitting: isSubmitting,
                      onSubmit: () => _submit(context, cubit),
                    ),
                    Divider(color: AppColors.divider, height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleController,
                              style: AppTextStyles.headline2.copyWith(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: 'Give your post a title...',
                                hintStyle: AppTextStyles.headline2.copyWith(
                                  fontSize: 20,
                                  color: AppColors.textHint,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(height: 14),
                            MentionAutocompleteOverlay(
                              controller: _descriptionController,
                              showAbove: false,
                              child: TextField(
                                controller: _descriptionController,
                                style: AppTextStyles.body1,
                                maxLines: 8,
                                decoration: InputDecoration(
                                  hintText:
                                      'What\'s on your mind? (Type @ to mention peers)',
                                  hintStyle: AppTextStyles.body1.copyWith(
                                    color: AppColors.textHint,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            CreatePostImageSection(
                              selectedImage: cubit.selectedImage,
                              onRemoveImage: cubit.removeImage,
                              onPickGallery: () => cubit.pickImage(source: ImageSource.gallery),
                              onPickCamera: () => cubit.pickImage(source: ImageSource.camera),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
