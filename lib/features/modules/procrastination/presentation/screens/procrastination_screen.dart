import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/presentation/providers/procrastination_gamification_provider.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/widgets/dialogs/task_creation_dialog.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/screens/procrastination_notifications_screen.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/screens/procrastination_stats_screen.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/widgets/my_progress_procrastination.dart' as procrastination_progress;
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/shared/widgets/common/module_screen_header.dart';
import 'package:disciplinum/shared/widgets/common/custom_segmented_control.dart';
import 'package:disciplinum/shared/widgets/common/how_it_works_section.dart';
import 'package:disciplinum/shared/widgets/common/task_list_tabs.dart';
import 'package:disciplinum/shared/widgets/common/task_list_header.dart';
import 'package:disciplinum/shared/widgets/common/task_list_widget.dart';
import 'package:disciplinum/shared/widgets/shared_widgets.dart';

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
    // Usando provider local do Procrastination
    final procrastinationState = ref.watch(procrastinationControllerIsarProvider);
    final isActive = procrastinationState.config?.isEnabled ?? false;

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
              ModuleScreenHeader(
                title: 'Evitar Procrastinação',
              ),

              // Segmented Control (2 opcoes)
              CustomSegmentedControl(
                controller: _tabController,
                tabs: const ['Como funciona', 'Evitar procrastinação'],
                isDark: isDark,
              ),

              // Conteudo
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    HowItWorksSection(
                      isDark: isDark,
                      onGetStarted: () => _tabController.animateTo(1),
                      infoCards: const [
                        InfoCardData(
                          icon: Icons.checklist_rounded,
                          title: 'Nova Tarefa: organize sua rotina',
                          content: 'Crie listas e adicione tarefas. O app usa Urgencia Dinamica para mostrar prazos.',
                        ),
                        InfoCardData(
                          icon: Icons.notifications_outlined,
                          title: 'Notificações: configure lembretes',
                          content: 'Defina horario para manter sua disciplina.',
                        ),
                        InfoCardData(
                          icon: Icons.bar_chart_rounded,
                          title: 'Estatísticas: veja sua produtividade',
                          content: 'Acompanhe seu Perfil de Execucao ao completar suas tarefas.',
                        ),
                      ],
                    ),
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

  Widget _buildTasksView(bool isDark, ProcrastinationService service, bool isActive) {
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
        TaskListTabs(
          isDark: isDark,
          lists: lists,
          selectedListId: _selectedListId,
          onListSelected: (listId) => setState(() => _selectedListId = listId),
          onCreateList: () => _showCreateListDialog(service),
        ),
        TaskListHeader(
          isDark: isDark,
          list: currentList,
          totalTasks: service.getTasksForList(currentList.id).length,
          completedTasks: service.getTasksForList(currentList.id).where((t) => t.isCompleted).length,
          onNotifications: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProcrastinationNotificationsScreen(),
            ),
          ),
          onStats: () => _showStatisticsMenu(),
          onAddTask: () => _showCreateTaskDialog(service, currentList),
        ),
        Expanded(
          child: TaskListWidget(
            isDark: isDark,
            tasks: service.getTasksForList(currentList.id),
            onTaskToggle: (task) => service.toggleTaskInList(currentList.id, task.id),
            onTaskEdit: (task) => _showEditTaskDialog(service, currentList.id, task),
            onTaskDelete: (task) => _showDeleteTaskDialog(service, currentList.id, task.id),
            onAddTask: () => _showCreateTaskDialog(service, currentList),
          ),
        ),
        _buildBottomButtons(isDark, service, isActive),
      ],
    );
  }

  void _showCreateTaskDialog(ProcrastinationService service, TaskList list) {
    showDialog(
      context: context,
      builder: (context) => TaskCreationDialog(
        onSave: (task) => service.addTaskToList(list.id, task),
      ),
    );
  }

  void _showEditTaskDialog(ProcrastinationService service, String listId, ProcrastinationTask task) {
    showDialog(
      context: context,
      builder: (context) => TaskCreationDialog(
        task: task,
        onSave: (updatedTask) => service.updateTaskInList(listId, updatedTask),
      ),
    );
  }

  void _showDeleteTaskDialog(ProcrastinationService service, String listId, String taskId) async {
    final shouldDelete = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir tarefa',
      content: 'Tem certeza que deseja excluir esta tarefa?',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      isDangerous: true,
    ) ?? false;

    if (!shouldDelete) return;

    await service.removeTaskFromList(listId, taskId);
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
                child: ModernStartButton(
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
                child: ModernStartButton(
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
                child: ModernStartButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatisticas',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _showStatisticsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: isActive ? Icons.power_settings_new : Icons.power_off,
                  label: isActive ? 'Desativar modulo' : 'Ativar modulo',
                  color: isActive ? Colors.red : Colors.green,
                  isDark: isDark,
                  onTap: () => _toggleModule(isActive),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showCreateListDialog(ProcrastinationService service) async {
    final controller = TextEditingController();
    
    final result = await AppDialog.showCustom<bool>(
      context: context,
      title: 'Nova lista',
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
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Criar'),
        ),
      ],
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      await service.createList(controller.text.trim());
      final lists = service.getAllLists();
      if (mounted) {
        setState(() {
          _selectedListId = lists.last.id;
        });
      }
    }
  }


  Future<void> _toggleModule(bool isActive) async {
    // Usar provider local do Procrastination
    final notifier = ref.read(procrastinationGamificationNotifierProvider.notifier);

    if (isActive) {
      final confirmed = await AppDialog.showConfirmation(
        context: context,
        title: 'Desativar módulo?',
        content: 'Ao desativar, seu progresso de medalhas será pausado. Deseja continuar?',
        confirmText: 'Sim, desativar',
        cancelText: 'Cancelar',
        isDangerous: true,
      );

      if (confirmed == true) {
        if (!mounted) return;
        HapticFeedback.heavyImpact();

        // Desativar via notifier local
        await notifier.deactivateModule();

        setState(() {
          // O estado será atualizado automaticamente pelo gamification.isModuleActive() no build
        });
        
        _tabController.animateTo(0);

        if (mounted) {
          SnackBarHelper.showWarning(context, 'Módulo desativado');
        }
      }
    } else {
      HapticFeedback.mediumImpact();
      if (!mounted) return;

      // Usar o novo sistema de permissões unificado
      await PermissionService.ensurePermissions(context, nicheId: NicheId.procrastination);
      if (!mounted) return;

      // Procrastination não precisa de acessibilidade/sobreposição, apenas notificação
      // Verificar se tem permissão de notificação
      bool notificationGranted = await NotificationService.requestPermission();
      if (!mounted) return;

      if (!notificationGranted) {
        if (mounted) {
          SnackBarHelper.showWarning(context, 'Permissão de notificação necessária para funcionar.');
        }
        return;
      }

      HapticFeedback.heavyImpact();
      ref.read(cloudSyncServiceProvider).saveModuleStatus(
        nicheId: NicheId.procrastination,
        isActive: true,
      );
      // Ativar via notifier local
      await notifier.activateModule();

      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Módulo de Procrastinação ativado!');
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
                    builder: (_) => const procrastination_progress.MyProgressProcrastination(),
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
