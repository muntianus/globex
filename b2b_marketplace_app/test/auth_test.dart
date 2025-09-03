import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:b2b_marketplace_app/main.dart';
import 'package:b2b_marketplace_app/core/providers/auth_provider.dart';
import 'package:b2b_marketplace_app/core/services/auth_service.dart';
import 'package:b2b_marketplace_app/features/auth/login_page.dart';
import 'package:b2b_marketplace_app/features/auth/register_page.dart';
import 'package:b2b_marketplace_app/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:b2b_marketplace_app/core/router/app_router.dart'; // Import appRouter
import 'package:mocktail/mocktail.dart';

// Mock AuthService
class MockAuthService extends Mock implements AuthService {}

// A test wrapper widget to provide necessary context
class TestApp extends StatelessWidget {
  final List<Override> overrides;
  final String initialLocation;
  final GoRouter? router; // Make router optional

  const TestApp({
    Key? key,
    this.overrides = const [],
    this.initialLocation = '/',
    this.router,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: Builder(
        builder: (context) {
          final container = ProviderScope.containerOf(context);
          final effectiveRouter = router ?? GoRouter(
            refreshListenable: GoRouterRefreshStream(container),
            initialLocation: initialLocation,
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                  return const Text('Home Page');
                },
              ),
              GoRoute(
                path: '/login',
                builder: (BuildContext context, GoRouterState state) {
                  return LoginPage();
                },
              ),
              GoRoute(
                path: '/register',
                builder: (BuildContext context, GoRouterState state) {
                  return RegisterPage();
                },
              ),
            ],
          );
          return MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: effectiveRouter,
          );
        },
      ),
    );
  }
}

// Helper class to convert a Riverpod ProviderContainer into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(ProviderContainer container) {
    // Listen to changes in the authProvider's state
    container.read(authProvider.notifier).addListener((_) {
      notifyListeners();
    });
  }
}

void main() {
  group('Authentication Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('Login page shows correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          initialLocation: '/login',
        ),
      );

      await tester.pumpAndSettle(); // Pump to allow navigation and localization to settle

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('Register page shows correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          initialLocation: '/register',
        ),
      );

      await tester.pumpAndSettle(); // Pump to allow navigation and localization to settle

      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('Successful login navigates to home', (WidgetTester tester) async {
      when(() => mockAuthService.login('testuser', 'password'))
          .thenAnswer((_) async => {'access_token': 'fake_token'});
      when(() => mockAuthService.fetchCurrentUser('fake_token'))
          .thenAnswer((_) async => {'username': 'testuser', 'email': 'test@example.com'});

      await tester.pumpWidget(
        TestApp(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          initialLocation: '/login', // Start on login page
        ),
      );

      await tester.pumpAndSettle(); // Allow initial redirect to login page

      // Should be on the login page initially due to redirect
      expect(find.text('Login'), findsOneWidget);

      await tester.enterText(find.bySemanticsLabel('Username'), 'testuser');
      await tester.enterText(find.bySemanticsLabel('Password'), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
      verify(() => mockAuthService.login('testuser', 'password')).called(1);
      verify(() => mockAuthService.fetchCurrentUser('fake_token')).called(1);
    });

    testWidgets('Failed login shows snackbar', (WidgetTester tester) async {
      when(() => mockAuthService.login('wronguser', 'wrongpass'))
          .thenThrow(Exception('Invalid credentials'));

      await tester.pumpWidget(
        TestApp(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          initialLocation: '/login', // Start on login page
        ),
      );

      await tester.pumpAndSettle(); // Allow initial redirect to login page

      // Should be on the login page initially due to redirect
      expect(find.text('Login'), findsOneWidget);

      await tester.enterText(find.bySemanticsLabel('Username'), 'wronguser');
      await tester.enterText(find.bySemanticsLabel('Password'), 'wrongpass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump(); // Pump to show the SnackBar

      expect(find.text('Login failed. Please check your credentials.'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget); // Still on login page
    });

    testWidgets('Successful registration navigates to home', (WidgetTester tester) async {
      when(() => mockAuthService.register(any(), any(), any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockAuthService.login('newuser', 'newpassword'))
          .thenAnswer((_) async => {'access_token': 'fake_token_reg'});
      when(() => mockAuthService.fetchCurrentUser('fake_token_reg'))
          .thenAnswer((_) async => {'username': 'newuser', 'email': 'new@example.com'});

      await tester.pumpWidget(
        TestApp(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          initialLocation: '/login', // Start on login page
        ),
      );

      await tester.pumpAndSettle(); // Allow initial redirect to login page

      // Navigate to register page
      final router = GoRouter.of(tester.element(find.byType(MaterialApp))); // Get router from MaterialApp
      router.go('/register');
      await tester.pumpAndSettle();

      expect(find.text('Register'), findsOneWidget);

      await tester.enterText(find.bySemanticsLabel('Username'), 'newuser');
      await tester.enterText(find.bySemanticsLabel('Password'), 'newpassword');
      await tester.enterText(find.bySemanticsLabel('Email'), 'new@example.com');
      await tester.enterText(find.bySemanticsLabel('Full Name'), 'New User');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
      verify(() => mockAuthService.register('newuser', 'newpassword', 'new@example.com', 'New User')).called(1);
      verify(() => mockAuthService.login('newuser', 'newpassword')).called(1);
      verify(() => mockAuthService.fetchCurrentUser('fake_token_reg')).called(1);
    });

    testWidgets('Auth redirect works correctly', (WidgetTester tester) async {
      // Initially not authenticated
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(Exception('Not logged in')); // Simulate not logged in

      await tester.pumpWidget(
        TestApp(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          initialLocation: '/home', // Start on a protected page
        ),
      );
      await tester.pumpAndSettle();

      // Should be redirected to login page
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Home Page'), findsNothing);

      // Simulate successful login
      when(() => mockAuthService.login('testuser', 'password'))
          .thenAnswer((_) async => {'access_token': 'fake_token'});
      when(() => mockAuthService.fetchCurrentUser('fake_token'))
          .thenAnswer((_) async => {'username': 'testuser', 'email': 'test@example.com'});

      await tester.enterText(find.bySemanticsLabel('Username'), 'testuser');
      await tester.enterText(find.bySemanticsLabel('Password'), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Should be on home page
      expect(find.text('Home Page'), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });
  });
}
