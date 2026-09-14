import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Map<String, dynamic>> users;
  final List<PostModel> posts;

  SearchLoaded({required this.users, required this.posts});
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
