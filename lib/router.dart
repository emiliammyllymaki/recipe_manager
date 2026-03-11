import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_edit_screen.dart';
import 'screens/recipe_detail_screen.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();
  static final _shellKey = GlobalKey<NavigatorState>();

  static GoRouter build({required ValueNotifier<int> tabIndex}) {
    return GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/',
      routes: [
        ShellRoute(
          navigatorKey: _shellKey,
          builder: (context, state, child) => ValueListenableBuilder<int>(
            valueListenable: tabIndex,
            builder: (context, idx, _) => AppShell(
              currentIndex: idx,
              onIndexChanged: (i) {
                tabIndex.value = i;
                switch (i) {
                  case 0: context.go('/'); break;
                  case 1: context.go('/stats'); break;
                  case 2: context.go('/settings'); break;
                }
              },
              child: child,
            ),
          ),
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
            GoRoute(
              path: '/stats',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: StatsScreen()),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SettingsScreen()),
            ),
            GoRoute(
              path: '/add',
              builder: (context, state) => const AddEditScreen(),
            ),
            GoRoute(
              path: '/edit/:id',
              builder: (context, state) =>
                  AddEditScreen(id: state.pathParameters['id']),
            ),
            // Path variable :id - required by project spec
            GoRoute(
              path: '/recipe/:id',
              builder: (context, state) =>
                  RecipeDetailScreen(id: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    );
  }
}
