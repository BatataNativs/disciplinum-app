import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Tela de configuração de horários do Jejum Digital
/// Permite definir janelas de tempo permitidas para uso de apps
class DigitalDetoxTimeSettingsScreen extends ConsumerStatefulWidget {
  const DigitalDetoxTimeSettingsScreen({super.key});

  @override
  ConsumerState<DigitalDetoxTimeSettingsScreen> createState() => _DigitalDetoxTimeSettingsScreenState();
}

class _DigitalDetoxTimeSettingsScreenState extends ConsumerState<DigitalDetoxTimeSettingsScreen> {
  bool _enableTimeWindow = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  bool _blockOnWeekends = false;
  TimeOfDay? _weekendStartTime;
  TimeOfDay? _weekendEndTime;

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
          _enableTimeWindow = config.enableTimeWindow;
          _startTime = _parseTimeString(config.allowedStartTime) ?? const TimeOfDay(hour: 8, minute: 0);
          _endTime = _parseTimeString(config.allowedEndTime) ?? const TimeOfDay(hour: 22, minute: 0);
          _blockOnWeekends = config.blockOnWeekends;
          _weekendStartTime = _parseTimeString(config.weekendAllowedStartTime);
          _weekendEndTime = _parseTimeString(config.weekendAllowedEndTime);
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configurações de horário', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  TimeOfDay? _parseTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, bool isStart, {bool isWeekend = false}) async {
    final initialTime = isWeekend
        ? (isStart ? (_weekendStartTime ?? const TimeOfDay(hour: 9, minute: 0)) : (_weekendEndTime ?? const TimeOfDay(hour: 21, minute: 0)))
        : (isStart ? _startTime : _endTime);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isWeekend) {
          if (isStart) {
            _weekendStartTime = picked;
          } else {
            _weekendEndTime = picked;
          }
        } else {
          if (isStart) {
            _startTime = picked;
          } else {
            _endTime = picked;
          }
        }
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final service = ref.read(digitalDetoxServiceLocalProvider);
      final config = await service.getOrCreateConfig(userId);

      config.enableTimeWindow = _enableTimeWindow;
      config.allowedStartTime = _formatTime(_startTime);
      config.allowedEndTime = _formatTime(_endTime);
      config.blockOnWeekends = _blockOnWeekends;
      config.weekendAllowedStartTime = _weekendStartTime != null ? _formatTime(_weekendStartTime!) : null;
      config.weekendAllowedEndTime = _weekendEndTime != null ? _formatTime(_weekendEndTime!) : null;

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

  bool _isValidTimeRange(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isValidWeekday = _isValidTimeRange(_startTime, _endTime);
    final isValidWeekend = !_blockOnWeekends || (_weekendStartTime != null && _weekendEndTime != null && _isValidTimeRange(_weekendStartTime!, _weekendEndTime!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Horários'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: (isValidWeekday && isValidWeekend) ? _saveSettings : null,
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
                  'Ativar Bloqueio por Horário',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Permitir uso de apps apenas em horários específicos'),
                value: _enableTimeWindow,
                onChanged: (value) {
                  setState(() {
                    _enableTimeWindow = value;
                    _hasChanges = true;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            if (_enableTimeWindow) ...[
              // HorÃ¡rios de semana
              Text(
                'Horário Permitido (Segunda a Sexta)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimeCard(
                      label: 'Início',
                      time: _startTime,
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TimeCard(
                      label: 'Fim',
                      time: _endTime,
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
              if (!isValidWeekday)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'O horÃ¡rio de fim deve ser depois do horÃ¡rio de inÃ­cio',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // ConfiguraÃ§Ã£o de fins de semana
              Card(
                child: SwitchListTile(
                  title: const Text(
                    'Horário Diferente nos Fins de Semana',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Sábado e Domingo'),
                  value: _blockOnWeekends,
                  onChanged: (value) {
                    setState(() {
                      _blockOnWeekends = value;
                      if (value && _weekendStartTime == null) {
                        _weekendStartTime = const TimeOfDay(hour: 9, minute: 0);
                        _weekendEndTime = const TimeOfDay(hour: 21, minute: 0);
                      }
                      _hasChanges = true;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              if (_blockOnWeekends) ...[
                Text(
                  'Horário Permitido (Fins de Semana)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TimeCard(
                        label: 'Início',
                        time: _weekendStartTime ?? const TimeOfDay(hour: 9, minute: 0),
                        onTap: () => _selectTime(context, true, isWeekend: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.arrow_forward),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _TimeCard(
                        label: 'Fim',
                        time: _weekendEndTime ?? const TimeOfDay(hour: 21, minute: 0),
                        onTap: () => _selectTime(context, false, isWeekend: true),
                      ),
                    ),
                  ],
                ),
                if (!isValidWeekend)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'O horário de fim deve ser depois do horário de início',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                    ),
                  ),
              ],

              const SizedBox(height: 24),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Como funciona',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¢ Fora dos horários permitidos, os apps selecionados serão bloqueados\n'
                      '¢ Ao tentar abrir um app fora do horário, a tela de bloqueio aparecerá\n'
                      '¢ O módulo deve estar ativo para o bloqueio funcionar',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (!_enableTimeWindow)
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
                        'O bloqueio por horário está desativado. Os apps selecionados serão monitorados 24h por dia.',
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

/// Widget auxiliar para exibir um cartão de horário
class _TimeCard extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeCard({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
