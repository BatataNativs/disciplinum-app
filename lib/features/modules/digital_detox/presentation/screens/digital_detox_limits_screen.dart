import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Tela de configuração de limites de tempo do Jejum Digital
/// Permite definir limites diários de uso de apps
class DigitalDetoxLimitsScreen extends ConsumerStatefulWidget {
  const DigitalDetoxLimitsScreen({super.key});

  @override
  ConsumerState<DigitalDetoxLimitsScreen> createState() => _DigitalDetoxLimitsScreenState();
}

class _DigitalDetoxLimitsScreenState extends ConsumerState<DigitalDetoxLimitsScreen> {
  bool _enableDailyLimit = false;
  int _dailyLimitMinutes = 60;
  String _limitType = "global"; // "perApp" | "global"
  int _warnBeforeLimitMinutes = 5;

  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final service = ref.read(digitalDetoxServiceLocalProvider);
      final config = await service.getOrCreateConfig(userId);

      if (mounted) {
        setState(() {
          _enableDailyLimit = config.enableDailyLimit;
          _dailyLimitMinutes = config.dailyLimitMinutes;
          _limitType = config.limitType;
          _warnBeforeLimitMinutes = config.warnBeforeLimitMinutes;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configurações de limites', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final service = ref.read(digitalDetoxServiceLocalProvider);
      final config = await service.getOrCreateConfig(userId);

      config.enableDailyLimit = _enableDailyLimit;
      config.dailyLimitMinutes = _dailyLimitMinutes;
      config.limitType = _limitType;
      config.warnBeforeLimitMinutes = _warnBeforeLimitMinutes;

      await service.saveConfig(config);

      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações salvas com sucesso!')),
        );
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configurações', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Limite de Tempo Diário'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveSettings,
              child: const Text('SALVAR'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle principal
            Card(
              child: SwitchListTile(
                title: const Text(
                  'Ativar Limite de Tempo Diário',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Bloquear apps após atingir o tempo limite'),
                value: _enableDailyLimit,
                onChanged: (value) {
                  setState(() {
                    _enableDailyLimit = value;
                    _hasChanges = true;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            if (_enableDailyLimit) ...[
              // Tipo de limite
              Text(
                'Tipo de Limite',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'global',
                    label: Text('Limite Global'),
                    icon: Icon(Icons.public),
                  ),
                  ButtonSegment(
                    value: 'perApp',
                    label: Text('Por App'),
                    icon: Icon(Icons.apps),
                  ),
                ],
                selected: {_limitType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _limitType = newSelection.first;
                    _hasChanges = true;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                _limitType == 'global'
                    ? 'Limite total para todos os apps juntos'
                    : 'Cada app tem seu próprio limite',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // Limite diÃ¡rio
              Text(
                'Tempo Limite Diário',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _formatDuration(_dailyLimitMinutes),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _dailyLimitMinutes.toDouble(),
                        min: 15,
                        max: 240,
                        divisions: 15,
                        label: _formatDuration(_dailyLimitMinutes),
                        onChanged: (value) {
                          setState(() {
                            _dailyLimitMinutes = value.round();
                            _hasChanges = true;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('15min', style: TextStyle(color: Colors.grey[600])),
                          Text('4h', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Aviso antes do limite
              Text(
                'Aviso Antes do Limite',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '$_warnBeforeLimitMinutes minutos antes',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _warnBeforeLimitMinutes.toDouble(),
                        min: 1,
                        max: 15,
                        divisions: 14,
                        label: '$_warnBeforeLimitMinutes min',
                        onChanged: (value) {
                          setState(() {
                            _warnBeforeLimitMinutes = value.round();
                            _hasChanges = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Como funciona',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¢ O tempo de uso é contado automaticamente\n'
                      '¢ Você recebe um aviso antes de atingir o limite\n'
                      '¢ Após o limite, os apps são bloqueados até o próximo dia\n'
                      '¢ O contador reseta à meia-noite',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (!_enableDailyLimit)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'O limite de tempo diário está desativado. Não há restrição de tempo de uso.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
