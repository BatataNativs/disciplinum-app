import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/gamification/services/achievement_notification_service.dart';

/// Eventos específicos de celebração do módulo Focus
class MedalhaConquistadaEvent extends AppEvent {
  final String medalhaId;
  final String medalhaName;
  
  MedalhaConquistadaEvent({
    required this.medalhaId,
    required this.medalhaName,
  }) : super(data: {
    'medalhaId': medalhaId,
    'medalhaName': medalhaName,
  });
}

class InsigniaDisciplinumConquistadaEvent extends AppEvent {
  final int disciplinumCount;
  
  InsigniaDisciplinumConquistadaEvent({
    required this.disciplinumCount,
  }) : super(data: {
    'disciplinumCount': disciplinumCount,
  });
}

class MilestoneAlcancadoEvent extends AppEvent {
  final int periodos;
  final String proximaInsignia;
  
  MilestoneAlcancadoEvent({
    required this.periodos,
    required this.proximaInsignia,
  }) : super(data: {
    'periodos': periodos,
    'proximaInsignia': proximaInsignia,
  });
}

class ConfetesDispararEvent extends AppEvent {
  final String tipo;
  final String intensidade;
  final Duration duracao;
  final List<String> cores;
  final int quantidade;
  
  ConfetesDispararEvent({
    required this.tipo,
    this.intensidade = 'media',
    required this.duracao,
    required this.cores,
    required this.quantidade,
  }) : super(data: {
    'tipo': tipo,
    'intensidade': intensidade,
    'duracao': duracao.inMilliseconds,
    'cores': cores,
    'quantidade': quantidade,
  });
}

class HapticFeedbackEvent extends AppEvent {
  final String tipo;
  final String intensidade;
  final Duration duracao;
  
  HapticFeedbackEvent({
    required this.tipo,
    this.intensidade = 'media',
    required this.duracao,
  }) : super(data: {
    'tipo': tipo,
    'intensidade': intensidade,
    'duracao': duracao.inMilliseconds,
  });
}

class SomConquistaEvent extends AppEvent {
  final String tipo;
  final double volume;
  
  SomConquistaEvent({
    required this.tipo,
    this.volume = 0.7,
  }) : super(data: {
    'tipo': tipo,
    'volume': volume,
  });
}

/// Service de celebração visual do módulo Focus
/// Gerencia confetes, animações e feedback visual de conquistas
class FocusCelebrationService {
  static FocusCelebrationService? _instance;
  static FocusCelebrationService get instance => _instance ??= FocusCelebrationService._();
  
  FocusCelebrationService._();

  /// Dispara celebração de conquista de medalha
  Future<void> celebrarMedalhaConquistada({
    required String medalhaId,
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('🎉 Iniciando celebração de medalha: $medalhaName');
      
      // Emite evento para UI escutar
      EventBus.instance.emit(MedalhaConquistadaEvent(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      ));
      
      // Dispara efeitos visuais
      await _dispararConfetes(tipo: 'medalha');
      await _dispararFeedbackHaptico();
      await _dispararSomConquista();
      
      // Notificação global de conquista
      await AchievementNotificationService.instance.showMedalhaNotification(
        moduleId: 'focus',
        medalhaId: medalhaId,
        medalhaName: medalhaName,
        medalhaDescription: medalhaDescription,
        assetPath: assetPath,
        rarity: medalhaId,
      );
      
      LoggerService.instance.gamification('✅ Celebração de medalha concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha', error: e);
    }
  }

  /// Dispara celebração de conquista de insígnia Disciplinum
  Future<void> celebrarDisciplinumConquistado({
    required int disciplinumCount,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('⭐ Iniciando celebração Disciplinum #$disciplinumCount');
      
      // Emite evento para UI escutar
      EventBus.instance.emit(InsigniaDisciplinumConquistadaEvent(
        disciplinumCount: disciplinumCount,
      ));
      
      // Dispara efeitos visuais especiais para Disciplinum
      await _dispararConfetes(tipo: 'disciplinum', intensidade: 'alta');
      await _dispararFeedbackHaptico(intensidade: 'forte');
      await _dispararSomConquista(tipo: 'epico');
      
      // Notificação global de conquista
      await AchievementNotificationService.instance.showInsigniaNotification(
        moduleId: 'focus',
        insigniaId: 'disciplinum_$disciplinumCount',
        insigniaName: 'Disciplinum #$disciplinumCount',
        insigniaDescription: 'Você completou $disciplinumCount Disciplinums!',
        assetPath: assetPath,
      );
      
      LoggerService.instance.gamification('✅ Celebração Disciplinum concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração Disciplinum', error: e);
    }
  }

