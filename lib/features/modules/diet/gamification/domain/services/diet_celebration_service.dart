import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/gamification/services/achievement_notification_service.dart';

/// Eventos específicos do módulo Diet
class DietMedalhaConquistadaEvent extends AppEvent {
  final String medalhaId;
  final String medalhaName;
  
  DietMedalhaConquistadaEvent({
    required this.medalhaId,
    required this.medalhaName,
  });
  
  String get eventType => 'diet_medalha_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'medalhaId': medalhaId,
    'medalhaName': medalhaName,
  };
}

class DietInsigniaConquistadaEvent extends AppEvent {
  final String insigniaId;
  final String insigniaName;
  
  DietInsigniaConquistadaEvent({
    required this.insigniaId,
    required this.insigniaName,
  });
  
  String get eventType => 'diet_insignia_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'insigniaId': insigniaId,
    'insigniaName': insigniaName,
  };
}

class DietMarcoDiasEvent extends AppEvent {
  final int dias;
  final String mensagem;
  
  DietMarcoDiasEvent({
    required this.dias,
    required this.mensagem,
  });
  
  String get eventType => 'diet_marco_dias';
  
  @override
  Map<String, dynamic> get data => {
    'dias': dias,
    'mensagem': mensagem,
  };
}

/// Service de celebração específico do módulo Diet
class DietCelebrationService {
  static DietCelebrationService? _instance;
  static DietCelebrationService get instance => _instance ??= DietCelebrationService._();
  
  DietCelebrationService._();

  Future<void> celebrarMedalhaConquistada({
    required String medalhaId,
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('🎉 Iniciando celebração medalha Diet: $medalhaName');

      EventBus.instance.emit(DietMedalhaConquistadaEvent(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      ));

      await _playMedalhaHapticFeedback(medalhaId);

      await AchievementNotificationService.instance.showMedalhaNotification(
        moduleId: 'diet',
        medalhaId: medalhaId,
        medalhaName: medalhaName,
        medalhaDescription: medalhaDescription,
        assetPath: assetPath,
        rarity: medalhaId,
      );

      LoggerService.instance.gamification('🏆 Celebração medalha Diet $medalhaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha Diet', error: e);
    }
  }

  Future<void> celebrarInsigniaConquistada({
    required String insigniaId,
    required String insigniaName,
    String? insigniaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('⭐ Iniciando celebração insígnia Diet: $insigniaName');

      EventBus.instance.emit(DietInsigniaConquistadaEvent(
        insigniaId: insigniaId,
        insigniaName: insigniaName,
      ));

      await SystemAudioService.instance.playHapticFeedback('medio');

      await AchievementNotificationService.instance.showInsigniaNotification(
        moduleId: 'diet',
        insigniaId: insigniaId,
        insigniaName: insigniaName,
        insigniaDescription: insigniaDescription,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✨ Celebração insígnia Diet $insigniaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de insígnia Diet', error: e);
    }
  }

  Future<void> celebrarMarcoDias({
    required int dias,
    required String mensagem,
  }) async {
    try {
      LoggerService.instance.gamification('📅 Iniciando celebração marco Diet: $dias dias');
      
      EventBus.instance.emit(DietMarcoDiasEvent(
        dias: dias,
        mensagem: mensagem,
      ));
      
      await SystemAudioService.instance.playHapticFeedback('leve');
      
      await AchievementNotificationService.instance.showSpecialAchievementNotification(
        moduleId: 'diet',
        achievementId: 'marco_dias_$dias',
        title: '📅 Marco Alcançado!',
        body: mensagem,
      );
      
      LoggerService.instance.gamification('🌟 Celebração marco Diet $dias dias concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de marco Diet', error: e);
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
      LoggerService.instance.gamification('DietCelebrationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar DietCelebrationService', error: e);
    }
  }

  void dispose() {
    LoggerService.instance.gamification('DietCelebrationService disposed');
  }
}
