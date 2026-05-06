import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/gamification/services/achievement_notification_service.dart';

/// Eventos específicos do módulo Procrastination
class ProcrastinationMedalhaConquistadaEvent extends AppEvent {
  final String medalhaId;
  final String medalhaName;
  
  ProcrastinationMedalhaConquistadaEvent({
    required this.medalhaId,
    required this.medalhaName,
  });
  
  String get eventType => 'procrastination_medalha_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'medalhaId': medalhaId,
    'medalhaName': medalhaName,
  };
}

class ProcrastinationInsigniaConquistadaEvent extends AppEvent {
  final String insigniaId;
  final String insigniaName;
  
  ProcrastinationInsigniaConquistadaEvent({
    required this.insigniaId,
    required this.insigniaName,
  });
  
  String get eventType => 'procrastination_insignia_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'insigniaId': insigniaId,
    'insigniaName': insigniaName,
  };
}

class ProcrastinationMarcoTarefasEvent extends AppEvent {
  final int tarefas;
  final String mensagem;
  
  ProcrastinationMarcoTarefasEvent({
    required this.tarefas,
    required this.mensagem,
  });
  
  String get eventType => 'procrastination_marco_tarefas';
  
  @override
  Map<String, dynamic> get data => {
    'tarefas': tarefas,
    'mensagem': mensagem,
  };
}

/// Service de celebração específico do módulo Procrastination
class ProcrastinationCelebrationService {
  static ProcrastinationCelebrationService? _instance;
  static ProcrastinationCelebrationService get instance => _instance ??= ProcrastinationCelebrationService._();
  
  ProcrastinationCelebrationService._();

  Future<void> celebrarMedalhaConquistada({
    required String medalhaId,
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('🎉 Iniciando celebração medalha Procrastination: $medalhaName');

      EventBus.instance.emit(ProcrastinationMedalhaConquistadaEvent(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      ));

      await _playMedalhaHapticFeedback(medalhaId);

      await AchievementNotificationService.instance.showMedalhaNotification(
        moduleId: 'procrastination',
        medalhaId: medalhaId,
        medalhaName: medalhaName,
        medalhaDescription: medalhaDescription,
        assetPath: assetPath,
        rarity: medalhaId,
      );

      LoggerService.instance.gamification('🏆 Celebração medalha Procrastination $medalhaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha Procrastination', error: e);
    }
  }

  Future<void> celebrarInsigniaConquistada({
    required String insigniaId,
    required String insigniaName,
    String? insigniaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('⭐ Iniciando celebração insígnia Procrastination: $insigniaName');

      EventBus.instance.emit(ProcrastinationInsigniaConquistadaEvent(
        insigniaId: insigniaId,
        insigniaName: insigniaName,
      ));

      await SystemAudioService.instance.playHapticFeedback('medio');

      await AchievementNotificationService.instance.showInsigniaNotification(
        moduleId: 'procrastination',
        insigniaId: insigniaId,
        insigniaName: insigniaName,
        insigniaDescription: insigniaDescription,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✨ Celebração insígnia Procrastination $insigniaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de insígnia Procrastination', error: e);
    }
  }

  Future<void> celebrarMarcoTarefas({
    required int tarefas,
    required String mensagem,
  }) async {
    try {
      LoggerService.instance.gamification('📅 Iniciando celebração marco Procrastination: $tarefas tarefas');
      
      EventBus.instance.emit(ProcrastinationMarcoTarefasEvent(
        tarefas: tarefas,
        mensagem: mensagem,
      ));
      
      await SystemAudioService.instance.playHapticFeedback('leve');
      
      await AchievementNotificationService.instance.showSpecialAchievementNotification(
        moduleId: 'procrastination',
        achievementId: 'marco_tarefas_$tarefas',
        title: '📅 Marco Alcançado!',
        body: mensagem,
      );
      
      LoggerService.instance.gamification('🌟 Celebração marco Procrastination $tarefas tarefas concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de marco Procrastination', error: e);
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
      LoggerService.instance.gamification('ProcrastinationCelebrationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar ProcrastinationCelebrationService', error: e);
    }
  }

  void dispose() {
    LoggerService.instance.gamification('ProcrastinationCelebrationService disposed');
  }
}
