import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connecthub/features/post/data/repos/post_repo.dart';
import 'package:connecthub/features/post/data/repos/post_repo_imp.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  final PostRepo _postRepo;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  CreatePostCubit({PostRepo? postRepo})
      : _postRepo = postRepo ?? PostRepoImp(),
        super(CreatePostInitial());

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 85,
      );
      if (xFile != null) {
        selectedImage = File(xFile.path);
        emit(CreatePostImagePicked(selectedImage!));
      }
    } catch (e) {
      emit(CreatePostError('Failed to pick image.'));
    }
  }

  void removeImage() {
    selectedImage = null;
    emit(CreatePostInitial());
  }

  Future<void> createPost({
    required String title,
    required String description,
  }) async {
    if (title.trim().isEmpty) {
      emit(CreatePostError('Title is required.'));
      return;
    }
    if (description.trim().isEmpty) {
      emit(CreatePostError('Description is required.'));
      return;
    }

    emit(CreatePostSubmitting());

    try {
      await _postRepo.createPost(
        title: title,
        description: description,
        image: selectedImage,
      );
      emit(CreatePostSuccess());
    } catch (e) {
      emit(CreatePostError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
