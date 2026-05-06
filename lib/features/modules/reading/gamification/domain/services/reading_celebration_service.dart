import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/gamification/services/achievement_notification_service.dart';

/// Eventos específicos do módulo Reading
class ReadingMedalhaConquistadaEvent extends AppEvent {
  final String medalhaId;
  final String medalhaName;
  
  ReadingMedalhaConquistadaEvent({
    required this.medalhaId,
    required this.medalhaName,
  });
  
  String get eventType => 'reading_medalha_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'medalhaId': medalhaId,
    'medalhaName': medalhaName,
  };
}

class ReadingInsigniaConquistadaEvent extends AppEvent {
  final String insigniaId;
  final String insigniaName;
  
  ReadingInsigniaConquistadaEvent({
    required this.insigniaId,
    required this.insigniaName,
  });
  
  String get eventType => 'reading_insignia_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'insigniaId': insigniaId,
    'insigniaName': insigniaName,
  };
}

class ReadingMarcoLivrosEvent extends AppEvent {
  final int livros;
  final String mensagem;
  
  ReadingMarcoLivrosEvent({
    required this.livros,
    required this.mensagem,
  });
  
  String get eventType => 'reading_marco_livros';
  
  @override
  Map<String, dynamic> get data => {
    'livros': livros,
    'mensagem': mensagem,
  };
}

/// Service de celebração específico do módulo Reading
class ReadingCelebrationService {
  static ReadingCelebrationService? _instance;
  static ReadingCelebrationService get instance => _instance ??= ReadingCelebrationService._();
  
  ReadingCelebrationService._();

  Future<void> celebrarMedalhaConquistada({
    required String medalhaId,
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('🎉 Iniciando celebração medalha Reading: $medalhaName');

      EventBus.instance.emit(ReadingMedalhaConquistadaEvent(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      ));

      await _playMedalhaHapticFeedback(medalhaId);

      await AchievementNotificationService.instance.showMedalhaNotification(
        moduleId: 'reading',
        medalhaId: medalhaId,
        medalhaName: medalhaName,
        medalhaDescription: medalhaDescription,
        assetPath: assetPath,
        rarity: medalhaId,
      );

      LoggerService.instance.gamification('🏆 Celebração medalha Reading $medalhaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha Reading', error: e);
    }
  }

  Future<void> celebrarInsigniaConquistada({
    required String insigniaId,
    required String insigniaName,
    String? insigniaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('⭐ Iniciando celebração insígnia Reading: $insigniaName');

      EventBus.instance.emit(ReadingInsigniaConquistadaEvent(
        insigniaId: insigniaId,
        insigniaName: insigniaName,
      ));

      await SystemAudioService.instance.playHapticFeedback('medio');

      await AchievementNotificationService.instance.showInsigniaNotification(
        moduleId: 'reading',
        insigniaId: insigniaId,
        insigniaName: insigniaName,
        insigniaDescription: insigniaDescription,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✨ Celebração insígnia Reading $insigniaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de insígnia Reading', error: e);
    }
  }

  Future<void> celebrarMarcoLivros({
    required int livros,
    required String mensagem,
  }) async {
    try {
      LoggerService.instance.gamification('📚 Iniciando celebração marco Reading: $livros livros');
      
      EventBus.instance.emit(ReadingMarcoLivrosEvent(
        livros: livros,
        mensagem: mensagem,
      ));
      
      await SystemAudioService.instance.playHapticFeedback('leve');
      
      await AchievementNotificationService.instance.showSpecialAchievementNotification(
        moduleId: 'reading',
        achievementId: 'marco_livros_$livros',
        title: '📚 Marco Alcançado!',
        body: mensagem,
      );
      
      LoggerService.instance.gamification('🌟 Celebração marco Reading $livros livros concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de marco Reading', error: e);
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
      LoggerService.instance.gamification('ReadingCelebrationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar ReadingCelebrationService', error: e);
    }
  }

  void dispose() {
    LoggerService.instance.gamification('ReadingCelebrationService disposed');
  }
}
