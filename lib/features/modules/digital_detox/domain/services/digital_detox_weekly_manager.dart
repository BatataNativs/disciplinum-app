import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_service_local.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';

/// InformaÃ§Ãµes sobre uso semanal
class DigitalDetoxWeeklyInfo {
  final int weeklyLimitMinutes;
  final int usedThisWeek;
  final int remainingThisWeek;
  final int weeklyAverage;
  final DateTime weekStart;
  final DateTime weekEnd;
  final bool isOverLimit;
  final double weeklyProgress;

  const DigitalDetoxWeeklyInfo({
    required this.weeklyLimitMinutes,
    required this.usedThisWeek,
    required this.remainingThisWeek,
    required this.weeklyAverage,
    required this.weekStart,
    required this.weekEnd,
    required this.isOverLimit,
    required this.weeklyProgress,
  });

  /// FormataÃ§Ã£o para exibiÃ§Ã£o
  String get formattedWeeklyLimit => _formatDuration(weeklyLimitMinutes);
  String get formattedUsedThisWeek => _formatDuration(usedThisWeek);
  String get formattedRemaining => _formatDuration(remainingThisWeek);
  String get formattedAverage => _formatDuration(weeklyAverage);

  static String _formatDuration(int minutes) {
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
}

/// EstratÃ©gia de limite semanal
enum WeeklyLimitStrategy {
  strict('Estrito', 'Bloqueia assim que atingir o limite semanal'),
  flexible('FlexÃ­vel', 'Permite exceder com aviso, mas reduz nos dias seguintes');

  const WeeklyLimitStrategy(this.name, this.description);
  final String name;
  final String description;
}

/// Gerenciador de Limites Semanais do Jejum Digital
/// Controla o tempo total de uso por semana
class DigitalDetoxWeeklyManager {
  static final DigitalDetoxWeeklyManager instance = DigitalDetoxWeeklyManager._internal();
  factory DigitalDetoxWeeklyManager() => instance;
  DigitalDetoxWeeklyManager._internal();

  final DigitalDetoxServiceLocal _service = DigitalDetoxServiceLocal.instance;
  Timer? _weeklyResetTimer;

  /// Verifica se o modo semanal estÃ¡ ativo
  Future<bool> isWeeklyLimitEnabled(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      return config.enableWeeklyLimit;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar modo semanal', error: e);
      return false;
    }
  }

  /// ObtÃ©m informaÃ§Ãµes detalhadas do uso semanal
  Future<DigitalDetoxWeeklyInfo> getWeeklyInfo(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      if (!config.enableWeeklyLimit) {
        final now = DateTime.now();
        final weekRange = _getWeekRange(now);
        
        return DigitalDetoxWeeklyInfo(
          weeklyLimitMinutes: 0,
          usedThisWeek: 0,
          remainingThisWeek: 0,
          weeklyAverage: 0,
          weekStart: weekRange.start,
          weekEnd: weekRange.end,
          isOverLimit: false,
          weeklyProgress: 0.0,
        );
      }

      final weekRange = _getWeekRange(DateTime.now());
      final usedThisWeek = await _getWeeklyUsage(userId, weekRange.start, weekRange.end);
      final weeklyLimitMinutes = config.weeklyLimitMinutes;
      final remainingThisWeek = weeklyLimitMinutes - usedThisWeek;
      final weeklyAverage = (usedThisWeek / 7).round();
      final isOverLimit = usedThisWeek > weeklyLimitMinutes;
      final weeklyProgress = (usedThisWeek / weeklyLimitMinutes).clamp(0.0, 2.0);

      return DigitalDetoxWeeklyInfo(
        weeklyLimitMinutes: weeklyLimitMinutes,
        usedThisWeek: usedThisWeek,
        remainingThisWeek: remainingThisWeek,
        weeklyAverage: weeklyAverage,
        weekStart: weekRange.start,
        weekEnd: weekRange.end,
        isOverLimit: isOverLimit,
        weeklyProgress: weeklyProgress,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao obter informaÃ§Ãµes semanais', error: e);
      final now = DateTime.now();
      final weekRange = _getWeekRange(now);
      
      return DigitalDetoxWeeklyInfo(
        weeklyLimitMinutes: 0,
        usedThisWeek: 0,
        remainingThisWeek: 0,
        weeklyAverage: 0,
        weekStart: weekRange.start,
        weekEnd: weekRange.end,
        isOverLimit: false,
        weeklyProgress: 0.0,
      );
    }
  }

