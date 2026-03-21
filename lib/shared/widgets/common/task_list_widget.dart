import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';

typedef Task = ProcrastinationTask;

/// Widget para exibir a lista de tarefas com drag and drop
class TaskListWidget extends StatelessWidget {
  final bool isDark;
  final List<Task> tasks;
  final Function(Task) onTaskToggle;
  final Function(Task) onTaskEdit;
  final Function(Task) onTaskDelete;
  final VoidCallback onAddTask;

  const TaskListWidget({
    super.key,
    required this.isDark,
    required this.tasks,
    required this.onTaskToggle,
    required this.onTaskEdit,
    required this.onTaskDelete,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      onReorder: _onReorder,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskTile(task, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 64,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma tarefa ainda',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione sua primeira tarefa para começar',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Tarefa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile(Task task, int index) {
    return Card(
      key: ValueKey(task.id),
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.description?.isNotEmpty == true
            ? Text(
                task.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) => onTaskToggle(task),
              activeColor: const Color(0xFF6366F1),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onTaskEdit(task);
                    break;
                  case 'delete':
                    onTaskDelete(task);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Excluir', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    // Implementar reordenação se necessário
    // Por enquanto, não fazemos nada
  }
}
