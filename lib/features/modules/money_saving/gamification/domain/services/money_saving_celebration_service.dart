import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/gamification/services/achievement_notification_service.dart';

/// Eventos específicos do módulo Money Saving
class MoneySavingMedalhaConquistadaEvent extends AppEvent {
  final String medalhaId;
  final String medalhaName;
  
  MoneySavingMedalhaConquistadaEvent({
    required this.medalhaId,
    required this.medalhaName,
  });
  
  String get eventType => 'money_saving_medalha_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'medalhaId': medalhaId,
    'medalhaName': medalhaName,
  };
}

class MoneySavingInsigniaConquistadaEvent extends AppEvent {
  final String insigniaId;
  final String insigniaName;
  
  MoneySavingInsigniaConquistadaEvent({
    required this.insigniaId,
    required this.insigniaName,
  });
  
  String get eventType => 'money_saving_insignia_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'insigniaId': insigniaId,
    'insigniaName': insigniaName,
  };
}

class MoneySavingMarcoEconomiaEvent extends AppEvent {
  final double valorEconomizado;
  final String mensagem;
  
  MoneySavingMarcoEconomiaEvent({
    required this.valorEconomizado,
    required this.mensagem,
  });
  
  String get eventType => 'money_saving_marco_economia';
  
  @override
  Map<String, dynamic> get data => {
    'valorEconomizado': valorEconomizado,
    'mensagem': mensagem,
  };
}

class MoneySavingDesafioCompletoEvent extends AppEvent {
  final String desafioId;
  final String desafioName;
  final double valorTotal;
  
  MoneySavingDesafioCompletoEvent({
    required this.desafioId,
    required this.desafioName,
    required this.valorTotal,
  });
  
  String get eventType => 'money_saving_desafio_completo';
  
  @override
  Map<String, dynamic> get data => {
    'desafioId': desafioId,
    'desafioName': desafioName,
    'valorTotal': valorTotal,
  };
}

/// Service de celebração específico do módulo Money Saving
/// Gerencia celebrações visuais e táteis para conquistas
class MoneySavingCelebrationService {
  static MoneySavingCelebrationService? _instance;
  static MoneySavingCelebrationService get instance => _instance ??= MoneySavingCelebrationService._();
  
  MoneySavingCelebrationService._();

  /// Celebra conquista de medalha com confetes e feedback tátil
  Future<void> celebrarMedalhaConquistada({
    required String medalhaId,
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('🎉 Iniciando celebração medalha Money Saving: $medalhaName');

      EventBus.instance.emit(MoneySavingMedalhaConquistadaEvent(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      ));

      await _playMedalhaHapticFeedback(medalhaId);

      // Notificação global de conquista
      await AchievementNotificationService.instance.showMedalhaNotification(
        moduleId: 'moneySavingChallenge',
        medalhaId: medalhaId,
        medalhaName: medalhaName,
        medalhaDescription: medalhaDescription,
        assetPath: assetPath,
        rarity: medalhaId,
      );

      LoggerService.instance.gamification('🏆 Celebração medalha Money Saving $medalhaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha Money Saving', error: e);
    }
  }

  /// Celebra conquista de insígnia
  Future<void> celebrarInsigniaConquistada({
    required String insigniaId,
    required String insigniaName,
    String? insigniaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('⭐ Iniciando celebração insígnia Money Saving: $insigniaName');

      EventBus.instance.emit(MoneySavingInsigniaConquistadaEvent(
        insigniaId: insigniaId,
        insigniaName: insigniaName,
      ));

      await SystemAudioService.instance.playHapticFeedback('medio');

      // Notificação global de conquista
      await AchievementNotificationService.instance.showInsigniaNotification(
        moduleId: 'moneySavingChallenge',
        insigniaId: insigniaId,
        insigniaName: insigniaName,
        insigniaDescription: insigniaDescription,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✨ Celebração insígnia Money Saving $insigniaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de insígnia Money Saving', error: e);
    }
  }

  /// Celebra marco de economia
  Future<void> celebrarMarcoEconomia({
    required double valorEconomizado,
    required String mensagem,
  }) async {
    try {
      LoggerService.instance.gamification('💰 Iniciando celebração marco Money Saving: R\$ $valorEconomizado');
      
      EventBus.instance.emit(MoneySavingMarcoEconomiaEvent(
        valorEconomizado: valorEconomizado,
        mensagem: mensagem,
      ));
      
      await SystemAudioService.instance.playHapticFeedback('leve');
      
      // Notificação global de marco econômico
      await AchievementNotificationService.instance.showSpecialAchievementNotification(
        moduleId: 'moneySavingChallenge',
        achievementId: 'marco_economia_${valorEconomizado.toStringAsFixed(0)}',
        title: '💰 Marco Alcançado!',
        body: mensagem,
      );
      
      LoggerService.instance.gamification('🌟 Celebração marco Money Saving R\$ $valorEconomizado concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de marco Money Saving', error: e);
    }
  }

  /// Celebra desafio completo - evento especial com confetes intensos
  Future<void> celebrarDesafioCompleto({
    required String desafioId,
    required String desafioName,
    required double valorTotal,
  }) async {
    try {
      LoggerService.instance.gamification('🎊 Iniciando celebração DESAFIO COMPLETO Money Saving: $desafioName - R\$ $valorTotal');

      EventBus.instance.emit(MoneySavingDesafioCompletoEvent(
        desafioId: desafioId,
        desafioName: desafioName,
        valorTotal: valorTotal,
      ));

      // Feedback tátil épico para desafio completo
      await SystemAudioService.instance.playConquestSound('epico', volume: 1.0);

      // Notificação global de desafio completo
      await AchievementNotificationService.instance.showSpecialAchievementNotification(
        moduleId: 'moneySavingChallenge',
        achievementId: 'desafio_completo_$desafioId',
        title: '🎉🎉🎉 Desafio Completo!',
        body: 'Parabéns! Você completou o desafio "$desafioName" e economizou R\$ $valorTotal!',
      );

      LoggerService.instance.gamification('🎊🎊🎊 Celebração DESAFIO COMPLETO Money Saving $desafioName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de desafio completo Money Saving', error: e);
    }
  }

  /// Feedback tátil baseado na raridade da medalha
  Future<void> _playMedalhaHapticFeedback(String medalhaId) async {
    try {
      switch (medalhaId) {
        case 'bronze':
          await SystemAudioService.instance.playHapticFeedback('medio');
          break;
        case 'prata':
          await SystemAudioService.instance.playHapticFeedback('medio');
          await Future.delayed(const Duration(milliseconds: 100));
          await SystemAudioService.instance.playHapticFeedback('forte');
          break;
        case 'ouro':
          await SystemAudioService.instance.playHapticFeedback('leve');
          await Future.delayed(const Duration(milliseconds: 80));
          await SystemAudioService.instance.playHapticFeedback('medio');
          await Future.delayed(const Duration(milliseconds: 80));
          await SystemAudioService.instance.playHapticFeedback('forte');
          break;
        case 'diamante':
          await SystemAudioService.instance.playConquestSound('epico', volume: 1.0);
          break;
        default:
          await SystemAudioService.instance.playHapticFeedback('medio');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao reproduzir feedback tátil', error: e);
    }
  }

  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      LoggerService.instance.gamification('MoneySavingCelebrationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar MoneySavingCelebrationService', error: e);
    }
  }

  /// Limpa recursos
  void dispose() {
    LoggerService.instance.gamification('MoneySavingCelebrationService disposed');
  }
}
