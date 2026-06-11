import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tasklance/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Login and Dashboard flow', (tester) async {
      app.main();
      // Wait for app to settle (splash screen, routing)
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // We should be on the login screen, but we might be somewhere else if already logged in.
      // Assuming we start logged out for a fresh test.
      // If we are logged in, we should log out first.
      
      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('login_button'));

      if (emailField.evaluate().isNotEmpty) {
        // We are on the login screen
        await tester.enterText(emailField, 'client@tasklance.app');
        await tester.pumpAndSettle();
        
        await tester.enterText(passwordField, 'password123');
        await tester.pumpAndSettle();

        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Check if we are on Dashboard
      expect(find.text('Active Projects'), findsWidgets);
      
      // Tap on Projects tab
      final projectsTab = find.text('Projects');
      if (projectsTab.evaluate().isNotEmpty) {
        await tester.tap(projectsTab.first);
        await tester.pumpAndSettle();
      }

    });
  });
}
