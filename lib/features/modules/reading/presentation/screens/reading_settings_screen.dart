import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/widgets/common/glowing_button.dart';
import 'package:disciplinum/shared/widgets/cards/neon_card.dart';
import 'package:disciplinum/features/notifications/presentation/widgets/notification_message_editor.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';

class ReadingSettingsScreen extends StatefulWidget {
  const ReadingSettingsScreen({super.key});

  @override
  State<ReadingSettingsScreen> createState() => _ReadingSettingsScreenState();
}

class _ReadingSettingsScreenState extends State<ReadingSettingsScreen> {
  TimeOfDay? _notificationTime;

  @override
  void initState() {
    super.initState();
    // Carregar horário salvo
    final service = Provider.of<ReadingService>(context, listen: false);
    _notificationTime = service.savedNotificationTime;
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
      Provider.of<ReadingService>(localContext, listen: false)
          .scheduleDailyReminder(picked);

      if (localContext.mounted) {
        EnhancedSnackBarHelper.showSuccess(localContext, 'Horário de leitura atualizado! 📚');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
              isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Editor de Mensagem Personalizada
                NotificationMessageEditor(nicheId: NicheId.reading),

                const SizedBox(height: 24),

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
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha o melhor horário para sua leitura diária.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
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
                                Provider.of<ReadingService>(context,
                                        listen: false)
                                    .cancelDailyReminder();
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
