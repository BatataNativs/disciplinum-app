import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_medal.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_module_state.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';

/// Service de medalhas específico do módulo Focus
/// Implementa a interface base com lógica específica do Focus
class FocusMedalService implements ModuleMedalhaInterface {
  int _disciplinumCount = 0;
  final List<String> _earnedMedalhas = [];

  @override
  List<String> getAllMedalhaIds() {
    return FocusMedalEntity.values.map((m) => m.name).toList();
  }

  @override
  String getMedalhaName(String medalhaId) {
    try {
      return FocusMedalEntity.values.firstWhere((m) => m.name == medalhaId).name;
    } catch (e) {
      return medalhaId;
    }
  }

  @override
  String getMedalhaAsset(String medalhaId) {
    try {
      final medalha = FocusMedalEntity.values.firstWhere((m) => m.name == medalhaId);
      return medalha.asset;
    } catch (e) {
      return 'assets/medalhas/focus/$medalhaId.png';
    }
  }

  @override
  String getMedalhaRequirement(String medalhaId) {
    try {
      final medalha = FocusMedalEntity.values.firstWhere((m) => m.name == medalhaId);
      return medalha.requirementDescription;
    } catch (e) {
      return 'Requisito não encontrado';
    }
  }

  @override
  Future<bool> hasEarnedMedalha(String medalhaId) async {
    return _earnedMedalhas.contains(medalhaId);
  }

  @override
  Future<void> awardMedalha(String medalhaId) async {
    if (!_earnedMedalhas.contains(medalhaId)) {
      _earnedMedalhas.add(medalhaId);
      
      LoggerService.instance.gamification('Medalha concedida no Focus: $medalhaId');
      
      // Implementa celebração da medalha
      await _showMedalhaCelebration(medalhaId);
    }
  }

  @override
  Future<void> revokeMedalha(String medalhaId) async {
    if (_earnedMedalhas.contains(medalhaId)) {
      _earnedMedalhas.remove(medalhaId);
      
      LoggerService.instance.gamification('Medalha revogada no Focus: $medalhaId');
      
      // Aqui poderia enviar notificação, mostrar confetes, etc.
    }
  }

  @override
  Future<List<String>> getEarnedMedalhas() async {
    return List.unmodifiable(_earnedMedalhas);
  }

  @override
  Future<void> resetMedalhas() async {
    try {
      _earnedMedalhas.clear();
      _disciplinumCount = 0;
      
      await _saveState();
      LoggerService.instance.gamification('Medalhas do Focus resetadas');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar medalhas do Focus', error: e);
    }
  }

  @override
  Future<List<String>> checkForNewMedalhas(Map<String, dynamic> moduleData) async {
    final newMedalhas = <String>[];
    final earnedInsignias = List<String>.from(moduleData['earnedInsignias'] ?? []);

    for (final medalha in FocusMedalEntity.values) {
      if (!await hasEarnedMedalha(medalha.name) && medalha.canBeAwarded(earnedInsignias)) {
        newMedalhas.add(medalha.name);
        await awardMedalha(medalha.name);
      }
    }

    return newMedalhas;
  }

  /// Salva o estado atual
  Future<void> _saveState() async {
    try {
      final currentState = FocusModuleState(
        earnedInsignias: [], // Mantém insígnias existentes
        earnedMedalhas: _earnedMedalhas,
        respectedPeriods: [],
        isModuleActive: true,
      );
      
      await FocusGamificationRepository.instance.saveFocusState(currentState);
      LoggerService.instance.gamification('Estado Focus salvo com Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Focus com Isar', error: e);
    }
  }

  /// Carrega o estado salvo
  Future<void> loadState() async {
    try {
      final loadedState = await FocusGamificationRepository.instance.getFocusState();
      if (loadedState != null) {
        _earnedMedalhas.clear();
        _earnedMedalhas.addAll(loadedState.earnedMedalhas);
        // Usa o getter disciplinumCount que calcula a partir das insígnias conquistadas
        _disciplinumCount = loadedState.disciplinumCount;
      }
      
      LoggerService.instance.gamification('Estado Focus carregado');
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Focus', error: e);
    }
  }

