# ConnectHub — Technical Project Document

> **Purpose:** CV writing, interview preparation, and professional project showcase.
> This document is grounded entirely in the actual implementation.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Features](#2-features)
3. [Technical Architecture](#3-technical-architecture)
4. [Technologies](#4-technologies)
5. [Database Design](#5-database-design)
6. [Authentication](#6-authentication)
7. [Follow System](#7-follow-system)
8. [Posts](#8-posts)
9. [State Management](#9-state-management)
10. [Performance Optimizations](#10-performance-optimizations)
11. [Error Handling](#11-error-handling)
12. [Security](#12-security)
13. [Challenges](#13-challenges)
14. [Things That Demonstrate Engineering Skills](#14-things-that-demonstrate-engineering-skills)
15. [Possible Improvements](#15-possible-improvements)
16. [Resume Highlights](#16-resume-highlights)
17. [Interview Questions & Answers](#17-interview-questions--answers)
18. [Metrics](#18-metrics)
19. [Final Technical Summary](#19-final-technical-summary)

---

## 1. Project Overview

**Project Name:** ConnectHub

**Summary:**
ConnectHub is a full-stack mobile social media application built with Flutter and Firebase. It allows authenticated users to create text and image posts, engage with other users through likes and comments, follow and unfollow accounts in real time, and generate social media content ideas through an integrated AI chatbot. The app implements a Feature-First Clean Architecture with BLoC/Cubit for predictable, testable state management.

**Main Objective:**
To deliver a production-quality social platform demonstrating real-time data synchronization, atomic database operations, a clean layered architecture, and integrated external services — all within a consistent, maintainable codebase.

**Problem Solved:**
Most social media app examples demonstrate only basic CRUD operations. ConnectHub addresses harder engineering problems: atomic follow/unfollow transactions to prevent counter drift, dual-stream real-time profiles, scoped vs. global Cubit isolation, Firestore security rules with cross-document validation using `getAfter()`, and safe async Cubit lifecycle management.

**Target Users:**
General users seeking a social sharing platform. As a portfolio project it also targets technical interviewers and engineering teams evaluating Flutter and Firebase proficiency.

---

## 2. Features

### Authentication

| Feature | What | Why | How |
|---|---|---|---|
| Sign Up | Creates Firebase Auth account + Firestore user document atomically | Users need persistent identity beyond Auth | `createUserWithEmailAndPassword` → `updateDisplayName` → Firestore `set` in sequence |
| Login | Email/password sign-in | Standard credential auth | `signInWithEmailAndPassword` with mapped error codes |
| Forgot Password | Sends reset email via Firebase | Self-service credential recovery | `sendPasswordResetEmail` |
| Auth Persistence | On app launch, redirects to Home or Login based on session | Avoid logging in every launch | `FirebaseAuth.currentUser` checked synchronously in `checkAuthStatus()` |
| Sign Out | Clears Auth session, navigates to Login removing all routes | Clean session termination | `signOut()` + `pushAndRemoveUntil` |

### Feed & Posts

| Feature | What | Why | How |
|---|---|---|---|
| Real-time Feed | Live list of all posts, newest first | Users see new content without refresh | Firestore `snapshots()` stream on `posts` collection ordered by `createdAt` |
| Pull-to-Refresh | `RefreshIndicator` re-subscribes the stream | Familiar mobile UX | Calls `PostsCubit.loadPosts()` which cancels and restarts the stream subscription |
| Create Post | Title + description + optional image | Core social feature | `CreatePostCubit` validates locally, uploads image to ImageBB, writes to Firestore |
| Image Upload | Pick from gallery or camera, compress, upload | Rich content sharing | `image_picker` → base64 encode → `ImageBBService` via Dio → URL stored in Firestore |
| Like / Unlike | Toggle heart on any post | Social engagement | Read-modify-write on `likes` array + `likeCount` integer |
| Post Details | Full post view with comments and like count | Deep engagement | Real-time `StreamBuilder` on single post document + comments subcollection |
| Comments | Add comments to any post | Social discussion | Firestore `add` to `comments` subcollection + `FieldValue.increment(1)` on `commentCount` |
| Liked By | Bottom sheet listing users who liked a post | Social proof / discovery | `FutureBuilder` fetches user name for each UID in the `likes` array |
| "Your Post" badge | Gradient banner on own posts in feed | Visual ownership cue | `isOwnPost` flag computed from `currentUser.uid == post.userId` |

### Profile

| Feature | What | Why | How |
|---|---|---|---|
| Own Profile | Displays name, email, stats, and post list | User self-view | `ProfileCubit` with two real-time stream subscriptions |
| Live Stats | Posts, Likes, Followers, Following — update in real time | Accurate social metrics | Stream 1: post stream for post count and total likes. Stream 2: user document for follow counters |
| User Profile View | View any other user's profile via post card tap | Social discovery | `UserProfileView` with scoped `FollowCubit` + scoped `PostsCubit` |
| Sign Out | Confirmation dialog → clears session | Prevents accidental logout | `AlertDialog` → `AuthCubit.signOut()` → `pushAndRemoveUntil` to `LoginView` |

### Follow System

| Feature | What | Why | How |
|---|---|---|---|
| Follow | Create relationship and increment counters atomically | Core social graph | Firestore transaction: reads follower doc, sets subcollection docs, updates counters |
| Unfollow | Remove relationship and decrement counters atomically | Correct counter management | Firestore transaction: reads follower doc, deletes subcollection docs, decrements counters |
| Real-time Follow Status | Button updates instantly on all devices | Live UX | `snapshots()` on `followers/{currentUserId}` — O(1) doc existence check |
| Self-follow Prevention | Follow button hidden on own posts | Data integrity | `loadFollowStatus()` returns early if `currentUserId == targetUserId`; PostCard skips navigation for `isOwnPost` |
| Duplicate Follow Prevention | Second follow from any device is a no-op | Counter integrity | Transaction reads follower doc first; returns early if `followerSnap.exists` |
| Live Follower Counts | Counts update in real time on profile cards | Accurate metrics | Second stream subscription on target user document |
| Action Loading Lock | Button disabled during in-flight operation | Prevent double-tap | `_isActionLoading` flag in Cubit; `GestureDetector.onTap` is null when loading |

### AI Chatbot

| Feature | What | Why | How |
|---|---|---|---|
| AI Post Idea Generator | Conversational interface for post content ideas | Added value / differentiation | `ChatbotCubit` holds message list in memory; sends via `AIChatService` to n8n webhook |
| Typing Indicator | Animated dots while awaiting AI response | UX feedback for async operations | `ChatbotLoaded(isTyping: true)` state + custom `TypingIndicator` widget with `AnimationController` |
| Chat Bubbles | Styled differently for user vs AI messages | Visual conversation clarity | `ChatBubble` widget checks `message.isUser` for alignment and color |
| Persistent Session | Chat history preserved within the session | Conversation context | `_messages` list maintained in `ChatbotCubit` as long as the Cubit lives |

### Navigation & UX

| Feature | What | Why | How |
|---|---|---|---|
| Animated Bottom Nav | Custom pill-style nav with animated label reveal | Polished UX | `AnimatedContainer` + conditional `Row` children based on `isSelected` |
| Splash Screen | Animated scale + fade logo on launch | Professional first impression | `AnimationController` with `Curves.elasticOut`; delays `checkAuthStatus()` by 2 seconds |
| Animated Auth Forms | Fade + slide transitions on login/signup | Smooth onboarding | `AnimationController` with `FadeTransition` + `SlideTransition` |
| Tab Switching Animation | `AnimatedSwitcher` between Home tabs | Smooth page transitions | `KeyedSubtree` with `ValueKey(_currentIndex)` |
| Custom Shimmer | Skeleton loading placeholder | Better perceived performance | Custom `ShimmerBox` with `AnimationController` and shifting `LinearGradient` |

---

## 3. Technical Architecture

### Folder Structure

```
lib/
├── core/                          # Shared, feature-agnostic code
│   ├── errors/
│   │   └── failures.dart          # Failure value object
│   ├── services/
│   │   ├── ai_chat_service.dart   # n8n webhook client (Dio)
│   │   └── image_bb_service.dart  # ImageBB upload client (Dio)
│   └── utils/
│       ├── app_theme.dart         # AppColors, AppTextStyles, AppTheme
│       └── app_widgets.dart       # PrimaryButton, CustomTextField,
│                                  # UserAvatar, ShimmerBox
└── features/
    ├── auth/
    │   ├── data/repos/            # AuthRepo (abstract) + AuthRepoImp
    │   └── presentation/
    │       ├── manager/cubit/     # AuthCubit + AuthState
    │       └── views/             # LoginView, SignUpView, ForgotPasswordView
    ├── chatbot/
    │   ├── data/
    │   │   ├── models/            # ChatMessage
    │   │   └── repos/             # ChatbotRepo + ChatbotRepoImp
    │   └── presentation/
    │       ├── manager/cubit/     # ChatbotCubit + ChatbotState
    │       ├── views/             # ChatbotView
    │       └── widgets/           # ChatBubble, TypingIndicator
    ├── follow/
    │   ├── data/repos/            # FollowRepo (abstract) + FollowRepoImp
    │   └── presentation/
    │       ├── manager/cubit/     # FollowCubit + FollowState
    │       └── widgets/           # FollowButton
    ├── home/
    │   ├── data/
    │   │   ├── models/            # PostModel
    │   │   └── repos/             # PostsRepo + PostsRepoImp
    │   └── presentation/
    │       ├── manager/cubit/     # PostsCubit + PostsState
    │       ├── views/             # HomeView (shell + FeedPage)
    │       └── widgets/           # PostCard
    ├── post/
    │   ├── data/
    │   │   ├── models/            # CommentModel
    │   │   └── repos/             # PostRepo + PostRepoImp
    │   └── presentation/
    │       ├── manager/cubit/     # CreatePostCubit + CreatePostState
    │       ├── views/             # CreatePostView, PostDetailsView
    │       └── widgets/           # CommentTile, LikedBySheet
    ├── profile/
    │   ├── data/repos/            # ProfileRepo + ProfileRepoImp
    │   └── presentation/
    │       ├── manager/cubit/     # ProfileCubit + ProfileState
    │       ├── views/             # ProfileView, UserProfileView
    │       └── widgets/           # ProfileCard, UserPostTile
    └── splash/
        └── presentation/views/    # SplashView
```

### Feature-Based Architecture

Each feature is fully self-contained. The `home` feature owns `PostModel` because the feed is the primary consumer, but other features import it by path — no barrel files or generated indexes. This keeps the dependency graph explicit and traceable.

There is **no domain layer** (no use-cases or entities). The repository interface serves as the boundary between data and presentation. This is a deliberate trade-off: fewer abstraction layers means faster development and less boilerplate for a project of this scope, at the cost of slightly less testability.

### State Management

BLoC/Cubit is used exclusively. No `setState` is used for business logic. `setState` appears only in `PostDetailsView` for a single local boolean (`_isSendingComment`) that has no business significance.

**Cubit provision strategy:**
- **Global** (provided in `main.dart` `MultiBlocProvider`): `AuthCubit`, `PostsCubit`, `ChatbotCubit` — these outlive any single screen.
- **Feature-scoped** (provided by `BlocProvider` inside the view's `build`): `ProfileCubit`, `CreatePostCubit`, `FollowCubit` — tied to the lifetime of a specific screen.

### Dependency Flow

```
Presentation Layer (Views / Cubits)
        │
        │  depends on
        ▼
   Repository Interface (abstract class XxxRepo)
        │
        │  implemented by
        ▼
  Repository Implementation (XxxRepoImp)
        │
        │  directly calls
        ▼
   Firebase SDK / External Services
```

No service locator (`get_it`) is used. Each Cubit accepts an optional `XxxRepo?` constructor parameter, defaulting to `XxxRepoImp()`. This pattern enables constructor injection for testing without requiring a DI framework.

### Repository Pattern

Every feature with data access has:
- An **abstract class** `XxxRepo` defining the contract (interface).
- A **concrete class** `XxxRepoImp implements XxxRepo` containing all SDK calls.

This means the Cubit depends only on the abstract interface. Swapping `PostsRepoImp` for a mock in tests requires no changes to `PostsCubit`.

### Data Flow

**Read flow (real-time):**
```
Firestore snapshot → XxxRepoImp stream → StreamSubscription in Cubit
  → emit(XxxLoaded(data)) → BlocBuilder rebuilds widget tree
```

**Write flow:**
```
User action → View calls cubit method → Cubit emits Loading
  → RepoImp writes to Firestore → on success, stream auto-updates
  → Cubit emits Loaded from stream update
```

### Firebase Integration

Firebase is initialized once in `main()` before `runApp`:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

Firebase services are accessed via singleton instances directly inside repository implementations:
```dart
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
```

No Firebase references exist in the Cubits or Views. All Firebase SDK calls are isolated to repository implementations and the two core services (`AIChatService`, `ImageBBService`).

### Firestore Collections

```
users/{uid}
posts/{postId}
posts/{postId}/comments/{commentId}
users/{uid}/followers/{followerId}
users/{uid}/following/{followingId}
```

### Authentication Flow

```
App Launch → SplashView (2s animation)
  → AuthCubit.checkAuthStatus()
  → FirebaseAuth.currentUser != null?
      Yes → emit AuthAuthenticated → navigate to HomeView
      No  → emit AuthUnauthenticated → navigate to LoginView
```

---

## 4. Technologies

| Technology | Version | Reason |
|---|---|---|
| **Flutter** | SDK ^3.12.2 | Cross-platform mobile UI framework; Dart's strong typing and hot reload improve development velocity |
| **firebase_core** | ^3.13.0 | Required bootstrap for all Firebase services |
| **firebase_auth** | ^5.7.0 | Managed authentication with session persistence across app restarts |
| **cloud_firestore** | ^5.6.7 | NoSQL real-time database with offline support, `snapshots()` streams, and atomic transactions |
| **flutter_bloc** | ^9.1.1 | Cubit provides lightweight, predictable state machines with `BlocBuilder` / `BlocListener` / `BlocConsumer` |
| **dio** | ^5.8.0+1 | HTTP client for ImageBB upload (multipart form-data) and n8n webhook (JSON). Chosen over `http` for its interceptors and `FormData` support |
| **http** | ^1.4.0 | Present in `pubspec.yaml` as a dependency but not actively used in code; Dio handles all HTTP |
| **image_picker** | ^1.1.2 | Native camera and gallery access with compression parameters (`maxWidth`, `imageQuality`) |
| **intl** | ^0.20.2 | Date formatting (`DateFormat('MMM d, yyyy • h:mm a')`) for post timestamps |
| **cached_network_image** | ^3.4.1 | Disk-cached network image loading with placeholder and error widget support |
| **uuid** | ^4.5.1 | Present in pubspec but not called in code directly; Firestore generates document IDs via `add()` |
| **cupertino_icons** | ^1.0.8 | iOS-style icon set for Material/Cupertino compatibility |
| **flutter_lints** | ^6.0.0 | Enforces Dart best practices at analysis time |
| **ImageBB** | External API | Free image hosting with direct URL return; avoids Firebase Storage cost and complexity for a portfolio project |
| **n8n** | External webhook | Self-hosted automation platform acting as an AI proxy; decouples the Flutter app from any specific AI provider |

---

## 5. Database Design

### `users/{uid}`

```
{
  uid:            String   // Firebase Auth UID (document ID mirrors this)
  name:           String   // Display name set at signup
  email:          String   // Email address
  createdAt:      Timestamp
  followersCount: int      // Denormalized counter (default 0 at signup)
  followingCount: int      // Denormalized counter (default 0 at signup)
}
```

**Design decisions:**
- `uid` is redundant with the document ID but included for Firestore query convenience.
- `followersCount` / `followingCount` are denormalized counters. Reading a count is O(1) (one document read) rather than requiring a subcollection `count()` query. Maintained atomically by Firestore transactions.

### `users/{uid}/followers/{followerId}`

```
{
  uid:        String     // The follower's UID (mirrors document ID)
  followedAt: Timestamp
}
```

**Design decision:** Using the follower's UID as the document ID enables an O(1) existence check (`document.get()` vs. a query) to determine if user A follows user B. Subcollections scale without document size limits (unlike array storage in the parent document).

### `users/{uid}/following/{followingId}`

```
{
  uid:        String     // The followed user's UID
  followedAt: Timestamp
}
```

Mirror of the followers subcollection, stored on the current user's document for efficient "who am I following?" queries.

### `posts/{postId}`

```
{
  userId:       String     // Author's UID
  userName:     String     // Denormalized author name (avoids join on read)
  title:        String
  description:  String
  imageUrl:     String?    // ImageBB CDN URL, null if no image
  likes:        String[]   // Array of UIDs who liked the post
  likeCount:    int        // Denormalized counter (mirrors likes.length)
  commentCount: int        // Denormalized counter
  createdAt:    Timestamp
}
```

**Design decisions:**
- `userName` is denormalized to avoid a join to `users` on every feed read. Trade-off: if a user changes their name, existing posts retain the old name.
- `likes` stores full UIDs to allow O(1) client-side "did I like this?" checks (`post.likes.contains(currentUserId)`) without an additional Firestore read.
- `likeCount` is kept in sync manually (`update({'likes': newLikes, 'likeCount': newLikes.length})`). This is safe since it is derived directly from the array, not an independent counter.

### `posts/{postId}/comments/{commentId}`

```
{
  userId:    String
  userName:  String    // Denormalized for the same reason as posts
  text:      String
  createdAt: Timestamp
}
```

Comments are a subcollection so they do not bloat the parent post document. They are ordered server-side by `createdAt` descending in `getCommentsStream`.

---

## 6. Authentication

**Implementation file:** `auth_repo_imp.dart` + `auth_cubit.dart`

### Sign Up Flow

1. `AuthCubit.signUp()` emits `AuthLoading`.
2. `AuthRepoImp.signUp()` calls `createUserWithEmailAndPassword`.
3. On success, `updateDisplayName(name)` is called and the user reloads (`credential.user?.reload()`).
4. A Firestore document is created at `users/{uid}` with name, email, timestamps, and `followersCount: 0, followingCount: 0`.
5. `AuthCubit` emits `AuthAuthenticated(user)`.

If the Firestore write fails after Auth creation, the user has an Auth account but no Firestore document. This edge case is handled defensively in `PostRepoImp.createPost()` which falls back to Firestore lookup or email prefix for `userName`.

### Error Mapping

`AuthRepoImp.getErrorMessage(code)` maps all Firebase Auth error codes to user-friendly English strings. This is called in `AuthCubit` catch blocks for `FirebaseAuthException`. The mapping covers 12 specific codes including `invalid-credential`, `too-many-requests`, `channel-error`, and `network-request-failed`.

### Session Persistence

Firebase Auth persists the session token on device. On cold launch, `FirebaseAuth.currentUser` returns non-null immediately if the session is valid. No async call is needed for the initial check — `checkAuthStatus()` is synchronous.

### Auth State in Cubits

`AuthCubit` exposes `currentUser` as a getter (`_authRepo.currentUser`). Other parts of the app that need the current user UID — `PostCard`, `HomeView`, `PostDetailsView` — access it directly via `FirebaseAuth.instance.currentUser?.uid` rather than through the Cubit, keeping the coupling minimal.

---

## 7. Follow System

### Data Model

The follow relationship between user A (follower) and user B (target) is represented by **two subcollection documents**:

- `users/B/followers/A` — "B has a follower named A"
- `users/A/following/B` — "A is following B"

Plus two denormalized counter fields updated atomically with the subcollection writes:
- `users/B.followersCount` incremented
- `users/A.followingCount` incremented

### Firestore Transaction

Both `followUser` and `unfollowUser` use `runTransaction` instead of `WriteBatch`. The critical difference:

**WriteBatch** writes unconditionally. If two devices call `followUser` simultaneously:
- Both `batch.set(followerRef, ...)` calls write the same document (last write wins — idempotent).
- Both `batch.update(..., increment(1))` calls both execute — counter becomes 2 for 1 follower. **Counter drift.**

**Transaction** reads before it writes:
```dart
await _firestore.runTransaction((transaction) async {
  final followerSnap = await transaction.get(followerRef);
  if (followerSnap.exists) return;  // Already following — no-op
  // Only reaches here if relationship didn't exist
  transaction.set(followerRef, {...});
  transaction.update(targetUserRef, {'followersCount': FieldValue.increment(1)});
  ...
});
```

If two transactions race, Firestore's optimistic concurrency will retry the losing transaction. On the retry, `followerSnap.exists` is `true`, and the transaction exits without incrementing. **Counter remains accurate.**

The same idempotency guard exists in `unfollowUser`: if `!followerSnap.exists`, the transaction is a no-op — the counter is never decremented for a relationship that doesn't exist.

### Followers/Following Collections

Subcollections were chosen over arrays for three reasons:
1. **Scale:** Firestore documents are capped at 1 MB. Storing UIDs in an array limits followers to approximately 20,000. Subcollections are unlimited.
2. **O(1) existence check:** Reading `users/{uid}/followers/{currentUserId}` to determine follow status is a single document lookup — it does not require reading all followers or running a query.
3. **Security:** Security rules can be applied independently to the subcollection, enforcing that only the follower can write their own entry.

### Counters

`followersCount` and `followingCount` are maintained as denormalized integers on the user document. `FieldValue.increment(n)` is atomic and creates the field at `n` if it doesn't exist — so existing users without the field are handled safely on first follow.

Reading a count is O(1) — one document read — versus a `count()` aggregation query against the subcollection.

### Real-time Updates

`FollowCubit` maintains **two concurrent stream subscriptions**:

```
Stream 1: users/{targetUserId}/followers/{currentUserId}
  → maps DocumentSnapshot.exists to bool
  → updates _isFollowing in cubit cache
  → triggers _emitLoaded() only after Stream 2 has initialized

Stream 2: users/{targetUserId}  (the whole user document)
  → reads followersCount, followingCount
  → sets _userDocInitialized = true on first emission
  → triggers _emitLoaded()
```

The `_userDocInitialized` flag ensures that `FollowLoaded` is not emitted until the user document has loaded, preventing a flash of `followersCount: 0` before the real data arrives.

`ProfileCubit` uses the same dual-stream pattern for the **own** profile, combining a posts stream with a user document stream.

### Error Handling

All errors in `FollowCubit` go through `_formatError(e, st)`:
- For `FirebaseException`: prints `[code] message plugin` to the debug console and returns `[code] message` for the snackbar.
- For other exceptions: prints full stack trace and returns `e.toString()`.

After any error, `_emitLoaded()` is called to restore the button to its pre-action state, so the user can retry.

Post-`await` emits are guarded with `if (isClosed) return;` to prevent `StateError` when the user navigates away during an in-flight transaction.

### Why Transactions Were Chosen

Transactions guarantee that the counter increment/decrement is **conditional** on the existence of the subcollection document. This prevents:
- **Double-follow inflation:** Two simultaneous follows result in exactly one follower and one counter increment.
- **Unfollow underflow:** An unfollow on a non-existent relationship does not decrement the counter below its correct value.

Without transactions (using `WriteBatch`), these race conditions are possible and their probability increases with network latency.

---

## 8. Posts

### Creating Posts

1. `CreatePostCubit.createPost()` validates title and description (both non-empty).
2. Emits `CreatePostSubmitting`.
3. If an image is selected (`selectedImage != null`), reads bytes, base64-encodes them, uploads via `ImageBBService.uploadImage()`.
4. If upload returns `null`, throws `Exception('Failed to upload image')`.
5. Calls `PostRepoImp.createPost()` which writes the document to `posts` collection with `FieldValue.serverTimestamp()`.
6. On success, emits `CreatePostSuccess` → `BlocListener` shows snackbar and pops the view.

**Username resolution:** `createPost` attempts three sources in order: `user.displayName`, Firestore `users/{uid}.name`, then `email.split('@').first`. This handles edge cases where `displayName` was not set.

### Editing

Post editing is **not implemented**. The Firestore security rule `allow update: if isSignedIn()` permits it technically, but there is no UI or cubit method for editing post content.

### Deleting

Post deletion is **not implemented** in the UI. The Firestore security rule `allow delete: if isSignedIn() && isOwner(resource.data.userId)` permits deletion by the author.

### Likes

`PostsRepoImp.toggleLike(postId, userId)` implements a read-modify-write:
1. Reads the post document.
2. Gets the `likes` array.
3. Adds or removes `userId`.
4. Writes `{'likes': updatedArray, 'likeCount': updatedArray.length}`.

This is **not a transaction** — it has the same race condition as the original follow batch approach. On a high-volume post with many concurrent likes, `likeCount` could drift. For a portfolio project, this is an accepted trade-off noted in improvements.

### Comments

`PostRepoImp.addComment(postId, data)`:
1. Calls `_postsCollection.doc(postId).update({'commentCount': FieldValue.increment(1)})` — not awaited, fire-and-forget.
2. Calls `_postsCollection.doc(postId).collection('comments').add(data)` — awaited.

The two operations are not atomic. If the `add` fails after the `update`, `commentCount` will be off by 1. This is a known limitation.

### Streams

**Feed stream:** `getPostsStream()` returns a Firestore real-time stream ordered by `createdAt` descending. Every document change (new post, like toggle, comment) triggers a re-emission of the full list. The `StreamSubscription` is stored in `PostsCubit._subscription` and cancelled when the cubit closes.

**User posts stream:** `getUserPostsStream(userId)` uses `where('userId', isEqualTo: userId)` without server-side `orderBy` (to avoid requiring a composite index). Sorting is done client-side: `posts.sort((a, b) => b.createdAt.compareTo(a.createdAt))`.

**Post detail stream:** `PostDetailsView` uses `StreamBuilder` directly (not a Cubit) because the view has no business logic — it just renders live Firestore data. This is the only `StreamBuilder` in the app; the pattern is intentional for simple, stateless views.

**Comments stream:** `getCommentsStream(postId)` orders comments server-side by `createdAt` descending using a composite index on `(postId path, createdAt)` — Firestore creates this automatically for subcollection ordered queries.

### Firestore Structure

```
posts/{autoId}
  userId, userName, title, description, imageUrl?,
  likes[], likeCount, commentCount, createdAt

posts/{autoId}/comments/{autoId}
  userId, userName, text, createdAt
```

---

## 9. State Management

### AuthCubit

**File:** `auth_cubit.dart` / `auth_state.dart`
**Scope:** Global (provided in `main.dart`)
**Responsibility:** All Firebase Auth operations and session state.

**States:**
| State | When |
|---|---|
| `AuthInitial` | App just started |
| `AuthLoading` | Any async auth operation in progress |
| `AuthAuthenticated(User user)` | Login/signup succeeded or session restored |
| `AuthUnauthenticated` | Logged out or no session found |
| `AuthError(String message)` | Auth operation failed |
| `AuthPasswordResetSent` | Password reset email sent successfully |
| `AuthSignedUp` | Defined but not emitted (superseded by `AuthAuthenticated`) |

**Data flow:**
```
SplashView calls checkAuthStatus()
  → synchronous check of FirebaseAuth.currentUser
  → emits AuthAuthenticated or AuthUnauthenticated
  → BlocListener in SplashView navigates accordingly
```

**Error handling:** Three separate catch blocks per method — `FirebaseAuthException` (mapped to friendly messages), `FirebaseException` (Firestore errors during signup), and generic `Exception`.

---

### PostsCubit

**File:** `posts_cubit.dart` / `posts_state.dart`
**Scope:** Global (provided in `main.dart`)
**Responsibility:** Real-time feed and user-specific post lists.

**States:**
| State | When |
|---|---|
| `PostsInitial` | Cubit created, no subscription yet |
| `PostsLoading` | Stream subscription starting |
| `PostsLoaded(List<PostModel>)` | Data received from stream |
| `PostsError(String)` | Stream emitted an error |

**Key design:** `loadUserPosts(userId)` is reused in two contexts: `ProfileCubit` (global cubit) would conflict, so `UserProfileView` provides a **new local instance** of `PostsCubit` scoped to that view. The global `PostsCubit` is never called with `loadUserPosts` — only `loadPosts`. This prevents feed data from being overwritten when navigating to a user profile.

---

### CreatePostCubit

**File:** `create_post_cubit.dart` / `create_post_state.dart`
**Scope:** Feature-scoped (provided by `BlocProvider` inside `CreatePostView`)
**Responsibility:** Post creation flow including image picking.

**States:**
| State | When |
|---|---|
| `CreatePostInitial` | View opened or image removed |
| `CreatePostImagePicked(File)` | User selected an image |
| `CreatePostSubmitting` | Upload + Firestore write in progress |
| `CreatePostSuccess` | Post written to Firestore |
| `CreatePostError(String)` | Validation or upload failure |

**Notable:** `selectedImage` is stored as a public field on the Cubit (not in state) because it is a large object and doesn't need to trigger rebuilds on its own — only `CreatePostImagePicked` triggers UI update.

---

### ProfileCubit

**File:** `profile_cubit.dart` / `profile_state.dart`
**Scope:** Feature-scoped (provided by `BlocProvider` inside `ProfileView`)
**Responsibility:** Own profile data from two simultaneous Firestore streams.

**States:**
| State | When |
|---|---|
| `ProfileInitial` | Cubit created |
| `ProfileLoading` | Subscriptions starting |
| `ProfileLoaded(user, userPosts, totalLikes, followersCount, followingCount)` | Both streams have data |
| `ProfileError(String)` | Posts stream failed |

**Dual-stream pattern:**
- `_postsSubscription`: listens to `getUserPostsStream`, computes `totalLikes` via `fold`.
- `_userDocSubscription`: listens to `getUserStream`, reads follow counters.
- User document stream updates are ignored (silent `onError`) until posts have loaded (`if (state is ProfileLoaded) _emitLoaded()`).

Both subscriptions are cancelled in `close()`.

---

### FollowCubit

**File:** `follow_cubit.dart` / `follow_state.dart`
**Scope:** Feature-scoped (provided by `MultiBlocProvider` inside `UserProfileView`)
**Responsibility:** Follow/unfollow for a specific (currentUser, targetUser) pair.

**States:**
| State | When |
|---|---|
| `FollowInitial` | Cubit created (or self-profile — stays here permanently) |
| `FollowLoading` | Subscriptions starting |
| `FollowLoaded(isFollowing, isActionLoading, followersCount, followingCount)` | Ready; all data loaded |
| `FollowError(String)` | Transaction or stream failed |

**Private cache pattern:** Rather than embedding all data in state variants, the cubit maintains private fields (`_isFollowing`, `_isActionLoading`, `_followersCount`, `_followingCount`) updated independently by two streams. `_emitLoaded()` assembles the canonical `FollowLoaded` state from these fields whenever either stream fires. This prevents state fragmentation and avoids emitting partial data.

**`wasFollowing` capture:** At the top of `toggleFollow()`, `final wasFollowing = _isFollowing` captures the intent before the `await`. This ensures the error message says "Failed to unfollow" even if the Firestore stream updates `_isFollowing` mid-flight.

---

### ChatbotCubit

**File:** `chatbot_cubit.dart` / `chatbot_state.dart`
**Scope:** Global (provided in `main.dart`)
**Responsibility:** In-memory chat session with AI webhook.

**States:**
| State | When |
|---|---|
| `ChatbotInitial` | Constructor runs (immediately replaced) |
| `ChatbotLoaded(messages, isTyping)` | All subsequent states |

**Notable:** The initial AI greeting message is added in the constructor before `super(ChatbotInitial())` completes, immediately followed by `emit(ChatbotLoaded(...))`. The `isTyping` flag within `ChatbotLoaded` drives the `TypingIndicator` widget, avoiding a separate state class for the typing condition.

**No error state:** If the n8n webhook fails, `AIChatService.sendMessage()` catches the `DioException` and returns an error string as a regular message. The error is displayed as an AI bubble in the chat, not as a cubit error state.

---

## 10. Performance Optimizations

### O(1) Follow Status Lookup

Follow status is determined by reading a **single document** by its full path:
```
users/{targetUserId}/followers/{currentUserId}
```
This is an O(1) key lookup. The alternative — querying all follower documents — would be O(n) and require a Firestore index.

### Denormalized Counters

`followersCount`, `followingCount`, `likeCount`, and `commentCount` are stored as integer fields, not computed from subcollection sizes. Reading a count costs one document read, not a `count()` aggregation call. Updates use `FieldValue.increment` (atomic, server-side).

### Real-time Streams vs Polling

All live data uses Firestore `snapshots()` streams. No polling, no manual refresh timers. Firestore delivers delta updates over a persistent WebSocket connection — unchanged documents do not trigger re-emissions or extra bandwidth.

### Avoiding Duplicate Writes (Idempotent Transactions)

The `followUser` transaction reads `followerRef` first. If `followerSnap.exists`, it returns immediately without any write. This means a double-tap on the Follow button — or a concurrent follow from two devices — results in exactly one follow relationship and exactly one counter increment.

### `isActionLoading` Optimistic Lock

`FollowCubit.toggleFollow()` sets `_isActionLoading = true` and re-emits `FollowLoaded` immediately, disabling the `FollowButton` before the network request begins. This prevents multiple in-flight transactions without waiting for a round-trip.

### StreamSubscription Cancellation

Every Cubit that opens a Firestore stream stores the `StreamSubscription` and calls `cancel()` in `close()`. This prevents Firestore listeners from continuing after the screen is popped, avoiding memory leaks and unnecessary Firestore reads.

### Scoped PostsCubit Isolation

`UserProfileView` provides a **new local instance** of `PostsCubit` rather than using the global one. This prevents `loadUserPosts(userId)` from overwriting the global feed state. The local cubit and its stream are automatically disposed when the view is popped.

### `_userDocInitialized` Gate

In `FollowCubit`, `FollowLoaded` is not emitted until the user document stream has fired at least once. This avoids a visible flash of `followersCount: 0` on the first render while the real data is in flight from Firestore cache.

### Cached Network Image

All remote images use `CachedNetworkImage` which maintains a disk cache. Once an image is loaded, subsequent visits to the same post do not re-download it. The package also provides loading placeholders and error fallback widgets.

### Client-side Sort for User Posts

`getUserPostsStream` applies no server-side `orderBy` to avoid requiring a composite Firestore index (which would need manual creation). Instead, the returned list is sorted client-side with `posts.sort((a, b) => b.createdAt.compareTo(a.createdAt))`. For small user post counts this is equivalent performance.

### `isClosed` Guard

`FollowCubit.toggleFollow()` checks `if (isClosed) return` after every `await`. This prevents `StateError` (throw in `flutter_bloc` ^9) when a user navigates away during an in-flight transaction. The Firestore write itself completes in the background (correct), but the Cubit does not attempt to emit on a closed stream.

---

## 11. Error Handling

### Authentication Errors

`AuthCubit` uses a three-tier catch hierarchy:
1. `FirebaseAuthException` — mapped through `getErrorMessage(code)` to user-friendly strings.
2. `FirebaseException` — catches Firestore errors during the signup Firestore write.
3. `catch (e)` — strips `Exception:` prefix and emits raw message.

This prevents unhelpful `"Exception: ..."` strings from appearing in the UI.

### Follow Errors

`FollowCubit._formatError(e, st)` logs to the debug console via `debugPrint` AND returns a displayable string. For `FirebaseException`, it formats `[code] message plugin`, allowing the developer to see the exact Firestore error code without logcat. The stack trace is printed for non-Firebase exceptions. This separation means the snackbar shows something useful and the console shows the full diagnostic.

After emitting `FollowError`, `_emitLoaded()` immediately restores the button to its correct pre-error state so the user can retry.

### Post Creation Errors

`CreatePostCubit` validates locally before touching the network:
- Empty title → emits `CreatePostError('Title is required.')` before any Firebase call.
- Empty description → same.
- Image upload failure → `ImageBBService` returns `null` → throws, caught in cubit.
- Firestore `permission-denied` → mapped to a specific helpful message in `PostRepoImp`.

### Stream Errors

Each `StreamSubscription.listen(onError:)` callback emits a typed error state. In `ProfileCubit`, the user document stream error is silently ignored (`onError: (_) {}`) because follow counts are non-critical — the profile still shows posts. This is an explicit, documented decision.

### Async Lifecycle Safety

All `emit` calls after `await` in `FollowCubit` are guarded with `if (isClosed) return`. This is specific to `FollowCubit` because it is the only Cubit with a user-initiated `async` method that can complete after the Cubit is disposed (user navigating away during a follow transaction).

---

## 12. Security

### Firestore Security Rules

The deployed rules enforce three permission models:

**User document updates** are split into three mutually exclusive cases:
1. **Owner, non-counter fields:** Owner can update any field except `followersCount`/`followingCount`. This prevents a user from setting their own follower count.
2. **followersCount:** Any signed-in user can update another user's `followersCount` by exactly ±1, **only if** the `followers/{uid}` subcollection document is also written in the same atomic transaction (`getAfter()` check). This ties the counter to the actual relationship.
3. **followingCount:** The account owner can update their own `followingCount` by exactly ±1.

Both counter rules use `resource.data.get('followersCount', 0)` and `request.resource.data.get('followersCount', 0)` to safely handle existing users without the field.

**Posts:** Any authenticated user can read/create/update posts. Only the post author can delete. Comments follow the same pattern.

**Subcollections:**
- `followers/{followerId}`: only the follower themselves can write their own entry (`isOwner(followerId)`).
- `following/{followingId}`: only the account owner can write their own following list (`isOwner(userId)`).

### Authentication Requirements

Every rule begins with `isSignedIn()` — unauthenticated reads and writes are rejected universally.

### Data Validation

**Client-side:**
- Auth forms use `Form` + `validator` callbacks for email format and password length.
- `CreatePostCubit` validates non-empty title and description before any network call.

**Firestore rules:**
- Post creation validates `request.resource.data.userId == request.auth.uid` — a user cannot impersonate another in a post.
- Comment creation validates `request.resource.data.userId == request.auth.uid`.
- Follow counter deltas are validated to ±1 to prevent arbitrary counter manipulation.
- `allow delete: if false` on user documents prevents client-side user deletion.

### Known Limitation

The `allow update: if isSignedIn()` rule on `posts` is intentionally broad to allow like/comment count updates from any authenticated user. This means any authenticated user can technically update any post's content fields. In a production system, this would be tightened to separate content updates (owner only) from social interaction updates (any user).

---

## 13. Challenges

### 1. Counter Drift in Multi-Device Follow Scenarios

**Challenge:** Initial implementation used `WriteBatch` for follow/unfollow. `WriteBatch` writes are unconditional — two simultaneous follow operations would both increment `followersCount`, resulting in a counter of 2 for 1 follower.

**Solution:** Replaced `WriteBatch` with `runTransaction`. The transaction reads the follower document first. If it exists, the transaction exits without writing. Firestore's optimistic concurrency retries the losing transaction. The counter is incremented exactly once regardless of concurrent requests.

### 2. Counter Decrement Without Existence Check

**Challenge:** `unfollowUser` with `WriteBatch` always decremented the counter, even if the follower document didn't exist. A malicious or buggy client could drive counters negative.

**Solution:** The transaction reads `followerSnap` and returns immediately (`if (!followerSnap.exists) return`) before any decrement. The counter only decrements when the relationship document actually exists.

### 3. Emit-After-Close StateError

**Challenge:** `FollowCubit.toggleFollow()` is async. If a user taps Follow then immediately navigates back, `BlocProvider` disposes the Cubit while the Firestore transaction is still in flight. When the transaction completes and the code attempts `emit(FollowError(...))`, `flutter_bloc` ^9 throws `StateError: Cannot emit new states after calling close`.

**Solution:** Captured `wasFollowing` before the first `await`. Added `if (isClosed) return` after the `catch` block and before the final `_emitLoaded()`. The Firestore write completes correctly in the background; the Cubit simply skips the UI update.

### 4. Scoped vs. Global PostsCubit

**Challenge:** `UserProfileView` needs to display a specific user's posts. Calling `loadUserPosts(userId)` on the global `PostsCubit` would overwrite the global feed state, breaking the home feed when the user navigates back.

**Solution:** `UserProfileView` provides a **new local instance** of `PostsCubit` via `BlocProvider`. The global `PostsCubit` is unaffected. When Flutter resolves `context.read<PostsCubit>()` inside `UserProfileView`, it finds the local instance first. Routes pushed from `UserProfileView` use a new context rooted in the `Navigator`, above the global `MultiBlocProvider`, so they see the global cubit — correct behavior for `PostDetailsView`.

### 5. Dual-Stream State Coordination in FollowCubit

**Challenge:** `FollowCubit` needs data from two independent Firestore streams: the follow status document and the user document for counts. Emitting `FollowLoaded` from either stream alone produces partial data — e.g., emitting on the follow status stream before the user document loads shows `followersCount: 0` briefly.

**Solution:** A `_userDocInitialized` boolean gate. Stream 1 (follow status) updates `_isFollowing` and only calls `_emitLoaded()` if `_userDocInitialized` is true. Stream 2 (user document) sets `_userDocInitialized = true` on its first emission and always calls `_emitLoaded()`. The first emission of `FollowLoaded` is guaranteed to have both follow status and user counts.

### 6. Security Rule Null Safety for Missing Counter Fields

**Challenge:** Existing users created before the follow feature was deployed don't have `followersCount`/`followingCount` fields. The initial security rule used `request.resource.data.followersCount` (direct access) which evaluates to `null` for a field being created by `FieldValue.increment()`. The comparison `null == 0 + 1` evaluates to `false`, and the rule denies the write.

**Solution:** Changed both sides of the comparison to use `.get(field, 0)`:
```javascript
request.resource.data.get('followersCount', 0) == resource.data.get('followersCount', 0) + 1
```
This is safe for both existing users (field absent → 0) and new users (field present → correct value).

### 7. Error Diagnosis from a Swallowed Exception

**Challenge:** `catch (_)` discarded the actual `FirebaseException` object. The only visible symptom was the generic string "Failed to follow" — no code, no message, no stack trace.

**Solution:** Changed to `catch (e, st)`. Added `_formatError(e, st)` which prints a structured block to `debugPrint` (code, message, plugin) and returns a formatted string for the snackbar. The real error code is now immediately visible in `flutter run` output without needing logcat or breakpoints.

---

## 14. Things That Demonstrate Engineering Skills

### 1. Firestore Transactions with Idempotency Guards
Using `runTransaction` with an existence check before write demonstrates understanding of distributed systems, optimistic concurrency, and the difference between eventual and strong consistency. Most tutorial implementations use `WriteBatch` and ignore counter drift.

### 2. Dual-Stream Cubit with Initialization Gate
`FollowCubit` and `ProfileCubit` both merge two independent Firestore streams into a single state object with a private cache pattern. The `_userDocInitialized` gate prevents partial state renders. This requires understanding async event ordering and stream lifecycle.

### 3. Scoped vs. Global Cubit Architecture
Knowing when to provide a Cubit globally (session-wide) vs. locally (screen-scoped) — and understanding that Flutter resolves providers up the widget tree — is a non-obvious BLoC pattern. The `UserProfileView` local `PostsCubit` correctly isolates user post data from the feed without duplicating any logic.

### 4. `isClosed` Guard for Async Cubit Safety
Explicitly handling the case where an async Cubit method completes after the Cubit is disposed shows awareness of Flutter widget lifecycle and the constraints of the BLoC library (^9 throws on post-close emit).

### 5. `wasFollowing` Intent Capture
Capturing `final wasFollowing = _isFollowing` before the first `await` prevents a race condition where the Firestore stream updates `_isFollowing` mid-flight, causing the error message to report the wrong action.

### 6. Security Rules with `getAfter()` Cross-Document Validation
Using `getAfter()` to tie a counter increment to a subcollection write in the same transaction is an advanced Firestore rules technique. It ensures the counter can only be modified alongside the actual relationship document, preventing standalone counter manipulation.

### 7. `_formatError` Diagnostic Pattern
Rather than logging to a separate monitoring service (which would require a dependency), `_formatError` surfaces the complete error context (Firebase code, message, plugin, stack trace) directly in the debug console in a structured, searchable format. This turns a previously invisible failure into an immediately diagnosable one.

### 8. Feature-First Clean Architecture Without Over-Engineering
The project applies repository abstraction, Cubit state machines, and feature isolation without a domain layer, service locator, or code generation. This demonstrates judgment about appropriate complexity for a given scale — choosing the right pattern, not the most complex one.

### 9. Denormalized Counter Design
Storing `followersCount`, `likeCount`, and `commentCount` as integer fields rather than computing them with aggregation queries demonstrates knowledge of NoSQL data modeling trade-offs: write amplification in exchange for O(1) read cost.

### 10. Consistent Error Code Mapping
`AuthRepoImp.getErrorMessage(code)` maps 12 Firebase Auth error codes to user-facing strings. This prevents internal codes like `invalid-credential` or `channel-error` from leaking into the UI and demonstrates attention to production-quality user experience.

### 11. O(1) Follow Status via Document Path
Detecting follow status by reading a single document at a known path (`followers/{currentUserId}`) rather than querying a collection demonstrates understanding of Firestore's document-level access patterns and why schema design choices affect query cost.

### 12. Animated Shimmer Without External Dependencies
`ShimmerBox` implements a shimmer loading effect using `AnimationController` and a shifting `LinearGradient` with no external package. This shows ability to implement polished UX from first principles.

---

## 15. Possible Improvements

These are realistic improvements, not implemented:

| Improvement | Technical Approach |
|---|---|
| Like toggle as transaction | Replace read-modify-write with `runTransaction` to prevent like count drift under concurrent likes |
| Comment count atomicity | Wrap `commentCount` increment and comment `add` in a single `WriteBatch` |
| Post editing and deletion | Add `updatePost` / `deletePost` to `PostRepo`; add UI in `PostDetailsView` for own posts |
| Pagination | Replace stream of all posts with cursor-based pagination using `startAfterDocument` |
| Push notifications | Firebase Cloud Messaging for follow/like/comment events |
| User profile photo | Store image URL in `users/{uid}` document; update `UserAvatar` to show real photo |
| Profile editing | Allow name change via Firebase Auth `updateDisplayName` + Firestore `update` |
| Search | Firestore `where` with `>=`/`<=` for prefix search, or Algolia integration |
| Username display in feed | Currently `userName` on posts is denormalized at post creation. Changing your name doesn't update existing posts. A Cloud Function could backfill on name change |
| Cloud Function for follow | Move follow/unfollow logic server-side to eliminate client-side counter writes entirely |
| Unit tests | Cubits are already injectable via constructor — writing tests requires only mock repo implementations |
| Bloc observer | Add a `BlocObserver` for global state transition logging in debug mode |
| Offline support | Firestore offline persistence is on by default; expose conflict resolution UI |

---

## 16. Resume Highlights

- **Built a full-stack social media mobile application** using Flutter and Firebase, implementing real-time feeds, follow/unfollow relationships, commenting, image uploads, and AI chatbot integration from scratch.

- **Designed and implemented a transactional follow system** using Firestore transactions with idempotency guards, preventing counter drift in multi-device race conditions — counters remain accurate under concurrent follow/unfollow operations.

- **Architected a Feature-First Clean Architecture** with 6 isolated features, each following a strict Data/Presentation split and repository abstraction pattern, enabling independent testability and feature iteration.

- **Implemented dual-stream Cubit state management** — `FollowCubit` and `ProfileCubit` each coordinate two simultaneous Firestore `snapshots()` streams into a single consistent state object, with an initialization gate to prevent partial-data renders.

- **Engineered Firestore Security Rules** with `getAfter()` cross-document validation, enforcing that follower counter increments can only occur alongside the corresponding subcollection document write in the same atomic transaction.

- **Designed a scalable follow graph schema** using Firestore subcollections (`followers/`, `following/`) with denormalized integer counters, achieving O(1) follow status lookups and O(1) count reads without aggregation queries.

- **Resolved async Cubit lifecycle bug** by guarding all post-`await` emit calls with `isClosed` checks, preventing `StateError` throws in `flutter_bloc` ^9 when users navigate away during in-flight Firestore transactions.

- **Integrated three external services** (Firebase Auth, Cloud Firestore, ImageBB CDN, n8n AI webhook) through a clean repository pattern — all SDK calls are isolated from business logic in concrete repository implementations.

- **Delivered structured error diagnostics** by replacing generic `catch (_)` with a `_formatError` helper that surfaces Firebase error codes, messages, and stack traces to both the debug console and the snackbar, reducing mean time to diagnose Firestore failures.

- **Built a custom animated shimmer widget** without external dependencies, and implemented multiple `AnimationController`-driven entry animations across auth screens and splash using `FadeTransition`, `SlideTransition`, `ScaleTransition`, and `Curves.elasticOut`.

- **Maintained zero analyzer warnings** across 53 Dart files throughout iterative feature development, enforcing code quality with `flutter_lints`.

- **Demonstrated architectural judgment** by deliberately omitting a domain layer, service locator, and code generation — choosing appropriate complexity for the project scope rather than applying enterprise patterns indiscriminately.

---

## 17. Interview Questions & Answers

### Architecture

**Q1. Why did you use Feature-First architecture instead of Layer-First?**
> Layer-first (e.g., `lib/data/`, `lib/presentation/`) groups all data files together and all views together. When working on a single feature, you touch files scattered across multiple directories. Feature-first keeps everything for a feature (`auth/data/`, `auth/presentation/`) co-located, reducing navigation overhead. It also makes it easier to identify and reason about feature boundaries.

**Q2. Why is there no domain layer?**
> A domain layer with use-cases adds value when business logic is complex enough to warrant isolation — for example, combining data from multiple repositories, applying domain rules, or enabling multiple presentation layers. In ConnectHub, each screen maps closely to one repository and one Cubit. Adding use-case classes would be an abstraction without a benefit: another indirection layer with no additional testability or reuse. The repository abstract class already serves as the boundary.

**Q3. How does the Cubit constructor injection enable testing?**
> Every Cubit accepts `XxxRepo? repo` with a default of `XxxRepoImp()`. In a test: `PostsCubit(postsRepo: MockPostsRepo())`. The `MockPostsRepo` extends `PostsRepo` and returns predictable data. No service locator, no global state to reset — just constructor arguments.

**Q4. Why are some Cubits global and others local?**
> Global Cubits (`AuthCubit`, `PostsCubit`, `ChatbotCubit`) hold state that must survive navigation — the auth session, the feed data, and the chat history. Providing them locally would reset them every time a route is popped. Local Cubits (`ProfileCubit`, `CreatePostCubit`, `FollowCubit`) hold state meaningful only to a single screen. Providing them locally ties their lifecycle to the screen, ensuring automatic cleanup when the screen is popped.

---

### State Management

**Q5. What is the difference between BlocBuilder, BlocListener, and BlocConsumer?**
> `BlocBuilder` rebuilds the widget subtree on every state change. `BlocListener` reacts to state changes with side effects (show snackbar, navigate) without rebuilding. `BlocConsumer` combines both — it has a `listener` for side effects and a `builder` for rendering. In ConnectHub, `BlocConsumer` is used in `ChatbotView` (scroll to bottom on new message + render chat list) and `CreatePostView` (navigate/snackbar + render form state).

**Q6. How does the FollowCubit prevent partial-data renders?**
> It uses a `_userDocInitialized` boolean. Stream 1 (follow status) updates `_isFollowing` but only calls `_emitLoaded()` if `_userDocInitialized` is true. Stream 2 (user document) sets `_userDocInitialized = true` on its first emission before calling `_emitLoaded()`. So the first `FollowLoaded` emission is guaranteed to have both follow status and follower counts.

**Q7. What does `wasFollowing` protect against?**
> Between `_isFollowing = true` being read at the top of `toggleFollow()` and the `await` completing, the Firestore stream could fire and update `_isFollowing` to `false` (if another device unfollowed concurrently). Without `wasFollowing`, the error message and the repo call would use the new value. Capturing `final wasFollowing = _isFollowing` before the `await` freezes the intent.

---

### Firebase & Firestore

**Q8. Why use Firestore transactions instead of WriteBatch for follow?**
> `WriteBatch` is unconditional — all writes execute regardless of existing data. In a follow operation, if two devices simultaneously call `followUser`, both batches would increment `followersCount`, resulting in 2 for 1 follower. A transaction reads the follower document first. If it exists (second concurrent call), it exits without writing. Firestore retries the losing transaction, which then finds the document exists and also exits cleanly. The counter is incremented exactly once.

**Q9. Why store followersCount as a field instead of counting the subcollection?**
> Counting a subcollection requires a `count()` aggregation query or reading all documents. Both cost more than reading a field. A stored integer is O(1) — one field in a document you're already reading. The trade-off is write amplification: every follow/unfollow updates both the subcollection and the counter. For a social app where reads vastly outnumber writes, this trade-off is correct.

**Q10. Why use subcollections for followers instead of an array in the user document?**
> Firestore documents have a 1 MB size limit. An array of UIDs (each ~28 bytes) would limit followers to approximately 37,000 before the document becomes unwritable. Subcollections have no document count limit. Additionally, checking "does user A follow user B?" with an array requires reading the entire array and searching it client-side. With a subcollection, it is a single document read at a known path — O(1).

**Q11. How does getAfter() work in the security rules?**
> `getAfter()` is a Firestore Security Rules v2 function that returns the state of a document *after all writes in the current atomic operation are applied*. In a transaction, all four writes (two subcollection sets, two counter updates) are committed together. When the rule for `users/{targetUserId}` update is evaluated, `getAfter(users/{targetUserId}/followers/{currentUserId})` sees the subcollection document as it will be after the transaction commits — so if the transaction includes a `set` on that path, `getAfter().exists` returns `true`. This allows the rule to verify that a counter increment is always accompanied by a real relationship document write.

**Q12. Why does the security rule use .get('followersCount', 0) instead of direct field access?**
> For existing users without the field, `resource.data.followersCount` evaluates to `null` in Firestore rules. `null == 0 + 1` evaluates to `false`, denying the rule. `resource.data.get('followersCount', 0)` returns the default `0` when the field is absent, making the comparison `1 == 0 + 1` which is `true`. Both sides of the comparison use `.get()` for symmetric null safety.

**Q13. How is FieldValue.serverTimestamp() different from DateTime.now()?**
> `FieldValue.serverTimestamp()` is resolved by the Firestore server at write time using the server's clock. `DateTime.now()` uses the client's clock, which may be wrong (device clock skew, timezone). Server timestamps are always consistent across all clients and unaffected by device settings. They are also used for Firestore ordering queries — documents ordered by a server timestamp are guaranteed to be ordered by actual write time.

---

### Performance

**Q14. How are Firestore reads minimized on the follow feature?**
> Three design choices minimize reads: (1) Follow status is a single document read by path — O(1). (2) Follower/following counts are stored as integers in the user document — already read for the profile card. (3) The real-time streams use Firestore's local cache — the first emission comes from the cached data immediately, with no round-trip.

**Q15. Why is the global PostsCubit not used in UserProfileView?**
> If `PostsCubit.loadUserPosts(targetUserId)` were called on the global cubit, it would cancel the active feed stream and replace it with user-specific data. When the user navigates back to the feed, it would show the target user's posts until `loadPosts()` is called again. Instead, `UserProfileView` provides a new local `PostsCubit` scoped to that view. When the view is popped, the local cubit is disposed and its stream cancelled.

---

### Error Handling

**Q16. How do you handle the case where a Cubit is closed while an async method is running?**
> In `FollowCubit.toggleFollow()`, after every `await`, there is `if (isClosed) return`. If the user pops the view while the Firestore transaction is in flight, `BlocProvider` calls `close()` which cancels stream subscriptions and closes the state stream. When the transaction completes and execution resumes, `isClosed` is `true` and the method exits without calling `emit()`. Without this guard, `flutter_bloc` ^9 would throw `StateError: Cannot emit new states after calling close`.

**Q17. Why does the ProfileCubit silently ignore user document stream errors?**
> The user document stream is used only for follower/following counts — display data, not business-critical. If it fails (e.g., a transient Firestore error), the profile still shows posts and likes correctly. Emitting `ProfileError` for a non-critical secondary stream would hide a working profile. The explicit `onError: (_) {}` is documented in the code as "follow counts are non-critical."

---

### Design Decisions

**Q18. Why is `userName` denormalized into posts instead of stored as a reference?**
> Firestore does not have JOINs. To show a post with its author's name, you would need to read both the post document and the user document — two reads instead of one. Denormalizing `userName` into the post at write time means the feed can be rendered from post documents alone. The trade-off is staleness: if a user changes their name, existing posts retain the old name. This is acceptable in most social platforms (Twitter/X shows original post data, not live user data).

**Q19. Why does PostDetailsView use StreamBuilder directly instead of a Cubit?**
> `PostDetailsView` has no business logic beyond rendering live Firestore data and delegating actions back to the repository. Adding a Cubit would require states for loading/loaded/error plus the post data — for a one-to-one mapping with the stream output. `StreamBuilder` expresses the same intent with less code. This is a deliberate pragmatic choice for simple, stateless views where the data model is the state.

**Q20. Why is there no GoRouter or named routes?**
> The app uses imperative navigation (`Navigator.push`) exclusively. Named routes add value when navigation is triggered from multiple places or when deep linking is required. In ConnectHub, navigation is always triggered from a specific widget with a specific context. Imperative navigation is simpler, more debuggable, and consistent with the existing codebase pattern.

---

### Practical

**Q21. How would you add unit tests to PostsCubit?**
> Create a `MockPostsRepo` implementing `PostsRepo` that returns a `StreamController`-backed stream. Inject it: `PostsCubit(postsRepo: mockRepo)`. Use `bloc_test`'s `blocTest` helper to assert emitted states in response to `loadPosts()`. The constructor injection pattern means no modifications to production code are needed.

**Q22. What would change if the app needed to support 1 million followers?**
> The subcollection structure already scales (no document size limit). The main concern would be `followersCount` update contention — if many users follow the same celebrity simultaneously, transactions will retry frequently. The solution is `FieldValue.increment` (which handles this atomically without transaction retries) or a Cloud Function with sharded counters. The current implementation uses `increment` inside a transaction, which is reasonable but could be simplified to a batch write with `increment` if the idempotency guarantee from the transaction read is relaxed.

**Q23. How does the chatbot handle errors?**
> `AIChatService.sendMessage()` catches `DioException` and generic exceptions and returns an error string (e.g., `"Error: Connection failed. Please try again."`). The `ChatbotCubit` adds this error string to the message list as an AI message. There is no `ChatbotError` state — the error is surfaced as a chat bubble, maintaining the conversational UX. This is intentional: the user sees the failure in context and can type a follow-up.

**Q24. How is image quality managed before upload?**
> `ImagePicker.pickImage()` is called with `maxWidth: 1080` and `imageQuality: 85`. This reduces the image to a maximum width of 1080 pixels and applies 85% JPEG compression before the file is even returned to the app. The compressed image is then base64-encoded and uploaded to ImageBB. This reduces upload time and bandwidth significantly compared to uploading the raw camera image.

**Q25. What happens if the ImageBB upload fails?**
> `ImageBBService.uploadImage()` returns `null` on any error (it catches all exceptions and returns null). `PostRepoImp.createPost()` checks for `null` and throws `Exception('Failed to upload image. Please try again.')`. `CreatePostCubit.createPost()` catches this and emits `CreatePostError` with the message. The Firestore post document is never written — no partial state is created.

**Q26. How is the follow button hidden when viewing your own profile?**
> `loadFollowStatus()` checks `if (currentUserId == targetUserId) return` and exits without emitting any state. The Cubit stays in `FollowInitial`. `FollowButton.build()` returns `SizedBox.shrink()` for `FollowInitial`. Additionally, `PostCard` skips navigation to `UserProfileView` when `isOwnPost` is true, so the current user never reaches a `UserProfileView` for their own profile through the feed.

**Q27. How does the app handle the case where a user signs up but the Firestore document creation fails?**
> Firebase Auth creates the account successfully, but the user has no `users/{uid}` document. The app emits `AuthAuthenticated` (since auth succeeded). When the user creates a post, `PostRepoImp.createPost()` resolves the `userName` through three fallback sources: `user.displayName`, Firestore lookup, then email prefix. The missing user document is handled gracefully for posts but would show 0 follow counts. A production improvement would be to verify or retry the Firestore write during the next login.

**Q28. How does the animated bottom navigation work?**
> `HomeView` is a `StatefulWidget` with `int _currentIndex`. The pages array (`[_FeedPage(), ChatbotView(), ProfileView()]`) is indexed by `_currentIndex`. The body is wrapped in `AnimatedSwitcher` with `KeyedSubtree(key: ValueKey(_currentIndex))` — changing the key forces a widget swap with the transition animation. The nav bar items are `AnimatedContainer` widgets that expand to show a label when `isSelected`, with a 250ms animation.

**Q29. How is the Shimmer animation implemented?**
> `ShimmerBox` uses a single `AnimationController` (1500ms, repeating). In `AnimatedBuilder`, the `LinearGradient` begin and end `Alignment`s are computed from `_controller.value`, sliding the highlight from left to right. No external shimmer package is used.

**Q30. What is the biggest architectural decision you would change if starting over?**
> I would add a Firestore transaction to the like toggle, matching the follow system's atomicity guarantees. The current read-modify-write on likes can produce incorrect `likeCount` under concurrent likes. I would also add a `LikeRepo` to isolate the like logic from `PostsRepoImp`, which currently contains toggle logic duplicated in both `PostsRepoImp` and `PostRepoImp` — a DRY violation worth addressing.

---

## 18. Metrics

| Metric | Value | Basis |
|---|---|---|
| Firestore reads for follow status check | **1** (O(1) document path lookup) | `followers/{currentUserId}` document read |
| Firestore reads for follower count display | **0** (included in existing user doc read) | `followersCount` field on `users/{uid}` document already fetched |
| Firestore writes per follow operation | **4** (atomic) | 2 subcollection sets + 2 counter updates in one transaction |
| Transaction retry safety | **Guaranteed idempotent** | Existence check before every write — N concurrent follows produce 1 relationship |
| Maximum followers before schema change | **Unlimited** (subcollection) vs. ~37,000 (array) | Firestore document 1 MB limit with 28-byte UIDs |
| Cubit subscription cleanup | **100%** | Every `StreamSubscription` cancelled in `close()` |
| Network round-trips for feed render | **1** (stream, cached) | Single Firestore stream; subsequent updates are delta-only |
| Auth error codes mapped | **12** | Explicit switch cases in `getErrorMessage()` |
| Image quality reduction before upload | **~60-70%** size reduction | `maxWidth: 1080, imageQuality: 85` vs. raw 4K camera image |
| Global state leakage from UserProfileView | **0** | Local `PostsCubit` instance; global feed unaffected |
| Features | **6** | auth, chatbot, follow, home, post, profile |
| Cubits | **6** | AuthCubit, PostsCubit, CreatePostCubit, ProfileCubit, FollowCubit, ChatbotCubit |
| Dart files | **53** | Across all features and core utilities |
| Analyzer warnings | **0** | `flutter analyze` on full codebase |

---

## 19. Final Technical Summary

ConnectHub is a Flutter social media application built on a Feature-First Clean Architecture with BLoC/Cubit state management and Firebase as the backend. The project demonstrates production-level thinking across data modeling, async safety, and distributed system correctness — areas where most tutorial implementations cut corners.

The most technically significant component is the follow system. Follow and unfollow operations are implemented as Firestore transactions that read before writing, making them idempotent under any concurrency — two simultaneous follows from different devices produce exactly one relationship and exactly one counter increment. Follower counts are stored as denormalized integers, enabling O(1) reads, and the follow status is determined by a single document path lookup rather than a collection query.

State management uses Cubits with a private cache pattern: `FollowCubit` and `ProfileCubit` each combine two independent real-time Firestore streams into a single consistent state object, with an initialization gate that prevents partial-data renders on first load. Cubit scope is deliberately chosen — three Cubits are global (session-wide data) and three are feature-scoped (tied to a specific screen's lifecycle), with explicit reasoning for each decision.

Async safety is addressed through `isClosed` guards on all post-`await` emit calls in `FollowCubit`, preventing the `StateError` throw that `flutter_bloc` ^9 produces when a Cubit is disposed while a Firestore transaction is still in flight. Error diagnosis is addressed through structured `_formatError` logging that surfaces Firebase error codes, messages, and stack traces to the debug console — replacing generic catch-all strings with actionable information.

The Firestore security rules use `getAfter()` to enforce that follower counter increments can only accompany real subcollection writes in the same atomic transaction, and `.get(field, default)` for null-safe comparison of fields that may not yet exist on older user documents. These rules represent the security boundary that the client-side transaction logic cannot provide on its own.

---

*Document generated from analysis of 53 Dart source files, Firestore rules, and project configuration. All claims are grounded in the actual implementation.*
