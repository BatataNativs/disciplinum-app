import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/challenge_card.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/screens/full_screen_grid_page.dart';

class MoneySavingTabContent extends StatelessWidget {
  final int selectedIndex;
  final List<MoneySavingChallengeModel> challenges;
  final MoneySavingChallengeModel? activeChallenge;
  final bool isDark;
  final String Function(double, String) formatValue;
  final Function(String) setActiveChallenge;

  const MoneySavingTabContent({
    super.key,
    required this.selectedIndex,
    required this.challenges,
    required this.activeChallenge,
    required this.isDark,
    required this.formatValue,
    required this.setActiveChallenge,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        // 0: Desafio da Poupança (módulo)
        return _buildChallengeTab(context);
      case 1:
        // 1: Como Funciona
        return _buildHowItWorksTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHowItWorksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          NicheInfoCard(
            isDark: isDark,
            icon: Icons.savings_outlined,
            title: 'Em "Meus Desafios", crie seu desafio de poupar dinheiro!',
            content: '''Defina uma meta de poupança, o período e os valores mínimos e máximos de aportes que você planeja fazer.
Exemplo: Meta de R\$ 1.000,00 em 10 meses, com aportes de R\$ 100,00 a R\$ 200,00 por mês.
O app gerará um grid com células marcáveis, pra você marcar cada aporte realizado.
Lembrando que o app Disciplinum não gerencia seu dinheiro, nem tem vínculo com bancos ou instituições financeiras.
O app é apenas uma ferramenta de controle e organização, que reflete o que você registrar sobre seus aportes reais realizados em instituições financeiras de sua escolha.''',
          ),
          const SizedBox(height: 16),
          NicheInfoCard(
            isDark: isDark,
            icon: Icons.notifications_outlined,
            title: 'Em "Notificações", defina seus lembretes',
            content: 'Configure horários para ser lembrado de guardar dinheiro e manter o foco no seu objetivo financeiro.',
          ),
          const SizedBox(height: 16),
          NicheInfoCard(
            isDark: isDark,
            icon: Icons.bar_chart_rounded,
            title: 'Em "Estatísticas", acompanhe sua poupança',
            content: 'Visualize seu progresso no grid do desafio e veja o quanto já acumulou para realizar seu sonho.',
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTab(BuildContext context) {
    if (challenges.isEmpty) return _buildEmptyState();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
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
          ...challenges.map((c) => ChallengeCard(
                challenge: c,
                isDark: isDark,
                isActive: c.id == activeChallenge?.id,
                formatValue: formatValue,
                onTap: () async {
                  if (c.id != activeChallenge?.id) {
                    setActiveChallenge(c.id);
                  }
                  if (context.mounted) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenGridPage(challenge: c),
                      ),
                    );
                  }
                },
              )),
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
      ),
    );
  }

  Widget _buildEmptyState() {
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
          Icon(
            Icons.savings_outlined,
            size: 64,
            color: const Color(0xFF6366F1).withValues(alpha: 0.5),
          ),
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
}
