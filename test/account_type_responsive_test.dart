import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/auth/data/repos/auth_repo.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/views/account_type_selection_view.dart';

class _FakeAuthRepo implements AuthRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final widthsToTest = [320, 360, 375, 390, 414, 768, 1024];

  group('AccountTypeSelectionView Responsive Overflow Tests', () {
    for (final width in widthsToTest) {
      testWidgets('Renders with zero overflow at ${width}px width', (tester) async {
        final height = width >= 768 ? 1024.0 : 700.0;
        tester.view.physicalSize = Size(width.toDouble(), height);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final authCubit = AuthCubit(authRepo: _FakeAuthRepo());

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.theme,
            home: BlocProvider<AuthCubit>.value(
              value: authCubit,
              child: const AccountTypeSelectionView(
                name: 'Test User',
                email: 'test@example.com',
                password: 'password123',
              ),
            ),
          ),
        );

        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('What best describes your account?'), findsOneWidget);
        expect(find.text('Personal Account'), findsOneWidget);
        expect(find.text('Professional Account'), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
      });
    }
  });
}
