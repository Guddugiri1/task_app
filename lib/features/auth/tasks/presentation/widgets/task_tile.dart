import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/widgets/confirmation_dialog.dart';
import '../../../data/providers/auth_providers.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_providers.dart';

class TaskTile extends ConsumerWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskTile({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCompleted = task.isCompleted;
    final Color statusColor = isCompleted ? Colors.green : Colors.red;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,

      confirmDismiss: (direction) async {
        final confirmed = await showStyledConfirmationDialog(
          context: context,
          title: 'Delete Task',
          content: 'Are you sure you want to permanently delete this task?',
        );

        if (confirmed == true) {
          final user = ref.read(authStateChangesProvider).value;
          if (user != null) {
            try {
              await ref.read(taskRepositoryProvider).deleteTask(user.id, task.id);
              return true;
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting task: $e')),
                );
              }
              return false;
            }
          }
        }
        return false;
      },

      background: Container(
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_sweep_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 20),
          ],
        ),
      ),

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              decoration: TextDecoration.none,
                              color: isCompleted ? Colors.black : Colors.black,
                              fontStyle: isCompleted ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (task.description.isNotEmpty)
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          const Spacer(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.yMMMd().format(task.createdAt.toDate()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Chip(
                                label: Text(
                                  isCompleted ? AppStrings.completed : AppStrings.incomplete,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: statusColor.withOpacity(0.15),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
