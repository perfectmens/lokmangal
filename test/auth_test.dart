import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lokmangal/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lokmangal/features/auth/views/login_page.dart';

void main() {
  group('AuthViewModel Unit Tests', () {
    test('Initializes with unauthenticated by default', () {
      final vm = AuthViewModel();
      expect(vm.isAuthenticated, isFalse);
      expect(vm.currentUser, isNull);
      expect(vm.errorMessage, isNull);
    });

    test('Rejects invalid credentials and sets error message', () async {
      final vm = AuthViewModel();
      final success = await vm.login('wrong', 'invalid');
      expect(success, isFalse);
      expect(vm.isAuthenticated, isFalse);
      expect(vm.errorMessage, contains('Invalid credentials'));
    });

    test('Accepts demo / demo credentials successfully', () async {
      final vm = AuthViewModel();
      final success = await vm.login('demo', 'demo');
      expect(success, isTrue);
      expect(vm.isAuthenticated, isTrue);
      expect(vm.currentUser, 'demo');
      expect(vm.errorMessage, isNull);
    });

    test('Accepts Demo with mixed case for username', () async {
      final vm = AuthViewModel();
      final success = await vm.login('Demo ', 'demo');
      expect(success, isTrue);
      expect(vm.isAuthenticated, isTrue);
      expect(vm.currentUser, 'demo');
    });

    test('Logout clears authentication state', () async {
      final vm = AuthViewModel();
      await vm.login('demo', 'demo');
      expect(vm.isAuthenticated, isTrue);

      await vm.logout();
      expect(vm.isAuthenticated, isFalse);
      expect(vm.currentUser, isNull);
    });
  });

  group('LoginPage Widget Tests', () {
    testWidgets('Renders LoginPage components and performs demo login', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authVm = AuthViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authVm,
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      expect(find.text('Auraliss Corelife'), findsOneWidget);
      expect(find.text('Operator Sign In'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Enter demo credentials
      await tester.enterText(find.byType(TextField).first, 'demo');
      await tester.enterText(find.byType(TextField).last, 'demo');
      await tester.pump();

      // Tap Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 100));

      expect(authVm.isAuthenticated, isTrue);
      expect(authVm.currentUser, 'demo');
    });
  });
}
