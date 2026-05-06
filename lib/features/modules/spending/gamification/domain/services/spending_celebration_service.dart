import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/gamification/services/achievement_notification_service.dart';

/// Eventos específicos do módulo Spending
class SpendingMedalhaConquistadaEvent extends AppEvent {
  final String medalhaId;
  final String medalhaName;
  
  SpendingMedalhaConquistadaEvent({
    required this.medalhaId,
    required this.medalhaName,
  });
  
  String get eventType => 'spending_medalha_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'medalhaId': medalhaId,
    'medalhaName': medalhaName,
  };
}

class SpendingInsigniaConquistadaEvent extends AppEvent {
  final String insigniaId;
  final String insigniaName;
  
  SpendingInsigniaConquistadaEvent({
    required this.insigniaId,
    required this.insigniaName,
  });
  
  String get eventType => 'spending_insignia_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'insigniaId': insigniaId,
    'insigniaName': insigniaName,
  };
}

class SpendingMarcoEconomiaEvent extends AppEvent {
  final double valorEconomizado;
  final String mensagem;
  
  SpendingMarcoEconomiaEvent({
    required this.valorEconomizado,
    required this.mensagem,
  });
  
  String get eventType => 'spending_marco_economia';
  
  @override
  Map<String, dynamic> get data => {
    'valorEconomizado': valorEconomizado,
    'mensagem': mensagem,
  };
}

/// Service de celebração específico do módulo Spending
class SpendingCelebrationService {
  static SpendingCelebrationService? _instance;
  static SpendingCelebrationService get instance => _instance ??= SpendingCelebrationService._();
  
  SpendingCelebrationService._();

  Future<void> celebrarMedalhaConquistada({
    required String medalhaId,
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('🎉 Iniciando celebração medalha Spending: $medalhaName');

      EventBus.instance.emit(SpendingMedalhaConquistadaEvent(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      ));

      await _playMedalhaHapticFeedback(medalhaId);

      await AchievementNotificationService.instance.showMedalhaNotification(
        moduleId: 'spending',
        medalhaId: medalhaId,
        medalhaName: medalhaName,
        medalhaDescription: medalhaDescription,
        assetPath: assetPath,
        rarity: medalhaId,
      );

      LoggerService.instance.gamification('🏆 Celebração medalha Spending $medalhaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha Spending', error: e);
    }
  }

  Future<void> celebrarInsigniaConquistada({
    required String insigniaId,
    required String insigniaName,
    String? insigniaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('⭐ Iniciando celebração insígnia Spending: $insigniaName');

      EventBus.instance.emit(SpendingInsigniaConquistadaEvent(
        insigniaId: insigniaId,
        insigniaName: insigniaName,
      ));

      await SystemAudioService.instance.playHapticFeedback('medio');

      await AchievementNotificationService.instance.showInsigniaNotification(
        moduleId: 'spending',
        insigniaId: insigniaId,
        insigniaName: insigniaName,
        insigniaDescription: insigniaDescription,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✨ Celebração insígnia Spending $insigniaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de insígnia Spending', error: e);
    }
  }

  Future<void> celebrarMarcoEconomia({
    required double valorEconomizado,
    required String mensagem,
  }) async {
    try {
      LoggerService.instance.gamification('💰 Iniciando celebração marco Spending: R\$ $valorEconomizado');
      
      EventBus.instance.emit(SpendingMarcoEconomiaEvent(
        valorEconomizado: valorEconomizado,
        mensagem: mensagem,
      ));
      
      await SystemAudioService.instance.playHapticFeedback('leve');
      
      await AchievementNotificationService.instance.showSpecialAchievementNotification(
        moduleId: 'spending',
        achievementId: 'marco_economia_${valorEconomizado.toStringAsFixed(0)}',
        title: '💰 Marco Alcançado!',
        body: mensagem,
      );
      
      LoggerService.instance.gamification('🌟 Celebração marco Spending R\$ $valorEconomizado concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de marco Spending', error: e);
    }
  }

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

  Future<void> initialize() async {
    try {
      LoggerService.instance.gamification('SpendingCelebrationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar SpendingCelebrationService', error: e);
    }
  }

  void dispose() {
    LoggerService.instance.gamification('SpendingCelebrationService disposed');
  }
}
