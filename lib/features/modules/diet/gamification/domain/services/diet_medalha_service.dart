import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/entities/diet_medalha.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/entities/diet_module_state.dart';

/// Service de medalhas específico do módulo Dieta
/// Implementa a interface base com lógica específica da Dieta
class DietMedalhaService implements ModuleMedalhaInterface {
  final DietGamificationRepository _repository;
  final List<String> _earnedMedalhas = [];
  int _disciplinumCount = 0;

  DietMedalhaService(this._repository);

  Future<void> initialize() async {
    try {
      final state = await _repository.getDietState();
      if (state != null) {
        _earnedMedalhas.clear();
        _earnedMedalhas.addAll(state.earnedMedalhas);
        _disciplinumCount = state.disciplinumCount;
        LoggerService.instance.gamification('DietMedalhaService inicializado');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar DietMedalhaService', error: e);
    }
  }

  Future<void> updateFromModuleState(dynamic state) async {
    if (state is DietModuleState) {
      _earnedMedalhas.clear();
      _earnedMedalhas.addAll(state.earnedMedalhas);
      _disciplinumCount = state.disciplinumCount;
    }
  }

  Future<void> loadState() async {
    await initialize();
  }

  Future<void> _saveState() async {
    try {
      final currentState = await _repository.getDietState();
      if (currentState != null) {
        final updatedState = currentState.copyWith(
          earnedMedalhas: _earnedMedalhas,
          disciplinumCount: _disciplinumCount,
          lastUpdated: DateTime.now(),
        );
        
        await _repository.saveDietState(updatedState);
        LoggerService.instance.gamification('Estado DietMedalhaService salvo');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado DietMedalhaService', error: e);
    }
  }

  @override
  List<String> getAllMedalhaIds() {
    return DietMedalha.values.map((medalha) => medalha.name).toList();
  }

  @override
  String getMedalhaName(String medalhaId) {
    try {
      return DietMedalha.values.firstWhere((m) => m.name == medalhaId).nameBr;
    } catch (e) {
      return medalhaId;
    }
  }

  @override
  String getMedalhaAsset(String medalhaId) {
    try {
      final medalha = DietMedalha.values.firstWhere((m) => m.name == medalhaId);
      return medalha.asset;
    } catch (e) {
      return 'assets/medalhas/diet/$medalhaId.png';
    }
  }

  @override
  String getMedalhaRequirement(String medalhaId) {
    try {
      final medalha = DietMedalha.values.firstWhere((m) => m.name == medalhaId);
      return medalha.description;
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
      
      LoggerService.instance.gamification('Medalha concedida na Dieta: $medalhaId');
      
      // Implementa celebração da medalha
      await _showMedalhaCelebration(medalhaId);
    }
  }

  @override
  Future<void> revokeMedalha(String medalhaId) async {
    if (_earnedMedalhas.contains(medalhaId)) {
      _earnedMedalhas.remove(medalhaId);
      
      LoggerService.instance.gamification('Medalha revogada na Dieta: $medalhaId');
    }
  }

  @override
  Future<List<String>> getEarnedMedalhas() async {
    return List.unmodifiable(_earnedMedalhas);
  }

  @override
  Future<List<String>> checkForNewMedalhas(Map<String, dynamic> moduleData) async {
    final newMedalhas = <String>[];
    final disciplinumCount = moduleData['disciplinumCount'] ?? _disciplinumCount;

    for (final medalha in DietMedalha.values) {
      if (!await hasEarnedMedalha(medalha.name) && medalha.canBeAwarded(disciplinumCount)) {
        newMedalhas.add(medalha.name);
        await awardMedalha(medalha.name);
      }
    }

    return newMedalhas;
  }

  @override
  Future<void> resetMedalhas() async {
    _earnedMedalhas.clear();
    _disciplinumCount = 0;
    await _saveState();
    LoggerService.instance.gamification('Medalhas da Dieta resetadas');
  }

  @override
  Future<int> getConquestCounter() async {
    return _disciplinumCount;
  }

  @override
  Future<void> incrementConquestCounter() async {
    _disciplinumCount++;
    await _saveState();
    
    // Verifica se há novas medalhas
    await checkForNewMedalhas({'disciplinumCount': _disciplinumCount});
  }

  /// Atualiza o contador de insignias Disciplinum
  Future<void> updateDisciplinumCount(int count) async {
    _disciplinumCount = count;
    await _saveState();
    
    // Verifica se há novas medalhas
    await checkForNewMedalhas({'disciplinumCount': _disciplinumCount});
  }

  /// Verifica se há medalhas Disciplinum para conceder
  void checkDisciplinumMedalhas(int disciplinumCount) async {
    if (disciplinumCount >= 1 && !await hasEarnedMedalha('bronze')) {
      await awardMedalha('bronze');
    } else if (disciplinumCount >= 3 && !await hasEarnedMedalha('prata')) {
      await awardMedalha('prata');
    } else if (disciplinumCount >= 6 && !await hasEarnedMedalha('ouro')) {
      await awardMedalha('ouro');
    } else if (disciplinumCount >= 10 && !await hasEarnedMedalha('diamante')) {
      await awardMedalha('diamante');
    }
  }

  /// Implementa celebração da medalha
  Future<void> _showMedalhaCelebration(String medalhaId) async {
    try {
      // Envia notificação de conquista
      final medalhaName = getMedalhaName(medalhaId);
      LoggerService.instance.gamification('Celebrando medalha Dieta: $medalhaName');
      
      // Implementa celebração visual completa
      LoggerService.instance.gamification('Medalha conquistada na Dieta: $medalhaName');
      
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
      LoggerService.instance.e('Erro ao mostrar celebração de medalha Dieta', error: e);
    }
  }
}
