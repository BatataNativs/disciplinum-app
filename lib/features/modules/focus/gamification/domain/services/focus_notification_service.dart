import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart' show sendModuleNotification;

/// Service de notificações específico do módulo Focus
/// Gerencia notificações de milestones e motivação
class FocusNotificationService {

  /// Envia notificação de milestone alcançado
  Future<void> sendMilestoneNotification(int periods, String nextInsignia) async {
    try {
      final title = '🎯 Milestone Alcançado!';
      final body = 'Você completou $periods períodos de foco! Continue assim para conquistar a insígnia $nextInsignia.';
      
      await sendModuleNotification(
        body,
        title: title,
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        payload: 'focus_milestone_$periods',
      );
      
      LoggerService.instance.gamification('Notificação de milestone enviada: $periods períodos');
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificação de milestone', error: e);
    }
  }

  /// Envia notificação motivacional
  Future<void> sendMotivationalNotification(int currentPeriods, String targetInsignia) async {
    try {
      final title = '💪 Quase lá!';
      final body = 'Você está com $currentPeriods períodos de foco! Faltam poucos para conquistar $targetInsignia. Não desista!';
      
      await sendModuleNotification(
        body,
        title: title,
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        payload: 'focus_motivational_$currentPeriods',
      );
      
      LoggerService.instance.gamification('Notificação motivacional enviada: $currentPeriods períodos');
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificação motivacional', error: e);
    }
  }

  /// Envia notificação de conquista de medalha
  Future<void> sendMedalhaNotification(String medalhaName) async {
    try {
      final title = '🏆 Nova Medalha!';
      final body = 'Parabéns! Você conquistou a medalha $medalhaName no módulo Foco!';
      
      await sendModuleNotification(
        body,
        title: title,
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        payload: 'focus_medalha_$medalhaName',
      );
      
      LoggerService.instance.gamification('Notificação de medalha enviada: $medalhaName');
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificação de medalha', error: e);
    }
  }

  /// Envia notificação de conquista de insígnia Disciplinum
  Future<void> sendDisciplinumNotification(int disciplinumCount) async {
    try {
      final title = '⭐ Disciplinum Conquistado!';
      final body = 'Incrível! Você conquistou sua ${_getOrdinalNumber(disciplinumCount)} insígnia Disciplinum!';
      
      await sendModuleNotification(
        body,
        title: title,
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        payload: 'focus_disciplinum_$disciplinumCount',
      );
      
      LoggerService.instance.gamification('Notificação Disciplinum enviada: $disciplinumCount');
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificação Disciplinum', error: e);
    }
  }

  /// Obtém número ordinal (1º, 2º, 3º, etc.)
  String _getOrdinalNumber(int number) {
    switch (number) {
      case 1:
        return '1ª';
      case 2:
        return '2ª';
      case 3:
        return '3ª';
      case 4:
        return '4ª';
      default:
        return '$numberª';
    }
  }

  /// Envia notificação de reset de progresso
  Future<void> sendResetNotification() async {
    try {
      final title = '🔄 Progresso Resetado';
      final body = 'Seu progresso de foco foi resetado. Não desista, comece novamente hoje mesmo!';
      
      await sendModuleNotification(
        body,
        title: title,
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        payload: 'focus_reset',
      );
      
      LoggerService.instance.gamification('Notificação de reset enviada');
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificação de reset', error: e);
    }
  }
}
