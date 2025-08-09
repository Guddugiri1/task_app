import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_providers.dart';
import '../data/models/task_model.dart';
import '../data/task_repository.dart';
import '../services/firebase_task_service.dart';

enum TaskFilter { all, completed, incomplete }

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseTaskServiceProvider = Provider<FirebaseTaskService>(
        (ref) => FirebaseTaskService(ref.watch(firestoreProvider)));

final taskRepositoryProvider = Provider<TaskRepository>(
        (ref) => TaskRepository(ref.watch(firebaseTaskServiceProvider)));

final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user != null) {
    return ref.watch(taskRepositoryProvider).getTasksStream(user.id);
  }
  return Stream.value([]);
});

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final filter = ref.watch(taskFilterProvider);
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