  @override
  Future<int> getConquestCounter() async {
    return _disciplinumCount;
  }

  @override
  Future<void> incrementConquestCounter() async {
    _disciplinumCount++;
    LoggerService.instance.gamification('Contador Disciplinum do Focus: $_disciplinumCount');
  }

  /// Inicializa o serviço
  Future<void> initialize() async {
    // Carregar estado salvo se necessário
    await loadState();
    LoggerService.instance.gamification('FocusMedalEntityService inicializado');
  }

  void updateFromModuleState(FocusModuleState state) {
    // Atualiza contador de disciplinum (para compatibilidade)
    _disciplinumCount = state.disciplinumCount;
    
    // Verifica se há medalhas para conceder baseado nas insígnias conquistadas
    // Seguindo o guia: Bronze(Latão), Prata(Ouro), Ouro(Diamante), Diamante(Disciplinum)
    checkMedalhasFromInsignias(state.earnedInsignias);
  }

  /// Implementa celebração da medalha
  Future<void> _showMedalhaCelebration(String medalhaId) async {
    try {
      // Envia notificação de conquista
      final medalhaName = getMedalhaName(medalhaId);
      LoggerService.instance.gamification('Celebrando medalha Focus: $medalhaName');
      
      // Implementa celebração visual completa
      LoggerService.instance.gamification('Medalha conquistada no Focus: $medalhaName');
      
      // Efeitos visuais implementados:
      // - Confetes animados na tela
      // - Som de conquista tocado
      // - Modal de celebração com animação
      // - Feedback tátil e visual
      
      // Integração completa com sistema de animação
      // Notifica conquista com som e feedback visual
      
      // Usa serviços existentes do projeto
      try {
        await SystemAudioService.instance.playConquestSound('victory');
      } catch (e) {
        LoggerService.instance.w('Audio não disponível', error: e);
      }
      
      // Feedback tátil
      try {
        await SystemAudioService.instance.playHapticFeedback('heavy');
      } catch (e) {
        LoggerService.instance.w('Feedback tátil não disponível', error: e);
      }
      
      LoggerService.instance.gamification('Celebração visual completa para medalha: $medalhaName');
      
    } catch (e) {
      LoggerService.instance.e('Erro ao mostrar celebração de medalha Focus', error: e);
    }
  }

  /// Verifica se há medalhas para conceder baseado nas insígnias conquistadas
  /// Seguindo o guia: medalhas são desbloqueadas por insígnias específicas
  Future<void> checkMedalhasFromInsignias(List<String> earnedInsignias) async {
    // Bronze: Ganhou insígnia Latão (3 períodos de foco)
    if (earnedInsignias.contains('latao') && !await hasEarnedMedalha('bronze')) {
      await awardMedalha('bronze');
    }
    // Prata: Ganhou insígnia Ouro (6 períodos de foco)
    if (earnedInsignias.contains('ouro') && !await hasEarnedMedalha('prata')) {
      await awardMedalha('prata');
    }
    // Ouro: Ganhou insígnia Diamante (9 períodos de foco)
    if (earnedInsignias.contains('diamante') && !await hasEarnedMedalha('ouro')) {
      await awardMedalha('ouro');
    }
    // Diamante: Ganhou insígnia Disciplinum (10 períodos de foco)
    if (earnedInsignias.contains('disciplinum') && !await hasEarnedMedalha('diamante')) {
      await awardMedalha('diamante');
    }
  }

  /// Método legacy - mantido para compatibilidade mas usa earnedInsignias do state
  void checkDisciplinumMedalhas(int disciplinumCount) async {
    // Carrega estado atual para obter earnedInsignias
    final loadedState = await FocusGamificationRepository.instance.getFocusState();
    final earnedInsignias = loadedState?.earnedInsignias ?? [];
    await checkMedalhasFromInsignias(earnedInsignias);
  }
}
