import 'package:flutter/material.dart';

/// Widget de ações da tela Stop Smoking
class StopSmokingActionsWidget extends StatelessWidget {
  final int selectedIndex;
  final bool isSaving;
  final PageController pageController;
  final VoidCallback onOpenCheckInManager;
  final VoidCallback onShowStatisticsMenu;
  final VoidCallback onOpenNotifications;
  final bool gamificationRunning;
  final VoidCallback onToggleModule;
  final VoidCallback onSaveSettings;

  const StopSmokingActionsWidget({
    super.key,
    required this.selectedIndex,
    required this.isSaving,
    required this.pageController,
    required this.onOpenCheckInManager,
    required this.onShowStatisticsMenu,
    required this.onOpenNotifications,
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
        // 0: Parar de fumar (módulo) - botão de salvar removido (agora está na aba)
        return const SizedBox.shrink();
      case 1:
        // 1: Como funciona - botão para voltar ao módulo
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              if (pageController.hasClients) {
                pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded, size: 20),
                SizedBox(width: 8),
                Text('Entendi!'),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linha 1: Check-in diário | Notificações
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onOpenCheckInManager,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Check-in diário'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onOpenNotifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_active_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Notificações'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Linha 2: Estatísticas | Ativar/Desativar
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onShowStatisticsMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Estatísticas'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onToggleModule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gamificationRunning ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gamificationRunning
                            ? Icons.power_settings_new
                            : Icons.power_off,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(gamificationRunning
                          ? 'Desativar Módulo'
                          : 'Ativar Módulo'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