  /// Dispara celebração de milestone
  Future<void> celebrarMilestoneAlcancado({
    required int periodos,
    required String proximaInsignia,
  }) async {
    try {
      LoggerService.instance.gamification('🎯 Iniciando celebração milestone: $periodos períodos');
      
      // Emite evento para UI escutar
      EventBus.instance.emit(MilestoneAlcancadoEvent(
        periodos: periodos,
        proximaInsignia: proximaInsignia,
      ));
      
      // Dispara efeitos visuais leves para milestones
      await _dispararConfetes(tipo: 'milestone', intensidade: 'media');
      await _dispararFeedbackHaptico(intensidade: 'leve');
      
      LoggerService.instance.gamification('✅ Celebração milestone concluída');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração milestone', error: e);
    }
  }

  /// Dispara efeito de confetes
  Future<void> _dispararConfetes({
    required String tipo,
    String intensidade = 'media',
  }) async {
    try {
      // Emite evento para UI renderizar confetes
      EventBus.instance.emit(ConfetesDispararEvent(
        tipo: tipo,
        intensidade: intensidade,
        duracao: _getDuracaoConfetes(intensidade),
        cores: _getCoresConfetes(tipo),
        quantidade: _getQuantidadeConfetes(intensidade),
      ));
      
      LoggerService.instance.gamification('🎊 Confetes disparados: $tipo ($intensidade)');
    } catch (e) {
      LoggerService.instance.e('Erro ao disparar confetes', error: e);
    }
  }

  /// Dispara feedback tátil (haptic)
  Future<void> _dispararFeedbackHaptico({
    String intensidade = 'media',
  }) async {
    try {
      // Emite evento para UI executar feedback tátil
      EventBus.instance.emit(HapticFeedbackEvent(
        tipo: 'conquista',
        intensidade: intensidade,
        duracao: _getDuracaoHaptico(intensidade),
      ));
      
      LoggerService.instance.gamification('📳 Feedback tátil: $intensidade');
    } catch (e) {
      LoggerService.instance.e('Erro ao disparar feedback tátil', error: e);
    }
  }

  /// Dispara som de conquista
  Future<void> _dispararSomConquista({
    String tipo = 'normal',
  }) async {
    try {
      // Emite evento para UI executar som
      EventBus.instance.emit(SomConquistaEvent(
        tipo: tipo,
        volume: _getVolumeSom(tipo),
      ));
      
      LoggerService.instance.gamification('🔊 Som reproduzido: $tipo');
    } catch (e) {
      LoggerService.instance.e('Erro ao reproduzir som', error: e);
    }
  }

  /// Obtém duração dos confetes baseada na intensidade
  Duration _getDuracaoConfetes(String intensidade) {
    switch (intensidade) {
      case 'leve':
        return const Duration(seconds: 2);
      case 'media':
        return const Duration(seconds: 3);
      case 'alta':
        return const Duration(seconds: 5);
      default:
        return const Duration(seconds: 3);
    }
  }

  /// Obtém cores dos confetes baseadas no tipo
  List<String> _getCoresConfetes(String tipo) {
    switch (tipo) {
      case 'medalha':
        return ['#FFD700', '#FFA500', '#FF6347']; // Dourado, laranja, vermelho
      case 'disciplinum':
        return ['#9370DB', '#4169E1', '#00CED1']; // Roxo, azul, ciano
      case 'milestone':
        return ['#32CD32', '#FFD700', '#FF69B4']; // Verde, dourado, rosa
      default:
        return ['#FFD700', '#FFA500', '#32CD32']; // Padrão
    }
  }

  /// Obtém quantidade de confetes baseada na intensidade
  int _getQuantidadeConfetes(String intensidade) {
    switch (intensidade) {
      case 'leve':
        return 50;
      case 'media':
        return 100;
      case 'alta':
        return 200;
      default:
        return 100;
    }
  }

  /// Obtém duração do feedback tátil baseada na intensidade
  Duration _getDuracaoHaptico(String intensidade) {
    switch (intensidade) {
      case 'leve':
        return const Duration(milliseconds: 100);
      case 'media':
        return const Duration(milliseconds: 200);
      case 'forte':
        return const Duration(milliseconds: 300);
      default:
        return const Duration(milliseconds: 200);
    }
  }

  /// Obtém volume do som baseado no tipo
  double _getVolumeSom(String tipo) {
    switch (tipo) {
      case 'normal':
        return 0.7;
      case 'epico':
        return 1.0;
      default:
        return 0.7;
    }
  }
}
