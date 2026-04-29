import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';

/// Widget de ações da tela Binge Eating
class BingeEatingActionsWidget extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final PageController pageController;
  final VoidCallback onSelectApps;
  final VoidCallback onNotifications;
  final VoidCallback onStatistics;
  final bool gamificationRunning;
  final VoidCallback onToggleModule;

  const BingeEatingActionsWidget({
    super.key,
    required this.selectedIndex,
    required this.isDark,
    required this.pageController,
    required this.onSelectApps,
    required this.onNotifications,
    required this.onStatistics,
    required this.gamificationRunning,
    required this.onToggleModule,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 0) {
      // 0: Compulsão alimentar (módulo) - mostra botões de ação
      return _buildBottomButtons();
    } else {
      // 1: Como funciona - mostra botão para voltar ao módulo
      return _buildTabActions(1);
    }
  }

  Widget _buildTabActions(int index) {
    switch (index) {
      case 0:
        // 0: Compulsão alimentar (módulo) - botão de selecionar apps
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ModernStartButton(
            icon: Icons.apps_rounded,
            label: "Selecionar aplicativos",
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: onSelectApps,
          ),
        );
      case 1:
        // 1: Como funciona - botão para voltar ao módulo
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ModernStartButton(
            icon: Icons.rocket_launch_rounded,
            label: "Entendi!",
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
                child: ModernStartButton(
                  icon: Icons.touch_app_outlined,
                  label: "Selecionar apps",
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: onSelectApps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: Icons.notifications_outlined,
                  label: "Notificações",
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: onNotifications,
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
                  label: "Estatísticas",
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: onStatistics,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: gamificationRunning
                      ? Icons.power_settings_new
                      : Icons.power_off,
                  label: gamificationRunning
                      ? "Desativar Módulo"
                      : "Ativar Módulo",
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
