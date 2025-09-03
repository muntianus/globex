import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_page.dart';
import '../../features/investors_showcase/investor_page.dart';
import '../../features/about/about_page.dart';
import '../../features/opportunities/opportunities_page.dart';
import '../../features/events/events_page.dart';
import '../../features/pricing/pricing_page.dart';
import '../../features/blog/blog_page.dart';
import '../../features/blog/blog_post_page.dart';
import '../../features/contact/contact_page.dart';


final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
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