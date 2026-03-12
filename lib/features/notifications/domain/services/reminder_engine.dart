import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/notifications/domain/services/motivation_engine.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Engine dedicado a programar lembretes (Check-ins e Hábitos) usando
/// de forma transparente os canais nativos.
class ReminderEngine {
  static final ReminderEngine instance = ReminderEngine._internal();
  ReminderEngine._internal();

  Future<void> scheduleModuleReminders({
    required NicheId nicheId,
    required List<TimeOfDay> times,
    List<String>? customPhrases,
  }) async {
    // 1. Limpa lembretes anteriores para este módulo para evitar duplicação
    // Aqui assumimos que os canais de módulos são agrupados de alguma forma
    // Em uma implementação real do NotificationScheduler, cancelaríamos os IDs previsíveis

    // 2. Agenda novos lembretes baseados nos horários
    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      final phrase = MotivationEngine.instance
          .getMotivationPhrase(nicheId, customPhrases: customPhrases);

      // Disparador seria substituído pelo NotificationScheduler da lib do FlutterLocals
      // Este é um mock arquitetural de como o ReminderEngine lidará com isso separando responsabilidades
      LoggerService.instance.d(
          "Scheduling reminder at ${time.hour}:${time.minute} for $nicheId -> $phrase");
    }
  }

  Future<void> cancelAllReminders(NicheId nicheId) async {
    // Cancela na lib local
  }
}
