import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/screens/full_screen_grid_page.dart';

// Widgets importados
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/money_saving_header_widget.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/money_saving_segmented_control.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/money_saving_challenge_modal.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/money_saving_actions_widget.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/money_saving_tab_content.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/screens/money_saving_challenge_notifications_screen.dart';
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';
import 'package:disciplinum/shared/widgets/shared_widgets.dart';

class MoneySavingChallengeScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const MoneySavingChallengeScreen({super.key, this.heroTag});

  @override
  ConsumerState<MoneySavingChallengeScreen> createState() =>
      _MoneySavingChallengeScreenState();
}

class _MoneySavingChallengeScreenState
    extends ConsumerState<MoneySavingChallengeScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.moneySavingChallenge);
  late MoneySavingChallengeService _service;

  MoneySavingChallengeModel? get _challenge => _service.activeChallenge;
  List<MoneySavingChallengeModel> get _challenges => _service.challengesList;
  bool _isLoading = true;

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0; // 0=Como Funciona, 1=Configuração

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // Buscamos o serviço do provider no próximo frame para ter o context pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _service = ref.read(moneySavingChallengeServiceProvider);
        _loadChallenge();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
    setState(() => _isLoading = true);
    try {
      await _service.getChallenges();
      await _service.getActiveChallenge(); // Retrieve active challenge here
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar desafios', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _activateChallenge() async {
    if (_challenge == null) return;

    // Atualiza status local e notifica gamification
    final updated = _challenge!.copyWith(isActive: true);
    await _service.saveChallenge(updated);

    if (mounted) {
      // Inicia ciclo de gamificação
      final gamification = ref.read(gamificationServiceProvider);
      gamification.startModuleCycle(nicheId: _niche.nicheId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Desafio ativado! Boa sorte! 🚀')),
      );
    }
  }

  Future<void> _deactivateChallenge() async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Desativar e Limpar Módulo?',
      content: 'Ao desativar o módulo, TODOS os seus desafios criados e o progresso financeiro serão APAGADOS permanentemente.\n\nAlém disso, a contagem de dias (gamificação) será zerada. Deseja continuar?',
      confirmText: 'Sim, desativar e excluir tudo',
      cancelText: 'Cancelar',
      isDangerous: true,
    );

    if (confirmed == true) {
      if (!mounted) return;

      // Para o ciclo da gamificação primeiro
      final gamification = ref.read(gamificationServiceProvider);
      await gamification.stopModuleCycle(nicheId: _niche.nicheId);

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

        // Força atualização do estado da gamificação
        await ref.read(gamificationServiceProvider).getModuleStatus(_niche.nicheId);

        setState(() {
          // _challenge será null automaticamente quando _service.activeChallenge for null
        });

        // Reseta gamificação e notifica
        gamification.resetMedals(
          _niche.nicheId,
          deactivate: true,
          notificationTitle: 'Módulo Desativado 🛑',
          notificationBody:
              'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
        );

        // Cancela notificações específicas
        await NotificationService.cancelNotification(7001);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Módulo desativado')),
          );
        }
      }
    }
  }

  Future<void> _switchChallenge(String id) async {
    // Apenas seleciona no serviço e recarrega para garantir dados frescos
    await _service.setActiveChallenge(id);
    await _loadChallenge();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Desafio selecionado!')),
      );

      // Navega automaticamente para os detalhes (Grid)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              FullScreenGridPage(challenge: _service.activeChallenge!),
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
                        color: isDark ? Colors.white54 : Colors.black54),
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
    // Abre o modal de edição com os dados do desafio
    _showCreateChallengeSheet(editId: challenge.id);
  }

  Future<void> _deleteSpecificChallenge(
      MoneySavingChallengeModel challenge) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir Desafio?',
      content: 'Deseja excluir permanentemente o desafio "${challenge.title}"?',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      isDangerous: true,
    );

    if (confirmed == true) {
      await _service.deleteChallenge(challenge.id);
      await _loadChallenge();

      if (_service.challengesList.isEmpty && mounted) {
        final gamification = ref.read(gamificationServiceProvider);
        gamification.resetMedals(
          _niche.nicheId,
          deactivate: true,
          notificationTitle: 'Módulo Desativado 🛑',
          notificationBody:
              'O último desafio foi excluído e o módulo foi desativado automaticamente.',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Desafio excluído')),
        );
      }
    }
  }

  void _showCreateChallengeSheet({String? editId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MoneySavingChallengeModal(
        challenge: editId != null ? _challenges.firstWhere((c) => c.id == editId) : null,
        editId: editId,
        onSave: (challenge) async {
          try {
            await _service.createChallenge(
              id: challenge.id,
              title: challenge.title,
              targetAmount: challenge.targetAmount,
              periodValue: challenge.periodValue,
              periodType: challenge.periodType,
              minValue: challenge.minValue,
              maxValue: challenge.maxValue,
              currency: challenge.currency,
              isActive: challenge.isActive,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(editId == null
                    ? 'Desafio criado e ativado!'
                    : 'Desafio atualizado!')),
              );

              // --- ATIVAÇÃO DE GAMIFICAÇÃO NOVO DESAFIO ---
              if (editId == null) {
                final gamification = ref.read(gamificationServiceProvider);
                gamification.startModuleCycle(nicheId: _niche.nicheId);
              }

              // Vai para a aba do grid (agora via botão, mas podemos mudar para tab 1 se preferir)
              if (_pageController.hasClients) {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic);
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao criar desafio')),
              );
            }
          }
        },
      ),
    );
  }

  void _showStatisticsMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MoneySavingStatisticsMenu(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    _service = ref.watch(moneySavingChallengeServiceProvider);
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
                MoneySavingHeaderWidget(
                  niche: _niche,
                  challenge: _challenge,
                  onBackPressed: () => Navigator.pop(context),
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
              // Header
              MoneySavingHeaderWidget(
                niche: _niche,
                challenge: _challenge,
                onBackPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: MoneySavingSegmentedControl(
                          selectedIndex: _selectedIndex,
                          onIndexChanged: (index) {
                            if (_pageController.hasClients) {
                              _pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutQuad);
                            } else {
                              setState(() => _selectedIndex = index);
                            }
                          },
                        ),
                    ),

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
                                MoneySavingTabContent(
                                  selectedIndex: 0,
                                  challenges: _challenges,
                                  activeChallenge: _challenge,
                                  isDark: isDark,
                                  formatValue: _formatValue,
                                  setActiveChallenge: (id) async {
                                    await _service.setActiveChallenge(id);
                                    await _loadChallenge();
                                  },
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          // 1: Desafio
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                MoneySavingTabContent(
                                  selectedIndex: 1,
                                  challenges: _challenges,
                                  activeChallenge: _challenge,
                                  isDark: isDark,
                                  formatValue: _formatValue,
                                  setActiveChallenge: (id) async {
                                    await _service.setActiveChallenge(id);
                                    await _loadChallenge();
                                  },
                                ),
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
              Center(
                child: _selectedIndex == 0
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: ModernStartButton(
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
                    : MoneySavingActionsWidget(
                        challenge: _challenge,
                        isDark: isDark,
                        onShowChallengesList: _showChallengesList,
                        onShowNotifications: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MoneySavingChallengeNotificationsScreen(),
                            ),
                          );
                        },
                        onShowStatistics: _showStatisticsMenu,
                        onToggleModule: _challenge?.isActive == true
                            ? _deactivateChallenge
                            : _activateChallenge,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
