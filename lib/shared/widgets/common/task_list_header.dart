import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';

/// Cabeçalho da lista de tarefas com estatísticas
class TaskListHeader extends StatelessWidget {
  final TaskList list;
  final int totalTasks;
  final int completedTasks;
  final VoidCallback onNotifications;
  final VoidCallback onStats;
  final VoidCallback onAddTask;

  const TaskListHeader({
    super.key,
    required this.list,
    required this.totalTasks,
    required this.completedTasks,
    required this.onNotifications,
    required this.onStats,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedTasks de $totalTasks concluídas',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: const Color(0xFF6366F1)),
                    onPressed: onNotifications,
                    tooltip: 'Notificações',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.bar_chart_rounded, color: const Color(0xFF6366F1)),
                    onPressed: onStats,
                    tooltip: 'Estatísticas',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.add, color: const Color(0xFF6366F1)),
                    onPressed: onAddTask,
                    tooltip: 'Adicionar tarefa',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar Tarefa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
