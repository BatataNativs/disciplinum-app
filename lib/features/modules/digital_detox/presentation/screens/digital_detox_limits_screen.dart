import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/presentation/providers/digital_detox_gamification_provider.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';

/// Tela de estatísticas do Jejum Digital
/// Exibe métricas de uso e progresso do usuário
class DigitalDetoxLimitsScreen extends ConsumerStatefulWidget {
  const DigitalDetoxLimitsScreen({super.key});

  @override
  ConsumerState<DigitalDetoxLimitsScreen> createState() => _DigitalDetoxLimitsScreenState();
}

class _DigitalDetoxLimitsScreenState extends ConsumerState<DigitalDetoxLimitsScreen> {
  bool _isLoading = true;
  dynamic _config;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final service = ref.read(digitalDetoxServiceLocalProvider);
      final config = await service.getOrCreateConfig(userId);
      
      if (mounted) {
        setState(() {
          _config = config;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final gamificationState = ref.watch(digitalDetoxGamificationStateProvider(userId));
    final gamification = gamificationState.gamification;

    if (_isLoading || gamificationState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (gamification == null || _config == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Estatísticas de Uso'),
        ),
        body: const Center(
          child: Text('Nenhum dado disponível'),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final currentStreak = gamification.currentStreak;
    final longestStreak = gamification.longestStreak;
    final totalDisciplinedDays = gamification.totalDisciplinedDays;
    final monitoredApps = _config.monitoredApps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas de Uso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Principal
            _buildStreakCard(context, colorScheme, currentStreak, longestStreak),
            
            const SizedBox(height: 16),
            
            // Dias Disciplinados
            _buildDisciplinedDaysCard(context, colorScheme, totalDisciplinedDays),
            
            const SizedBox(height: 16),
            
            // Apps Monitorados
            _buildMonitoredAppsCard(context, colorScheme, monitoredApps),
            
            const SizedBox(height: 16),
            
            // Configurações Ativas
            _buildActiveConfigCard(context, colorScheme, _config),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, ColorScheme colorScheme, int currentStreak, int longestStreak) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Streak Atual',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          '$currentStreak dias',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.emoji_events, color: colorScheme.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recorde: $longestStreak dias',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisciplinedDaysCard(BuildContext context, ColorScheme colorScheme, int totalDisciplinedDays) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: colorScheme.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de Dias Disciplinados',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$totalDisciplinedDays dias',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoredAppsCard(BuildContext context, ColorScheme colorScheme, List<String> monitoredApps) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.apps,
                    color: colorScheme.tertiary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apps Monitorados',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${monitoredApps.length} apps',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (monitoredApps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: monitoredApps.take(5).map((app) => 
                  Chip(
                    label: Text(
                      app,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  )
                ).toList(),
              ),
              if (monitoredApps.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${monitoredApps.length - 5} outros apps',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveConfigCard(BuildContext context, ColorScheme colorScheme, dynamic config) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: colorScheme.onSurface,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Configurações Ativas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildConfigItem(
              context,
              'Bloqueio por Horário',
              config.enableTimeWindow ? 'Ativado' : 'Desativado',
              config.enableTimeWindow ? Icons.check_circle : Icons.cancel,
              config.enableTimeWindow ? colorScheme.primary : colorScheme.error,
            ),
            const SizedBox(height: 12),
            _buildConfigItem(
              context,
              'Limite Diário',
              config.enableDailyLimit ? 'Ativado' : 'Desativado',
              config.enableDailyLimit ? Icons.check_circle : Icons.cancel,
              config.enableDailyLimit ? colorScheme.primary : colorScheme.error,
            ),
            if (config.enableDailyLimit) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  'Tipo: ${config.limitType == 'global' ? 'Global' : 'Por App'}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildConfigItem(
              context,
              'Bloqueio nos Finais de Semana',
              config.blockOnWeekends ? 'Ativado' : 'Desativado',
              config.blockOnWeekends ? Icons.check_circle : Icons.cancel,
              config.blockOnWeekends ? colorScheme.primary : colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
