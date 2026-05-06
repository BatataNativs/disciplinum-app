import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';

/// Widget para as abas horizontais de listas de tarefas
class TaskListTabs extends StatelessWidget {
  final List<TaskList> lists;
  final String selectedListId;
  final Function(String) onListSelected;
  final VoidCallback onCreateList;

  const TaskListTabs({
    super.key,
    required this.lists,
    required this.selectedListId,
    required this.onListSelected,
    required this.onCreateList,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: lists.length + 1,
        itemBuilder: (ctx, index) {
          if (index == lists.length) {
            return Center(
              child: TextButton.icon(
                onPressed: onCreateList,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nova Lista'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            );
          }

          final list = lists[index];
          final isSelected = list.id == selectedListId;

          return RepaintBoundary(
            child: GestureDetector(
              onTap: () => onListSelected(list.id),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  list.name,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
