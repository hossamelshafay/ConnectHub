import 'package:flutter_test/flutter_test.dart';

import 'package:connecthub/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verify that the app widget can be created.
    expect(const ConnectHubApp(), isNotNull);
  });
}
