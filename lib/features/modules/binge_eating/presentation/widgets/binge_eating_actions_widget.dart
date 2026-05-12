import 'package:flutter/material.dart';

/// Widget de ações da tela Binge Eating
class BingeEatingActionsWidget extends StatelessWidget {
  final int selectedIndex;
  final PageController pageController;
  final VoidCallback onSelectApps;
  final VoidCallback onNotifications;
  final VoidCallback onStatistics;
  final bool gamificationRunning;
  final VoidCallback onToggleModule;

  const BingeEatingActionsWidget({
    super.key,
    required this.selectedIndex,
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
      return _buildBottomButtons(context);
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
          child: ElevatedButton(
            onPressed: onSelectApps,
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
                Icon(Icons.apps_rounded, size: 20),
                SizedBox(width: 8),
                Text("Selecionar aplicativos"),
              ],
            ),
          ),
        );
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
                Text("Entendi!"),
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linha principal: Selecionar Apps | Notificações
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onSelectApps,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.touch_app_outlined, size: 20),
                      const SizedBox(width: 2),
                      Text(
                        'Selecionar Apps',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNotifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_outlined, size: 20),
                      const SizedBox(width: 2),
                      Text(
                        'Notificações',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Linha inferior: Estatísticas | Ativar/Desativar módulo
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onStatistics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bar_chart_rounded, size: 20),
                      const SizedBox(width: 2),
                      Text(
                        'Estatísticas',
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gamificationRunning ? Icons.power_settings_new : Icons.power_off,
                        size: 20,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        gamificationRunning ? 'Desativar módulo' : 'Ativar módulo',
                        overflow: TextOverflow.ellipsis,
                      ),
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
