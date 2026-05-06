import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/modules/reading/presentation/screens/my_shelf_screen.dart';
import 'package:disciplinum/features/modules/reading/presentation/screens/reading_settings_screen.dart';
import 'package:disciplinum/features/modules/reading/presentation/screens/reading_stats_screen.dart' as stats;
import 'package:disciplinum/features/modules/reading/presentation/widgets/my_progress_reading.dart' as reading_progress;
import 'package:disciplinum/features/modules/reading/gamification/presentation/widgets/reading_celebration_widget.dart';
import 'package:disciplinum/features/modules/reading/presentation/widgets/add_book_dialog.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';
import 'package:disciplinum/shared/widgets/shared_widgets.dart';
import 'dart:async';

class ReadingScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  final int initialTabIndex;

  const ReadingScreen({
    super.key,
    this.heroTag,
    this.initialTabIndex = 1, // Default para Leitura (índice 1, Como funciona = índice 0)
  });

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final Niche _niche = NicheRepository.getById(NicheId.reading);
  late TabController _tabController;

  // Cache dos horários como no módulo Focus
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    WidgetsBinding.instance.addObserver(this);
    _loadReminderData();

    // Adiciona listener para recarregar dados quando mudar de aba
    _tabController.addListener(() {
      if (_tabController.index == 0 && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadReminderData();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Força atualização quando a app volta para o primeiro plano
      if (mounted) {
        _loadReminderData();
      }
    }
  }

  @override
  void didUpdateWidget(ReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Força atualização quando o widget é reconstruído (volta de outras telas)
    if (mounted) {
      _loadReminderData();
    }
  }

  Future<void> _loadReminderData() async {
    try {
      final reminderTimes = await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(
          nicheId: _niche.nicheId.id + 200);

      TimeOfDay? newReminderTime;
      if (reminderTimes.isNotEmpty) {
        newReminderTime = TimeOfDay(
            hour: reminderTimes[0].hour, minute: reminderTimes[0].minute);
      }

      // Só atualiza se realmente mudou
      if (_reminderTime != newReminderTime) {
        if (mounted) {
          setState(() {
            _reminderTime = newReminderTime;
          });
        }
      }
    } catch (e) {
      // Silenciosamente ignora erros de carregamento
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = ref.watch(readingActiveProvider);

    return ReadingCelebrationWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header com título e stats
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, 
                          color: colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leitura',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Consumer(
                              builder: (context, ref, child) {
                                final readingService = ref.watch(readingServiceProvider);
                                final totalBooks = readingService.books.length;
                                final completedBooks = readingService.completedBooks.length;
                                final currentStreak = readingService.currentStreak;
                                
                                return Row(
                                  children: [
                                    _buildStatChip(
                                      '$totalBooks livros',
                                      colorScheme.onSurface.withValues(alpha: 0.2),
                                      colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatChip(
                                      '$completedBooks concluídos',
                                      const Color(0xFF10B981).withValues(alpha: 0.2),
                                      const Color(0xFF10B981),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatChip(
                                      '$currentStreak dias 🔥',
                                      const Color(0xFF6366F1).withValues(alpha: 0.2),
                                      const Color(0xFF6366F1),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Segmented Control (2 opções)
              _buildSegmentedControl(),

              // Conteúdo
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 0: Leitura (módulo) - Aba da Estante + Botões
                    Column(
                        children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Adicione livros e ative o módulo para começar:",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Minha Estante:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Expanded(child: MyShelfScreen()),
                        const SizedBox(height: 12),
                        _buildReminderSection(),
                        _buildBottomButtons(isActive),
                      ],
                    ),
                    // 1: Como funciona
                    _buildHowItWorks(context),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
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
            Tab(text: 'Leitura'),
            Tab(text: 'Como funciona'),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NicheInfoCard(
                  icon: Icons.auto_stories_rounded,
                  title: 'Em " + Livro", adicione os livros',
                  content:
                      'Adicione os livros que você está lendo ou planeja ler, em seguida, ative o módulo (após adicionar o primeiro livro).\n'
                      'É preenchido nome do livro, autor (opcional), número de páginas e tema.',
                ),
                const SizedBox(height: 16),
                NicheInfoCard(
                  icon: Icons.notifications_outlined,
                  title: 'Em "Notificações", configure o lembrete diário',
                  content:
                      'Defina horário para ser lembrado de cultivar seu hábito de leitura e manter sua mente ativa todos os dias. \n'
                      'E o app registra as páginas lidas para atualizar seu progresso, conforme você informa o quanto leu.',
                ),
                const SizedBox(height: 16),
                NicheInfoCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Em "Estatísticas", veja sua evolução',
                  content:
                      'Acompanhe sua sequência de leitura e acompanhe seu progresso no módulo.',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ModernStartButton(
              icon: Icons.rocket_launch_rounded,
              label: 'Entendi!',
              color: const Color(0xFF6366F1),
              onTap: () {
                _tabController.animateTo(1);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linha superior: + Livro | Notificações
          Row(
            children: [
              Expanded(
                child: ModernStartButton(
                  icon: Icons.add,
                  label: 'Livro',
                  color: const Color(0xFF6366F1),
                  onTap: () {
                    AddBookDialog.show(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReadingSettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Linha inferior: Estatísticas | Ativar/Desativar módulo
          Row(
            children: [
              Expanded(
                child: ModernStartButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatísticas',
                  color: const Color(0xFF6366F1),
                  onTap: _showStatsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: isActive ? Icons.power_settings_new : Icons.power_off,
                  label: isActive ? 'Desativar módulo' : 'Ativar módulo',
                  color: isActive ? Colors.red : Colors.green,
                  onTap: () => _toggleModule(isActive),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatsMenu() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
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
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.bar_chart_rounded,
              label: 'Estatísticas de leitura',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const stats.ReadingStatsScreen()),
                );
              },
            ),
            ListActionTile(
              icon: Icons.bar_chart_rounded,
              label: 'Conquistas',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const reading_progress.MyProgressReading()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleModule(bool isActive) async {
    if (isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Desativar Módulo'),
          content: const Text('Ao desativar, seu progresso e gamificação serão resetados.\n\nDeseja continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Desativar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        if (!mounted) return;
        HapticFeedback.heavyImpact();
        
        // Implementando lógica de desativação local
        // Salvar estado desativado em configuração
        await ref.read(readingControllerIsarProvider.notifier).setModuleActive(false);
        
        // Sincronizar com a nuvem
        ref.read(cloudSyncServiceProvider).saveModuleStatus(
          nicheId: NicheId.reading,
          isModuleActive: false,
        );
        
        if (mounted) {
          setState(() {}); // Rebuild para atualizar UI
        }
      }
    } else {
      HapticFeedback.lightImpact();
      
      // Implementando lógica de ativação local
      // Salvar estado ativado em configuração
      await ref.read(readingControllerIsarProvider.notifier).setModuleActive(true);
      
      // Sincronizar com a nuvem
      ref.read(cloudSyncServiceProvider).saveModuleStatus(
        nicheId: NicheId.reading,
        isModuleActive: true,
      );
      
      if (mounted) {
        setState(() {}); // Rebuild para atualizar UI
      }
    }
  }


  Widget _buildReminderSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lembrete Diário',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (_reminderTime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Horário configurado:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showDeleteTimeDialog(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.red.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Defina novo horário em "Configurar"',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horário não configurado',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Acesse "Notificações" para configurar seu lembrete diário',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _showDeleteTimeDialog() async {
    final formatted = "${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}";

    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir horário?',
      content: 'Deseja excluir o horário $formatted do seu lembrete diário?',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      isDangerous: true,
    ) ?? false;

    if (!confirmed) return;

    // Remove o horário específico
    await ref.read(cloudSyncServiceProvider).removeUserNicheTime(
      nicheId: _niche.nicheId.id + 200,
      hour: _reminderTime!.hour,
      minute: _reminderTime!.minute,
    );

    // Atualiza a variável de estado
    if (mounted) {
      setState(() {
        _reminderTime = null;
      });
    }
  }

  Widget _buildStatChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
