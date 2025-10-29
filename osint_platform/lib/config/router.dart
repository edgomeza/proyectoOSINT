import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/home_screen_redesigned.dart';
import '../screens/nexo/nexo_chat_screen.dart';
import '../screens/planning/planning_screen.dart';
import '../screens/collection/collection_screen.dart';
import '../screens/processing/processing_screen_redesigned.dart';
import '../screens/analysis/analysis_screen_redesigned.dart';
import '../screens/reports/reports_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreenRedesigned(),
    ),
    GoRoute(
      path: '/investigations',
      name: 'investigations',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/nexo',
      name: 'nexo',
      builder: (context, state) => const NexoChatScreen(),
    ),
    GoRoute(
      path: '/investigation/:id/planning',
      name: 'planning',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: PlanningScreen(investigationId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/investigation/:id/collection',
      name: 'collection',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: CollectionScreen(investigationId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/investigation/:id/processing',
      name: 'processing',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ProcessingScreenRedesigned(investigationId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/investigation/:id/analysis',
      name: 'analysis',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: AnalysisScreenRedesigned(investigationId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/investigation/:id/reports',
      name: 'reports',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ReportsScreen(investigationId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Página no encontrada',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Error: ${state.error}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: const Text('Ir al inicio'),
          ),
        ],
      ),
    ),
  ),
);
