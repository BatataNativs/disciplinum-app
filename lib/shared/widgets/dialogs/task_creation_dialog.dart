import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';

/// Dialog para criação de tarefas de procrastinação
/// Widget reutilizável para gerenciamento de tarefas
class TaskCreationDialog extends StatefulWidget {
  final ProcrastinationTask? task;
  final Function(ProcrastinationTask) onSave;

  const TaskCreationDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _scheduledDate;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _scheduledDate = widget.task?.scheduledDate;
    _startTime = widget.task?.startTime;
    _endTime = widget.task?.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _scheduledDate != null 
                    ? 'Data: ${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                    : 'Sem data',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _scheduledDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _scheduledDate = date);
                }
              },
            ),
            ListTile(
              title: Text(
                _startTime != null 
                    ? 'Início: ${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                    : 'Sem horário de início',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _startTime != null 
                      ? TimeOfDay(hour: _startTime!.hour, minute: _startTime!.minute)
                      : TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _startTime = DateTime(
                      _scheduledDate?.year ?? DateTime.now().year,
                      _scheduledDate?.month ?? DateTime.now().month,
                      _scheduledDate?.day ?? DateTime.now().day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('SALVAR'),
        ),
      ],
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O título é obrigatório')),
      );
      return;
    }

    final task = ProcrastinationTask(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      scheduledDate: _scheduledDate,
      startTime: _startTime,
      endTime: _endTime,
      isCompleted: widget.task?.isCompleted ?? false,
      listId: widget.task?.listId ?? 'default',
      order: widget.task?.order ?? 0,
      repetition: widget.task?.repetition ?? TaskRepetition.none,
      repetitionConfig: widget.task?.repetitionConfig,
      completedUrgencyLevel: widget.task?.completedUrgencyLevel,
    );

    widget.onSave(task);
    Navigator.of(context).pop();
  }
}
