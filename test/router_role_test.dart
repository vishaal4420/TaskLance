import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasklance/core/router/app_router.dart';
import 'package:tasklance/features/auth/providers/auth_providers.dart';
import 'package:tasklance/models/user.dart';

class MockUser implements User {
  @override
  String get uid => '123';
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Router redirects Client to /client-dashboard', (WidgetTester tester) async {
    final mockUser = MockUser();
    
    final clientUserModel = UserModel(
      uid: '123',
      name: 'Client Test',
      email: 'client@test.com',
      role: UserRole.client,
      createdAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
        currentUserProvider.overrideWith((ref) => Stream.value(clientUserModel)),
      ],
    );

    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // The router should have redirected to /client-dashboard
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    expect(location, '/client-dashboard');
  });

  testWidgets('Router redirects new Freelancer to /profile-setup', (WidgetTester tester) async {
    final mockUser = MockUser();
    
    final freelancerUserModel = UserModel(
      uid: '123',
      name: 'Freelancer Test',
      email: 'free@test.com',
      role: UserRole.freelancer,
      skills: [], // Empty skills -> new freelancer
      createdAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
        currentUserProvider.overrideWith((ref) => Stream.value(freelancerUserModel)),
      ],
    );

    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should redirect to /profile-setup
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    expect(location, '/profile-setup');
  });

  testWidgets('Router redirects returning Freelancer to /dashboard', (WidgetTester tester) async {
    final mockUser = MockUser();
    
    final returningFreelancer = UserModel(
      uid: '123',
      name: 'Freelancer Test',
      email: 'free@test.com',
      role: UserRole.freelancer,
      skills: ['Flutter'], // Has skills -> returning
      createdAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
        currentUserProvider.overrideWith((ref) => Stream.value(returningFreelancer)),
      ],
    );

    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should redirect to /dashboard
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    expect(location, '/dashboard');
  });
}
