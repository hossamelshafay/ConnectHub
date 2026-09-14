import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/search/data/repos/search_repo.dart';
import 'package:connecthub/features/search/data/repos/search_repo_imp.dart';
import 'package:connecthub/features/search/presentation/manager/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo _repo;
  Timer? _debounce;

  SearchCubit({SearchRepo? repo})
      : _repo = repo ?? SearchRepoImp(),
        super(SearchInitial());

  /// Called on every keystroke from the search field.
  /// Debounces 400 ms before executing the Firestore queries.
  void search(String query) {
    _debounce?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final usersFuture = _repo.searchUsers(trimmed);
        final postsFuture = _repo.searchPosts(trimmed);
        final users = await usersFuture;
        final posts = await postsFuture;
        if (isClosed) return;
        emit(SearchLoaded(users: users, posts: posts));
      } catch (_) {
        if (isClosed) return;
        emit(SearchError('Search failed. Please try again.'));
      }
    });
  }

  /// Clears the search and resets to the initial state.
  void clear() {
    _debounce?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
