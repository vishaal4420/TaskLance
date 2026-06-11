import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasklance/app.dart';
import 'package:tasklance/core/config/app_config.dart';

void main() {
  testWidgets('Auth workflow successfully navigates from Login to Dashboard in Mock Mode', (WidgetTester tester) async {
    // 1. Verify we are in mock mode
    expect(AppConfig.useLiveFirebase, isFalse, reason: 'Test requires mock mode');

    // 2. Pump the app
    await tester.pumpWidget(
      const ProviderScope(
        child: TaskLanceApp(),
      ),
    );

    // Let the splash screen animations and delays finish
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 3. We should be on the Login screen (or Onboarding then Login)
    // Find the login button
    final loginButton = find.text('Sign In');
    
    // If we are on onboarding, navigate to login
    if (find.text('Get Started').evaluate().isNotEmpty) {
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
    }

    expect(loginButton, findsOneWidget, reason: 'Should be on Login screen');

    // 4. Fill out the email and password
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 5. Tap the Sign In button
    await tester.tap(loginButton);
    
    // 6. Wait for the 1500ms mock delay and the router redirect
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 7. Verify we arrived at the Dashboard
    // The freelancer dashboard has a "Good morning/afternoon" greeting
    // Or we can just check if "New Invoice" FAB is present
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: 'Should be on Dashboard with a FAB');
  });
}
