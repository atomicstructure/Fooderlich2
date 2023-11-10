import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../screens/screens.dart';

class AppRouter {
  final AppStateManager appStateManager;
  final ProfileManager profileManager;
  final GroceryManager groceryManager;

  AppRouter(
    this.appStateManager,
    this.profileManager,
    this.groceryManager,
  );
  late final router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: appStateManager,
    initialLocation: '/login',
    routes: [
      // TODO: Add Login Route
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // TODO: Add Onboarding Route
      GoRoute(
          name: 'onboarding',
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen()),
      // TODO: Add Home Route
      GoRoute(
        name: 'home',
// 1
        path: '/:tab',
        builder: (context, state) {
// 2
          final tab = int.parse(state.pathParameters['tab']!);
// 3
          return Home(
            key: state.pageKey,
            currentTab: tab,
          );
        },
// 3
        routes: [
// TODO: Add Item Subroute
          GoRoute(
            name: 'item',
            path: 'item/:id',
            builder: (context, state) {
              final itemId = state.pathParameters['id'] ?? '';
              final item = groceryManager.getGroceryItem(itemId);

              return GroceryItemScreen(
                originalItem: item,
                onCreate: (item) {
                  groceryManager.addItem(item);
                },
                onUpdate: (item) {
                  groceryManager.updateItem(item);
                },
              );
            },
          )
// TODO: Add Profile Subroute
        ],
      ),
    ],
    // TODO: Add Error Handler
    errorPageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: Scaffold(
          body: Center(
            child: Text(
              state.error.toString(),
            ),
          ),
        ),
      );
    },
    // TODO: Add Redirect Handler
    redirect: (context, state) {
      final loggedIn = appStateManager.isLoggedIn;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }
      final isOnboardingComplete = appStateManager.isOnboardingComplete;
      final onboarding = state.matchedLocation == '/onboarding';

      if (!isOnboardingComplete) {
        return onboarding ? null : '/onboarding';
      }

      if (loggingIn || onboarding) return '/${FooderlichTab.explore}';
      return null;
    },
  );
}
