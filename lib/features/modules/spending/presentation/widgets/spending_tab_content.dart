import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';

/// Widget de conteúdo das abas da tela Spending
class SpendingTabContent extends StatelessWidget {
  final int tabIndex;
  final bool isDark;
  final List<String> selectedApps;
  final Function(String) onRemoveApp;

  const SpendingTabContent({
    super.key,
    required this.tabIndex,
    required this.isDark,
    required this.selectedApps,
    required this.onRemoveApp,
  });

  @override
  Widget build(BuildContext context) {
    switch (tabIndex) {
      case 0:
        // 0: Controlar Gastos (módulo)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Aplicativos monitorados:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (selectedApps.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Nenhum app selecionado.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              )
            else
              const Text(
                'Para gerenciar gastos fixos, use o menu "Controle de gastos" → "Gastos fixos"',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 24),
          ],
        );
      case 1:
        // 1: Como Funciona
        return Column(
          children: [
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.account_balance_wallet_outlined,
              title:
                  'Em "Controle de gastos", gerencie apps monitorados e gastos fixos',
              content:
                  'Em "Selecionar apps", escolha apps de compras online para monitorar. Ao abri-los, você receberá um alerta para evitar compras por impulso.\nEm "Gastos fixos", cadastre suas contas fixas (aluguel, luz, internet...) e seja lembrado de pagá-las antes do vencimento.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.edit_note_rounded,
              title: 'Edite valor e vencimento a qualquer momento',
              content:
                  'Na tela principal, toque nos três pontinhos (⋮) em cada conta para editar o valor daquele mês ou alterar o dia de vencimento. Ao marcar uma conta como paga, ela sai da lista e aparece nas estatísticas.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.notifications_outlined,
              title: 'Em "Notificações", configure seus alertas',
              content:
                  'Receba alertas ao abrir apps monitorados e lembretes para pagar suas contas fixas antes do vencimento.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.circle,
              title: 'Sistema de urgência por cores',
              content:
                  '🟢 Verde: a conta ainda está longe do vencimento.\n🟡 Amarelo: faltam poucos dias para vencer.\n🔴 Vermelho: a conta está vencendo hoje ou já venceu.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.bar_chart_rounded,
              title: 'Em "Estatísticas", acompanhe seu progresso',
              content:
                  'Veja o resumo das contas pagas no mês, o total gasto e acompanhe sua disciplina financeira ao longo do tempo.',
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
