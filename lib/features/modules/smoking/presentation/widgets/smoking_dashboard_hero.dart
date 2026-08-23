import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_motivational_phrase_service.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/smoking_tools_bar.dart';

/// Hero Dashboard moderno para o módulo Smoking
class SmokingDashboardHero extends StatelessWidget {
  final bool isModuleActive;
  final SmokingSettingsModel? settings;
  final TimeOfDay? checkinTime;
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final VoidCallback onOpenConsumptionSettings;
  final VoidCallback onOpenCheckInManager;
  final VoidCallback onToggleModule;
  final VoidCallback? onOpenSavings;
  final VoidCallback? onOpenCigarettesAvoided;
  final VoidCallback? onOpenBreathing;
  final VoidCallback? onOpenDiary;
  final VoidCallback? onOpenSos;
  final VoidCallback? onOpenTriggers;

  const SmokingDashboardHero({
    super.key,
    required this.isModuleActive,
    required this.settings,
    required this.checkinTime,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    required this.onOpenConsumptionSettings,
    required this.onOpenCheckInManager,
    required this.onToggleModule,
    this.onOpenSavings,
    this.onOpenCigarettesAvoided,
    this.onOpenBreathing,
    this.onOpenDiary,
    this.onOpenSos,
    this.onOpenTriggers,
  });

  @override
  Widget build(BuildContext context) {
    if (isModuleActive) {
      return _buildActiveView(context);
    } else {
      return _buildInactiveView(context);
    }
  }

  // --- VISÃO QUANDO ATIVO ---
  Widget _buildActiveView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final quitDate = settings?.quitDate ?? DateTime.now();
    final now = DateTime.now();
    final difference = now.difference(quitDate);
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    final packPrice = settings?.packPrice ?? 10.0;
    final packsPerDay = settings?.packsPerDay ?? 1.0;
    final currency = settings?.currency ?? 'R\$';

    final totalHours = difference.inHours;
    final dailyCost = packPrice * packsPerDay;
    final moneySaved = (totalHours / 24.0) * dailyCost;
    final cigarettesAvoided = ((totalHours / 24.0) * packsPerDay * 20).round();

    final phrase = SmokingMotivationalPhraseService().generateMotivationalPhrase(
      earnedInsignias: earnedInsignias,
      earnedMedalhas: earnedMedalhas,
      daysWithoutSmoking: days,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Card de Tempo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4F46E5),
                Color(0xFF6366F1),
                Color(0xFF818CF8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF34D399),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Livre do Cigarro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Desde ${quitDate.day.toString().padLeft(2, '0')}/${quitDate.month.toString().padLeft(2, '0')}/${quitDate.year}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Contador Principal
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$days',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    days == 1 ? 'dia' : 'dias',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${hours}h ${minutes}m',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Métricas Rápidas Clicáveis
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        label: 'Economia',
                        value: '$currency ${moneySaved.toStringAsFixed(2)}',
                        icon: Icons.savings_outlined,
                        onTap: onOpenSavings,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        label: 'Não fumados',
                        value: '$cigarettesAvoided unid',
                        icon: Icons.smoke_free_rounded,
                        onTap: onOpenCigarettesAvoided,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Frase Motivacional
        if (phrase.isNotEmpty)
          Container(
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
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    phrase,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Opções / Botões de Gestão
        Text(
          'Configurações e Gestão',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),

        _buildOptionTile(
          context,
          icon: Icons.tune_rounded,
          title: 'Informações de Consumo',
          subtitle:
              '$currency ${packPrice.toStringAsFixed(2)} / ${packsPerDay.toStringAsFixed(1)} maços por dia',
          badgeText: 'Editar',
          onTap: onOpenConsumptionSettings,
        ),
        const SizedBox(height: 8),

        _buildOptionTile(
          context,
          icon: Icons.access_time_rounded,
          title: 'Horário do Check-in',
          subtitle: checkinTime != null
              ? 'Configurado para às ${checkinTime!.hour.toString().padLeft(2, '0')}:${checkinTime!.minute.toString().padLeft(2, '0')}'
              : 'Nenhum horário definido',
          badgeText: checkinTime != null ? 'Ajustar' : 'Configurar',
          badgeColor: checkinTime != null ? null : Colors.orange,
          onTap: onOpenCheckInManager,
        ),

        const SizedBox(height: 20),

        // Nova Barra de 4 Ferramentas para Lidar com a Vontade (Respirar, Diário, SOS Vontade, Gatilhos)
        if (onOpenBreathing != null &&
            onOpenDiary != null &&
            onOpenSos != null &&
            onOpenTriggers != null)
          SmokingToolsBar(
            onOpenBreathing: onOpenBreathing!,
            onOpenDiary: onOpenDiary!,
            onOpenSos: onOpenSos!,
            onOpenTriggers: onOpenTriggers!,
          ),

        const SizedBox(height: 24),

        // Botão Destaque: Módulo Ativo / Desativar
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              onToggleModule();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.power_settings_new_rounded,
                    size: 20,
                    color: Color(0xFF10B981),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Módulo Ativo • Desativar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // --- VISÃO QUANDO INATIVO ---
  Widget _buildInactiveView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasConsumption = settings?.isConfigured ?? false;
    final hasCheckin = checkinTime != null;

    final currency = settings?.currency ?? 'R\$';
    final packPrice = settings?.packPrice ?? 0.0;
    final packsPerDay = settings?.packsPerDay ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smoke_free_rounded,
                  size: 36,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Liberte-se do Cigarro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Configure seus dados de consumo e seu check-in para iniciar a contagem da sua nova vida.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Passos para Iniciar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),

        // Opção 1: Configurar Consumo
        _buildOptionTile(
          context,
          icon: Icons.tune_rounded,
          title: '1. Informações de Consumo',
          subtitle: hasConsumption
              ? '$currency ${packPrice.toStringAsFixed(2)} • ${packsPerDay.toStringAsFixed(1)} maço(s)/dia'
              : 'Informe o custo do maço e quantidade',
          badgeText: hasConsumption ? 'Pronto' : 'Pendente',
          badgeColor: hasConsumption ? const Color(0xFF10B981) : Colors.orange,
          onTap: onOpenConsumptionSettings,
        ),
        const SizedBox(height: 8),

        // Opção 2: Configurar Check-in
        _buildOptionTile(
          context,
          icon: Icons.access_time_rounded,
          title: '2. Check-in Diário',
          subtitle: hasCheckin
              ? 'Horário: ${checkinTime!.hour.toString().padLeft(2, '0')}:${checkinTime!.minute.toString().padLeft(2, '0')}'
              : 'Defina o horário do lembrete diário',
          badgeText: hasCheckin ? 'Pronto' : 'Pendente',
          badgeColor: hasCheckin ? const Color(0xFF10B981) : Colors.orange,
          onTap: onOpenCheckInManager,
        ),

        const SizedBox(height: 24),

        // Botão Destaque: Ativar Módulo
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              onToggleModule();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.power_settings_new_rounded,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Ativar Módulo (Iniciar Jornada)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            HapticFeedback.lightImpact();
            onTap();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBadgeColor = badgeColor ?? const Color(0xFF6366F1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: effectiveBadgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: effectiveBadgeColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: effectiveBadgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: effectiveBadgeColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
