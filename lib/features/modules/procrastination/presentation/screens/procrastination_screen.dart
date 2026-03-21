import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/widgets/progress/my_progress_widgets.dart';
import 'package:disciplinum/shared/widgets/dialogs/task_creation_dialog.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/screens/procrastination_notifications_screen.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/screens/procrastination_stats_screen.dart';
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

  void _showDeleteTaskDialog(ProcrastinationService service, String listId, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await service.removeTaskFromList(listId, taskId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

        // Para o ciclo da gamificação primeiro
        await gamification.stopModuleCycle(nicheId: NicheId.procrastination);
        
        gamification.resetMedals(
          NicheId.procrastination,
          deactivate: true,
          notificationTitle: 'Módulo Desativado 🛑',
          notificationBody:
              'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
        );

        // Força atualização do estado da gamificação
        await ref.read(gamificationServiceProvider).getModuleStatus(NicheId.procrastination);

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
      gamification.startModuleCycle(nicheId: NicheId.procrastination);

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
