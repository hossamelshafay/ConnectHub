import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/auth/data/models/saved_account_model.dart';

abstract class AuthRepo {
  User? get currentUser;
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<User> login({
    required String email,
    required String password,
  });
  Future<void> forgotPassword(String email);
  Future<void> signOut();
  void checkAuthStatus({
    required void Function(User user) onAuthenticated,
    required void Function() onUnauthenticated,
  });
  String getErrorMessage(String code);

  // Multi-Account Secure Storage Methods
  Future<List<SavedAccountModel>> getSavedAccounts();
  Future<void> saveOrUpdateAccount(SavedAccountModel account);
  Future<void> removeSavedAccount(String uid);
  Future<SavedAccountModel?> getActiveAccount();
  Future<SavedAccountModel?> syncCurrentAccountToSaved();
}

