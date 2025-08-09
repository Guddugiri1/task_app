import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_providers.dart';

class FilterOptionsBottomSheet extends ConsumerWidget {
  const FilterOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(taskFilterProvider);

    Widget buildFilterTile(TaskFilter filter, String title, IconData icon) {
      final isSelected = currentFilter == filter;

      return ListTile(
        leading: Icon(icon,
            color: isSelected ? Theme.of(context).primaryColor : null),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_rounded, color: Theme.of(context).primaryColor)
            : null,
        onTap: () {
          ref.read(taskFilterProvider.notifier).state = filter;
          // Close the bottom sheet
          Navigator.of(context).pop();
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Tasks',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          buildFilterTile(TaskFilter.all, 'All Tasks', Icons.all_inbox_rounded),
          const Divider(),
          buildFilterTile(
              TaskFilter.completed, 'Completed', Icons.check_circle_rounded),
          const Divider(),
          buildFilterTile(TaskFilter.incomplete, 'Incomplete',
              Icons.pending_actions_rounded),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}