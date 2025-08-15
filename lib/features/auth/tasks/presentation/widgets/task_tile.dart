import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../../core/widgets/confirmation_dialog.dart';
import '../../../data/providers/auth_providers.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_providers.dart';

class TaskTile extends ConsumerWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskTile({super.key, required this.task, required this.onTap});

  /// Handles the logic for showing a confirmation dialog and deleting the task.
  Future<bool> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showStyledConfirmationDialog(
      context: context,
      title: 'Delete Task',
      content: 'Are you sure you want to permanently delete this task?',
    );

    if (confirmed != true) return false;

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return false;

    try {
      await ref.read(taskRepositoryProvider).deleteTask(user.uid, task.id);
      return true;
    } catch (e) {
      if (context.mounted) {
        showStyledSnackBar(
          context: context,
          content: 'Error deleting task: $e',
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isCompleted = task.isCompleted;
    final Color statusColor = isCompleted ? Colors.green : Colors.redAccent;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _showDeleteConfirmation(context, ref),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_sweep_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                            // --- THIS IS THE FIX ---
                            // The 'decoration' property has been removed to get rid
                            // of the strikethrough. The color change is kept as a
                            // clear visual indicator of a completed task.
                            style: textTheme.titleLarge?.copyWith(
                              color: isCompleted ? Colors.grey[600] : null,
                            ),
                          ),
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                          const Spacer(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat.yMMMd().format(task.createdAt.toDate()),
                                style: textTheme.bodySmall,
                              ),
                              const Spacer(),
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