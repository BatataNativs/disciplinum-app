import 'package:disciplinum/shared/widgets/cards/neon_card.dart';
import 'package:disciplinum/shared/widgets/common/glowing_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';

class ReadingSettingsScreen extends ConsumerStatefulWidget {
  const ReadingSettingsScreen({super.key});

  @override
  ConsumerState<ReadingSettingsScreen> createState() => _ReadingSettingsScreenState();
}

class _ReadingSettingsScreenState extends ConsumerState<ReadingSettingsScreen> {
  TimeOfDay? _notificationTime;

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    final time = await ref.read(readingServiceProvider).getSavedNotificationTime();
    if (mounted) {
      setState(() {
        _notificationTime = time;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (!context.mounted) return;

    if (picked != null && picked != _notificationTime) {
      final localContext = context;
      setState(() {
        _notificationTime = picked;
      });
      // Salvar no service
      ref.read(readingServiceProvider).scheduleDailyReminder(picked);

      if (localContext.mounted) {
        EnhancedSnackBarHelper.showSuccess(localContext, 'Horário de leitura atualizado! 📚');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de Lembrete Diário
                NeonCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.notifications_active,
                          size: 40, color: Color(0xFF6366F1)),
                      const SizedBox(height: 16),
                      Text(
                        'Lembrete Diário',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha o melhor horário para ser lembrado do início da sua leitura diária.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GlowingButton(
                              text: _notificationTime != null
                                  ? 'Horário: ${_notificationTime!.format(context)}'
                                  : 'Definir Horário',
                              color: const Color(0xFF6366F1),
                              icon: Icons.access_time,
                              onPressed: () => _selectTime(context),
                            ),
                          ),
                          if (_notificationTime != null) ...[
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                ref.read(readingServiceProvider).cancelDailyReminder();
                                setState(() {
                                  _notificationTime = null;
                                });
                                EnhancedSnackBarHelper.showInfo(context, 'Lembrete removido');
                              },
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              tooltip: 'Remover lembrete',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
