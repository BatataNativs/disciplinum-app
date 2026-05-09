import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_rollover_manager.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Tela de configuração de Horas Cumulativas (Rollover) do Jejum Digital
/// Permite configurar acúmulo de minutos não usados para o próximo dia
class DigitalDetoxRolloverScreen extends ConsumerStatefulWidget {
  const DigitalDetoxRolloverScreen({super.key});

  @override
  ConsumerState<DigitalDetoxRolloverScreen> createState() => _DigitalDetoxRolloverScreenState();
}

class _DigitalDetoxRolloverScreenState extends ConsumerState<DigitalDetoxRolloverScreen> {
  bool _enableRolloverMinutes = false;
  int _maxRolloverMinutes = 60;
  int _rolloverExpirationDays = 7;
  bool _hasChanges = false;
  DigitalDetoxRolloverInfo? _rolloverInfo;
  bool _isLoadingInfo = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadRolloverInfo();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final config = await ref.read(digitalDetoxServiceLocalProvider).getOrCreateConfig(userId);
      
      setState(() {
        _enableRolloverMinutes = config.enableRolloverMinutes;
        _maxRolloverMinutes = config.maxRolloverMinutes;
        _rolloverExpirationDays = config.rolloverExpirationDays;
        _hasChanges = false;
      });
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configurações de rollover', error: e);
    }
  }

  Future<void> _loadRolloverInfo() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final rolloverManager = DigitalDetoxRolloverManager.instance;
      final info = await rolloverManager.getRolloverInfo(userId);
      
      setState(() {
        _rolloverInfo = info;
        _isLoadingInfo = false;
      });
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar informações de rollover', error: e);
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
      
      config.enableRolloverMinutes = _enableRolloverMinutes;
      config.maxRolloverMinutes = _maxRolloverMinutes;
      config.rolloverExpirationDays = _rolloverExpirationDays;
      
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
      
      LoggerService.instance.i('Configurações de rollover salvas');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configurações de rollover', error: e);
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

  Future<void> _resetRollover() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Horas Cumulativas'),
        content: const Text('Deseja apagar todos os minutos acumulados? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userId = ref.read(digitalDetoxCurrentUserIdProvider);
        final rolloverManager = DigitalDetoxRolloverManager.instance;
        await rolloverManager.resetRollover(userId);
        
        await _loadRolloverInfo();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Minutos acumulados resetados!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        LoggerService.instance.e('Erro ao resetar rollover', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao resetar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horas Cumulativas'),
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
            // InformaÃ§Ãµes sobre Horas Cumulativas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hourglass_bottom, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          'O que são Horas Cumulativas?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Minutos não usados no seu limite diário são acumulados e podem ser usados '
                      'nos prÃ³ximos dias. Perfeito para dias em que usa menos e quer compensar '
                      'em outros dias.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status Atual
            if (!_isLoadingInfo && _rolloverInfo != null) ...[
              Card(
                color: Colors.purple.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            'Status Atual',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Minutos acumulados:'),
                          Text(
                            _rolloverInfo!.formattedAccumulated,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Disponíveis hoje:'),
                          Text(
                            _rolloverInfo!.formattedAvailable,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Restantes hoje:'),
                          Text(
                            _rolloverInfo!.formattedRemaining,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      if (_rolloverInfo!.expiresAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Expiram em: ${_formatDate(_rolloverInfo!.expiresAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _rolloverInfo!.isExpired ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (_rolloverInfo!.accumulatedMinutes > 0)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _resetRollover,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                            ),
                            child: const Text('Resetar Acumulados'),
                          ),
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

            // Ativar Horas Cumulativas
            SwitchListTile(
              title: const Text('Ativar Horas Cumulativas'),
              subtitle: const Text('Acumule minutos não usados para usar depois'),
              value: _enableRolloverMinutes,
              onChanged: (value) {
                setState(() {
                  _enableRolloverMinutes = value;
                  _hasChanges = true;
                });
              },
              secondary: const Icon(Icons.hourglass_top),
            ),
            const SizedBox(height: 24),

            if (_enableRolloverMinutes) ...[
              // Máximo de minutos acumuláveis
              Text(
                'Limite de Acumulação',
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
                          const Text('Máximo acumulável'),
                          Text(
                            '$_maxRolloverMinutes min',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _maxRolloverMinutes.toDouble(),
                        min: 15,
                        max: 180,
                        divisions: 11,
                        label: '$_maxRolloverMinutes minutos',
                        onChanged: (value) {
                          setState(() {
                            _maxRolloverMinutes = value.round();
                            _hasChanges = true;
                          });
                        },
                      ),
                      const Text(
                        'Máximo de minutos que podem ser acumulados',
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

              // Validade dos minutos acumulados
              Text(
                'Validade dos Minutos',
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
                          const Text('Expiram em'),
                          Text(
                            '$_rolloverExpirationDays dias',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _rolloverExpirationDays.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '$_rolloverExpirationDays dias',
                        onChanged: (value) {
                          setState(() {
                            _rolloverExpirationDays = value.round();
                            _hasChanges = true;
                          });
                        },
                      ),
                      const Text(
                        'Minutos acumulados expiram após este período',
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
                            'Como funcionar',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '¢ Minutos não usados hoje são acumulados\n'
                        '¢ Pode usar até $_maxRolloverMinutes minutos acumulados\n'
                        '¢ Minutos expiram após $_rolloverExpirationDays dias\n'
                        '¢ Total disponível = limite diário + acumulados',
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
                          'Ative as Horas Cumulativas para acumular minutos não usados.',
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dias';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas';
    } else {
      return '${difference.inMinutes} minutos';
    }
  }
}
