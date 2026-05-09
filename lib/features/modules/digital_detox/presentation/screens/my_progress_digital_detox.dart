import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';

import '../../gamification/domain/services/digital_detox_gamification_service.dart';
import '../../gamification/domain/entities/digital_detox_gamification_entity.dart';
import '../../gamification/domain/repositories/digital_detox_gamification_repository.dart';
import '../providers/digital_detox_providers.dart';
import '../screens/digital_detox_fasting_breaks_screen.dart';

/// Tela de progresso e conquistas do Jejum Digital (FASE 8)
class DigitalDetoxProgressScreen extends ConsumerStatefulWidget {
  const DigitalDetoxProgressScreen({super.key});

  @override
  ConsumerState<DigitalDetoxProgressScreen> createState() => _DigitalDetoxProgressScreenState();
}

class _DigitalDetoxProgressScreenState extends ConsumerState<DigitalDetoxProgressScreen> {
  late DigitalDetoxGamificationService _gamificationService;
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadStatistics();
  }

  void _initializeService() {
    final store = ObjectBoxService.instance.store;
    _gamificationService = DigitalDetoxGamificationService(
      DigitalDetoxGamificationRepository(store.box<DigitalDetoxGamificationEntity>()),
    );
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      
      // Criar estatísticas básicas
      final gamification = _gamificationService.getGamification(userId);
      _statistics = {
        'currentStreak': gamification?.currentStreak ?? 0,
        'longestStreak': gamification?.longestStreak ?? 0,
        'totalDisciplinedDays': gamification?.totalDisciplinedDays ?? 0,
        'earnedInsignias': gamification?.earnedInsigniasList ?? [],
        'earnedMedalhas': gamification?.earnedMedalhasList ?? [],
        'isModuleActive': gamification?.isModuleActive ?? false,
      };
      
      // Inicializar gamificaÃ§Ã£o se ainda nÃ£o existe
      _gamificationService.initializeGamification(userId);
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estatÃ­sticas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _statistics == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final stats = _statistics!;
    final currentStreak = stats['currentStreak'] as int;
    final sevenDayCycle = stats['sevenDayCycle'] as int;
    final daysIn30DayCycle = stats['daysInCurrent30DayCycle'] as int;
    final availableBreaks = stats['availableBreaks'] as int;
    final totalInsignias = stats['totalInsignias'] as Map<String, String>;
    final totalMedals = stats['totalMedals'] as Map<String, int>;
    final nextInsignia = stats['nextInsignia'] as String?;
    final daysUntilNextInsignia = stats['daysUntilNextInsignia'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progresso e Conquistas'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Principal
            _buildStreakCard(currentStreak, nextInsignia, daysUntilNextInsignia),
            
            const SizedBox(height: 16),
            
            // Ciclo de 7 Dias
            _buildSevenDayCycleCard(sevenDayCycle, availableBreaks),
            
            const SizedBox(height: 16),
            
            // Ciclo de 30 Dias
            _buildThirtyDayCycleCard(daysIn30DayCycle),
            
            const SizedBox(height: 16),
            
            // InsÃ­gnias
            _buildInsigniasCard(totalInsignias),
            
            const SizedBox(height: 16),
            
            // Medalhas
            _buildMedalsCard(totalMedals),
            
            const SizedBox(height: 16),
            
            // Quebras DisponÃ­veis
            _buildAvailableBreaksCard(availableBreaks),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(int currentStreak, String? nextInsignia, int daysUntilNext) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streak Principal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$currentStreak dias vÃ¡lidos consecutivos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (nextInsignia != null) ...[
                        Text(
                          'PrÃ³xima insÃ­gnia: $nextInsignia',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'em $daysUntilNext dias',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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

  Widget _buildSevenDayCycleCard(int sevenDayCycle, int availableBreaks) {
    final progress = sevenDayCycle / 7.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.coffee,
                  color: Colors.brown,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ciclo de Quebras de Jejum',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$sevenDayCycle/7 dias',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (sevenDayCycle >= 7) ...[
                        Text(
                          'ðŸŽ Quebra disponÃ­vel!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'VocÃª tem $availableBreaks quebra(s)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ] else ...[
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                        ),
                        Text(
                          'Faltam ${7 - sevenDayCycle} dias para prÃ³xima quebra',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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

  Widget _buildThirtyDayCycleCard(int daysIn30DayCycle) {
    final progress = daysIn30DayCycle / 30.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Colors.blue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ciclo de 30 Dias',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$daysIn30DayCycle/30 dias',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      Text(
                        'Faltam ${30 - daysIn30DayCycle} dias para prÃ³xima medalha',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
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

  Widget _buildInsigniasCard(Map<String, String> totalInsignias) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.military_tech,
                  color: Colors.purple,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'InsÃ­gnias Conquistadas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildInsigniaItem('ðŸªµ Madeira', totalInsignias['wood'] == '1'),
                          _buildInsigniaItem('ðŸ¥ˆ Ferro', totalInsignias['iron'] == '1'),
                          _buildInsigniaItem('ðŸ¥ˆ AlumÃ­nio', totalInsignias['aluminum'] == '1'),
                          _buildInsigniaItem('ðŸ¥‡ LatÃ£o', totalInsignias['brass'] == '1'),
                          _buildInsigniaItem('ðŸ¥‰ Bronze', totalInsignias['bronze'] == '1'),
                          _buildInsigniaItem('ðŸ¥ˆ Prata', totalInsignias['silver'] == '1'),
                          _buildInsigniaItem('ðŸ¥‡ Ouro', totalInsignias['gold'] == '1'),
                          _buildInsigniaItem('ðŸ’Ž Diamante', totalInsignias['diamond'] == '1'),
                          _buildInsigniaItem('ðŸŽ± Disciplinum', totalInsignias['disciplinum'] == '1'),
                        ],
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

  Widget _buildInsigniaItem(String name, bool earned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: earned ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: earned ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: earned ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: earned ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (earned) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.check_circle,
              color: Colors.green.shade700,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedalsCard(Map<String, int> totalMedals) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medalhas de 30 Dias',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildMedalItem('ðŸ¥‰ Bronze', totalMedals['bronze'] ?? 0),
                          _buildMedalItem('ðŸ¥ˆ Prata', totalMedals['silver'] ?? 0),
                          _buildMedalItem('ðŸ¥‡ Ouro', totalMedals['gold'] ?? 0),
                          _buildMedalItem('ðŸ’Ž Diamante', totalMedals['diamond'] ?? 0),
                        ],
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

  Widget _buildMedalItem(String name, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: count > 0 ? Colors.amber.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: count > 0 ? Colors.amber.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: count > 0 ? Colors.amber.shade700 : Colors.grey.shade600,
              fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailableBreaksCard(int availableBreaks) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_cafe,
                  color: Colors.brown,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quebras de Jejum DisponÃ­veis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$availableBreaks quebra(s) disponÃ­vel(is)',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: availableBreaks > 0 ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (availableBreaks == 0) ...[
                        Text(
                          'Complete 7 dias vÃ¡lidos para ganhar uma quebra',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navegar para tela de quebras
                            Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DigitalDetoxFastingBreaksScreen(),
                          ),
                        );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: Text('Ver Quebras'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
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
}
