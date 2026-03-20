import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:intl/intl.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/widgets/progress/my_progress_widgets.dart';
import 'package:disciplinum/shared/widgets/dialogs/task_creation_dialog.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/screens/procrastination_notifications_screen.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/screens/procrastination_stats_screen.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/shared/widgets/buttons/niche_action_button.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';

class ProcrastinationScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  final int initialTabIndex;

  const ProcrastinationScreen({
    super.key,
    this.heroTag,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<ProcrastinationScreen> createState() => _ProcrastinationScreenState();
}

class _ProcrastinationScreenState extends ConsumerState<ProcrastinationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedListId = 'default';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = ref.watch(procrastinationServiceProvider);
    final gamification = ref.watch(gamificationServiceProvider);
    final isActive = gamification.isModuleActive(NicheId.procrastination);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
              isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Evitar Procrastinação',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Segmented Control (2 opcoes)
              _buildSegmentedControl(isDark),

              // Conteudo
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHowItWorks(isDark),
                    _buildTasksView(isDark, service, isActive),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black45,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Como funciona'),
            Tab(text: 'Evitar procrastinação'),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            NicheInfoCard(
              isDark: isDark,
                  icon: Icons.checklist_rounded,
                  title: 'Nova Tarefa: organize sua rotina',
                  content:
                      'Crie listas e adicione tarefas. O app usa Urgencia Dinamica para mostrar prazos.',
                ),
                const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
                  icon: Icons.notifications_outlined,
                  title: 'Notificacoes: configure lembretes',
                  content: 'Defina horario para manter sua disciplina.',
                ),
                const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
                  icon: Icons.bar_chart_rounded,
                  title: 'Estatisticas: veja sua produtividade',
                  content:
                      'Acompanhe seu Perfil de Execucao ao completar suas tarefas.',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: NicheActionButton(
              icon: Icons.rocket_launch_rounded,
              label: 'Comecar',
              color: const Color(0xFF6366F1),
              isDark: isDark,
              onTap: () {
                _tabController.animateTo(1);
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildTasksView(
      bool isDark, ProcrastinationService service, bool isActive) {
    final lists = service.getAllLists();
    final currentList = lists.firstWhere(
      (l) => l.id == _selectedListId,
      orElse: () => lists.isNotEmpty
          ? lists.first
          : TaskList(
              id: 'default', name: 'Nome da lista', createdAt: DateTime.now()),
    );

    return Column(
      children: [
        _buildListTabs(isDark, service, lists),
        _buildListHeader(isDark, service, currentList, lists),
        Expanded(
          child: _buildTaskList(isDark, service, currentList),
        ),
        _buildBottomButtons(isDark, service, isActive),
      ],
    );
  }

  Widget _buildListTabs(
      bool isDark, ProcrastinationService service, List<TaskList> lists) {
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
                onPressed: () => _showCreateListDialog(service),
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
          final isSelected = list.id == _selectedListId;

          return RepaintBoundary(
            child: GestureDetector(
              onTap: () => setState(() => _selectedListId = list.id),
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
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF6366F1))
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListHeader(bool isDark, ProcrastinationService service,
      TaskList currentList, List<TaskList> lists) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showRenameListDialog(service, currentList),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        currentList.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<SortMode>(
            icon: Icon(
              Icons.swap_vert,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            onSelected: (mode) {
              service.setListSortMode(currentList.id, mode);
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: SortMode.custom,
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 18,
                      color: currentList.sortMode == SortMode.custom
                          ? const Color(0xFF6366F1)
                          : Colors.transparent,
                    ),
                    const SizedBox(width: 8),
                    const Text('Personalizado'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortMode.date,
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 18,
                      color: currentList.sortMode == SortMode.date
                          ? const Color(0xFF6366F1)
                          : Colors.transparent,
                    ),
                    const SizedBox(width: 8),
                    const Text('Data'),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            onSelected: (action) {
              if (action == 'delete_all') {
                _showDeleteAllTasksDialog(service, currentList.id);
              } else if (action == 'delete_list') {
                _showDeleteListDialog(service, currentList.id);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 18),
                    SizedBox(width: 8),
                    Text('Excluir todas as tarefas'),
                  ],
                ),
              ),
              if (lists.length > 1)
                const PopupMenuItem(
                  value: 'delete_list',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Excluir lista',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
      bool isDark, ProcrastinationService service, TaskList currentList) {
    final sortMode = service.getListSortMode(currentList.id);

    if (sortMode == SortMode.date) {
      return _buildGroupedTaskList(isDark, service, currentList.id);
    }

    final tasks = service.getTasksForList(currentList.id);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma tarefa ainda',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque em "Nova Tarefa" para adicionar',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ),
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tasks.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          final taskIds = tasks.map((t) => t.id).toList();
          final item = taskIds.removeAt(oldIndex);
          taskIds.insert(newIndex, item);
          service.reorderTasks(currentList.id, taskIds);
        },
        itemBuilder: (ctx, index) {
          final task = tasks[index];
          return _buildTaskTile(
            key: ValueKey(task.id),
            isDark: isDark,
            task: task,
            service: service,
            listId: currentList.id,
          );
        },
      ),
    );
  }

  Widget _buildGroupedTaskList(
      bool isDark, ProcrastinationService service, String listId) {
    final grouped = service.getTasksGroupedByDate(listId);

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma tarefa ainda',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    final sortedDates = grouped.keys.toList()..sort();

    return RepaintBoundary(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sortedDates.length,
        itemBuilder: (ctx, index) {
          final date = sortedDates[index];
          final tasks = grouped[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  _formatDateHeader(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              ...tasks.map((task) => _buildTaskTile(
                    key: ValueKey(task.id),
                    isDark: isDark,
                    task: task,
                    service: service,
                    listId: listId,
                  )),
            ],
          );
        },
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoje';
    } else if (dateOnly == tomorrow) {
      return 'Amanha';
    } else {
      return DateFormat("d 'de' MMMM", 'pt_BR').format(date);
    }
  }

  Widget _buildTaskTile({
    required Key key,
    required bool isDark,
    required ProcrastinationTask task,
    required ProcrastinationService service,
    required String listId,
  }) {
    final now = DateTime.now();
    final urgency = task.isCompleted
        ? (task.completedUrgencyLevel ?? UrgencyLevel.green)
        : (task.startTime != null || task.endTime != null
            ? task.getUrgencyLevel(now)
            : (task.scheduledDate != null
                ? ProcrastinationTask.getUrgencyForDate(
                    task.scheduledDate!, now)
                : UrgencyLevel.green));

    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? Colors.transparent
              : urgency.color.withValues(alpha: 0.6),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TaskCreationDialog(
              task: task,
              onSave: (newTask) {
                if (task.id.isEmpty) {
                  // Nova tarefa
                  service.addTaskToList(listId, newTask);
                } else {
                  // Atualizar tarefa existente
                  service.updateTaskInList(listId, newTask);
                }
              },
            ),
          );
        },
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            service.toggleTaskInList(listId, task.id);
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? const Color(0xFF6366F1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: task.isCompleted
                    ? const Color(0xFF6366F1)
                    : (isDark ? Colors.white38 : Colors.black26),
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: task.isCompleted
                ? (isDark ? Colors.white38 : Colors.black38)
                : (isDark ? Colors.white : Colors.black87),
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: _buildTaskSubtitle(task, isDark),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            size: 20,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          onSelected: (action) {
            if (action == 'edit') {
              showDialog(
                context: context,
                builder: (context) => TaskCreationDialog(
                  task: task,
                  onSave: (newTask) {
                    // Atualizar tarefa existente
                    service.updateTaskInList(listId, newTask);
                  },
                ),
              );
            } else if (action == 'delete') {
              _showDeleteTaskDialog(service, listId, task.id);
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  const SizedBox(width: 8),
                  const Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildTaskSubtitle(ProcrastinationTask task, bool isDark) {
    final parts = <String>[];

    if (task.scheduledDate != null) {
      parts.add(DateFormat('dd/MM/yyyy').format(task.scheduledDate!));
    }

    if (task.startTime != null && task.endTime != null) {
      final start = DateFormat('HH:mm').format(task.startTime!);
      final end = DateFormat('HH:mm').format(task.endTime!);
      parts.add('$start - $end');
    } else if (task.startTime != null) {
      parts.add(DateFormat('HH:mm').format(task.startTime!));
    }

    if (parts.isEmpty) return null;

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 14,
          color: const Color(0xFF6366F1).withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          parts.join(' - '),
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF6366F1).withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(
      bool isDark, ProcrastinationService service, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: NicheActionButton(
                  icon: Icons.add,
                  label: 'Nova Tarefa',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => TaskCreationDialog(
                        onSave: (newTask) {
                          // Nova tarefa - adiciona à lista atual
                          service.addTaskToList(_selectedListId, newTask);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NicheActionButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificacoes',
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ProcrastinationNotificationsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NicheActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatisticas',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _showStatisticsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NicheActionButton(
                  icon: isActive ? Icons.power_settings_new : Icons.power_off,
                  label: isActive ? 'Desativar modulo' : 'Ativar modulo',
                  color: isActive ? Colors.red : Colors.green,
                  isDark: isDark,
                  isDestructive: isActive,
                  onTap: () => _toggleModule(isActive),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showCreateListDialog(ProcrastinationService service) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        title: const Text('Nova lista'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nome da lista',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await service.createList(controller.text.trim());
                final lists = service.getAllLists();
                if (!ctx.mounted) return;
                setState(() {
                  _selectedListId = lists.last.id;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showRenameListDialog(ProcrastinationService service, TaskList list) {
    final controller = TextEditingController(text: list.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        title: const Text('Renomear lista'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nome da lista',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await service.renameList(list.id, controller.text.trim());
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllTasksDialog(
      ProcrastinationService service, String listId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir todas as tarefas?'),
        content: const Text(
            'Esta ação removerá todas as tarefas desta lista. Não é possível desfazer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await service.deleteAllTasksFromList(listId);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteListDialog(ProcrastinationService service, String listId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir lista?'),
        content: const Text(
            'Esta ação removerá a lista e todas as suas tarefas. Não é possível desfazer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await service.deleteList(listId);
              final lists = service.getAllLists();
              if (!ctx.mounted) return;
              setState(() {
                _selectedListId = lists.isNotEmpty ? lists.first.id : 'default';
              });
              Navigator.pop(ctx);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteTaskDialog(
      ProcrastinationService service, String listId, String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await service.removeTaskFromList(listId, taskId);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleModule(bool isActive) async {
    final gamification = ref.read(gamificationServiceProvider);

    if (isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Desativar modulo?'),
          content: const Text(
              'Ao desativar, seu progresso de medalhas será pausado. Deseja continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sim, desativar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        if (!mounted) return;
        HapticFeedback.heavyImpact();

        gamification.stopModuleCycle(nicheId: NicheId.procrastination);
        gamification.resetMedals(
          NicheId.procrastination,
          deactivate: true,
          notificationTitle: 'Módulo Desativado 🛑',
          notificationBody:
              'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
        );
        _tabController.animateTo(0);

        if (mounted) {
          SnackBarHelper.showWarning(context, 'Módulo desativado');
        }
      }
    } else {
      HapticFeedback.mediumImpact();
      if (!mounted) return;

      bool granted = await NotificationService.requestPermission();
      if (!mounted) return;

      if (granted) {
        HapticFeedback.heavyImpact();
        ref.read(cloudSyncServiceProvider).saveModuleStatus(
          nicheId: NicheId.procrastination,
          isActive: true,
        );
        gamification.startModuleCycle(nicheId: NicheId.procrastination);

        SnackBarHelper.showSuccess(context, 'Módulo de Procrastinação ativado!');
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text(
              'Para o módulo de Procrastinação funcionar, habilite as notificações do app nas configurações.',
            ),
            actions: [
              TextButton(
                child: const Text('Abrir configurações'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  NotificationService.openNotificationSettings();
                },
              ),
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  void _showStatisticsMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas e Opções',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.auto_graph_rounded,
              label: 'Nivel de desprocrastinação',
              color: const Color(0xFF6366F1),
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProcrastinationStatsScreen(),
                  ),
                );
              },
            ),
            ListActionTile(
              icon: Icons.bar_chart_rounded,
              label: 'Conquistas',
              color: Colors.blue,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyProgressProcrastination(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
