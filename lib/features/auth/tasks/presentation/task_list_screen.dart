import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_app/core/widgets/app_drawer.dart'; // Import your AppDrawer
import 'package:task_app/features/auth/tasks/presentation/widgets/task_filter.dart';
import 'package:task_app/features/auth/tasks/presentation/widgets/task_tile.dart';

import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/task_providers.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

    // --- THIS IS THE FIX ---
    // The entire screen is now wrapped in its own Scaffold to provide the
    // AppBar and the AppDrawer, making it a primary screen.
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        // The leading property is explicitly set to a hamburger menu button.
        // The 'Builder' is important to get the correct context for the drawer.
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open Menu',
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter Tasks',
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      // --- The AppDrawer is now part of this screen ---
      drawer: const AppDrawer(),
      body: tasksAsyncValue.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return _EmptyTasksView(
              icon: Icons.note_add_outlined,
              title: "No Tasks Yet",
              subtitle: "Tap the button in the menu to add your first task!",
            );
          }
          if (filteredTasks.isEmpty) {
            final currentFilter = ref.watch(taskFilterProvider);
            return _EmptyTasksView(
              icon: Icons.filter_list_off_rounded,
              title: 'No Matches Found',
              subtitle: 'There are no tasks that match the filter: "${currentFilter.name.toUpperCase()}".',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tasksStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return _AnimatedTaskTile(
                  key: ValueKey(task.id),
                  child: TaskTile(
                    task: task,
                    onTap: () => context.go('/tasks/task/${task.id}', extra: task),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => AppErrorWidget(message: error.toString()),
      ),
    );
  }
}

// Reusable empty state view
class _EmptyTasksView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyTasksView({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Animated tile wrapper
class _AnimatedTaskTile extends StatefulWidget {
  final Widget child;
  const _AnimatedTaskTile({super.key, required this.child});

  @override
  State<_AnimatedTaskTile> createState() => _AnimatedTaskTileState();
}

class _AnimatedTaskTileState extends State<_AnimatedTaskTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SizeTransition(
        sizeFactor: _animation,
        child: widget.child,
      ),
    );
  }
}