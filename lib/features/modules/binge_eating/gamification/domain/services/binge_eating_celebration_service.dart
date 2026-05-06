import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/gamification/services/achievement_notification_service.dart';

/// Eventos específicos do módulo Binge Eating
class BingeEatingMedalhaConquistadaEvent extends AppEvent {
  final String medalhaId;
  final String medalhaName;
  
  BingeEatingMedalhaConquistadaEvent({
    required this.medalhaId,
    required this.medalhaName,
  });
  
  String get eventType => 'binge_eating_medalha_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'medalhaId': medalhaId,
    'medalhaName': medalhaName,
  };
}

class BingeEatingInsigniaConquistadaEvent extends AppEvent {
  final String insigniaId;
  final String insigniaName;
  
  BingeEatingInsigniaConquistadaEvent({
    required this.insigniaId,
    required this.insigniaName,
  });
  
  String get eventType => 'binge_eating_insignia_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'insigniaId': insigniaId,
    'insigniaName': insigniaName,
  };
}

class BingeEatingMarcoDiasEvent extends AppEvent {
  final int dias;
  final String mensagem;
  
  BingeEatingMarcoDiasEvent({
    required this.dias,
    required this.mensagem,
  });
  
  String get eventType => 'binge_eating_marco_dias';
  
  @override
  Map<String, dynamic> get data => {
    'dias': dias,
    'mensagem': mensagem,
  };
}

/// Service de celebração específico do módulo Binge Eating
class BingeEatingCelebrationService {
  static BingeEatingCelebrationService? _instance;
  static BingeEatingCelebrationService get instance => _instance ??= BingeEatingCelebrationService._();
  
  BingeEatingCelebrationService._();

  Future<void> celebrarMedalhaConquistada({
    required String medalhaId,
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('🎉 Iniciando celebração medalha Binge Eating: $medalhaName');

      EventBus.instance.emit(BingeEatingMedalhaConquistadaEvent(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      ));

      await _playMedalhaHapticFeedback(medalhaId);

      await AchievementNotificationService.instance.showMedalhaNotification(
        moduleId: 'bingeEating',
        medalhaId: medalhaId,
        medalhaName: medalhaName,
        medalhaDescription: medalhaDescription,
        assetPath: assetPath,
        rarity: medalhaId,
      );

      LoggerService.instance.gamification('🏆 Celebração medalha Binge Eating $medalhaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha Binge Eating', error: e);
    }
  }

  Future<void> celebrarInsigniaConquistada({
    required String insigniaId,
    required String insigniaName,
    String? insigniaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('⭐ Iniciando celebração insígnia Binge Eating: $insigniaName');

      EventBus.instance.emit(BingeEatingInsigniaConquistadaEvent(
        insigniaId: insigniaId,
        insigniaName: insigniaName,
      ));

      await SystemAudioService.instance.playHapticFeedback('medio');

      await AchievementNotificationService.instance.showInsigniaNotification(
        moduleId: 'bingeEating',
        insigniaId: insigniaId,
        insigniaName: insigniaName,
        insigniaDescription: insigniaDescription,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✨ Celebração insígnia Binge Eating $insigniaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de insígnia Binge Eating', error: e);
    }
  }

  Future<void> celebrarMarcoDias({
    required int dias,
    required String mensagem,
  }) async {
    try {
      LoggerService.instance.gamification('📅 Iniciando celebração marco Binge Eating: $dias dias');
      
      EventBus.instance.emit(BingeEatingMarcoDiasEvent(
        dias: dias,
        mensagem: mensagem,
      ));
      
      await SystemAudioService.instance.playHapticFeedback('leve');
      
      await AchievementNotificationService.instance.showSpecialAchievementNotification(
        moduleId: 'bingeEating',
        achievementId: 'marco_dias_$dias',
        title: '📅 Marco Alcançado!',
        body: mensagem,
      );
      
      LoggerService.instance.gamification('🌟 Celebração marco Binge Eating $dias dias concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de marco Binge Eating', error: e);
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
      LoggerService.instance.gamification('BingeEatingCelebrationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar BingeEatingCelebrationService', error: e);
    }
  }

  void dispose() {
    LoggerService.instance.gamification('BingeEatingCelebrationService disposed');
  }
}
