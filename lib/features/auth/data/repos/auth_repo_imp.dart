import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connecthub/core/services/account_deletion_service.dart';
import 'package:connecthub/features/auth/data/models/saved_account_model.dart';
import 'package:connecthub/features/auth/data/repos/auth_repo.dart';

class AuthRepoImp implements AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _savedAccountsKey = 'connecthub_saved_accounts';

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.reload();

    // Save user data to Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'followersCount': 0,
      'followingCount': 0,
    });

    final user = _auth.currentUser ?? credential.user!;
    await syncCurrentAccountToSaved();
    return user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final cleanedEmail = email.trim();
    // Debug logging for email synchronization verification
    // ignore: avoid_print
    print('=== [AuthRepo] signInWithEmailAndPassword attempt ===');
    // ignore: avoid_print
    print('Email passed to signInWithEmailAndPassword: "$cleanedEmail"');

    final credential = await _auth.signInWithEmailAndPassword(
      email: cleanedEmail,
      password: password,
    );
    final user = _auth.currentUser ?? credential.user!;
    // ignore: avoid_print
    print('=== [AuthRepo] signInWithEmailAndPassword SUCCESS ===');
    // ignore: avoid_print
    print('Authenticated user.uid: ${user.uid}');
    // ignore: avoid_print
    print('Authenticated user.email: ${user.email}');

    // Synchronize Firestore user document with verified auth email
    if (user.email != null && user.email!.isNotEmpty) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email!.trim(),
        }, SetOptions(merge: true));
        // ignore: avoid_print
        print('=== [AuthRepo] Firestore users/${user.uid}.email synced to "${user.email}" ===');
      } catch (e) {
        // ignore: avoid_print
        print('=== [AuthRepo] Firestore sync warning: $e ===');
      }
    }

    await syncCurrentAccountToSaved();
    return user;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<User?> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      await syncCurrentAccountToSaved();
      return _auth.currentUser;
    }
    return null;
  }

  @override
  Future<void> deleteAccount({
    required String password,
    void Function(String step)? onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated user session found.');
    }

    // 1. Re-authenticate user
    onProgress?.call('Re-authenticating your account...');
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    // 2. Cascade delete all Firestore collections, comments, likes, notifications
    await AccountDeletionService(firestore: _firestore).executeFullDeletion(
      user,
      onProgress: onProgress,
    );

    // 3. Remove from Secure Storage
    onProgress?.call('Removing saved credentials...');
    await removeSavedAccount(user.uid);
    final remaining = await getSavedAccounts();
    if (remaining.isEmpty) {
      try {
        await _storage.deleteAll();
      } catch (_) {}
    }

    // 4. Delete Firebase Authentication account
    onProgress?.call('Deleting authentication account...');
    await user.delete();

    // 5. Sign out
    onProgress?.call('Finalizing...');
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  @override
  void checkAuthStatus({
    required void Function(User user) onAuthenticated,
    required void Function() onUnauthenticated,
  }) {
    final user = _auth.currentUser;
    if (user != null) {
      syncCurrentAccountToSaved();
      onAuthenticated(user);
    } else {
      onUnauthenticated();
    }
  }

  @override
  Future<List<SavedAccountModel>> getSavedAccounts() async {
    try {
      final rawJson = await _storage.read(key: _savedAccountsKey);
      if (rawJson == null || rawJson.trim().isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(rawJson);
      final accounts = jsonList
          .map((item) => SavedAccountModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Sort with most recently used account first
      accounts.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
      return accounts;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveOrUpdateAccount(SavedAccountModel account) async {
    try {
      final accounts = await getSavedAccounts();
      final index = accounts.indexWhere((a) => a.uid == account.uid);

      final updatedAccount = account.copyWith(lastUsedAt: DateTime.now());

      if (index >= 0) {
        // Deduplicate: Update existing entry
        accounts[index] = updatedAccount;
      } else {
        // Add new entry
        accounts.add(updatedAccount);
      }

      // Re-sort with most recent first
      accounts.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));

      final jsonString = jsonEncode(accounts.map((a) => a.toJson()).toList());
      await _storage.write(key: _savedAccountsKey, value: jsonString);
    } catch (_) {}
  }

  @override
  Future<void> removeSavedAccount(String uid) async {
    try {
      final accounts = await getSavedAccounts();
      accounts.removeWhere((a) => a.uid == uid);
      final jsonString = jsonEncode(accounts.map((a) => a.toJson()).toList());
      await _storage.write(key: _savedAccountsKey, value: jsonString);
    } catch (_) {}
  }

  @override
  Future<SavedAccountModel?> getActiveAccount() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final accounts = await getSavedAccounts();
    try {
      return accounts.firstWhere((a) => a.uid == user.uid);
    } catch (_) {
      return syncCurrentAccountToSaved();
    }
  }

  @override
  Future<SavedAccountModel?> syncCurrentAccountToSaved() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    String displayName = user.displayName ?? '';
    String username = '';
    String profileImage = user.photoURL ?? '';
    String email = user.email ?? '';

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if ((data['name'] as String?)?.isNotEmpty == true) {
          displayName = data['name'] as String;
        }
        if ((data['username'] as String?)?.isNotEmpty == true) {
          username = data['username'] as String;
        }
        if ((data['profileImage'] as String?)?.isNotEmpty == true) {
          profileImage = data['profileImage'] as String;
        }
        if ((data['email'] as String?)?.isNotEmpty == true) {
          email = data['email'] as String;
        }
      }
    } catch (_) {}

    final account = SavedAccountModel(
      uid: user.uid,
      email: email,
      displayName: displayName.isNotEmpty ? displayName : (user.email ?? 'User'),
      username: username,
      profileImage: profileImage,
      lastUsedAt: DateTime.now(),
    );

    await saveOrUpdateAccount(account);
    return account;
  }

  @override
  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'operation-not-allowed':
        return 'Email/Password authentication is not enabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'permission-denied':
        return 'Database access denied. Please check Firestore rules.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again later.';
      case 'channel-error':
        return 'Please fill in all required fields.';
      default:
        return 'An error occurred ($code). Please try again.';
    }
  }
}

