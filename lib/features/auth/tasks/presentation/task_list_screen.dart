import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_app/features/auth/tasks/presentation/widgets/task_filter.dart';
import 'package:task_app/features/auth/tasks/presentation/widgets/task_tile.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/providers/auth_providers.dart';
import '../providers/task_providers.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FilterOptionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksStreamProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(taskFilterProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          tooltip: 'Filter Tasks',
          onPressed: () => _showFilterSheet(context),
        ),
        centerTitle: true,
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: tasksAsyncValue.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("You're all caught up!", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Text("Press '+' to add a new task.", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }
                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_off_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No matches found', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Text('There are no "${currentFilter.name}" tasks.', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  children: filteredTasks.map((task) => TaskTile(
                    task: task,
                    onTap: () => context.go('/task/${task.id}', extra: task),
                  )).toList(),
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => AppErrorWidget(message: error.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-task'),
        tooltip: AppStrings.addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}