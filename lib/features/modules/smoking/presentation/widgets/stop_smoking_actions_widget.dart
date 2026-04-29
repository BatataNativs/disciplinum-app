import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';
import '../screens/frases_motivacionais.dart';

/// Widget de ações da tela Stop Smoking
class StopSmokingActionsWidget extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final bool isSaving;
  final PageController pageController;
  final VoidCallback onOpenCheckInManager;
  final VoidCallback onShowStatisticsMenu;
  final bool gamificationRunning;
  final VoidCallback onToggleModule;
  final VoidCallback onSaveSettings;

  const StopSmokingActionsWidget({
    super.key,
    required this.selectedIndex,
    required this.isDark,
    required this.isSaving,
    required this.pageController,
    required this.onOpenCheckInManager,
    required this.onShowStatisticsMenu,
    required this.gamificationRunning,
    required this.onToggleModule,
    required this.onSaveSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 0) {
      // 0: Parar de fumar (módulo) - mostra botões de ação
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabActions(0),
          _buildBottomButtons(context),
        ],
      );
    } else {
      // 1: Como funciona - mostra botão para voltar ao módulo
      return _buildTabActions(1);
    }
  }

  Widget _buildTabActions(int index) {
    switch (index) {
      case 0:
        // 0: Parar de fumar (módulo) - botão de salvar
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ModernStartButton(
            icon: Icons.save_rounded,
            label: isSaving ? 'Salvando...' : 'Salvar',
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: isSaving ? () {} : onSaveSettings,
          ),
        );
      case 1:
        // 1: Como funciona - botão para voltar ao módulo
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ModernStartButton(
            icon: Icons.rocket_launch_rounded,
            label: 'Entendi!',
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: () {
              if (pageController.hasClients) {
                pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            },
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButtons(BuildContext context) {
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
                  icon: Icons.check_circle_outline,
                  label: 'Check-in diário',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: onOpenCheckInManager,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FrasesMotivacionaisScreen(),
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
                  color: Colors.teal,
                  isDark: isDark,
                  onTap: onShowStatisticsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: gamificationRunning
                      ? Icons.power_settings_new
                      : Icons.power_off,
                  label: gamificationRunning
                      ? 'Desativar Módulo'
                      : 'Ativar Módulo',
                  color: gamificationRunning ? Colors.red : Colors.green,
                  isDark: isDark,
                  onTap: onToggleModule,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
