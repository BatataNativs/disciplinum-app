import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service_local.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tela de configuracao de horarios do Controle de Gastos
class SpendingTimeSettingsScreen extends StatefulWidget {
  const SpendingTimeSettingsScreen({super.key});

  @override
  State<SpendingTimeSettingsScreen> createState() =>
      _SpendingTimeSettingsScreenState();
}

class _SpendingTimeSettingsScreenState
    extends State<SpendingTimeSettingsScreen> {
  bool _enableTimeWindow = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  bool _blockOnWeekends = false;
  TimeOfDay? _weekendStartTime;
  TimeOfDay? _weekendEndTime;

  bool _isLoading = true;
  bool _hasChanges = false;

  String get _userId =>
      Supabase.instance.client.auth.currentUser?.id ?? 'guest_user';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final config =
          await SpendingServiceLocal.instance.getOrCreateConfig(_userId);
      if (mounted) {
        setState(() {
          _enableTimeWindow = config.enableTimeWindow;
          _startTime = _parseTimeString(config.allowedStartTime) ??
              const TimeOfDay(hour: 8, minute: 0);
          _endTime = _parseTimeString(config.allowedEndTime) ??
              const TimeOfDay(hour: 22, minute: 0);
          _blockOnWeekends = config.blockOnWeekends;
          _weekendStartTime = _parseTimeString(config.weekendAllowedStartTime);
          _weekendEndTime = _parseTimeString(config.weekendAllowedEndTime);
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.instance
          .e('Erro ao carregar config de horario Spending', error: e);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TimeOfDay? _parseTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  bool _isValidTimeRange(TimeOfDay start, TimeOfDay end) {
    final s = start.hour * 60 + start.minute;
    final e = end.hour * 60 + end.minute;
    return e > s;
  }

  Future<void> _selectTime(BuildContext context, bool isStart,
      {bool isWeekend = false}) async {
    final initialTime = isWeekend
        ? (isStart
            ? (_weekendStartTime ?? const TimeOfDay(hour: 9, minute: 0))
            : (_weekendEndTime ?? const TimeOfDay(hour: 21, minute: 0)))
        : (isStart ? _startTime : _endTime);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
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
      final config =
          await SpendingServiceLocal.instance.getOrCreateConfig(_userId);
      config.enableTimeWindow = _enableTimeWindow;
      config.allowedStartTime = _formatTime(_startTime);
      config.allowedEndTime = _formatTime(_endTime);
      config.blockOnWeekends = _blockOnWeekends;
      config.weekendAllowedStartTime =
          _weekendStartTime != null ? _formatTime(_weekendStartTime!) : null;
      config.weekendAllowedEndTime =
          _weekendEndTime != null ? _formatTime(_weekendEndTime!) : null;

      await SpendingServiceLocal.instance.saveConfig(config);

      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuracoes salvas!')));
      }
    } catch (e) {
      LoggerService.instance
          .e('Erro ao salvar config horario Spending', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isValidWeekday = _isValidTimeRange(_startTime, _endTime);
    final isValidWeekend = !_blockOnWeekends ||
        (_weekendStartTime != null &&
            _weekendEndTime != null &&
            _isValidTimeRange(_weekendStartTime!, _weekendEndTime!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Horarios'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed:
                  (isValidWeekday && isValidWeekend) ? _saveSettings : null,
              child:
                  const Text('SALVAR', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle - Bloqueio por horario
            Card(
              child: SwitchListTile(
                title: const Text('Bloqueio por horario',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                    'Bloquear apps de compras apenas em horarios especificos'),
                value: _enableTimeWindow,
                activeThumbColor: const Color(0xFF8B5CF6),
                activeTrackColor:
                    const Color(0xFF8B5CF6).withValues(alpha: 0.3),
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
              Text('Horario Permitido (Segunda a Sexta)',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimeCard(
                      label: 'Inicio',
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
                    'O horario de fim deve ser depois do inicio',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
              Card(
                child: SwitchListTile(
                  title: const Text('Horario Diferente nos Fins de Semana',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Sabado e Domingo'),
                  value: _blockOnWeekends,
                  activeThumbColor: const Color(0xFF8B5CF6),
                  activeTrackColor:
                      const Color(0xFF8B5CF6).withValues(alpha: 0.3),
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
                Text('Horario Permitido (Fins de Semana)',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TimeCard(
                        label: 'Inicio',
                        time: _weekendStartTime ??
                            const TimeOfDay(hour: 9, minute: 0),
                        onTap: () =>
                            _selectTime(context, true, isWeekend: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.arrow_forward),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _TimeCard(
                        label: 'Fim',
                        time: _weekendEndTime ??
                            const TimeOfDay(hour: 21, minute: 0),
                        onTap: () =>
                            _selectTime(context, false, isWeekend: true),
                      ),
                    ),
                  ],
                ),
                if (!isValidWeekend)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'O horario de fim deve ser depois do inicio',
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 12),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.info_outline, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      Text('Como funciona',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700)),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      'Fora dos horarios permitidos, os apps de compras serao bloqueados.\n'
                      'Ao tentar abrir um app fora do horario, a tela de bloqueio aparecera.\n'
                      'O modulo deve estar ativo para o bloqueio funcionar.',
                      style:
                          TextStyle(color: Colors.purple.shade700, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],

            if (!_enableTimeWindow)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline,
                      color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O bloqueio por horario esta desativado. Os apps de compras selecionados serao monitorados 24h por dia.',
                      style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

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
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ]),
      ),
    );
  }
}
