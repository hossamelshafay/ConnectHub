import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/notification/data/models/notification_model.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo_imp.dart';
import 'package:connecthub/features/search/data/repos/search_repo_imp.dart';

class MentionHelper {
  static final RegExp _mentionRegex = RegExp(r'@([a-zA-Z0-9_]+)');

  /// In-memory cache mapping normalized username/name/uid -> user data map {id, name, username, profileImage, bio}
  /// Avoids unnecessary Firestore reads when tapping mentions multiple times during a session.
  static final Map<String, Map<String, dynamic>?> _userCache = {};

  /// Extracts a unique set of mentioned usernames (without the leading '@') in lowercase.
  static Set<String> extractUsernames(String text) {
    if (text.isEmpty) return {};
    final matches = _mentionRegex.allMatches(text);
    final usernames = <String>{};
    for (final match in matches) {
      final username = match.group(1);
      if (username != null && username.isNotEmpty) {
        usernames.add(username.toLowerCase());
      }
    }
    return usernames;
  }

  /// Determines if the cursor is currently inside an active mention being typed.
  /// Returns the query string (e.g. "sam" or "" for just "@") if active, or null if not.
  static String? extractActiveMentionQuery(String text, int cursorPosition) {
    if (cursorPosition <= 0 || cursorPosition > text.length) return null;

    final textBeforeCursor = text.substring(0, cursorPosition);

    // Matches an '@' preceded by start of string or whitespace, followed by word characters up to cursor
    final match = RegExp(r'(?:^|\s)@([a-zA-Z0-9_]*)$').firstMatch(textBeforeCursor);
    if (match != null) {
      return match.group(1) ?? '';
    }

    return null;
  }

  /// Resolves a user document by username, checking memory cache first.
  /// Reuses SearchRepo search logic when querying Firestore to cover names and usernames.
  static Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final raw = username.trim().replaceAll('@', '');
    if (raw.isEmpty) return null;
    final normalized = raw.toLowerCase();
    final withSpaces = raw.replaceAll('_', ' ');

    // 1. Check memory cache first
    if (_userCache.containsKey(normalized) && _userCache[normalized] != null) {
      return _userCache[normalized];
    }
    if (_userCache.containsKey(raw) && _userCache[raw] != null) {
      return _userCache[raw];
    }
    if (_userCache.containsKey(withSpaces.toLowerCase()) && _userCache[withSpaces.toLowerCase()] != null) {
      return _userCache[withSpaces.toLowerCase()];
    }

