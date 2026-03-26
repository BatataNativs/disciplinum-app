import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart' show sendModuleNotification;

/// Service para notificações especiais do módulo Smoking
/// Baseado exatamente nas especificações do usuário
class SmokingSpecialNotificationsService {
  static SmokingSpecialNotificationsService? _instance;
  static SmokingSpecialNotificationsService get instance => _instance ??= SmokingSpecialNotificationsService._();
  
  SmokingSpecialNotificationsService._();

  /// Envia notificação especial de saúde com base nos dias sem fumar
  Future<void> sendHealthNotification(int daysWithoutSmoking) async {
    try {
      String title = '';
      String body = '';
      bool shouldSend = false;

      switch (daysWithoutSmoking) {
        case 0:
          // 20 minutos - Pressão arterial normal
          title = 'Saúde em Melhora! 🎊';
          body = 'Sua pressão arterial e frequência cardíaca tem potencial de melhora após 20 minutos. Continue!';
          shouldSend = true;
          break;
        case 1:
          // 1 dia - Sem monóxido de carbono
          title = 'Liberando-se do Monóxido! 🎊';
          body = 'Seus níveis de monóxido de carbono no sangue podem diminuir drasticamente após 1 dia. Continue!';
          shouldSend = true;
          break;
        case 2:
          // 2 dias - Olfato e paladar melhoram
          title = 'Sentidos Revitalizados! 🎊';
          body = 'Olfato e paladar costumam melhorar após 2 dias. Aproveite. E continue!';
          shouldSend = true;
          break;
        case 3:
          // 3 dias - Respiração mais fácil
          title = 'Respiração Facilitada! 🎊';
          body = 'Sua respiração tende a melhorar após 3 dias. Provavelmente vai conseguir dormir melhor. E continue!';
          shouldSend = true;
          break;
        case 14:
          // 14 dias - Circulação melhora
          title = 'Circulação Ativada! 🎊';
          body = 'Sua circulação tende a melhorar após 14 dias. Tente caminhar mais após isso. Continue!';
          shouldSend = true;
          break;
        case 90:
          // 90 dias - Função pulmonar +10%
          title = 'Pulmões Fortalecidos! 🎊';
          body = 'Sua função pulmonar pode ter tido uma melhora de uns 10% após 90 dias. Aproveite mais a vida! E continue em frente!';
          shouldSend = true;
          break;
      }

      if (shouldSend) {
        await sendModuleNotification(
          body,
          title: title,
          id: DateTime.now().millisecondsSinceEpoch % 10000,
          payload: 'smoking_health_$daysWithoutSmoking',
        );
        
        LoggerService.instance.gamification('Notificação de saúde enviada: $daysWithoutSmoking dias');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificação de saúde', error: e);
    }
  }

  /// Envia notificação especial de economia com base nos maços economizados
  Future<void> sendEconomyNotification(int packsSaved) async {
    try {
      bool shouldSend = false;
      String body = '';

      switch (packsSaved) {
        case 1:
        case 2:
        case 5:
        case 10:
        case 20:
        case 30:
          shouldSend = true;
          body = 'Economizou o valor de $packsSaved ${packsSaved == 1 ? "maço" : "maços"}';
          break;
      }

      if (shouldSend) {
        await sendModuleNotification(
          body,
          title: 'Economia Conquistada! 🎊',
          id: DateTime.now().millisecondsSinceEpoch % 10000,
          payload: 'smoking_economy_$packsSaved',
        );
        
        LoggerService.instance.gamification('Notificação de economia enviada: $packsSaved maços');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificação de economia', error: e);
    }
  }

  /// Obtém a mensagem de saúde para exibição em janelinha flutuante
  String getHealthMessage(int daysWithoutSmoking) {
    switch (daysWithoutSmoking) {
      case 0:
        return 'Parabéns 🎊! Sua pressão arterial e frequência cardíaca tem potencial de melhora após 20 minutos. Continue!';
      case 1:
        return 'Parabéns 🎊! Seus níveis de monóxido de carbono no sangue podem diminuir drasticamente após 1 dia. Continue!';
      case 2:
        return 'Parabéns 🎊! Olfato e paladar costumam melhorar após 2 dias. Aproveite. E continue!';
      case 3:
        return 'Parabéns 🎊! Sua respiração tende a melhorar após 3 dias. Provavelmente vai conseguir dormir melhor. E continue!';
      case 14:
        return 'Parabéns 🎊! Sua circulação tende a melhorar após 14 dias. Tente caminhar mais após isso. Continue!';
      case 90:
        return 'Parabéns 🎊! Sua função pulmonar pode ter tido uma melhora de uns 10% após 90 dias. Aproveite mais a vida! E continue em frente!';
      default:
        return '';
    }
  }

  /// Obtém a mensagem de economia para exibição em janelinha flutuante
  String getEconomyMessage(int packsSaved) {
    return 'Parabéns 🎊! Economizou o valor de $packsSaved ${packsSaved == 1 ? "maço" : "maços"}';
  }

  /// Verifica se deve mostrar notificação de saúde para estes dias
  bool shouldShowHealthNotification(int daysWithoutSmoking) {
    return [0, 1, 2, 3, 14, 90].contains(daysWithoutSmoking);
  }

  /// Verifica se deve mostrar notificação de economia para estes valores
  bool shouldShowEconomyNotification(int packsSaved) {
    return [1, 2, 5, 10, 20, 30].contains(packsSaved);
  }

  /// Obtém todos os marcos de saúde
  List<int> getHealthMilestones() {
    return [0, 1, 2, 3, 14, 90];
  }

  /// Obtém todos os marcos de economia
  List<int> getEconomyMilestones() {
    return [1, 2, 5, 10, 20, 30];
  }

  /// Calcula maços economizados baseado no valor diário e dias sem fumar
  int calculatePacksSaved(double dailyCost, int daysWithoutSmoking, double packCost) {
    if (packCost <= 0) return 0;
    
    final totalSaved = dailyCost * daysWithoutSmoking;
    return (totalSaved / packCost).floor();
  }
}