  /// Verifica se pode usar mais tempo baseado no limite semanal
  Future<bool> canUseMoreTime(String userId, int additionalMinutes) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      if (!config.enableWeeklyLimit) {
        return true;
      }

      final weeklyInfo = await getWeeklyInfo(userId);
      final strategy = WeeklyLimitStrategy.values.firstWhere(
        (s) => s.name.toLowerCase() == config.weeklyLimitStrategy.toLowerCase(),
        orElse: () => WeeklyLimitStrategy.flexible,
      );

      switch (strategy) {
        case WeeklyLimitStrategy.strict:
          return weeklyInfo.usedThisWeek + additionalMinutes <= weeklyInfo.weeklyLimitMinutes;
          
        case WeeklyLimitStrategy.flexible:
          // Permite exceder em atÃ© 20% com aviso
          final maxAllowed = (weeklyInfo.weeklyLimitMinutes * 1.2).round();
          return weeklyInfo.usedThisWeek + additionalMinutes <= maxAllowed;
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar se pode usar mais tempo', error: e);
      return true; // Em caso de erro, permite uso
    }
  }

  /// Registra uso de tempo e verifica limite semanal
  Future<bool> registerUsage(String userId, int minutes) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      if (!config.enableWeeklyLimit) {
        return true;
      }

      final weeklyInfo = await getWeeklyInfo(userId);
      final strategy = WeeklyLimitStrategy.values.firstWhere(
        (s) => s.name.toLowerCase() == config.weeklyLimitStrategy.toLowerCase(),
        orElse: () => WeeklyLimitStrategy.flexible,
      );

      switch (strategy) {
        case WeeklyLimitStrategy.strict:
          if (weeklyInfo.usedThisWeek + minutes > weeklyInfo.weeklyLimitMinutes) {
            LoggerService.instance.i('Limite semanal estrito atingido - bloqueando uso');
            return false;
          }
          break;
          
        case WeeklyLimitStrategy.flexible:
          final maxAllowed = (weeklyInfo.weeklyLimitMinutes * 1.2).round();
          if (weeklyInfo.usedThisWeek + minutes > maxAllowed) {
            LoggerService.instance.i('Limite semanal flexÃ­vel excedido - bloqueando uso');
            return false;
          }
          
          if (weeklyInfo.usedThisWeek + minutes > weeklyInfo.weeklyLimitMinutes) {
            LoggerService.instance.i('Aviso: excedendo limite semanal flexÃ­vel');
            // Implementar notificaÃ§Ã£o de aviso semanal
            final remainingMinutes = weeklyInfo.weeklyLimitMinutes - weeklyInfo.usedThisWeek;
            _sendWeeklyWarningNotification(userId, remainingMinutes);
          }
          break;
      }

      // Registra o uso
      await _addWeeklyUsage(userId, minutes);
      LoggerService.instance.gamification('Uso semanal registrado: $minutes minutos');
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro ao registrar uso semanal', error: e);
      return true; // Em caso de erro, permite uso
    }
  }

  /// ObtÃ©m sugestÃ£o de limite diÃ¡rio baseado no semanal
  Future<int> getSuggestedDailyLimit(String userId) async {
    try {
      final config = await _service.getOrCreateConfig(userId);
      
      if (!config.enableWeeklyLimit) {
        return config.dailyLimitMinutes;
      }

      final weeklyInfo = await getWeeklyInfo(userId);
      final daysRemaining = _getDaysRemainingInWeek();
      
      if (daysRemaining <= 0) {
        return 0; // Semana acabando, sem tempo disponÃ­vel
      }

      final remainingMinutes = weeklyInfo.remainingThisWeek;
      final suggestedDaily = (remainingMinutes / daysRemaining).round();
      
      // Limita a um valor razoÃ¡vel (mÃ­nimo 15 minutos)
      return suggestedDaily.clamp(15, config.dailyLimitMinutes);
    } catch (e) {
      LoggerService.instance.e('Erro ao calcular sugestÃ£o diÃ¡ria', error: e);
      return 60; // Default fallback
    }
  }

  /// Reseta o uso semanal (chamado no inÃ­cio da semana)
  Future<void> resetWeeklyUsage(String userId) async {
    try {
      await _clearWeeklyUsage(userId);
      LoggerService.instance.gamification('Uso semanal resetado para $userId');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar uso semanal', error: e);
    }
  }

  /// Inicia timer para reset semanal automÃ¡tico
  void startWeeklyResetTimer() {
    _weeklyResetTimer?.cancel();
    
    final now = DateTime.now();
    final nextWeek = _getNextWeekStart(now);
    final timeUntilNextWeek = nextWeek.difference(now);
    
    _weeklyResetTimer = Timer(timeUntilNextWeek, () async {
      LoggerService.instance.i('Iniciando reset semanal');
      // O timer apenas reagenda - o processamento real ocorre via resetWeeklyUsage(userId)
      _scheduleNextWeeklyReset();
    });
    
    LoggerService.instance.i('Timer semanal configurado para: ${nextWeek.toString()}');
  }

  /// Envia notificaÃ§Ã£o de aviso semanal
  Future<void> _sendWeeklyWarningNotification(String userId, int remainingMinutes) async {
    try {
      await NotificationService.showNotification(
        id: 9001,
        title: 'âš ï¸ Limite Semanal PrÃ³ximo',
        body: 'Restam $remainingMinutes minutos do seu limite semanal',
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao mostrar notificaÃ§Ã£o semanal', error: e);
    }
  }

  /// Agenda prÃ³ximo reset semanal
  void _scheduleNextWeeklyReset() {
    final now = DateTime.now();
    final nextWeek = _getNextWeekStart(now);
    final timeUntilNextWeek = nextWeek.difference(now);
    
    _weeklyResetTimer = Timer(timeUntilNextWeek, () async {
      LoggerService.instance.i('Iniciando reset semanal');
      _scheduleNextWeeklyReset();
    });
  }

  /// ObtÃ©m o intervalo da semana atual (Domingo a SÃ¡bado)
  ({DateTime start, DateTime end}) _getWeekRange(DateTime date) {
    final now = date;
    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    return (start: startOfWeek, end: endOfWeek);
  }

  /// ObtÃ©m o inÃ­cio da prÃ³xima semana
  DateTime _getNextWeekStart(DateTime now) {
    final currentWeek = _getWeekRange(now);
    return currentWeek.start.add(const Duration(days: 7));
  }

  /// ObtÃ©m dias restantes na semana atual
  int _getDaysRemainingInWeek() {
    final now = DateTime.now();
    final weekEnd = _getWeekRange(now).end;
    final remaining = weekEnd.difference(now).inDays;
    return remaining.clamp(0, 7);
  }

  /// ObtÃ©m uso semanal (simulaÃ§Ã£o)
  Future<int> _getWeeklyUsage(String userId, DateTime weekStart, DateTime weekEnd) async {
    // Na implementaÃ§Ã£o real, viria do TimeTracker ou repositÃ³rio especÃ­fico
    // Por agora, retorna 0 para permitir testes
    return 0;
  }

  /// Adiciona uso semanal (simulaÃ§Ã£o)
  Future<void> _addWeeklyUsage(String userId, int minutes) async {
    // Na implementaÃ§Ã£o real, salvaria no repositÃ³rio de uso semanal
    LoggerService.instance.i('Adicionando $minutes minutos ao uso semanal para $userId');
  }

  /// Limpa uso semanal (simulaÃ§Ã£o)
  Future<void> _clearWeeklyUsage(String userId) async {
    // Na implementaÃ§Ã£o real, limparia o repositÃ³rio de uso semanal
    LoggerService.instance.i('Limpando uso semanal para $userId');
  }

  /// Limpa recursos
  void dispose() {
    _weeklyResetTimer?.cancel();
    _weeklyResetTimer = null;
  }
}
