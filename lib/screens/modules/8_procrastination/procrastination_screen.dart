import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:disciplinum/models/8_procrastination/procrastination_model.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/services/8_procrastination/procrastination_service.dart';
import 'package:disciplinum/widgets/niche_details/niche_header.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';

class ProcrastinationScreen extends StatefulWidget {
  final String heroTag;

  const ProcrastinationScreen({
    super.key,
    required this.heroTag,
  });

  @override
  State<ProcrastinationScreen> createState() => _ProcrastinationScreenState();
}

class _ProcrastinationScreenState extends State<ProcrastinationScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _ativarModulo() async {
    setState(() => _isLoading = true);
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.startModuleCycle(nicheId: NicheId.procrastination);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _desativarModulo() async {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Desativar módulo?"),
        content: const Text(
          "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado.\n\n"
          "Deseja continuar?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sim, desativar e zerar"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      gamification.resetMedals(
        NicheId.procrastination,
        notificationTitle: 'Módulo Desativado',
        notificationBody: 'Seu progresso foi zerado e o módulo desativado.',
        deactivate: true,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ProcrastinationService>(context);
    final gamification = Provider.of<GamificationService>(context);
    final isActive = gamification.isModuleActive(NicheId.procrastination);

    final tasks = service.getTasksForDay(_selectedDay);
    final dayStatus = service.getDay(_selectedDay);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Obter objeto Niche
    final niche = NicheRepository.getById(NicheId.procrastination);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Custom com Back e Desativar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  if (isActive)
                    TextButton.icon(
                      onPressed: _desativarModulo,
                      icon: const Icon(Icons.power_settings_new,
                          color: Colors.redAccent, size: 18),
                      label: const Text('Desativar módulo',
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 13)),
                    ),
                ],
              ),
            ),

            if (!isActive)
              _buildInactiveState(niche, isDark)
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Padrão (Ícone)
                      NicheHeader(
                        niche: niche,
                        showBackground: false,
                        heroTag: widget.heroTag,
                      ),

                      // Calendário
                      _buildCalendar(service, isDark),

                      const SizedBox(height: 16),

                      // Resumo do Dia
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat("d 'de' MMMM", 'pt_BR')
                                  .format(_selectedDay),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (tasks.isNotEmpty)
                              _buildDayStatusBadge(dayStatus),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Lista de Tarefas
                      if (tasks.isEmpty) _buildEmptyState(isDark),

                      if (tasks.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return _buildTaskTile(task, service, isDark);
                          },
                        ),

                      if (tasks.any((t) => t.isCompleted))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () =>
                                  service.clearCompletedTasks(_selectedDay),
                              icon: const Icon(Icons.delete_sweep_outlined,
                                  color: Colors.redAccent, size: 20),
                              label: const Text('Excluir concluídos',
                                  style: TextStyle(color: Colors.redAccent)),
                            ),
                          ),
                        ),

                      const SizedBox(height: 80), // Espaço para FAB
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: isActive
          ? FloatingActionButton.extended(
              heroTag: 'add_task_fab',
              onPressed: () => _showAddTaskModal(context, service),
              label: const Text('Nova Tarefa'),
              icon: const Icon(Icons.add_task),
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInactiveState(Niche niche, bool isDark) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: widget.heroTag,
              child: Image.asset(niche.iconPath, height: 120),
            ),
            const SizedBox(height: 32),
            Text(
              niche.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Pequenas tarefas geram grandes mudanças. Organize seu dia e vença a procrastinação.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            GlowingButton(
              text: 'ATIVAR MÓDULO',
              onPressed: _ativarModulo,
              color: const Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayStatusBadge(ProcrastinationDay? day) {
    if (day == null) return const SizedBox();

    if (day.isDayComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: const Text('COMPLETO 🏆',
            style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      );
    } else if (day.isDayFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: const Text('PENDENTE ⚠️',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
      );
    }

    return const SizedBox();
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(Icons.event_note,
              size: 48, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa para este dia.',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ProcrastinationService service, bool isDark) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TableCalendar(
          locale: 'pt_BR',
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Mês',
            CalendarFormat.twoWeeks: '2 Semanas',
            CalendarFormat.week: 'Semana',
          },
          headerStyle: HeaderStyle(
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.5)),
            ),
            formatButtonTextStyle: const TextStyle(
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.bold,
            ),
            titleCentered: true,
          ),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() => _calendarFormat = format);
            }
          },
          onHeaderTapped: (focusedDay) async {
            final picked = await showDatePicker(
              context: context,
              initialDate: focusedDay,
              firstDate: DateTime.utc(2024, 1, 1),
              lastDate: DateTime.utc(2030, 12, 31),
              helpText: 'Selecionar Mês/Ano',
              cancelText: 'Cancelar',
              confirmText: 'Selecionar',
            );
            if (picked != null) {
              setState(() {
                _focusedDay = picked;
                _selectedDay = picked;
              });
            }
          },
          onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          calendarStyle: CalendarStyle(
            markerDecoration: const BoxDecoration(
                color: Color(0xFF6366F1), shape: BoxShape.circle),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          eventLoader: (day) {
            final tasks = service.getTasksForDay(day);
            return tasks.isNotEmpty ? [true] : [];
          },
        ),
      ),
    );
  }

  Widget _buildTaskTile(
      ProcrastinationTask task, ProcrastinationService service, bool isDark) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('Remover tarefa?'),
                  content: const Text('Esta ação não pode ser desfeita.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Remover',
                            style: TextStyle(color: Colors.red))),
                  ],
                ));
      },
      onDismissed: (_) {
        service.removeTask(_selectedDay, task.id);
      },
      child: Container(
        decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: task.isCompleted
                    ? Colors.green.withValues(alpha: 0.5)
                    : (isDark ? Colors.white12 : Colors.grey[300]!)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ]),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: Colors.green,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              final updated = task.copyWith(isCompleted: val);
              service.updateTask(_selectedDay, updated);

              // Feedback visual imediato e possível validação de dia
              // A validação completa pode ser feita aqui se quisermos feedback instantaneo
              if (val == true) {
                service.checkDayCompletion(_selectedDay);
              }
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? (isDark ? Colors.white38 : Colors.black38)
                    : (isDark ? Colors.white : Colors.black87),
                fontWeight: FontWeight.w600),
          ),
          subtitle: task.description != null
              ? Text(task.description!,
                  maxLines: 2, overflow: TextOverflow.ellipsis)
              : null,
          trailing: (task.startTime != null || task.endTime != null)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (task.startTime != null)
                      Text(
                        DateFormat('HH:mm').format(task.startTime!),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    if (task.endTime != null && task.startTime != null)
                      Text(
                        'até ${DateFormat('HH:mm').format(task.endTime!)}',
                        style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white38 : Colors.black38),
                      )
                    else if (task.endTime != null)
                      Text(
                        DateFormat('HH:mm').format(task.endTime!),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87),
                      ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context, ProcrastinationService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _AddTaskModal(selectedDay: _selectedDay, service: service),
    );
  }
}

class _AddTaskModal extends StatefulWidget {
  final DateTime selectedDay;
  final ProcrastinationService service;

  const _AddTaskModal({required this.selectedDay, required this.service});

  @override
  State<_AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<_AddTaskModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nova Tarefa',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Título da tarefa',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(
                        _startTime?.format(context) ?? 'Início (Opcional)'),
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (t != null) setState(() => _startTime = t);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time_filled),
                    label: Text(_endTime?.format(context) ?? 'Fim (Opcional)'),
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (t != null) setState(() => _endTime = t);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Adicionar Tarefa',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    final now = widget.selectedDay;
    DateTime? startDt;
    DateTime? endDt;

    if (_startTime != null) {
      startDt = DateTime(
          now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
    }
    if (_endTime != null) {
      endDt = DateTime(
          now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);
    }

    final task = ProcrastinationTask(
      id: Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      startTime: startDt,
      endTime: endDt,
    );

    widget.service.addTask(widget.selectedDay, task);
    Navigator.pop(context);
  }
}
