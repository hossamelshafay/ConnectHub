import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/auth/data/models/saved_account_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthSignedUp extends AuthState {}

class AuthPasswordResetSent extends AuthState {}

class AuthSavedAccountsLoaded extends AuthState {
  final List<SavedAccountModel> savedAccounts;
  final SavedAccountModel? activeAccount;
  AuthSavedAccountsLoaded({
    required this.savedAccounts,
    this.activeAccount,
  });
}


