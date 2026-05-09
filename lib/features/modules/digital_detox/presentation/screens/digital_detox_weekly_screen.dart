import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_weekly_manager.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Tela de configuração de Limites Semanais do Jejum Digital
/// Permite configurar controle de tempo total por semana
class DigitalDetoxWeeklyScreen extends ConsumerStatefulWidget {
  const DigitalDetoxWeeklyScreen({super.key});

  @override
  ConsumerState<DigitalDetoxWeeklyScreen> createState() => _DigitalDetoxWeeklyScreenState();
}

class _DigitalDetoxWeeklyScreenState extends ConsumerState<DigitalDetoxWeeklyScreen> {
  bool _enableWeeklyLimit = false;
  int _weeklyLimitMinutes = 540; // 9 horas
  String _weeklyLimitStrategy = 'flexible';
  bool _hasChanges = false;
  DigitalDetoxWeeklyInfo? _weeklyInfo;
  bool _isLoadingInfo = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadWeeklyInfo();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final config = await ref.read(digitalDetoxServiceLocalProvider).getOrCreateConfig(userId);
      
      setState(() {
        _enableWeeklyLimit = config.enableWeeklyLimit;
        _weeklyLimitMinutes = config.weeklyLimitMinutes;
        _weeklyLimitStrategy = config.weeklyLimitStrategy;
        _hasChanges = false;
      });
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configurações semanais', error: e);
    }
  }

  Future<void> _loadWeeklyInfo() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final weeklyManager = DigitalDetoxWeeklyManager.instance;
      final info = await weeklyManager.getWeeklyInfo(userId);
      
      setState(() {
        _weeklyInfo = info;
        _isLoadingInfo = false;
      });
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar informações semanais', error: e);
      setState(() {
        _isLoadingInfo = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final service = ref.read(digitalDetoxServiceLocalProvider);
      
      final config = await service.getOrCreateConfig(userId);
      
      config.enableWeeklyLimit = _enableWeeklyLimit;
      config.weeklyLimitMinutes = _weeklyLimitMinutes;
      config.weeklyLimitStrategy = _weeklyLimitStrategy;
      
      await service.saveConfig(config);
      
      setState(() {
        _hasChanges = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      LoggerService.instance.i('Configurações semanais salvas');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configurações semanais', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Limites Semanais'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveSettings,
              child: const Text('Salvar'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações sobre Limites Semanais
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_view_week, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          'O que são Limites Semanais?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Controle o tempo total de uso durante a semana inteira. '
                      'Ideal para planejamento de longo prazo e evitar excessos '
                      'em dias específicos.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status Atual
            if (!_isLoadingInfo && _weeklyInfo != null) ...[
              Card(
                color: Colors.teal.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Status da Semana',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Limite semanal:'),
                          Text(
                            _weeklyInfo!.formattedWeeklyLimit,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Usado esta semana:'),
                          Text(
                            _weeklyInfo!.formattedUsedThisWeek,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _weeklyInfo!.isOverLimit ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Restante:'),
                          Text(
                            _weeklyInfo!.formattedRemaining,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Média diária:'),
                          Text(
                            _weeklyInfo!.formattedAverage,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar semanal
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progresso semanal',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: _weeklyInfo!.weeklyProgress.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _weeklyInfo!.isOverLimit ? Colors.red : Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_weeklyInfo!.weeklyProgress * 100).round()}% do limite',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ] else if (_isLoadingInfo) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),
            ],

            // Ativar Limites Semanais
            SwitchListTile(
              title: const Text('Ativar Limites Semanais'),
              subtitle: const Text('Controle o tempo total de uso por semana'),
              value: _enableWeeklyLimit,
              onChanged: (value) {
                setState(() {
                  _enableWeeklyLimit = value;
                  _hasChanges = true;
                });
              },
              secondary: const Icon(Icons.calendar_today),
            ),
            const SizedBox(height: 24),

            if (_enableWeeklyLimit) ...[
              // Limite semanal
              Text(
                'Limite Semanal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tempo total por semana'),
                          Text(
                            '${(_weeklyLimitMinutes / 60).toStringAsFixed(1)}h',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _weeklyLimitMinutes.toDouble(),
                        min: 180, // 3 horas
                        max: 1680, // 28 horas (4h por dia)
                        divisions: 25,
                        label: '${(_weeklyLimitMinutes / 60).toStringAsFixed(1)} horas',
                        onChanged: (value) {
                          setState(() {
                            _weeklyLimitMinutes = value.round();
                            _hasChanges = true;
                          });
                        },
                      ),
                      const Text(
                        'Tempo máximo permitido durante a semana',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Estratégia de limite
              Text(
                'Estratégia de Limite',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estratégia de Limite'),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'flexible',
                            label: Text('Flexível'),
                            icon: Icon(Icons.sync),
                          ),
                          ButtonSegment(
                            value: 'strict',
                            label: Text('Estrito'),
                            icon: Icon(Icons.block),
                          ),
                        ],
                        selected: {_weeklyLimitStrategy},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _weeklyLimitStrategy = newSelection.first;
                            _hasChanges = true;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _weeklyLimitStrategy == 'flexible'
                            ? 'Permite exceder com aviso, mas reduz nos dias seguintes'
                            : 'Bloqueia assim que atingir o limite semanal',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Exemplo de Funcionamento
              Card(
                color: Colors.blue.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Como funcionará',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Limite total: ${(_weeklyLimitMinutes / 60).toStringAsFixed(1)} horas por semana\n'
                        '• Estratégia: ${_weeklyLimitStrategy == 'flexible' ? 'Flexível - permite exceder até 20%' : 'Estrito - bloqueia no limite'}\n'
                        '• Média diária sugerida: ${(_weeklyLimitMinutes / 7 / 60).toStringAsFixed(1)} horas\n'
                        '• Reset automático todo domingo',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Mensagem quando desativado
              Card(
                color: Colors.grey.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ative os Limites Semanais para controlar o tempo total de uso por semana.',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
