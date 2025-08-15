import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_providers.dart';
import '../data/models/task_model.dart';

import '../data/task_repository.dart';
import '../services/firebase_task_service.dart';

// This enum is used for filtering tasks in the main task list screen.
enum TaskFilter { all, completed, incomplete }

// --- CORE SERVICE AND REPOSITORY PROVIDERS ---

final firestoreProvider =
Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseTaskServiceProvider = Provider<FirebaseTaskService>(
        (ref) => FirebaseTaskService(ref.watch(firestoreProvider)));

final taskRepositoryProvider = Provider<TaskRepository>(
        (ref) => TaskRepository(ref.watch(firebaseTaskServiceProvider)));

// --- TASK LIST PROVIDERS ---

/// Provides a real-time stream of all tasks for the currently logged-in user.
/// This is the foundational provider for all task-related data.
final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  // Watches the auth provider to get the current user.
  final user = ref.watch(authStateChangesProvider).value;
  if (user != null) {
    // If a user is logged in, fetch their tasks stream.
    return ref.watch(taskRepositoryProvider).getTasksStream(user.uid);
  }
  // If no user is logged in, return an empty stream.
  return Stream.value([]);
});

/// Manages the current filter state for the task list (e.g., All, Completed).
final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

/// A derived provider that returns a filtered list of tasks based on the current filter state.
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  // Listens to the main tasks stream for its data.
  final tasks = ref.watch(tasksStreamProvider).value ?? [];

  switch (filter) {
    case TaskFilter.completed:
      return tasks.where((task) => task.isCompleted).toList();
    case TaskFilter.incomplete:
      return tasks.where((task) => !task.isCompleted).toList();
    case TaskFilter.all:
    default:
      return tasks;
  }
});

// --- DASHBOARD PROVIDERS ---

/// A data class to hold all the calculated statistics for the dashboard.
class DashboardStats {
  final int todoCount;
  final int doneCount;
  final int overdueCount;
  final List<double> weeklyTasks; // Tasks completed per day for the last 7 days

  DashboardStats({
    this.todoCount = 0,
    this.doneCount = 0,
    this.overdueCount = 0,
    this.weeklyTasks = const [0, 0, 0, 0, 0, 0, 0],
  });

  /// Getter that calculates the total number of tasks.
  int get totalTasks => todoCount + doneCount + overdueCount;

  /// Getter that calculates the total number of incomplete tasks.
  int get incompleteTasks => todoCount + overdueCount;
}

/// The main provider that calculates all dashboard statistics from the tasks stream.
final dashboardProvider = Provider<DashboardStats>((ref) {
  // Listens to the main tasks stream.
  final tasksAsyncValue = ref.watch(tasksStreamProvider);

  // Processes the task data and returns a single DashboardStats object.
  return tasksAsyncValue.when(
    data: (tasks) {
      if (tasks.isEmpty) {
        return DashboardStats(); // Return empty stats if there are no tasks.
      }

      int todo = 0;
      int done = 0;
      int overdue = 0;
      final now = DateTime.now();

      for (var task in tasks) {
        if (task.isCompleted) {
          done++;
        } else {
          // Logic for overdue: created more than 2 days ago and still not completed.
          final taskDate = task.createdAt.toDate();
          if (now.difference(taskDate).inDays > 2) {
            overdue++;
          } else {
            todo++;
          }
        }
      }

      // Calculate weekly progress (tasks completed in the last 7 days).
      List<double> weekly = List.filled(7, 0.0);
      final today = DateTime(now.year, now.month, now.day);
      final completedTasks = tasks.where((t) => t.isCompleted);

      for (var task in completedTasks) {
        final taskCompletionDate = task.createdAt.toDate();
        final completionDay = DateTime(taskCompletionDate.year, taskCompletionDate.month, taskCompletionDate.day);
        final differenceInDays = today.difference(completionDay).inDays;

        if (differenceInDays >= 0 && differenceInDays < 7) {
          weekly[6 - differenceInDays]++;
        }
      }

      return DashboardStats(
        todoCount: todo,
        doneCount: done,
        overdueCount: overdue,
        weeklyTasks: weekly,
      );
    },
    // Return empty stats during loading or error states to prevent UI crashes.
    loading: () => DashboardStats(),
    error: (e, s) => DashboardStats(),
  );
});

/// A derived provider that returns a list of only the overdue tasks.
/// The dashboard UI watches this directly to build the actionable "Overdue" list.
final overdueTasksProvider = Provider<List<TaskModel>>((ref) {
  // Watches the main tasks stream for data.
  final tasks = ref.watch(tasksStreamProvider).value ?? [];
  final now = DateTime.now();

  // Filters the tasks based on the "overdue" logic, ensuring it's consistent
  // with the logic inside the dashboardProvider.
  return tasks.where((task) {
    if (task.isCompleted) return false;
    final taskDate = task.createdAt.toDate();
    return now.difference(taskDate).inDays > 2;
  }).toList();
});