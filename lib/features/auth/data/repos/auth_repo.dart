import 'package:firebase_auth/firebase_auth.dart';

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
}
