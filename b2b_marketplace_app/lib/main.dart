import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'package:b2b_marketplace_app/l10n/app_localizations.dart';
import 'package:b2b_marketplace_app/features/auth/login_page.dart'; // New import
import 'package:b2b_marketplace_app/features/auth/register_page.dart'; // New import
import 'package:b2b_marketplace_app/core/providers/auth_provider.dart'; // New import
import 'package:b2b_marketplace_app/core/providers/app_initializer.dart'; // New import
import 'package:b2b_marketplace_app/features/home/home_page.dart';
import 'package:b2b_marketplace_app/features/investors_showcase/investor_page.dart';
import 'package:b2b_marketplace_app/features/about/about_page.dart';
import 'package:b2b_marketplace_app/features/opportunities/opportunities_page.dart';
import 'package:b2b_marketplace_app/features/events/events_page.dart';
import 'package:b2b_marketplace_app/features/pricing/pricing_page.dart';
import 'package:b2b_marketplace_app/features/blog/blog_page.dart';
import 'package:b2b_marketplace_app/features/blog/blog_post_page.dart';
import 'package:b2b_marketplace_app/features/contact/contact_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    
    // Companies provider will handle its own initialization

    final GoRouter router = GoRouter(
      redirect: (BuildContext context, GoRouterState state) {
        final isAuthenticated = authState.isAuthenticated;

        final loggingIn = state.uri.path == '/login';
        final registering = state.uri.path == '/register';

        // If not authenticated, redirect to login unless already on login/register page
        if (!isAuthenticated) {
          return loggingIn || registering ? null : '/login';
        }

        // If authenticated, redirect from login/register to home
        if (loggingIn || registering) {
          return '/';
        }

        // No redirect needed
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
        ),
        GoRoute(
          path: '/register',
          builder: (BuildContext context, GoRouterState state) {
            return const RegisterPage();
          },
        ),
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: '/investors',
          builder: (BuildContext context, GoRouterState state) {
            return const InvestorPage();
          },
        ),
        GoRoute(
          path: '/about',
          builder: (BuildContext context, GoRouterState state) {
            return const AboutPage();
          },
        ),
        GoRoute(
          path: '/opportunities',
          builder: (BuildContext context, GoRouterState state) {
            return const OpportunitiesPage();
          },
        ),
        GoRoute(
          path: '/events',
          builder: (BuildContext context, GoRouterState state) {
            return const EventsPage();
          },
        ),
        GoRoute(
          path: '/pricing',
          builder: (BuildContext context, GoRouterState state) {
            return const PricingPage();
          },
        ),
        GoRoute(
          path: '/blog',
          builder: (BuildContext context, GoRouterState state) {
            return const BlogPage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: ':slug',
              builder: (BuildContext context, GoRouterState state) {
                return BlogPostPage(slug: state.pathParameters['slug']!);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/contact',
          builder: (BuildContext context, GoRouterState state) {
            return const ContactPage();
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'B2B Marketplace',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
  