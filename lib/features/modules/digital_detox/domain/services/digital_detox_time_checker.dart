import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_config_entity.dart';

/// ServiÃ§o para verificar se o usuÃ¡rio estÃ¡ dentro do horÃ¡rio permitido
/// para usar apps durante o Jejum Digital
class DigitalDetoxTimeChecker {
  /// Verifica se o horÃ¡rio atual estÃ¡ dentro da janela permitida
  /// Retorna true se o app PODE ser usado (dentro do horÃ¡rio)
  /// Retorna false se o app deve ser BLOQUEADO (fora do horÃ¡rio)
  static bool isWithinAllowedTime(DigitalDetoxConfigEntity config) {
    // Se nÃ£o tem bloqueio por horÃ¡rio ativado, sempre permite
    if (!config.enableTimeWindow) {
      return true;
    }

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    // Verifica se Ã© fim de semana
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    if (isWeekend && config.blockOnWeekends) {
      // Usa horÃ¡rios de fim de semana
      final weekendStart = _parseTimeString(config.weekendAllowedStartTime);
      final weekendEnd = _parseTimeString(config.weekendAllowedEndTime);

      if (weekendStart == null || weekendEnd == null) {
        // Se nÃ£o configurou horÃ¡rios de fim de semana, usa os padrÃµes
        return _isTimeInRange(currentTime, const TimeOfDay(hour: 9, minute: 0), const TimeOfDay(hour: 21, minute: 0));
      }

      return _isTimeInRange(currentTime, weekendStart, weekendEnd);
    } else {
      // Usa horÃ¡rios de semana
      final start = _parseTimeString(config.allowedStartTime) ?? const TimeOfDay(hour: 8, minute: 0);
      final end = _parseTimeString(config.allowedEndTime) ?? const TimeOfDay(hour: 22, minute: 0);

      return _isTimeInRange(currentTime, start, end);
    }
  }

  /// Verifica se um horÃ¡rio estÃ¡ dentro de um range
  static bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    // Caso simples: start < end (ex: 08:00 - 22:00)
    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    }

    // Caso onde atravessa meia-noite (ex: 22:00 - 08:00)
    return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
  }

  /// Converte string de horÃ¡rio (HH:MM) para TimeOfDay
  static TimeOfDay? _parseTimeString(String? timeStr) {
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

  /// Retorna uma mensagem descritiva do horÃ¡rio atual
  static String getCurrentTimeWindowMessage(DigitalDetoxConfigEntity config) {
    if (!config.enableTimeWindow) {
      return 'Sem restriÃ§Ã£o de horÃ¡rio';
    }

    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    if (isWeekend && config.blockOnWeekends) {
      final start = config.weekendAllowedStartTime ?? '09:00';
      final end = config.weekendAllowedEndTime ?? '21:00';
      return 'Fim de semana: $start - $end';
    } else {
      return 'Seg-Sex: ${config.allowedStartTime} - ${config.allowedEndTime}';
    }
  }

  /// Verifica se o horÃ¡rio atual estÃ¡ prÃ³ximo do limite (Ãºltimos 5 minutos)
  static bool isNearTimeLimit(DigitalDetoxConfigEntity config) {
    if (!config.enableTimeWindow) return false;

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    TimeOfDay? endTime;
    if (isWeekend && config.blockOnWeekends) {
      endTime = _parseTimeString(config.weekendAllowedEndTime);
    } else {
      endTime = _parseTimeString(config.allowedEndTime);
    }

    if (endTime == null) return false;

    final endMinutes = endTime.hour * 60 + endTime.minute;

    // Considera "prÃ³ximo do limite" se faltam 5 minutos ou menos
    final diff = endMinutes - currentMinutes;
    return diff >= 0 && diff <= 5;
  }

  /// Formata TimeOfDay como string HH:MM
  static String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