    try {
      // 2. Query using SearchRepo logic (covers name and username prefix matching)
      final searchRepo = SearchRepoImp();
      final results = await searchRepo.searchUsers(raw);
      if (results.isEmpty && withSpaces != raw) {
        results.addAll(await searchRepo.searchUsers(withSpaces));
      }

      for (final u in results) {
        cacheUser(u);
      }

      // Check if any returned result matches target
      for (final u in results) {
        final uId = (u['id'] as String? ?? '');
        final uUsername = (u['username'] as String? ?? '').trim().toLowerCase();
        final uName = (u['name'] as String? ?? '').trim().toLowerCase();
        final uNameSlug = uName.replaceAll(' ', '_');

        if (uId == raw ||
            uUsername == normalized ||
            uName == normalized ||
            uName == withSpaces.toLowerCase() ||
            uNameSlug == normalized) {
          return u;
        }
      }

      // 3. Direct Firestore doc query by UID if raw matches document ID
      final docById = await FirebaseFirestore.instance.collection('users').doc(raw).get();
      if (docById.exists && docById.data() != null) {
        final data = docById.data()!;
        final rawName = (data['name'] as String?)?.trim();
        final rawUsername = (data['username'] as String?)?.trim();
        final displayName = (rawName != null && rawName.isNotEmpty)
            ? rawName
            : ((rawUsername != null && rawUsername.isNotEmpty)
                ? rawUsername
                : username);

        final userMap = {
          'id': docById.id,
          'name': displayName,
          'username': rawUsername ?? username,
          'bio': data['bio'] ?? '',
          'profileImage': data['profileImage'],
        };
        cacheUser(userMap);
        return userMap;
      }

      // 4. Exact equality queries on username and name
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: normalized)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: withSpaces)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        final rawName = (data['name'] as String?)?.trim();
        final rawUsername = (data['username'] as String?)?.trim();
        final displayName = (rawName != null && rawName.isNotEmpty)
            ? rawName
            : ((rawUsername != null && rawUsername.isNotEmpty)
                ? rawUsername
                : username);

        final userMap = {
          'id': doc.id,
          'name': displayName,
          'username': rawUsername ?? username,
          'bio': data['bio'] ?? '',
          'profileImage': data['profileImage'],
        };
        cacheUser(userMap);
        return userMap;
      }
    } catch (_) {}

    return null;
  }

  /// Caches a known user map directly into the in-memory cache.
  static void cacheUser(Map<String, dynamic> userMap) {
    final id = (userMap['id'] as String? ?? '').trim();
    final username = (userMap['username'] as String? ?? '').trim().toLowerCase().replaceAll('@', '');
    final name = (userMap['name'] as String? ?? '').trim().toLowerCase();
    final nameSlug = name.replaceAll(' ', '_');

    if (id.isNotEmpty) {
      _userCache[id] = userMap;
    }
    if (username.isNotEmpty) {
      _userCache[username] = userMap;
    }
    if (name.isNotEmpty) {
      _userCache[name] = userMap;
    }
    if (nameSlug.isNotEmpty) {
      _userCache[nameSlug] = userMap;
    }
  }

  /// Parses text into a list of [InlineSpan]s, styling `@username` mentions as clickable primary text.
  static List<InlineSpan> buildMentionSpans({
    required String text,
    TextStyle? defaultStyle,
    TextStyle? mentionStyle,
    required void Function(String username) onMentionTap,
  }) {
    if (text.isEmpty) return [];

    final spans = <InlineSpan>[];
    int lastMatchEnd = 0;

    for (final match in _mentionRegex.allMatches(text)) {
      // Add text before the mention
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }

      final mentionText = match.group(0)!; // e.g. "@sam"
      final username = match.group(1)!;    // e.g. "sam"

      spans.add(
        TextSpan(
          text: mentionText,
          style: mentionStyle ??
              (defaultStyle ?? const TextStyle()).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => onMentionTap(username),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining trailing text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    return spans;
  }

  /// Dispatches mention notifications for all valid mentioned users in [text].
  ///
  /// Rules:
  /// - Excludes current user (no self-mentions).
  /// - Deduplicates mentions within the same text.
  /// - Safely ignores non-existent or deleted users.
  static Future<void> sendMentionNotifications({
    required String text,
    required String postId,
    String? commentId,
    NotificationRepo? notificationRepo,
    Set<String>? onlyUsernames,
  }) async {
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;
    if (currentFirebaseUser == null) return;

    var mentionedUsernames = extractUsernames(text);
    if (onlyUsernames != null) {
      final allowed = onlyUsernames.map((u) => u.toLowerCase()).toSet();
      mentionedUsernames =
          mentionedUsernames.where((u) => allowed.contains(u)).toSet();
    }
    if (mentionedUsernames.isEmpty) return;

    final repo = notificationRepo ?? NotificationRepoImp();

    // Fetch current user details for the sender info
    String senderName = currentFirebaseUser.displayName ?? '';
    String senderUsername = '';
    String? senderPhoto = currentFirebaseUser.photoURL;

    try {
      final senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentFirebaseUser.uid)
          .get();
      if (senderDoc.exists && senderDoc.data() != null) {
        final data = senderDoc.data()!;
        if ((data['name'] as String?)?.isNotEmpty == true) {
          senderName = data['name'] as String;
        }
        if ((data['username'] as String?)?.isNotEmpty == true) {
          senderUsername = data['username'] as String;
        }
        if ((data['profileImage'] as String?)?.isNotEmpty == true) {
          senderPhoto = data['profileImage'] as String;
        }
      }
    } catch (_) {}

    final currentUsernameNormalized = senderUsername.trim().toLowerCase();

    for (final username in mentionedUsernames) {
      // Rule: Never notify self
      if (username == currentUsernameNormalized) continue;

      final targetUser = await getUserByUsername(username);
      if (targetUser == null) continue;

      final receiverId = targetUser['id'] as String? ?? '';
      if (receiverId.isEmpty || receiverId == currentFirebaseUser.uid) continue;

      final notification = NotificationModel(
        id: '',
        senderId: currentFirebaseUser.uid,
        senderName: senderName.isNotEmpty ? senderName : 'User',
        senderUsername: senderUsername,
        senderPhoto: senderPhoto,
        receiverId: receiverId,
        type: NotificationType.mention,
        postId: postId,
        commentId: commentId,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await repo.createNotification(notification);
    }
  }
}
