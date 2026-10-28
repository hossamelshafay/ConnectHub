import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connecthub/core/widgets/user_avatar.dart';

void main() {
  group('UserAvatar Widget Tests', () {
    testWidgets('renders fallback circle with initial when imageUrl is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatar(name: 'John Doe', size: 50)),
        ),
      );

      // Should show the first-letter initial
      expect(find.text('J'), findsOneWidget);

      // No CachedNetworkImage when there's no URL
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byType(ClipOval), findsNothing);
    });

    testWidgets(
        'renders fallback circle with initial when imageUrl is blank/whitespace',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'Alice', size: 44, imageUrl: '   '),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets(
        'renders SizedBox+ClipOval+CachedNetworkImage with correct params '
        'when a valid imageUrl is provided — no imageBuilder distortion',
        (tester) async {
      const testUrl = 'https://example.com/avatar.jpg';
      const testSize = 60.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'Jane Doe', size: testSize, imageUrl: testUrl),
          ),
        ),
      );

      // Outer SizedBox enforces the exact square bounding box
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(of: find.byType(UserAvatar), matching: find.byType(SizedBox))
            .first,
      );
      expect(sizedBox.width, testSize);
      expect(sizedBox.height, testSize);

      // ClipOval clips the square to a perfect circle
      expect(find.byType(ClipOval), findsOneWidget);

      // CachedNetworkImage with correct url, size, and BoxFit.cover
      final img = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
      expect(img.imageUrl, testUrl);
      expect(img.width, testSize);
      expect(img.height, testSize);
      expect(img.fit, BoxFit.cover);

      // imageBuilder must NOT be set — it bypasses fit/width/height and causes
      // the image to be stretched/squashed based on intrinsic image dimensions.
      expect(img.imageBuilder, isNull);

      // No destructive memory/disk cache constraints that force square distortion
      expect(img.memCacheWidth, isNull);
      expect(img.memCacheHeight, isNull);
      expect(img.maxWidthDiskCache, isNull);
      expect(img.maxHeightDiskCache, isNull);
    });

    testWidgets('UserAvatarById falls back to UserAvatar when userId is empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatarById(
              userId: '',
              fallbackName: 'Bob',
              size: 36,
            ),
          ),
        ),
      );

      // Should delegate to UserAvatar and show the fallback initial
      expect(find.byType(UserAvatar), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });
}
