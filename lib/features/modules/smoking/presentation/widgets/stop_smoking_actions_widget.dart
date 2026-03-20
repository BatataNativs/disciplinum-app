import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/buttons/niche_action_button.dart';
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
  final BuildContext context;

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
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 0) {
      return _buildTabActions(0);
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabActions(1),
          _buildBottomButtons(),
        ],
      );
    }
  }

  Widget _buildTabActions(int index) {
    switch (index) {
      case 0:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: NicheActionButton(
            icon: Icons.rocket_launch_rounded,
            label: 'Começar',
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: () {
              if (pageController.hasClients) {
                pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            },
          ),
        );
      case 1:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: NicheActionButton(
            icon: Icons.save_rounded,
            label: isSaving ? 'Salvando...' : 'Salvar',
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: isSaving ? () {} : onSaveSettings,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButtons() {
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
                child: NicheActionButton(
                  icon: Icons.check_circle_outline,
                  label: 'Check-in diário',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: onOpenCheckInManager,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NicheActionButton(
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
                child: NicheActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatisticas',
                  color: Colors.teal,
                  isDark: isDark,
                  onTap: onShowStatisticsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NicheActionButton(
                  icon: gamificationRunning
                      ? Icons.power_settings_new
                      : Icons.power_off,
                  label: gamificationRunning
                      ? 'Desativar Módulo'
                      : 'Ativar Módulo',
                  color: gamificationRunning ? Colors.red : Colors.green,
                  isDark: isDark,
                  isDestructive: gamificationRunning,
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
