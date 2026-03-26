import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Eventos específicos do módulo Smoking
class SmokingMedalhaConquistadaEvent extends AppEvent {
  final String medalhaId;
  final String medalhaName;
  
  SmokingMedalhaConquistadaEvent({
    required this.medalhaId,
    required this.medalhaName,
  });
  
  String get eventType => 'smoking_medalha_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'medalhaId': medalhaId,
    'medalhaName': medalhaName,
  };
}

class SmokingInsigniaConquistadaEvent extends AppEvent {
  final String insigniaId;
  final String insigniaName;
  
  SmokingInsigniaConquistadaEvent({
    required this.insigniaId,
    required this.insigniaName,
  });
  
  String get eventType => 'smoking_insignia_conquistada';
  
  @override
  Map<String, dynamic> get data => {
    'insigniaId': insigniaId,
    'insigniaName': insigniaName,
  };
}

class SmokingMarcoSaudeEvent extends AppEvent {
  final int dias;
  final String mensagem;
  
  SmokingMarcoSaudeEvent({
    required this.dias,
    required this.mensagem,
  });
  
  String get eventType => 'smoking_marco_saude';
  
  @override
  Map<String, dynamic> get data => {
    'dias': dias,
    'mensagem': mensagem,
  };
}

class SmokingMarcoEconomiaEvent extends AppEvent {
  final int macos;
  final String mensagem;
  
  SmokingMarcoEconomiaEvent({
    required this.macos,
    required this.mensagem,
  });
  
  String get eventType => 'smoking_marco_economia';
  
  @override
  Map<String, dynamic> get data => {
    'macos': macos,
    'mensagem': mensagem,
  };
}

/// Service de celebração específico do módulo Smoking
/// Gerencia celebrações visuais e táteis para conquistas
class SmokingCelebrationService {
  static SmokingCelebrationService? _instance;
  static SmokingCelebrationService get instance => _instance ??= SmokingCelebrationService._();
  
  SmokingCelebrationService._();

  /// Celebra conquista de medalha com confetes e feedback tátil
  Future<void> celebrarMedalhaConquistada({
    required String medalhaId,
    required String medalhaName,
  }) async {
    try {
      LoggerService.instance.gamification('🎉 Iniciando celebração medalha: $medalhaName');
      
      // Emite evento para UI mostrar confetes
      EventBus.instance.emit(SmokingMedalhaConquistadaEvent(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      ));
      
      // Feedback tátil baseado na raridade da medalha
      await _playMedalhaHapticFeedback(medalhaId);
      
      LoggerService.instance.gamification('🏆 Celebração medalha $medalhaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha Smoking', error: e);
    }
  }

  /// Celebra conquista de insígnia
  Future<void> celebrarInsigniaConquistada({
    required String insigniaId,
    required String insigniaName,
  }) async {
    try {
      LoggerService.instance.gamification('⭐ Iniciando celebração insígnia: $insigniaName');
      
      // Emite evento para UI mostrar celebração
      EventBus.instance.emit(SmokingInsigniaConquistadaEvent(
        insigniaId: insigniaId,
        insigniaName: insigniaName,
      ));
      
      // Feedback tátil para insígnia
      await SystemAudioService.instance.playHapticFeedback('medio');
      
      LoggerService.instance.gamification('✨ Celebração insígnia $insigniaName concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de insígnia Smoking', error: e);
    }
  }

  /// Celebra marco de saúde
  Future<void> celebrarMarcoSaude({
    required int dias,
    required String mensagem,
  }) async {
    try {
      LoggerService.instance.gamification('❤️ Iniciando celebração saúde: $dias dias');
      
      // Emite evento para UI mostrar celebração de saúde
      EventBus.instance.emit(SmokingMarcoSaudeEvent(
        dias: dias,
        mensagem: mensagem,
      ));
      
      // Feedback tátil suave para marcos de saúde
      await SystemAudioService.instance.playHapticFeedback('leve');
      
      LoggerService.instance.gamification('🌟 Celebração saúde $dias dias concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de marco saúde Smoking', error: e);
    }
  }

  /// Celebra marco de economia
  Future<void> celebrarMarcoEconomia({
    required int macos,
    required String mensagem,
  }) async {
    try {
      LoggerService.instance.gamification('💰 Iniciando celebração economia: $macos maços');
      
      // Emite evento para UI mostrar celebração de economia
      EventBus.instance.emit(SmokingMarcoEconomiaEvent(
        macos: macos,
        mensagem: mensagem,
      ));
      
      // Feedback tátil para economia
      await SystemAudioService.instance.playHapticFeedback('medio');
      
      LoggerService.instance.gamification('💎 Celebração economia $macos maços concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de marco economia Smoking', error: e);
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

  /// Celebra conquista especial (múltiplas conquistas)
  Future<void> celebrarConquistaEspecial({
    required String tipo,
    required String mensagem,
    required double volume,
  }) async {
    try {
      LoggerService.instance.gamification('🎊 Iniciando celebração especial: $tipo');
      
      // Feedback tátil épico
      await SystemAudioService.instance.playConquestSound('epico', volume: volume);
      
      LoggerService.instance.gamification('🌟 Celebração especial $tipo concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração especial Smoking', error: e);
    }
  }

  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      LoggerService.instance.gamification('SmokingCelebrationService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar SmokingCelebrationService', error: e);
    }
  }

  /// Limpa recursos
  void dispose() {
    LoggerService.instance.gamification('SmokingCelebrationService disposed');
  }
}
