import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';

/// Cabeçalho da lista de tarefas com estatísticas
class TaskListHeader extends StatelessWidget {
  final bool isDark;
  final TaskList list;
  final int totalTasks;
  final int completedTasks;
  final VoidCallback onNotifications;
  final VoidCallback onStats;
  final VoidCallback onAddTask;

  const TaskListHeader({
    super.key,
    required this.isDark,
    required this.list,
    required this.totalTasks,
    required this.completedTasks,
    required this.onNotifications,
    required this.onStats,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
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
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedTasks de $totalTasks concluídas',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListActionTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notificações',
                    color: const Color(0xFF6366F1),
                    onTap: onNotifications,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  ListActionTile(
                    icon: Icons.bar_chart_rounded,
                    label: 'Estatísticas',
                    color: const Color(0xFF6366F1),
                    onTap: onStats,
                    isDark: isDark,
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
