import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/gamification/services/achievement_notification_service.dart';

/// Eventos específicos do módulo Adult Content
class AdultContentMedalhaConquistadaEvent extends AppEvent {
  final String medalhaId;
  final String medalhaName;
  
  AdultContentMedalhaConquistadaEvent({
    required this.medalhaId,
    required this.medalhaName,
  });
  
  String get eventType => 'adult_content_medalha_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'medalhaId': medalhaId,
    'medalhaName': medalhaName,
  };
}

class AdultContentInsigniaConquistadaEvent extends AppEvent {
  final String insigniaId;
  final String insigniaName;
  
  AdultContentInsigniaConquistadaEvent({
    required this.insigniaId,
    required this.insigniaName,
  });
  
  String get eventType => 'adult_content_insignia_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'insigniaId': insigniaId,
    'insigniaName': insigniaName,
  };
}

class AdultContentMarcoDiasEvent extends AppEvent {
  final int dias;
  final String mensagem;
  
  AdultContentMarcoDiasEvent({
    required this.dias,
    required this.mensagem,
  });
  
  String get eventType => 'adult_content_marco_dias';
  
  @override
  Map<String, dynamic> get data => {
    'dias': dias,
    'mensagem': mensagem,
  };
}

/// Service de celebração específico do módulo Adult Content
/// Gerencia celebrações visuais e táteis para conquistas
class AdultContentCelebrationService {
  static AdultContentCelebrationService? _instance;
  static AdultContentCelebrationService get instance => _instance ??= AdultContentCelebrationService._();
  
  AdultContentCelebrationService._();

  /// Celebra conquista de medalha com confetes e feedback tátil
  Future<void> celebrarMedalhaConquistada({
    required String medalhaId,
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('🎉 Iniciando celebração medalha Adult Content: $medalhaName');

      EventBus.instance.emit(AdultContentMedalhaConquistadaEvent(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      ));

      await _playMedalhaHapticFeedback(medalhaId);

      await AchievementNotificationService.instance.showMedalhaNotification(
        moduleId: 'adultContent',
        medalhaId: medalhaId,
        medalhaName: medalhaName,
        medalhaDescription: medalhaDescription,
        assetPath: assetPath,
        rarity: medalhaId,
      );

      LoggerService.instance.gamification('🏆 Celebração medalha Adult Content $medalhaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha Adult Content', error: e);
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
      LoggerService.instance.gamification('⭐ Iniciando celebração insígnia Adult Content: $insigniaName');

      EventBus.instance.emit(AdultContentInsigniaConquistadaEvent(
        insigniaId: insigniaId,
        insigniaName: insigniaName,
      ));

      await SystemAudioService.instance.playHapticFeedback('medio');

      await AchievementNotificationService.instance.showInsigniaNotification(
        moduleId: 'adultContent',
        insigniaId: insigniaId,
        insigniaName: insigniaName,
        insigniaDescription: insigniaDescription,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✨ Celebração insígnia Adult Content $insigniaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de insígnia Adult Content', error: e);
    }
  }

  /// Celebra marco de dias
  Future<void> celebrarMarcoDias({
    required int dias,
    required String mensagem,
  }) async {
    try {
      LoggerService.instance.gamification('📅 Iniciando celebração marco Adult Content: $dias dias');
      
      EventBus.instance.emit(AdultContentMarcoDiasEvent(
        dias: dias,
        mensagem: mensagem,
      ));
      
      await SystemAudioService.instance.playHapticFeedback('leve');
      
      await AchievementNotificationService.instance.showSpecialAchievementNotification(
        moduleId: 'adultContent',
        achievementId: 'marco_dias_$dias',
        title: '📅 Marco Alcançado!',
        body: mensagem,
      );
      
      LoggerService.instance.gamification('🌟 Celebração marco Adult Content $dias dias concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de marco Adult Content', error: e);
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
      LoggerService.instance.gamification('AdultContentCelebrationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar AdultContentCelebrationService', error: e);
    }
  }

  /// Limpa recursos
  void dispose() {
    LoggerService.instance.gamification('AdultContentCelebrationService disposed');
  }
}
