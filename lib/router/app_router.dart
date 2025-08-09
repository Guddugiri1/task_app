import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/presentation/login_screen.dart';
import '../features/auth/data/presentation/signup_screen.dart';
import '../features/auth/data/providers/auth_providers.dart';
import '../features/auth/tasks/data/models/task_model.dart';
import '../features/auth/tasks/presentation/add_task_screen.dart';
import '../features/auth/tasks/presentation/edit_task_screen.dart';
import '../features/auth/tasks/presentation/task_detail_screen.dart';
import '../features/auth/tasks/presentation/task_list_screen.dart';


final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateProvider = ref.watch(authStateChangesProvider);

  return GoRouter(
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
      GoRoute(
          path: '/',
          builder: (context, state) => const TaskListScreen(),
          routes: [
            GoRoute(
              path: 'add-task',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: const AddTaskScreen(),
                fullscreenDialog: true,
              ),
            ),
            GoRoute(
                path: 'task/:taskId',
                builder: (context, state) {
                  final task = state.extra as TaskModel?;
                  if (task != null) {
                    return TaskDetailScreen(task: task);
                  }
                  return const Scaffold(
                    body: Center(child: Text('Task not found')),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) {
                      final task = state.extra as TaskModel?;
                      if (task != null) {
                        return MaterialPage(
                          key: state.pageKey,
                          child: EditTaskScreen(task: task),
                          fullscreenDialog: true,
                        );
                      }
                      return MaterialPage(
                        key: state.pageKey,
                        child: const Scaffold(
                          body: Center(
                              child: Text('Cannot edit a non-existent task')),
                        ),
                      );
                    },
                  ),
                ]),
          ]),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authStateProvider.value != null;
      final onAuthRoutes =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!loggedIn && !onAuthRoutes) {
        return '/login';
      }

      if (loggedIn && onAuthRoutes) {
        return '/';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateChangesProvider.stream)),
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