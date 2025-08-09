import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../data/providers/auth_providers.dart';
import '../data/models/task_model.dart';
import '../providers/task_providers.dart';

class TaskDetailScreen extends ConsumerWidget {
  final TaskModel task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void deleteTask() async {
      final confirmed = await showStyledConfirmationDialog(
        context: context,
        title: 'Delete Task',
        content: 'This action is permanent and cannot be undone.',
      );

      if (confirmed == true) {
        final user = ref.read(authStateChangesProvider).value;
        if (user != null && context.mounted) {
          try {
            await ref.read(taskRepositoryProvider).deleteTask(user.id, task.id);
            context.go('/');
            showStyledSnackBar(context: context, content: 'Task deleted successfully.');
          } catch (e) {
            showStyledSnackBar(context: context, content: 'Error: $e');
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () => context.go('/task/${task.id}/edit', extra: task),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.red),
            onPressed: deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (task.description.isNotEmpty) ...[
              const _SectionHeader(title: 'Description'),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.grey[800]),
              ),
              const SizedBox(height: 24),
            ],
            const _SectionHeader(title: 'Details'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Completed', style: TextStyle(fontWeight: FontWeight.bold)),
                    value: task.isCompleted,
                    onChanged: (isCompleted) async {
                      // ... (update logic is the same)
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Created On'),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(task.createdAt.toDate())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey[600]),
      ),
    );
  }
}