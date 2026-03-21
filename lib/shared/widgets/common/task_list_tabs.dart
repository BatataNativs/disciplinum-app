import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';

/// Widget para as abas horizontais de listas de tarefas
class TaskListTabs extends StatelessWidget {
  final bool isDark;
  final List<TaskList> lists;
  final String selectedListId;
  final Function(String) onListSelected;
  final VoidCallback onCreateList;

  const TaskListTabs({
    super.key,
    required this.isDark,
    required this.lists,
    required this.selectedListId,
    required this.onListSelected,
    required this.onCreateList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
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
                        : (isDark ? Colors.white70 : Colors.black87),
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
