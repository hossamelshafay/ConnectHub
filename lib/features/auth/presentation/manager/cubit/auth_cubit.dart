import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/auth/data/models/saved_account_model.dart';
import 'package:connecthub/features/auth/data/repos/auth_repo.dart';
import 'package:connecthub/features/auth/data/repos/auth_repo_imp.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit({AuthRepo? authRepo})
      : _authRepo = authRepo ?? AuthRepoImp(),
        super(AuthInitial());

  User? get currentUser => _authRepo.currentUser;

  void checkAuthStatus() {
    _authRepo.checkAuthStatus(
      onAuthenticated: (user) => emit(AuthAuthenticated(user)),
      onUnauthenticated: () => emit(AuthUnauthenticated()),
    );
  }

  Future<void> reloadUser() async {
    try {
      final user = await _authRepo.reloadUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
      await loadSavedAccounts();
    } catch (_) {}
  }

  Future<void> deleteAccount({
    required String password,
    void Function(String step)? onProgress,
  }) async {
    try {
      await _authRepo.deleteAccount(
        password: password,
        onProgress: onProgress,
      );
      emit(AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      final baseMsg = _authRepo.getErrorMessage(e.code);
      throw Exception(baseMsg);
    } catch (e) {
      rethrow;
    }
  }

  void emitUnauthenticated() {
    emit(AuthUnauthenticated());
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.signUp(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_authRepo.getErrorMessage(e.code)));
    } on FirebaseException catch (e) {
      emit(AuthError(e.message ?? _authRepo.getErrorMessage(e.code)));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg.isNotEmpty ? msg : 'An unexpected error occurred.'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.login(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('=== [AuthCubit] login FirebaseAuthException ===');
      // ignore: avoid_print
      print('Code: ${e.code}');
      // ignore: avoid_print
      print('Message: ${e.message}');
      final baseMsg = _authRepo.getErrorMessage(e.code);
      emit(AuthError('$baseMsg (${e.code})'));
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print('=== [AuthCubit] login FirebaseException ===');
      // ignore: avoid_print
      print('Code: ${e.code}');
      // ignore: avoid_print
      print('Message: ${e.message}');
      emit(AuthError('${e.message ?? _authRepo.getErrorMessage(e.code)} (${e.code})'));
    } catch (e) {
      // ignore: avoid_print
      print('=== [AuthCubit] login Generic Exception: $e ===');
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg.isNotEmpty ? msg : 'An unexpected error occurred.'));
    }
  }

  Future<void> loadSavedAccounts() async {
    final accounts = await _authRepo.getSavedAccounts();
    final active = await _authRepo.getActiveAccount();
    emit(AuthSavedAccountsLoaded(
      savedAccounts: accounts,
      activeAccount: active,
    ));
  }

  Future<void> removeSavedAccount(String uid) async {
    await _authRepo.removeSavedAccount(uid);
    await loadSavedAccounts();
  }

  Future<List<SavedAccountModel>> getSavedAccounts() =>
      _authRepo.getSavedAccounts();

  Future<SavedAccountModel?> getActiveAccount() =>
      _authRepo.getActiveAccount();

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      await _authRepo.forgotPassword(email);
      emit(AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_authRepo.getErrorMessage(e.code)));
    } on FirebaseException catch (e) {
      emit(AuthError(e.message ?? _authRepo.getErrorMessage(e.code)));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg.isNotEmpty ? msg : 'An unexpected error occurred.'));
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    emit(AuthUnauthenticated());
  }
}

