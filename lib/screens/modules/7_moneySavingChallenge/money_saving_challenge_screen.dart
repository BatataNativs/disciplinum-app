import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/7_moneySavingChallenge/money_saving_challenge_model.dart';
import 'package:disciplinum/services/7_moneySavingChallenge/money_saving_challenge_service.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/widgets/niche_details/niche_header.dart';
import 'package:disciplinum/widgets/niche_details/niche_info_section.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/screens/modules/7_moneySavingChallenge/money_saving_challenge_notifications_screen.dart';

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
  bool _isLoading = true;
  bool _isSaving = false;

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0;

  // --- CONFIGURAÇÃO ---
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
    _targetController.dispose();
    _periodValueController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
    setState(() => _isLoading = true);
    try {
      final challenge = await _service.getChallenge();
      if (mounted) {
        setState(() {
          _challenge = challenge;
          _isLoading = false;

          // Se já tem um desafio, vai direto para o grid
          if (_challenge != null) {
            _selectedIndex = 2;
            if (_pageController.hasClients) {
              _pageController.jumpToPage(2);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar desafio: $e');
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
        targetAmount: target,
        periodValue: periodValue,
        periodType: _selectedPeriodType,
        gridSize: _selectedGridSize,
        minValue: minValue,
        maxValue: maxValue,
        currency: _selectedCurrency,
        isActive: false, // Começa como inativo (Rascunho)
      );

      if (mounted) {
        setState(() {
          _challenge = challenge;
          _isSaving = false;
        });

        _showSnackBar('Desafio criado! Ative-o para começar.');

        // Vai para a aba do grid
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            2,
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
      HapticFeedback.heavyImpact();

      // Atualiza status
      final updated = _challenge!.copyWith(isActive: false);
      await _service.saveChallenge(updated);

      if (mounted) {
        setState(() => _challenge = updated);

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

  Future<void> _toggleCell(int index) async {
    if (_challenge == null) return;

    if (!_challenge!.isActive) {
      _showSnackBar('Ative o desafio para marcar células!');
      return;
    }

    HapticFeedback.lightImpact();

    final updated = await _service.toggleCell(index);
    if (mounted && updated != null) {
      setState(() => _challenge = updated);

      // Comemoração se completou o desafio
      if (updated.isComplete) {
        HapticFeedback.heavyImpact();
        if (mounted) {
          _showSnackBar('🎉 Parabéns! Você completou o desafio!');
          _handleCompletionReset();
        }
      }
    }
  }

  Future<void> _handleCompletionReset() async {
    // Reseta a gamificação mas MATÉM o desafio como ativo ou inativo?
    // O pedido diz "Reset de Gamificação". Vamos zerar dias.
    final gamification =
        Provider.of<GamificationService>(context, listen: false);

    // Envia notificação de sucesso e reseta dias
    gamification.resetMedals(_niche.id,
        notificationTitle: 'Desafio Concluído! 🏆',
        notificationBody:
            'Parabéns por atingir sua meta financeira! Sua contagem de dias foi reiniciada para o próximo ciclo.',
        deactivate:
            false // Mantém ativo por enquanto, ou usuário desativa manualmente?
        // Se o usuario completou, talvez queira apenas admirar.
        // Mas o pedido diz explicitamente resetar gamificação.
        );
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

    if (confirmed == true) {
      HapticFeedback.heavyImpact();

      if (!mounted) return;

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

      await _service.deleteChallenge();
      if (mounted) {
        setState(() => _challenge = null);
        _showSnackBar('Desafio excluído');

        // Limpa os campos
        _targetController.clear();
        _periodValueController.clear();
        _minValueController.clear();
        _maxValueController.clear();

        // Volta para a aba de configuração
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
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
        appBar: AppBar(
          title: Text(_niche.name),
          centerTitle: true,
        ),
        body: Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 60, width: double.infinity, color: Colors.white),
                const SizedBox(height: 16),
                Container(height: 20, width: 200, color: Colors.white),
                const SizedBox(height: 8),
                Container(
                    height: 40, width: double.infinity, color: Colors.white),
              ],
            ),
          ),
        ),
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
                        _niche.name,
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
                        niche: _niche,
                        showBackground: false,
                        heroTag: widget.heroTag,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSegmentedControl(),
                    ),
                    const SizedBox(height: 16),

                    // --- PAGEVIEW ---
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _selectedIndex = index);
                        },
                        children: [
                          // 0: Como Funciona
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildHowItWorksTab(),
                                const SizedBox(height: 24),
                                _buildHowItWorksActions(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                          // 1: Configurar
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildConfigTab(),
                                const SizedBox(height: 24),
                                _buildConfigActions(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                          // 2: Meu Desafio (Grid)
                          _challenge != null
                              ? _buildChallengeTab()
                              : _buildNoChallengeTab(),
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
    final List<String> options = ['Como Funciona', 'Configurar', 'Meu Desafio'];

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
                  style: TextStyle(
                    fontSize: 12,
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

  // ============ ABA 0: COMO FUNCIONA ============

  Widget _buildHowItWorksTab() {
    return const NicheInfoSection(
      hintText:
          'O Desafio da Poupança é um tracker visual para te ajudar a poupar dinheiro de forma lúdica!\n\n'
          '1️⃣ Defina sua meta (ex: R\$ 5.000)\n'
          '2️⃣ Configure o período desejado (ex: 6 meses)\n'
          '3️⃣ Escolha o tamanho do grid e os valores das células\n'
          '4️⃣ A cada depósito que fizer na vida real, marque a célula correspondente no app\n\n'
          'As células mudam de cor conforme você marca, e você acompanha seu progresso visualmente!\n\n'
          '💡 Dica: Este é um tracker manual - você é responsável por registrar seus depósitos.',
    );
  }

  Widget _buildHowItWorksActions() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: GlowingButton(
        text: 'Começar a Configurar',
        color: const Color.fromARGB(255, 57, 92, 208),
        onPressed: () {
          if (_pageController.hasClients) {
            _pageController.animateToPage(1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic);
          }
        },
        borderRadius: 18,
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

  Widget _buildConfigActions() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: GlowingButton(
        text: _isSaving ? 'Criando...' : 'Criar Desafio',
        color: const Color.fromARGB(255, 16, 185, 129),
        onPressed: _isSaving ? () {} : () => _createChallenge(),
        borderRadius: 18,
      ),
    );
  }

  // ============ ABA 2: MEU DESAFIO (GRID) ============

  Widget _buildNoChallengeTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 80,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum desafio ativo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure um novo desafio na aba anterior!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeTab() {
    final challenge = _challenge!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 1. Status Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: challenge.isActive
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                challenge.isActive
                    ? Icons.check_circle
                    : Icons.pause_circle_filled,
                size: 16,
                color: challenge.isActive ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                challenge.isActive
                    ? 'MÓDULO ATIVO'
                    : 'MÓDULO DESATIVADO (RASCUNHO)',
                style: TextStyle(
                  color: challenge.isActive ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 2. Reposioned Summary (Piggy Bank + Texts)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildRepositionedSummary(challenge, isDark),
        ),

        const SizedBox(height: 12),

        // 3. Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildGrid(challenge, isDark),
          ),
        ),

        // 4. Action Buttons (Activate/Deactivate)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              if (!challenge.isActive)
                GlowingButton(
                  text: 'ATIVAR DESAFIO',
                  color: Colors.green,
                  icon: Icons.play_arrow_rounded,
                  onPressed: _activateChallenge,
                ),
              if (challenge.isActive) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.notifications_outlined,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black54),
                        label: Text('Notificações',
                            style: TextStyle(
                                fontSize: 13,
                                color:
                                    isDark ? Colors.white70 : Colors.black54)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const MoneySavingChallengeNotificationsScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : const Color.fromARGB(255, 0, 0, 0)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.fullscreen,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black54),
                        label: Text('Tela Cheia',
                            style: TextStyle(
                                fontSize: 13,
                                color:
                                    isDark ? Colors.white70 : Colors.black54)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  _FullScreenGridPage(challenge: challenge),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : const Color.fromARGB(255, 0, 0, 0)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: const Icon(Icons.pause_circle_outline,
                        color: Colors.orange),
                    label: const Text('Desativar Desafio',
                        style: TextStyle(color: Colors.orange)),
                    onPressed: _deactivateChallenge,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
              if (!challenge.isActive)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Excluir Desafio',
                          style: TextStyle(color: Colors.red)),
                      onPressed: _resetChallenge,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _buildGrid(MoneySavingChallengeModel challenge, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: challenge.gridSize,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: challenge.totalCells,
      itemBuilder: (context, index) {
        final isMarked = challenge.markedCells.contains(index);
        final value = index < challenge.cellValues.length
            ? challenge.cellValues[index]
            : 0.0;

        return GestureDetector(
          onTap: () => _toggleCell(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: isMarked
                  ? const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: isDark
                          ? [Colors.grey[800]!, Colors.grey[700]!]
                          : [Colors.grey[300]!, Colors.grey[200]!],
                    ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: isMarked
                  ? [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      color: isMarked
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontSize: challenge.gridSize > 10 ? 10 : 12,
                      fontWeight:
                          isMarked ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FullScreenGridPage extends StatelessWidget {
  final MoneySavingChallengeModel challenge;

  const _FullScreenGridPage({required this.challenge});

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
                    'Meta: ${challenge.currency} ${challenge.targetAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Usamos LayoutBuilder para garantir que a grade caiba na tela
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
                            crossAxisCount: challenge.gridSize,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: challenge.totalCells,
                          itemBuilder: (context, index) {
                            final isMarked =
                                challenge.markedCells.contains(index);
                            final value = index < challenge.cellValues.length
                                ? challenge.cellValues[index]
                                : 0.0;

                            return Container(
                              decoration: BoxDecoration(
                                gradient: isMarked
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF4CAF50),
                                          Color(0xFF66BB6A)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: isDark
                                            ? [
                                                Colors.grey[800]!,
                                                Colors.grey[700]!
                                              ]
                                            : [
                                                Colors.grey[300]!,
                                                Colors.grey[200]!
                                              ],
                                      ),
                                borderRadius: BorderRadius.circular(
                                    challenge.gridSize > 12 ? 2 : 4),
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
                                            : (isDark
                                                ? Colors.white70
                                                : Colors.black87),
                                        fontSize:
                                            challenge.gridSize > 10 ? 8 : 10,
                                        fontWeight: isMarked
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                      'Total Guardado: ${challenge.currency} ${challenge.totalSaved.toStringAsFixed(2)} (${(challenge.progressPercent * 100).toInt()}%)',
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
