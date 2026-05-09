import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Tela de configuraÃ§Ã£o de SessÃµes Controladas do Jejum Digital
/// Permite configurar duraÃ§Ã£o, cooldown e limites diÃ¡rios das sessÃµes
class DigitalDetoxSessionsScreen extends ConsumerStatefulWidget {
  const DigitalDetoxSessionsScreen({super.key});

  @override
  ConsumerState<DigitalDetoxSessionsScreen> createState() => _DigitalDetoxSessionsScreenState();
}

class _DigitalDetoxSessionsScreenState extends ConsumerState<DigitalDetoxSessionsScreen> {
  bool _enableSessionMode = false;
  int _sessionDurationMinutes = 10;
  int _sessionCooldownHours = 2;
  int _maxSessionsPerDay = 4;
  int _sessionDailyLimitMinutes = 40;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final config = await ref.read(digitalDetoxServiceLocalProvider).getOrCreateConfig(userId);
      
      setState(() {
        _enableSessionMode = config.enableSessionMode;
        _sessionDurationMinutes = config.sessionDurationMinutes;
        _sessionCooldownHours = config.sessionCooldownHours;
        _maxSessionsPerDay = config.maxSessionsPerDay;
        _sessionDailyLimitMinutes = config.sessionDailyLimitMinutes;
        _hasChanges = false;
      });
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuraÃ§Ãµes de sessÃ£o', error: e);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final service = ref.read(digitalDetoxServiceLocalProvider);
      
      final config = await service.getOrCreateConfig(userId);
      
      config.enableSessionMode = _enableSessionMode;
      config.sessionDurationMinutes = _sessionDurationMinutes;
      config.sessionCooldownHours = _sessionCooldownHours;
      config.maxSessionsPerDay = _maxSessionsPerDay;
      config.sessionDailyLimitMinutes = _sessionDailyLimitMinutes;
      
      await service.saveConfig(config);
      
      setState(() {
        _hasChanges = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ConfiguraÃ§Ãµes salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      LoggerService.instance.i('ConfiguraÃ§Ãµes de sessÃ£o salvas');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuraÃ§Ãµes de sessÃ£o', error: e);
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
        title: const Text('SessÃµes Controladas'),
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
            // InformaÃ§Ãµes sobre SessÃµes Controladas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'O que sÃ£o SessÃµes Controladas?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SessÃµes Controladas permitem usar apps monitorados em perÃ­odos curtos e definidos, '
                      'com tempo de espera (cooldown) entre as sessÃµes. Ideal para uso consciente '
                      'e controle de impulsos.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ativar SessÃµes Controladas
            SwitchListTile(
              title: const Text('Ativar SessÃµes Controladas'),
              subtitle: const Text('Permite usar apps apenas em sessÃµes controladas'),
              value: _enableSessionMode,
              onChanged: (value) {
                setState(() {
                  _enableSessionMode = value;
                  _hasChanges = true;
                });
              },
              secondary: const Icon(Icons.play_circle),
            ),
            const SizedBox(height: 24),

            if (_enableSessionMode) ...[
              // DuraÃ§Ã£o da SessÃ£o
              Text(
                'DuraÃ§Ã£o da SessÃ£o',
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
                          const Text('Tempo por sessÃ£o'),
                          Text(
                            '$_sessionDurationMinutes min',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _sessionDurationMinutes.toDouble(),
                        min: 5,
                        max: 30,
                        divisions: 5,
                        label: '$_sessionDurationMinutes minutos',
                        onChanged: (value) {
                          setState(() {
                            _sessionDurationMinutes = value.round();
                            _hasChanges = true;
                          });
                        },
                      ),
                      const Text(
                        'Cada sessÃ£o terÃ¡ esta duraÃ§Ã£o fixa',
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

              // Cooldown
              Text(
                'Tempo de Espera (Cooldown)',
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
                          const Text('Cooldown entre sessÃµes'),
                          Text(
                            '$_sessionCooldownHours h',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _sessionCooldownHours.toDouble(),
                        min: 1,
                        max: 6,
                        divisions: 5,
                        label: '$_sessionCooldownHours horas',
                        onChanged: (value) {
                          setState(() {
                            _sessionCooldownHours = value.round();
                            _hasChanges = true;
                          });
                        },
                      ),
                      const Text(
                        'Tempo de espera obrigatÃ³rio entre sessÃµes',
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

              // Limites DiÃ¡rios
              Text(
                'Limites DiÃ¡rios',
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
                      // MÃ¡ximo de sessÃµes por dia
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('MÃ¡ximo de sessÃµes por dia'),
                          Text(
                            '$_maxSessionsPerDay',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _maxSessionsPerDay.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$_maxSessionsPerDay sessÃµes',
                        onChanged: (value) {
                          setState(() {
                            _maxSessionsPerDay = value.round();
                            _hasChanges = true;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Tempo total diÃ¡rio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tempo total diÃ¡rio'),
                          Text(
                            '$_sessionDailyLimitMinutes min',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _sessionDailyLimitMinutes.toDouble(),
                        min: 15,
                        max: 120,
                        divisions: 7,
                        label: '$_sessionDailyLimitMinutes minutos',
                        onChanged: (value) {
                          setState(() {
                            _sessionDailyLimitMinutes = value.round();
                            _hasChanges = true;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tempo mÃ¡ximo total em sessÃµes por dia',
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
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Como funcionarÃ¡',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'â€¢ Cada sessÃ£o durarÃ¡ $_sessionDurationMinutes minutos\n'
                        'â€¢ ApÃ³s cada sessÃ£o, aguarde $_sessionCooldownHours horas de cooldown\n'
                        'â€¢ MÃ¡ximo de $_maxSessionsPerDay sessÃµes por dia\n'
                        'â€¢ Tempo total diÃ¡rio limitado a $_sessionDailyLimitMinutes minutos',
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
                          'Ative as SessÃµes Controladas para configurar os parÃ¢metros de uso.',
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
