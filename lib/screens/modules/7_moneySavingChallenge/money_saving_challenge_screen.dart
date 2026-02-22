import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/7_moneySavingChallenge/money_saving_challenge_model.dart';
import 'package:disciplinum/services/7_moneySavingChallenge/money_saving_challenge_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/screens/modules/7_moneySavingChallenge/money_saving_challenge_notifications_screen.dart';
import 'package:disciplinum/widgets/7_moneySavingChallenge/my_progress_money_saving_challenge.dart';
import 'package:confetti/confetti.dart';
import 'package:disciplinum/screens/modules/7_moneySavingChallenge/money_saving_challenge_stats.dart';

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
  late MoneySavingChallengeService _service;

  MoneySavingChallengeModel? get _challenge => _service.activeChallenge;
  List<MoneySavingChallengeModel> get _challenges => _service.challengesList;
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
  final Map<String, String> _currencyNames = {
    'R\$': 'R\$ - Real',
    'US\$': 'US\$ - Dólar Americano',
    '€': '€ - Euro',
    '\$': '\$ - Peso Argentino',
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // Buscamos o serviço do provider no próximo frame para ter o context pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _service =
            Provider.of<MoneySavingChallengeService>(context, listen: false);
        _loadChallenge();
      }
    });

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

  double _parseFormattedCurrency(String text, String currency) {
    if (text.isEmpty) return 0;
    bool isLatin = currency == 'R\$' || currency == '€' || currency == '\$';
    // Nota: Peso Argentino ($) também usa vírgula para decimais no padrão oficial.

    String cleaned;
    if (isLatin) {
      // 1.234,56 -> 1234.56
      cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    } else {
      // 1,234.56 -> 1234.56
      cleaned = text.replaceAll(',', '');
    }
    return double.tryParse(cleaned) ?? 0;
  }

  void _reformatAmountFields(String newCurrency, String oldCurrency) {
    for (var controller in [
      _targetController,
      _minValueController,
      _maxValueController
    ]) {
      if (controller.text.isNotEmpty) {
        double value = _parseFormattedCurrency(controller.text, oldCurrency);
        controller.text = _formatValue(value, newCurrency);
      }
    }
  }

  String _formatValue(double value, String currency) {
    bool isLatin = currency == 'R\$' || currency == '€' || currency == '\$';
    String fixed = value.toStringAsFixed(2);
    List<String> parts = fixed.split('.');
    String whole = parts[0];
    String decimal = parts[1];

    String decimalSep = isLatin ? ',' : '.';
    String thousandSep = isLatin ? '.' : ',';

    String result = '';
    int count = 0;
    for (int i = whole.length - 1; i >= 0; i--) {
      result = whole[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = thousandSep + result;
        count = 0;
      }
    }
    return result + decimalSep + decimal;
  }

  Future<void> _loadChallenge() async {
    setState(() => _isLoading = true);
    try {
      await _service.getChallenges();
      final active =
          await _service.getActiveChallenge(); // Retrieve active challenge here
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Se tem um desafio ativo, preenche os campos com os dados dele (opcional)
        if (active != null) {
          _titleController.text = active.title;
          _targetController.text =
              _formatValue(active.targetAmount, active.currency);
          _periodValueController.text = active.periodValue.toString();
          _minValueController.text =
              _formatValue(active.minValue, active.currency);
          _maxValueController.text =
              _formatValue(active.maxValue, active.currency);
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

  Future<void> _createChallenge({String? editId}) async {
    HapticFeedback.mediumImpact();

    final target = _targetController.text.isEmpty
        ? 3000.0
        : _parseFormattedCurrency(_targetController.text, _selectedCurrency);
    final periodValue = _periodValueController.text.isEmpty
        ? 6
        : (int.tryParse(_periodValueController.text) ?? 0);
    final minValue = _minValueController.text.isEmpty
        ? 10.0
        : _parseFormattedCurrency(_minValueController.text, _selectedCurrency);
    final maxValue = _maxValueController.text.isEmpty
        ? 100.0
        : _parseFormattedCurrency(_maxValueController.text, _selectedCurrency);

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
      await _service.createChallenge(
        id: editId,
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
        setState(() {
          _isSaving = false;
        });

        _showSnackBar(editId == null
            ? 'Desafio criado e ativado!'
            : 'Desafio atualizado!');

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
      // Inicia ciclo de gamificação
      final gamification =
          Provider.of<GamificationService>(context, listen: false);
      gamification.startModuleCycle(nicheId: _niche.id);

      _showSnackBar('Desafio ativado! Boa sorte! 🚀');
    }
  }

  Future<void> _deactivateChallenge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desativar e Limpar Módulo?'),
        content: const Text(
          'Ao desativar o módulo, TODOS os seus desafios criados e o progresso financeiro serão APAGADOS permanentemente.\n\nAlém disso, a contagem de dias (gamificação) será zerada. Deseja continuar?',
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
            child: const Text('Sim, desativar e excluir tudo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();

      // Deleta todos os desafios
      await _service.deleteAllChallenges();

      if (mounted) {
        setState(() {
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
          notificationTitle: 'Módulo Desativado 🛑',
          notificationBody:
              'O módulo foi desativado e todos os dados foram limpos conforme solicitado.',
        );

        // Cancela notificações específicas
        await NotificationService.cancelNotification(7001);

        _showSnackBar('Módulo desativado e dados limpos.');
      }
    }
  }

  Future<void> _switchChallenge(String id) async {
    // Apenas seleciona no serviço e recarrega para garantir dados frescos
    await _service.setActiveChallenge(id);
    await _loadChallenge();

    if (mounted) {
      _showSnackBar('Desafio selecionado!');

      // Navega automaticamente para os detalhes (Grid)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              _FullScreenGridPage(challenge: _service.activeChallenge!),
        ),
      );
      _loadChallenge();
    }
  }

  Future<void> _showChallengesList() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Configuração do Desafio:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            if (_challenges.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.savings_outlined,
                        size: 48,
                        color: isDark ? Colors.white12 : Colors.black12),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum desafio criado.',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _challenges.length,
                  separatorBuilder: (_, __) => Divider(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final c = _challenges[index];
                    final isActive = c.id == _challenge?.id;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.02)),
                          shape: BoxShape.circle,
                        ),
                        child: Text('💰', style: TextStyle(fontSize: 20)),
                      ),
                      title: Text(
                        c.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: isDark ? Colors.white60 : Colors.black45),
                        onSelected: (val) {
                          if (val == 'edit') {
                            Navigator.pop(ctx);
                            _editChallenge(c);
                          } else if (val == 'delete') {
                            Navigator.pop(ctx);
                            _deleteSpecificChallenge(c);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Excluir Desafio',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _switchChallenge(c.id);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showCreateChallengeSheet();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo Desafio',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _editChallenge(MoneySavingChallengeModel challenge) {
    // Preenche controladores e abre o modal de criação/Edição
    setState(() {
      _titleController.text = challenge.title;
      _targetController.text =
          _formatValue(challenge.targetAmount, challenge.currency);
      _periodValueController.text = challenge.periodValue.toString();
      _minValueController.text =
          _formatValue(challenge.minValue, challenge.currency);
      _maxValueController.text =
          _formatValue(challenge.maxValue, challenge.currency);
      _selectedPeriodType = challenge.periodType;
      _selectedGridSize = challenge.gridSize;
      _selectedCurrency = challenge.currency;
    });

    // Passamos o ID para o método de criação saber que é uma edição (precisaremos ajustar _createChallenge)
    _showCreateChallengeSheet(editId: challenge.id);
  }

  Future<void> _deleteSpecificChallenge(
      MoneySavingChallengeModel challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Desafio?'),
        content: Text(
            'Deseja excluir permanentemente o desafio "${challenge.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteChallenge(challenge.id);
      await _loadChallenge();
      _showSnackBar('Desafio excluído');
    }
  }

  void _showCreateChallengeSheet({String? editId}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Reset controllers ONLY if creating new challenge
    if (editId == null) {
      _titleController.clear();
      _targetController.clear();
      _periodValueController.clear();
      _minValueController.clear();
      _maxValueController.clear();
      _selectedPeriodType = 'mês(es)';
      _selectedGridSize = 10;
      _selectedCurrency = 'R\$';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        editId == null
                            ? 'Criar novo desafio'
                            : 'Editar desafio',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Título
                  const Text('Nome',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _titleController,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Dê um nome ao desafio!',
                      border: UnderlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Moeda e Meta
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Moeda',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey)),
                            const SizedBox(height: 4),
                            _buildCurrencyDropdownForModal(setModalState),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _targetController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              CurrencyInputFormatter(
                                  currency: _selectedCurrency)
                            ],
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                            decoration: const InputDecoration(
                              hintText: '5.000,00',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Período
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _periodValueController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                            decoration: const InputDecoration(
                              hintText: '6',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child:
                              _buildPeriodTypeDropdownForModal(setModalState)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tamanho do Grid
                  _buildGridSizeSelectorForModal(setModalState),
                  const SizedBox(height: 20),

                  // Valores Mínimo e Máximo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Aporte mínimo',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _minValueController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  CurrencyInputFormatter(
                                      currency: _selectedCurrency)
                                ],
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black),
                                decoration: const InputDecoration(
                                  hintText: '10,00',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Aporte máximo',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _maxValueController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  CurrencyInputFormatter(
                                      currency: _selectedCurrency)
                                ],
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black),
                                decoration: const InputDecoration(
                                  hintText: '100,00',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar',
                              style: TextStyle(
                                  color: Color(0xFF4338CA),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  await _createChallenge(editId: editId);
                                  if (mounted && ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                },
                          child: Text(_isSaving
                              ? (editId == null ? 'Criando...' : 'Salvando...')
                              : (editId == null ? 'Criar!' : 'Salvar!')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyDropdownForModal(StateSetter setModalState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 24),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
          selectedItemBuilder: (BuildContext context) {
            return _currencyOptions.map<Widget>((String value) {
              return Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold));
            }).toList();
          },
          onChanged: (value) {
            if (value != null) {
              final oldCurrency = _selectedCurrency;
              setModalState(() {
                _selectedCurrency = value;
                // Reformatar valores existentes usando a moeda antiga para o parse
                _reformatAmountFields(value, oldCurrency);
              });
              setState(() {
                _selectedCurrency = value;
              });
            }
          },
          items: _currencyOptions.map((c) {
            return DropdownMenuItem(
                value: c,
                child: Text(_currencyNames[c] ?? c,
                    style: const TextStyle(fontSize: 16)));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPeriodTypeDropdownForModal(StateSetter setModalState) {
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
            if (value != null) {
              setModalState(() => _selectedPeriodType = value);
              setState(() => _selectedPeriodType = value);
            }
          },
          items: _periodTypes.map((p) {
            String label = p;
            final val = int.tryParse(_periodValueController.text) ?? 0;
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

  Widget _buildGridSizeSelectorForModal(StateSetter setModalState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _gridSizeOptions.map((size) {
        final isSelected = _selectedGridSize == size;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setModalState(() => _selectedGridSize = size);
            setState(() => _selectedGridSize = size);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF15B7D1)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFFDF2FF)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isSelected
                      ? const Color(0xFF15B7D1)
                      : Colors.purple.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check, color: Colors.white, size: 16),
                if (isSelected) const SizedBox(width: 4),
                Text(
                  '${size}x$size',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
    _service = context.watch<MoneySavingChallengeService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark
                    ? Colors.black
                    : const Color.fromARGB(255, 226, 229, 251),
                isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
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
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
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
                    const SizedBox(width: 48),
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
                          // 1: Desafio
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _challenge == null
                                    ? _buildEmptyState()
                                    : _buildConfigTab(), // Em vez de deletar, podemos mostrar um resumo aqui se houver desafio
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
                  label: 'Meus Desafios',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _showChallengesList,
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
              'Estatísticas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.analytics_rounded,
              label: 'Estatísticas dos Desafios',
              color: const Color(0xFF10B981), // Emerald
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MoneySavingChallengeStatsScreen()),
                );
              },
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
          title: 'Em "Meus Desafios", crie seu desafio de poupar dinheiro!',
          content:
              '''Defina uma meta de poupança, o período e os valores mínimos e máximos de aportes que você planeja fazer.
Exemplo: Meta de R\$ 1.000,00 em 10 meses, com aportes de R\$ 100,00 a R\$ 200,00 por mês.
O app gerará um grid com células marcáveis, pra você marcar cada aporte realizado.
Lembrando que o app Disciplinum não gerencia seu dinheiro, nem tem vínculo com bancos ou instituições financeiras.
O app é apenas uma ferramenta de controle e organização, que reflete o que você registrar sobre seus aportes reais realizados em instituições financeiras de sua escolha.''',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          isDark,
          icon: Icons.notifications_outlined,
          title: 'Em "Notificações", defina seus lembretes',
          content:
              'Configure horários para ser lembrado de guardar dinheiro e manter o foco no seu objetivo financeiro.',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          isDark,
          icon: Icons.bar_chart_rounded,
          title: 'Em "Estatísticas", acompanhe sua poupança',
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

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.savings_outlined,
              size: 64, color: const Color(0xFF6366F1).withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(
            'Crie seu desafio clicando em "Meus Desafios" e configurando. Depois, ative o módulo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab() {
    if (_challenges.isEmpty) return _buildEmptyState();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Seus Desafios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ),
        ..._challenges.map((c) => _buildChallengeCard(c, isDark)),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Para editar ou excluir desafios, acesse-os pelo botão "Meus Desafios", abaixo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildChallengeCard(MoneySavingChallengeModel c, bool isDark) {
    final bool isActive = c.id == _challenge?.id;
    final double completion = c.progressPercent;
    final int percent = (completion * 100).toInt();

    return GestureDetector(
      onTap: () async {
        if (!isActive) {
          await _service.setActiveChallenge(c.id);
          await _loadChallenge();
        }
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  _FullScreenGridPage(challenge: _service.activeChallenge!),
            ),
          );
          _loadChallenge();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                : (isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05)),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Gráfico de completude pequeno
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: completion,
                    strokeWidth: 6,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isActive
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF6366F1).withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isActive)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Text('💰', style: TextStyle(fontSize: 14)),
                        ),
                      Expanded(
                        child: Text(
                          c.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${c.gridSize}x${c.gridSize} • ${_formatValue(c.targetAmount, c.currency)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }

  // Removidos dropdowns antigos que agora estão dentro do modal

  // ============ ABA 2: MEU DESAFIO (GRID) ============
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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _currentChallenge = widget.challenge;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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

        // Notifica a tela principal para atualizar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Apenas carregamos o desafio novamente para refletir as mudanças
            // O notifyListeners() é protegido e não deve ser chamado externamente
          }
        });

        if (updated.isComplete) {
          HapticFeedback.heavyImpact();
          _confettiController.play();
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
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Esquerda: Porquinho e Porcentagem
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6366F1)),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('💰', style: TextStyle(fontSize: 18)),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Meu Desafio da Poupança',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            child: Column(
              children: [
                Text(
                  'Meta: ${_currentChallenge.currency} ${_currentChallenge.targetAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRepositionedSummary(_currentChallenge, isDark),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _currentChallenge.totalCells,
                  itemBuilder: (context, index) {
                    final isMarked =
                        _currentChallenge.markedCells.contains(index);
                    final value = index < _currentChallenge.cellValues.length
                        ? _currentChallenge.cellValues[index]
                        : 0.0;

                    return ChallengeCell(
                      index: index,
                      value: value,
                      isMarked: isMarked,
                      isDark: isDark,
                      gridSize: 5,
                      onTap: _toggleCell,
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            createParticlePath: _drawStar, // Usamos estrelas para o visual cool
          ),
        ],
      ),
    );
  }

  /// Desenha uma estrela para o confetti
  Path _drawStar(Size size) {
    // Escala baseada no tamanho sugerido pelo ConfettiWidget
    double degToRad(double deg) => deg * (3.1415926535897932 / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(
          halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
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
    colors: [
      Color(0xFF10B981), // Emerald 500
      Color(0xFF059669), // Emerald 600
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    // Gradiente escuro premium para células não marcadas
    final unMarkedGradient = LinearGradient(
      colors: [
        const Color(0xFF2C2C2E), // Cinza escuro
        const Color(0xFF1C1C1E), // Quase preto
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isMarked ? _markedGradient : unMarkedGradient,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (isMarked)
              // Brilho externo sutil para marcada
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              )
            else
              // Efeito de relevo sutil para não marcada
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            if (!isMarked)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                offset: const Offset(-1, -1),
                blurRadius: 2,
              ),
          ],
          border: Border.all(
            color: isMarked
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.05),
            width: isMarked ? 1.0 : 0.5,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: isMarked ? FontWeight.w900 : FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final String currency;

  CurrencyInputFormatter({required this.currency});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Apenas números
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return newValue.copyWith(text: '');

    double value = double.parse(cleaned) / 100;

    // Formatação baseada na moeda
    bool isLatin = currency == 'R\$' || currency == '€' || currency == '\$';

    String formatted;
    if (isLatin) {
      formatted = _formatWithSeparators(value,
          decimalSeparator: ',', thousandSeparator: '.');
    } else {
      formatted = _formatWithSeparators(value,
          decimalSeparator: '.', thousandSeparator: ',');
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithSeparators(double value,
      {required String decimalSeparator, required String thousandSeparator}) {
    String fixed = value.toStringAsFixed(2);
    List<String> parts = fixed.split('.');
    String whole = parts[0];
    String decimal = parts[1];

    String result = '';
    int count = 0;
    for (int i = whole.length - 1; i >= 0; i--) {
      result = whole[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = thousandSeparator + result;
        count = 0;
      }
    }

    return result + decimalSeparator + decimal;
  }
}
