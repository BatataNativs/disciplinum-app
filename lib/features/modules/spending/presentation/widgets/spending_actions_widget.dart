import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/features/modules/spending/presentation/screens/fixed_expenses_screen.dart';
import 'package:disciplinum/features/modules/spending/presentation/screens/fixed_bills_stats_screen.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/my_progress_spending.dart' as spending_progress;
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';

/// Widget de ações da tela Spending
class SpendingActionsWidget extends StatelessWidget {
  final int selectedIndex;
  final ColorScheme colorScheme;
  final bool gamificationRunning;
  final PageController pageController;
  final VoidCallback onOpenSelectApps;
  final VoidCallback onShowControlGastosMenu;
  final VoidCallback onShowStatisticsMenu;
  final VoidCallback onToggleModule;
  final BuildContext context;

  const SpendingActionsWidget({
    super.key,
    required this.selectedIndex,
    required this.colorScheme,
    required this.gamificationRunning,
    required this.pageController,
    required this.onOpenSelectApps,
    required this.onShowControlGastosMenu,
    required this.onShowStatisticsMenu,
    required this.onToggleModule,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 0) {
      // 0: Controlar Gastos (módulo) - mostra botões de ação
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabActions(0),
          _buildBottomButtons(),
        ],
      );
    } else {
      // 1: Como Funciona - mostra botão para voltar ao módulo
      return _buildTabActions(1);
    }
  }

  Widget _buildTabActions(int index) {
    switch (index) {
      case 0:
        // 0: Controlar Gastos (módulo) - botão de selecionar apps
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ModernStartButton(
            icon: Icons.apps_rounded,
            label: 'Selecionar Apps',
            color: const Color(0xFF6366F1),
            onTap: onOpenSelectApps,
          ),
        );
      case 1:
        // 1: Como Funciona - botão para voltar ao módulo
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ModernStartButton(
              icon: Icons.rocket_launch_rounded,
              label: 'Entendi!',
              color: const Color(0xFF6366F1),
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showControlGastosMenu(),
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
                      Icon(Icons.account_balance_wallet_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Controle de gastos'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showStatisticsMenu(),
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
                          ? 'Desativar módulo'
                          : 'Ativar módulo'),
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

  void _showControlGastosMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controle de Gastos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.touch_app_outlined,
              label: 'Selecionar apps',
              color: const Color(0xFF6366F1),
              onTap: () {
                Navigator.pop(ctx);
                onOpenSelectApps();
              },
            ),
            ListActionTile(
              icon: Icons.receipt_long_rounded,
              label: 'Gastos fixos',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FixedExpensesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatisticsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas e Progresso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.receipt_long_outlined,
              label: 'Estatísticas de contas pagas',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FixedBillsStatsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            ListActionTile(
              icon: Icons.bar_chart_rounded,
              label: 'Conquistas',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const spending_progress.MyProgressSpending()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
