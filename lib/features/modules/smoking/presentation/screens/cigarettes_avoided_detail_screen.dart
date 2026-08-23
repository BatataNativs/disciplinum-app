import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';

/// Tela de detalhamento estatístico de cigarros não fumados fundamentada em literatura científica
class CigarettesAvoidedDetailScreen extends ConsumerStatefulWidget {
  final SmokingSettingsModel settings;
  final bool isActive;

  const CigarettesAvoidedDetailScreen({
    super.key,
    required this.settings,
    this.isActive = true,
  });

  @override
  ConsumerState<CigarettesAvoidedDetailScreen> createState() =>
      _CigarettesAvoidedDetailScreenState();
}

class _CigarettesAvoidedDetailScreenState
    extends ConsumerState<CigarettesAvoidedDetailScreen> {
  int _activeTab = 0; // 0 = Atual, 1 = Projeções

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final quitDate = widget.settings.quitDate ?? DateTime.now();
    final now = DateTime.now();
    final difference = now.difference(quitDate);
    final totalHours = widget.isActive ? difference.inHours : 0;
    final totalDays = widget.isActive ? difference.inDays : 0;

    final packsPerDay = widget.settings.packsPerDay > 0
        ? widget.settings.packsPerDay
        : 1.0;
    final dailyCigarettes = (packsPerDay * 20).round();

    // Total de cigarros evitados até agora
    final cigarettesAvoided =
        widget.isActive ? ((totalHours / 24.0) * dailyCigarettes).round() : 0;
    final packsAvoided = (cigarettesAvoided / 20.0);

    // Tempo de vida recuperado: ~11 minutos por cigarro evitado (estudo BMJ 2000 / British Doctors Study)
    final minutesOfLifeSaved = cigarettesAvoided * 11;
    final hoursOfLifeSaved = minutesOfLifeSaved / 60.0;
    final daysOfLifeSaved = hoursOfLifeSaved / 24.0;

    // Toxinas evitadas: Rendimento médio segundo normas ISO (ISO 4387 / ISO 10315): ~1mg nicotina, ~10mg alcatrão por cigarro
    final gramsNicotineAvoided = (cigarettesAvoided * 0.001);
    final gramsTarAvoided = (cigarettesAvoided * 0.010);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Cigarros Evitados'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tabs de alternância (Visão Geral vs Projeções)
            Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      label: 'Visão Geral',
                      isSelected: _activeTab == 0,
                      onTap: () => setState(() => _activeTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      label: 'Projeções Futuras',
                      isSelected: _activeTab == 1,
                      onTap: () => setState(() => _activeTab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            if (_activeTab == 0) ...[
                // Hero Card Principal
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0D9488),
                        Color(0xFF14B8A6),
                        Color(0xFF2DD4BF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.smoke_free_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isActive
                                  ? 'Em Abstinência Ativa'
                                  : 'Módulo Inativo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$cigarettesAvoided',
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cigarettesAvoided == 1
                            ? 'cigarro não fumado'
                            : 'cigarros não fumados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHeroStat(
                              label: 'Maços Poupados',
                              value: packsAvoided.toStringAsFixed(1),
                              icon: Icons.inventory_2_outlined,
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            _buildHeroStat(
                              label: 'Dias Livres',
                              value: '$totalDays dias',
                              icon: Icons.calendar_today_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Seção: Impacto Biológico e Vida Recuperada
                Text(
                  'Impacto e Saúde Recuperada',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                _buildImpactCard(
                  context,
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Tempo de Vida Ganho',
                  value: daysOfLifeSaved >= 1
                      ? '+${daysOfLifeSaved.toStringAsFixed(1)} dias de vida'
                      : '+${hoursOfLifeSaved.toStringAsFixed(1)} horas de vida',
                  description:
                      'Cálculo baseado no estudo de Shaw et al. (BMJ 2000), estimando ~11 minutos de expectativa de vida preservados por cigarro não fumado.',
                ),
                const SizedBox(height: 10),

                _buildImpactCard(
                  context,
                  icon: Icons.air_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Nicotina e Alcatrão Evitados',
                  value: gramsNicotineAvoided >= 1
                      ? '${gramsNicotineAvoided.toStringAsFixed(1)}g nicotina • ${gramsTarAvoided.toStringAsFixed(1)}g alcatrão'
                      : '${(gramsNicotineAvoided * 1000).toStringAsFixed(0)}mg nicotina • ${(gramsTarAvoided * 1000).toStringAsFixed(0)}mg alcatrão',
                  description:
                      'Baseado no rendimento médio padrão internacional (ISO 4387 / ISO 10315 e OMS) de 1mg de nicotina e 10mg de alcatrão por cigarro convencional.',
                ),
                const SizedBox(height: 10),

                _buildImpactCard(
                  context,
                  icon: Icons.monitor_heart_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Monóxido de Carbono (CO) no Sangue',
                  value: totalHours >= 24
                      ? 'Níveis de CO normalizados'
                      : 'Em processo de normalização (24h)',
                  description:
                      'Conforme diretrizes da OMS e CDC, em 12 a 24 horas sem fumar o monóxido de carbono no sangue cai aos níveis de não-fumante e a oxigenação se restabelece.',
                ),
              ] else ...[
                // Aba de Projeções Futuras
                Text(
                  'Projeção de Cigarros Não Fumados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Baseado no seu consumo de $dailyCigarettes cigarros (${packsPerDay.toStringAsFixed(1)} maço/dia)',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),

                _buildProjectionCard(
                  context,
                  period: '1 Semana',
                  cigarettes: dailyCigarettes * 7,
                  packs: (dailyCigarettes * 7) / 20.0,
                  lifeDays: ((dailyCigarettes * 7) * 11) / (60 * 24),
                ),
                const SizedBox(height: 10),

                _buildProjectionCard(
                  context,
                  period: '1 Mês (30 dias)',
                  cigarettes: dailyCigarettes * 30,
                  packs: (dailyCigarettes * 30) / 20.0,
                  lifeDays: ((dailyCigarettes * 30) * 11) / (60 * 24),
                ),
                const SizedBox(height: 10),

                _buildProjectionCard(
                  context,
                  period: '6 Meses (180 dias)',
                  cigarettes: dailyCigarettes * 180,
                  packs: (dailyCigarettes * 180) / 20.0,
                  lifeDays: ((dailyCigarettes * 180) * 11) / (60 * 24),
                ),
                const SizedBox(height: 10),

                _buildProjectionCard(
                  context,
                  period: '1 Ano (365 dias)',
                  cigarettes: dailyCigarettes * 365,
                  packs: (dailyCigarettes * 365) / 20.0,
                  lifeDays: ((dailyCigarettes * 365) * 11) / (60 * 24),
                ),
                const SizedBox(height: 10),

                _buildProjectionCard(
                  context,
                  period: '5 Anos',
                  cigarettes: dailyCigarettes * 365 * 5,
                  packs: (dailyCigarettes * 365 * 5) / 20.0,
                  lifeDays: ((dailyCigarettes * 365 * 5) * 11) / (60 * 24),
                ),
              ],

              const SizedBox(height: 24),

              // Seção de Fontes e Referências Científicas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 18,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Fontes e Diretrizes Científicas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Todas as estimativas de recuperação, tempo de vida e desintoxicação são fundamentadas em publicações médicas revisadas por pares e diretrizes oficiais de saúde:',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Links
                    _buildReferenceLink(
                      title: 'British Medical Journal (BMJ)',
                      subtitle: 'Shaw et al. (2000) - "Time for a smoke? One cigarette reduces your life by 11 minutes"',
                      url: 'https://www.bmj.com/content/320/7226/53',
                    ),
                    const Divider(height: 16),
                    _buildReferenceLink(
                      title: 'Organização Mundial da Saúde (OMS / WHO)',
                      subtitle: 'Benefícios da Cessação do Tabagismo e cronologia de recuperação fisiológica',
                      url: 'https://www.who.int/news-room/questions-and-answers/item/tobacco-health-benefits-of-smoking-cessation',
                    ),
                    const Divider(height: 16),
                    _buildReferenceLink(
                      title: 'CDC & U.S. Surgeon General',
                      subtitle: 'The Health Benefits of Smoking Cessation - Relatório oficial do Surgeon General',
                      url: 'https://www.cdc.gov/tobacco/quit_smoking/how_to_quit/benefits/index.htm',
                    ),
                    const Divider(height: 16),
                    _buildReferenceLink(
                      title: 'INCA (Instituto Nacional de Câncer - Brasil)',
                      subtitle: 'Ministério da Saúde - O que acontece quando você para de fumar',
                      url: 'https://www.gov.br/inca/pt-br/assuntos/causas-e-prevencao-do-cancer/tabagismo/beneficios-ao-parar-de-fumar',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF14B8A6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImpactCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionCard(
    BuildContext context, {
    required String period,
    required int cigarettes,
    required double packs,
    required double lifeDays,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${packs.toStringAsFixed(0)} maços poupados • +${lifeDays.toStringAsFixed(1)} dias de vida',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$cigarettes unid',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D9488),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceLink({
    required String title,
    required String subtitle,
    required String url,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }
}
