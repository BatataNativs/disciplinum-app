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
import 'package:disciplinum/widgets/niche_details/niche_info_section.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/widgets/8_procrastination/my_progress_procrastination.dart';
import 'package:disciplinum/screens/modules/8_procrastination/procrastination_notifications_screen.dart';
import 'package:flutter/services.dart';

class ProcrastinationScreen extends StatefulWidget {
  final String heroTag;
  final int initialTabIndex;

  const ProcrastinationScreen({
    super.key,
    required this.heroTag,
    this.initialTabIndex = 0,
  });

  @override
  State<ProcrastinationScreen> createState() => _ProcrastinationScreenState();
}

class _ProcrastinationScreenState extends State<ProcrastinationScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = false;

  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _ativarModulo() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.startModuleCycle(nicheId: NicheId.procrastination);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _desativarModulo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Desativar módulo?"),
        content: const Text(
          "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado.\n\n"
          "Além disso, todas as suas tarefas serão excluídas permanentemente.\n\n"
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
            child: const Text("Sim, desativar"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) {
        return;
      }
      HapticFeedback.heavyImpact();
      setState(() => _isLoading = true);

      // Reinicia gamificação REAL
      final gamification =
          Provider.of<GamificationService>(context, listen: false);
      gamification.resetMedals(
        NicheId.procrastination,
        notificationTitle: 'Módulo Reiniciado 🔄',
        notificationBody: 'Seu progresso da procrastinação foi zerado.',
        deactivate: true,
      );

      // Limpa tarefas no serviço
      final service =
          Provider.of<ProcrastinationService>(context, listen: false);
      await service.deleteAllTasks();

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ProcrastinationService>(context);
    final gamification = Provider.of<GamificationService>(context);
    final isActive = gamification.isModuleActive(NicheId.procrastination);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Obter objeto Niche
    final niche = NicheRepository.getById(NicheId.procrastination);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(niche.name),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : const Color.fromARGB(255, 230, 235, 255),
              isDark
                  ? const Color.fromARGB(255, 10, 15, 30)
                  : const Color.fromARGB(255, 255, 255, 255)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Custom
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
                        niche.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: NicheHeader(
                        niche: niche,
                        showBackground: false,
                        heroTag: widget.heroTag,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSegmentedControl(),
                    ),
                    const SizedBox(height: 24),

                    // --- PAGEVIEW ---
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _selectedIndex = index);
                        },
                        children: [
                          // Aba 0: Como funciona
                          _buildHowItWorksTab(isDark),

                          // Aba 1: Editor de tarefas
                          _buildEditorTab(service, isDark),

                          // Aba 2: Ativar módulo
                          _buildActivationTab(isActive, niche, service, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = [
      'Como funciona',
      'Editor de tarefas',
      'Ativar módulo'
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (_pageController.hasClients) {
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutQuad);
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutQuart,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color.fromARGB(255, 57, 92, 208)
                          : const Color.fromARGB(255, 18, 189, 211))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (isDark
                                    ? const Color.fromARGB(255, 57, 92, 208)
                                    : const Color.fromARGB(255, 10, 223, 219))
                                .withValues(alpha: 0.3),
                            blurRadius: 10,
                          )
                        ]
                      : [],
                ),
                child: Text(
                  options[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- ABA 0: COMO FUNCIONA ---
  Widget _buildHowItWorksTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const NicheInfoSection(
            hintText:
                "Neste módulo, na tela 'Editor de Tarefas', você pode criar, editar e excluir tarefas a serem cumpridas, no dia atual ou em qualquer dia. Concluindo todas do dia, você segue com seu progresso. Deixando de cumprir alguma, o seu progresso reinicia.",
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: GlowingButton(
              text: 'Acessar Editor',
              color: const Color(0xFF6366F1),
              onPressed: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              },
              borderRadius: 18,
            ),
          ),
        ],
      ),
    );
  }

  // --- ABA 1: EDITOR DE TAREFAS ---
  Widget _buildEditorTab(ProcrastinationService service, bool isDark) {
    final tasks = service.getTasksForDay(_selectedDay);
    final dayStatus = service.getDay(_selectedDay);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCalendar(service, isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat("d 'de' MMMM", 'pt_BR').format(_selectedDay),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (tasks.isNotEmpty) _buildDayStatusBadge(dayStatus),
                    ],
                  ),
                ),
                if (tasks.isEmpty) _buildEmptyState(isDark),
                if (tasks.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      // No editor, checkbox desabilitado ou apenas visual
                      return _buildTaskTile(task, service, isDark,
                          isEditable: true, taskDate: _selectedDay);
                    },
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: GlowingButton(
            text: 'Nova Tarefa',
            icon: Icons.add_task,
            color: const Color(0xFF6366F1),
            onPressed: () => _showAddTaskModal(context, service),
            borderRadius: 18,
          ),
        ),
      ],
    );
  }

  // --- ABA 2: ATIVAR MÓDULO ---
  Widget _buildActivationTab(
      bool isActive, Niche niche, ProcrastinationService service, bool isDark) {
    if (!isActive) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.do_not_disturb_on,
              size: 80,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              "Ative o módulo para começar a usá-lo e para criar seu progresso",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            GlowingButton(
              text: 'Ativar Módulo',
              onPressed: _ativarModulo,
              color: const Color(0xFF6366F1),
            ),
          ],
        ),
      );
    }

    final todayTasks = service.getTasksForDay(DateTime.now());

    return Column(
      children: [
        Expanded(
          child: todayTasks.isEmpty
              ? Center(
                  child: Text(
                    "Nenhuma tarefa para hoje.\nCrie no Editor!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: todayTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = todayTasks[index];
                    if (task.isCompleted) {
                      return const SizedBox.shrink();
                    }
                    return _buildTaskTile(task, service, isDark,
                        isCheckable: true, taskDate: DateTime.now());
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton.icon(
            onPressed: _desativarModulo,
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            label: const Text('Desativar módulo',
                style: TextStyle(color: Colors.redAccent, fontSize: 16)),
          ),
        ),

        // --- BOTÕES DE AÇÃO ESTILO PÍLULA (PADRÃO SMOKING) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyProgressProcrastination()),
                    );
                  },
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF395CC8),
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF395CC8).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Meu progresso',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const ProcrastinationNotificationsScreen()),
                    );
                  },
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.grey[400]!,
                      ),
                    ),
                    child: Text(
                      'Notificações',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayStatusBadge(ProcrastinationDay? day) {
    if (day == null) {
      return const SizedBox();
    }

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
            if (!mounted) {
              return;
            }
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
      ProcrastinationTask task, ProcrastinationService service, bool isDark,
      {bool isCheckable = false, bool isEditable = false, DateTime? taskDate}) {
    // Calcula a urgência atual da tarefa
    final urgency = task.isCompleted
        ? task.completedUrgencyLevel
        : service.getTaskUrgency(task, taskDate ?? _selectedDay);
    final urgencyColor = urgency?.color ?? Colors.grey;

    final tile = Container(
      decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: task.isCompleted
                  ? Colors.green.withValues(alpha: 0.5)
                  : urgencyColor.withValues(alpha: 0.6),
              width: task.isCompleted ? 1 : 2),
          boxShadow: [
            BoxShadow(
                color: task.isCompleted
                    ? Colors.black.withValues(alpha: 0.05)
                    : urgencyColor.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de urgência (bolinha colorida)
            if (!task.isCompleted)
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: urgencyColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: urgencyColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            if (isCheckable)
              Checkbox(
                value: task.isCompleted,
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: (val) {
                  // Usa toggleTaskCompletion para salvar a urgência corretamente
                  service.toggleTaskCompletion(
                      taskDate ?? DateTime.now(), task.id);
                },
              )
            else
              Icon(Icons.task_alt,
                  color: task.isCompleted ? Colors.green : urgencyColor),
          ],
        ),
        title: Text(
          task.title,
          style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? (isDark ? Colors.white38 : Colors.black38)
                  : (isDark ? Colors.white : Colors.black87),
              fontWeight: FontWeight.w600),
        ),
        subtitle: task.description != null
            ? Text(task.description!,
                maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.startTime != null || task.endTime != null)
              Column(
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
              ),
            if (isEditable) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (val) {
                  if (val == 'delete') {
                    _confirmDeleteTask(task, service);
                  } else if (val == 'edit') {
                    _showEditTaskModal(task, service);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar')
                      ])),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Excluir', style: TextStyle(color: Colors.red))
                      ])),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    return tile;
  }

  Future<void> _confirmDeleteTask(
      ProcrastinationTask task, ProcrastinationService service) async {
    final confirmed = await showDialog<bool>(
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
              child:
                  const Text('Remover', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (!mounted) {
      return;
    }
    if (confirmed == true) {
      service.removeTask(_selectedDay, task.id);
    }
  }

  void _showEditTaskModal(
      ProcrastinationTask task, ProcrastinationService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddTaskModal(
        selectedDay: _selectedDay,
        service: service,
        taskToEdit: task,
      ),
    ).then((result) {
      if (result == true && mounted) {
        _pageController.animateToPage(
          2, // Aba Ativar Módulo
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  void _showAddTaskModal(BuildContext context, ProcrastinationService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _AddTaskModal(selectedDay: _selectedDay, service: service),
    ).then((result) {
      if (result == true && mounted) {
        HapticFeedback.lightImpact();
        _pageController.animateToPage(
          2, // Aba Ativar Módulo
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }
}

class _AddTaskModal extends StatefulWidget {
  final DateTime selectedDay;
  final ProcrastinationService service;
  final ProcrastinationTask? taskToEdit;

  const _AddTaskModal(
      {required this.selectedDay, required this.service, this.taskToEdit});

  @override
  State<_AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<_AddTaskModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description ?? '';
      if (widget.taskToEdit!.startTime != null) {
        _startTime = TimeOfDay.fromDateTime(widget.taskToEdit!.startTime!);
      }
      if (widget.taskToEdit!.endTime != null) {
        _endTime = TimeOfDay.fromDateTime(widget.taskToEdit!.endTime!);
      }
    }
  }

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
              widget.taskToEdit != null ? 'Editar Tarefa' : 'Nova Tarefa',
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
                labelText: 'Nome da tarefa',
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
                      if (t != null) {
                        setState(() => _startTime = t);
                      }
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
                      if (t != null) {
                        setState(() => _endTime = t);
                      }
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
                child: Text(
                    widget.taskToEdit != null
                        ? 'Salvar Alterações'
                        : 'Adicionar Tarefa',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      return;
    }

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

    if (widget.taskToEdit != null) {
      final updated = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        startTime: startDt,
        endTime: endDt,
      );
      widget.service.updateTask(widget.selectedDay, updated);
    } else {
      final task = ProcrastinationTask(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        startTime: startDt,
        endTime: endDt,
      );
      widget.service.addTask(widget.selectedDay, task);
    }

    Navigator.pop(context, true);
  }
}
