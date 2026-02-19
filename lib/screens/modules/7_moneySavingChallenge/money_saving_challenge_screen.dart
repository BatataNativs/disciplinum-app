import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/7_moneySavingChallenge/money_saving_challenge_model.dart';
import 'package:disciplinum/services/7_moneySavingChallenge/money_saving_challenge_service.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/screens/modules/7_moneySavingChallenge/money_saving_challenge_notifications_screen.dart';
import 'package:disciplinum/widgets/7_moneySavingChallenge/my_progress_money_saving_challenge.dart';

class MoneySavingChallengeScreen extends StatefulWidget {
  final String? heroTag;
  const MoneySavingChallengeScreen({super.key, this.heroTag});

  @override
  State<MoneySavingChallengeScreen> createState() =>
      _MoneySavingChallengeScreenState();
}

class _MoneySavingChallengeScreenState
    extends State<MoneySavingChallengeScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.moneySavingChallenge);
  final MoneySavingChallengeService _service = MoneySavingChallengeService();

  MoneySavingChallengeModel? _challenge;
  List<MoneySavingChallengeModel> _challenges = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0; // 0=Como Funciona, 1=Configuração

  // --- CONFIGURAÇÃO ---
  final TextEditingController _titleController =
      TextEditingController(text: 'Novo Desafio');
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _periodValueController = TextEditingController();
  final TextEditingController _minValueController = TextEditingController();
  final TextEditingController _maxValueController = TextEditingController();
  String _selectedPeriodType = 'mês(es)';
  int _selectedGridSize = 10;
  String _selectedCurrency = 'R\$';

  final List<String> _periodTypes = [
    'dia(s)',
    'semana(s)',
    'mês(es)',
    'ano(s)',
    'indeterminado'
  ];
  final List<int> _gridSizeOptions = [8, 10, 12, 15];
  final List<String> _currencyOptions = ['R\$', 'US\$', '€', '\$'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadChallenge();

    // Listener para atualizar o singular/plural do dropdown em tempo real
    _periodValueController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _targetController.dispose();
    _periodValueController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.getChallenges();
      final active = await _service.getActiveChallenge();
      if (mounted) {
        setState(() {
          _challenges = list;
          _challenge = active;
          _isLoading = false;
        });

        // Se tem um desafio ativo, preenche os campos com os dados dele (opcional)
        if (active != null) {
          _titleController.text = active.title;
          _targetController.text = active.targetAmount.toStringAsFixed(2);
          _periodValueController.text = active.periodValue.toString();
          _minValueController.text = active.minValue.toStringAsFixed(2);
          _maxValueController.text = active.maxValue.toStringAsFixed(2);
          _selectedPeriodType = active.periodType;
          _selectedGridSize = active.gridSize;
          _selectedCurrency = active.currency;
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar desafios: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createChallenge() async {
    HapticFeedback.mediumImpact();

    final target = double.tryParse(
            _targetController.text.replaceAll('.', '').replaceAll(',', '.')) ??
        0;
    final periodValue = int.tryParse(_periodValueController.text) ?? 0;
    final minValue = double.tryParse(_minValueController.text
            .replaceAll('.', '')
            .replaceAll(',', '.')) ??
        0;
    final maxValue = double.tryParse(_maxValueController.text
            .replaceAll('.', '')
            .replaceAll(',', '.')) ??
        0;

    if (target <= 0) {
      _showSnackBar('Defina uma meta válida');
      return;
    }
    if (minValue <= 0 || maxValue <= 0) {
      _showSnackBar('Defina os valores mínimo e máximo');
      return;
    }
    if (minValue >= maxValue) {
      _showSnackBar('O valor mínimo deve ser menor que o máximo');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final challenge = await _service.createChallenge(
        title: _titleController.text.trim().isEmpty
            ? 'Novo Desafio'
            : _titleController.text.trim(),
        targetAmount: target,
        periodValue: periodValue,
        periodType: _selectedPeriodType,
        gridSize: _selectedGridSize,
        minValue: minValue,
        maxValue: maxValue,
        currency: _selectedCurrency,
        isActive: true, // Agora criamos e já ativamos para facilitar
      );

      if (mounted) {
        final list = await _service.getChallenges();
        setState(() {
          _challenges = list;
          _challenge = challenge;
          _isSaving = false;
        });

        _showSnackBar('Desafio criado e ativado!');

        // Vai para a aba do grid (agora via botão, mas podemos mudar para tab 1 se preferir)
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('Erro ao criar desafio');
      }
    }
  }

  Future<void> _activateChallenge() async {
    if (_challenge == null) return;
    HapticFeedback.mediumImpact();

    // Atualiza status local e notifica gamification
    final updated = _challenge!.copyWith(isActive: true);
    await _service.saveChallenge(updated);

    if (mounted) {
      setState(() => _challenge = updated);

      // Inicia ciclo de gamificação
      final gamification =
          Provider.of<GamificationService>(context, listen: false);
      gamification.startModuleCycle(nicheId: _niche.id);

      _showSnackBar('Desafio ativado! Boa sorte! 🚀');
    }
  }

  Future<void> _deactivateChallenge() async {
    if (_challenge == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desativar Desafio?'),
        content: const Text(
          'Ao desativar, seu progresso de dias consecutivos (gamificação) será zerado.\n\nVocê manterá os dados financeiros salvos, mas a contagem de dias reinicia.',
        ),
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

      // Atualiza status
      final updated = _challenge!.copyWith(isActive: false);
      await _service.saveChallenge(updated);

      if (mounted) {
        setState(() {
          _challenge = updated;
          _selectedIndex = 0;
        });

        if (_pageController.hasClients) {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic);
        }

        // Reseta gamificação e notifica
        final gamification =
            Provider.of<GamificationService>(context, listen: false);

        gamification.resetMedals(
          _niche.id,
          deactivate: true,
          notificationTitle: 'Desafio Pausado ⏸️',
          notificationBody:
              'Seu desafio foi desativado e a contagem de dias reiniciada. Seus valores guardados permanecem salvos.',
        );

        // Cancela notificações específicas
        await NotificationService.cancelNotification(7001);

        _showSnackBar('Desafio desativado.');
      }
    }
  }

  Future<void> _resetChallenge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Desafio?'),
        content: const Text(
          'Isso vai apagar TODO o progresso financeiro e zerar sua gamificação.\n\nDeseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && _challenge != null) {
      HapticFeedback.heavyImpact();

      if (!mounted) return;

      final idToDelete = _challenge!.id;

      // Reseta gamificação e notifica exclusão
      final gamification =
          Provider.of<GamificationService>(context, listen: false);

      gamification.resetMedals(
        _niche.id,
        deactivate: true,
        notificationTitle: 'Desafio Excluído 🗑️',
        notificationBody:
            'Todo o seu progresso do desafio (financeiro e gamificação) foi apagado permanentemente.',
      );

      await _service.deleteChallenge(idToDelete);
      if (mounted) {
        await _loadChallenge();
        _showSnackBar('Desafio excluído');

        // Volta para a aba de configuração se não sobrou nenhum
        if (_challenge == null && _pageController.hasClients) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
  }

  Future<void> _switchChallenge(String id) async {
    setState(() => _isLoading = true);
    await _service.setActiveChallenge(id);
    await _loadChallenge();
    if (mounted) {
      _showSnackBar('Desafio alterado!');
      Navigator.pop(context); // Fecha o menu de desafios
    }
  }

  Future<void> _showChallengesList() async {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meus Desafios',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Color(0xFF6366F1)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (_pageController.hasClients) {
                      _pageController.animateToPage(1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _challenges.length,
                itemBuilder: (context, index) {
                  final c = _challenges[index];
                  final isActive = c.id == _challenge?.id;
                  return _buildMenuTile(
                    icon: isActive ? Icons.check_circle : Icons.circle_outlined,
                    label: c.title,
                    color: isActive
                        ? Colors.green
                        : (isDark ? Colors.white38 : Colors.black38),
                    onTap: () => _switchChallenge(c.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_niche.name), centerTitle: true),
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
              isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
              isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _niche.name,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          if (_challenge != null)
                            Text(
                              _challenge!.title,
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.layers_outlined,
                          color: isDark ? Colors.white : Colors.black87),
                      onPressed: _showChallengesList,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: _buildSegmentedControl()),

                    // --- PAGEVIEW ---
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        children: [
                          // 0: Como Funciona
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildHowItWorksTab(),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          // 1: Configurações
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildConfigTab(),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _selectedIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildActionButton(
                        icon: Icons.rocket_launch_rounded,
                        label: 'Começar',
                        color: const Color(0xFF6366F1),
                        isDark: isDark,
                        onTap: () {
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic);
                          } else {
                            setState(() => _selectedIndex = 1);
                          }
                        },
                      ),
                    )
                  : _buildBottomButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = ['Como Funciona', 'Desafio da Poupança'];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
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
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF6366F1).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  options[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black45),
                    letterSpacing: isSelected ? 0.3 : 0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButtons(bool isDark) {
    bool hasChallenge = _challenge != null;
    bool isActive = _challenge?.isActive ?? false;

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
                child: _buildActionButton(
                  icon: Icons.grid_view_rounded,
                  label: 'Meu Desafio',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: hasChallenge
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  _FullScreenGridPage(challenge: _challenge!),
                            ),
                          );
                        }
                      : () {
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic);
                          }
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MoneySavingChallengeNotificationsScreen(),
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
                child: _buildActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatísticas',
                  color: Colors.teal,
                  isDark: isDark,
                  onTap: _showStatisticsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: isActive ? Icons.power_settings_new : Icons.power_off,
                  label: isActive ? 'Desativar módulo' : 'Ativar módulo',
                  color: isActive ? Colors.red : Colors.green,
                  isDark: isDark,
                  isDestructive: isActive,
                  onTap: hasChallenge
                      ? (isActive ? _deactivateChallenge : _activateChallenge)
                      : () {
                          _showSnackBar('Crie um desafio primeiro!');
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic);
                          }
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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
            if (_challenge != null) ...[
              _buildRepositionedSummary(_challenge!, isDark),
              const SizedBox(height: 24),
            ],
            _buildMenuTile(
              icon: Icons.layers_outlined,
              label: 'Trocar Desafio',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(ctx);
                _showChallengesList();
              },
            ),
            _buildMenuTile(
              icon: Icons.delete_outline,
              label: 'Excluir Desafio Atual',
              color: _challenge != null ? Colors.red : Colors.grey,
              onTap: _challenge != null
                  ? () {
                      Navigator.pop(ctx);
                      _resetChallenge();
                    }
                  : () {},
            ),
            _buildMenuTile(
              icon: Icons.bar_chart_rounded,
              label: 'Meu progresso',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyProgressMoneySavingChallenge()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListActionTile(
      icon: icon,
      label: label,
      color: color,
      isDark: isDark,
      onTap: onTap,
    );
  }

  // ============ ABA 0: COMO FUNCIONA ============

  Widget _buildHowItWorksTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        _buildInfoCard(
          isDark,
          icon: Icons.savings_outlined,
          title: 'Crie seu desafio na aba "Configuração"',
          content:
              'Defina uma meta de economia, o período e os valores mínimos e máximos que você deseja poupar em cada etapa.',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          isDark,
          icon: Icons.notification_add_outlined,
          title: 'Em "Notificações", defina seus lembretes',
          content:
              'Configure horários para ser lembrado de guardar dinheiro e manter o foco no seu objetivo financeiro.',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          isDark,
          icon: Icons.bar_chart_rounded,
          title: 'Em "Estatísticas", acompanhe sua economia',
          content:
              'Visualize seu progresso no grid do desafio e veja o quanto já acumulou para realizar seu sonho.',
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    bool isDark, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============ ABA 1: CONFIGURAR ============

  Widget _buildConfigTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text('Nome do Desafio:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Ex: Viagem, Carro Novo...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(height: 20),

          // Meta
          const Text('Meta de poupança:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCurrencyDropdown(),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: '5.000,00',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Período
          const Text('Período do desafio:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _periodValueController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: '6',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodTypeDropdown()),
            ],
          ),

          const SizedBox(height: 20),

          // Tamanho do Grid
          const Text('Tamanho do grid:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildGridSizeSelector(),

          const SizedBox(height: 20),

          // Valores Min/Max
          const Text('Valores das células:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minValueController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Mínimo',
                    hintText: '10',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxValueController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Máximo',
                    hintText: '200',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            'O app vai preencher as ${_selectedGridSize * _selectedGridSize} células com valores entre o mínimo e máximo.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: GlowingButton(
              text: _isSaving ? 'Criando...' : 'Criar Desafio',
              color: const Color.fromARGB(255, 16, 185, 129),
              onPressed: _isSaving ? () {} : () => _createChallenge(),
              borderRadius: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.white24 : Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onChanged: (value) {
            if (value != null) setState(() => _selectedCurrency = value);
          },
          items: _currencyOptions.map((c) {
            return DropdownMenuItem(value: c, child: Text(c));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPeriodTypeDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.white24 : Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriodType,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          onChanged: (value) {
            if (value != null) setState(() => _selectedPeriodType = value);
          },
          items: _periodTypes.map((p) {
            String label = p;
            final val = int.tryParse(_periodValueController.text) ?? 0;

            // Lógica inteligente de singular/plural
            if (val == 1) {
              if (p == 'dia(s)') {
                label = 'dia';
              } else if (p == 'semana(s)') {
                label = 'semana';
              } else if (p == 'mês(es)') {
                label = 'mês';
              } else if (p == 'ano(s)') {
                label = 'ano';
              }
            } else if (val > 1) {
              if (p == 'dia(s)') {
                label = 'dias';
              } else if (p == 'semana(s)') {
                label = 'semanas';
              } else if (p == 'mês(es)') {
                label = 'meses';
              } else if (p == 'ano(s)') {
                label = 'anos';
              }
            }

            return DropdownMenuItem(value: p, child: Text(label));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGridSizeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      children: _gridSizeOptions.map((size) {
        final isSelected = _selectedGridSize == size;
        return ChoiceChip(
          label: Text('${size}x$size'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              HapticFeedback.selectionClick();
              setState(() => _selectedGridSize = size);
            }
          },
          selectedColor: isDark
              ? const Color.fromARGB(255, 57, 92, 208)
              : const Color.fromARGB(255, 18, 189, 211),
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  // ============ ABA 2: MEU DESAFIO (GRID) ============

  Widget _buildRepositionedSummary(
      MoneySavingChallengeModel challenge, bool isDark) {
    // Calcula progresso
    final progress = challenge.progressPercent;
    final totalSaved = challenge.totalSaved;
    final remaining = challenge.targetAmount - totalSaved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Esquerda: Porquinho e Porcentagem
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor:
                          isDark ? Colors.white10 : Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF6366F1)),
                      strokeWidth: 6,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Icon(Icons.savings, color: Color(0xFF6366F1), size: 20),
            ],
          ),

          const SizedBox(width: 16),

          // Direita: Valores
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildValueRow(
                    'Guardado',
                    '${challenge.currency} ${totalSaved.toStringAsFixed(2)}',
                    const Color(0xFF6366F1),
                    isDark),
                const SizedBox(height: 8),
                _buildValueRow(
                    'Falta',
                    '${challenge.currency} ${remaining.toStringAsFixed(2)}',
                    isDark ? Colors.white60 : Colors.grey[600]!,
                    isDark),
                const SizedBox(height: 8),
                _buildValueRow(
                    'Meta',
                    '${challenge.currency} ${challenge.targetAmount.toStringAsFixed(2)}',
                    isDark ? Colors.white30 : Colors.grey[400]!,
                    isDark,
                    isSmall: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueRow(String label, String value, Color color, bool isDark,
      {bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: isSmall ? 10 : 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 12 : 16,
          ),
        ),
      ],
    );
  }
}

class _FullScreenGridPage extends StatefulWidget {
  final MoneySavingChallengeModel challenge;

  const _FullScreenGridPage({required this.challenge});

  @override
  State<_FullScreenGridPage> createState() => _FullScreenGridPageState();
}

class _FullScreenGridPageState extends State<_FullScreenGridPage> {
  late MoneySavingChallengeModel _currentChallenge;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentChallenge = widget.challenge;
  }

  Future<void> _toggleCell(int index) async {
    if (_isProcessing) return;
    if (!_currentChallenge.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ative o desafio para marcar células!')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      final service =
          Provider.of<MoneySavingChallengeService>(context, listen: false);
      final updated = await service.toggleCell(index);

      if (mounted && updated != null) {
        setState(() {
          _currentChallenge = updated;
          _isProcessing = false;
        });

        if (updated.isComplete) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('🎉 Parabéns! Você completou o desafio!')),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Grid centralizado
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Meu Desafio da Poupança 💰',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Meta: ${_currentChallenge.currency} ${_currentChallenge.targetAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.maxWidth;
                      return SizedBox(
                        width: size,
                        height: size,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _currentChallenge.gridSize,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: _currentChallenge.totalCells,
                          itemBuilder: (context, index) {
                            final isMarked =
                                _currentChallenge.markedCells.contains(index);
                            final value =
                                index < _currentChallenge.cellValues.length
                                    ? _currentChallenge.cellValues[index]
                                    : 0.0;

                            return ChallengeCell(
                              index: index,
                              value: value,
                              isMarked: isMarked,
                              isDark: isDark,
                              gridSize: _currentChallenge.gridSize,
                              onTap: _toggleCell,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Total Guardado: ${_currentChallenge.currency} ${_currentChallenge.totalSaved.toStringAsFixed(2)} (${(_currentChallenge.progressPercent * 100).toInt()}%)',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botão de voltar
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const ListActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: isDark ? Colors.white30 : Colors.black26,
        ),
        onTap: onTap,
      ),
    );
  }
}

class ChallengeCell extends StatelessWidget {
  final int index;
  final double value;
  final bool isMarked;
  final bool isDark;
  final int gridSize;
  final ValueChanged<int> onTap;

  const ChallengeCell({
    super.key,
    required this.index,
    required this.value,
    required this.isMarked,
    required this.isDark,
    required this.gridSize,
    required this.onTap,
  });

  static const LinearGradient _markedGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    // Cache gradients based on theme to avoid recreation
    final unMarkedGradient = LinearGradient(
      colors: isDark
          ? [Colors.grey[800]!, Colors.grey[700]!]
          : [Colors.grey[300]!, Colors.grey[200]!],
    );

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isMarked ? _markedGradient : unMarkedGradient,
          borderRadius: BorderRadius.circular(gridSize > 12 ? 2 : 4),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: isMarked
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontSize: gridSize > 10 ? 8 : 10,
                  fontWeight: isMarked ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
