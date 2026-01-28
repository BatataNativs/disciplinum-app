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
import 'package:disciplinum/screens/modules/7_moneySavingChallenge/money_saving_challenge_notifications_screen.dart';

class MoneySavingChallengeScreen extends StatefulWidget {
  const MoneySavingChallengeScreen({super.key});

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
      );

      if (mounted) {
        setState(() {
          _challenge = challenge;
          _isSaving = false;
        });

        _showSnackBar('Desafio criado! Bora poupar! 💰');

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

  Future<void> _toggleCell(int index) async {
    if (_challenge == null) return;
    HapticFeedback.lightImpact();

    final updated = await _service.toggleCell(index);
    if (mounted && updated != null) {
      setState(() => _challenge = updated);

      // Comemoração se completou o desafio
      if (updated.isComplete) {
        HapticFeedback.heavyImpact();
        _showSnackBar('🎉 Parabéns! Você completou o desafio!');
      }
    }
  }

  Future<void> _resetChallenge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetar Desafio?'),
        content: const Text(
          'Isso vai apagar todo o progresso atual e você poderá criar um novo desafio.\n\nDeseja continuar?',
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
            child: const Text('Sim, resetar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      await _service.deleteChallenge();
      if (mounted) {
        setState(() => _challenge = null);
        _showSnackBar('Desafio resetado');

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
        // Progresso
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildProgressCard(challenge, isDark),
        ),
        const SizedBox(height: 12),

        // Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildGrid(challenge, isDark),
          ),
        ),

        // Ações
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const MoneySavingChallengeNotificationsScreen()),
                    );
                  },
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.grey[400]!,
                      ),
                    ),
                    child: Text(
                      'Notificações',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
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
                  onTap: _resetChallenge,
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      'Resetar',
                      style: TextStyle(
                        color: Colors.redAccent,
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

  Widget _buildProgressCard(MoneySavingChallengeModel challenge, bool isDark) {
    final saved = challenge.totalSaved;
    final target = challenge.targetAmount;
    final percent = challenge.progressPercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A5F), const Color(0xFF0D253F)]
              : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.blue : Colors.green).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Guardado',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${challenge.currency} ${saved.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Meta',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${challenge.currency} ${target.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 1.0 ? Colors.amber : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percent * 100).toStringAsFixed(1)}% concluído • ${challenge.markedCells.length}/${challenge.totalCells} células',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
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
