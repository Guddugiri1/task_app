import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:task_app/features/lumo_ai/presentation/lumo_ai_screen.dart'; // Import the new screen
import 'package:task_app/features/profile/presentation/profile_screen.dart';
import 'package:task_app/router/shell_screen.dart';
import '../features/auth/data/presentation/login_screen.dart';
import '../features/auth/data/presentation/signup_screen.dart';
import '../features/auth/data/providers/auth_providers.dart';
import '../features/auth/tasks/data/models/task_model.dart';
import '../features/auth/tasks/presentation/add_task_screen.dart';
import '../features/auth/tasks/presentation/edit_task_screen.dart';
import '../features/auth/tasks/presentation/task_detail_screen.dart';
import '../features/auth/tasks/presentation/task_list_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      // --- THE SHELL ROUTE IS RECONFIGURED ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard (Primary)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Branch 1: LUMO AI (Center)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lumo-ai',
                builder: (context, state) => const LumoAiScreen(),
              ),
            ],
          ),
          // Branch 2: Profile (Last)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // --- TASK-RELATED ROUTES ARE NOW TOP-LEVEL ---
      // This allows them to be pushed on top of the shell UI from the AppDrawer.
      GoRoute(
        path: '/tasks',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TaskListScreen(),
        routes: [
          GoRoute(
            path: 'task/:taskId',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final task = state.extra as TaskModel?;
              if (task != null) return TaskDetailScreen(task: task);
              return const Scaffold(body: Center(child: Text('Task not found')));
            },
            routes: [
              GoRoute(
                path: 'edit',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final task = state.extra as TaskModel?;
                  return MaterialPage(
                    key: state.pageKey,
                    fullscreenDialog: true,
                    child: task != null
                        ? EditTaskScreen(task: task)
                        : const Scaffold(body: Center(child: Text('Cannot edit task'))),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/add-task',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          fullscreenDialog: true,
          child: const AddTaskScreen(),
        ),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final onAuthRoutes = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!isLoggedIn && !onAuthRoutes) {
        return '/login';
      }
      if (isLoggedIn && onAuthRoutes) {
        // Redirect logged-in users to the Dashboard by default.
        return '/dashboard';
      }
      return null;
    },
    refreshListenable:
    GoRouterRefreshStream(ref.watch(authStateChangesProvider.stream)),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}