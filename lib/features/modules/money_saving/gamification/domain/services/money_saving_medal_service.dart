import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_medal.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';

/// Service de medalhas do módulo Money Saving Challenge
/// Gerencia conquista e progressão de medalhas
class MoneySavingMedalService implements ModuleMedalhaInterface {
  final MoneySavingGamificationRepository _repository;
  MoneySavingModuleState? _currentState;
  bool _isInitialized = false;

  MoneySavingMedalService(this._repository);

  /// Inicializa o service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _repository.initialize();
      _currentState = await _repository.getMoneySavingState();
      
      if (_currentState == null) {
        _currentState = MoneySavingModuleState.initial();
        await _repository.saveMoneySavingState(_currentState!);
      }

      _isInitialized = true;
      LoggerService.instance.gamification('MoneySavingMedalhaService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar MoneySavingMedalhaService', error: e);
      rethrow;
    }
  }

  /// Atualiza o estado atual
  Future<void> updateState(MoneySavingModuleState newState) async {
    _currentState = newState;
    await _repository.saveMoneySavingState(newState);
  }

  /// Verifica e concede novas medalhas baseadas nos desafios concluídos
  Future<List<MoneySavingMedalEntity>> checkAndAwardMedalhas(int completedChallenges) async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('MoneySavingMedalhaService não inicializado');
      return [];
    }

    final awardedMedalhas = <MoneySavingMedalEntity>[];
    final updatedMedalhas = List<String>.from(_currentState!.earnedMedalhas);

    for (final medalha in MoneySavingMedalEntity.values) {
      if (medalha.canBeAwarded(completedChallenges)) {
        if (!updatedMedalhas.contains(medalha.name)) {
          updatedMedalhas.add(medalha.name);
          awardedMedalhas.add(medalha);
          
          LoggerService.instance.gamification(
            '🏅 Medalha conquistada: ${medalha.name} ($completedChallenges desafios)'
          );
        }
      }
    }

    if (awardedMedalhas.isNotEmpty) {
      final updatedState = _currentState!.copyWith(
        earnedMedalhas: updatedMedalhas,
        disciplinumCount: completedChallenges,
      );
      
      await updateState(updatedState);
      await _repository.syncWithSupabase(updatedState);
    }

    return awardedMedalhas;
  }

  /// Concede uma medalha específica (método interno)
  Future<bool> _awardMedalhaInternal(MoneySavingMedalEntity medalha) async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('MoneySavingMedalhaService não inicializado');
      return false;
    }

    if (_currentState!.earnedMedalhas.contains(medalha.name)) {
      LoggerService.instance.w('Medalha ${medalha.name} já conquistada');
      return false;
    }

    final updatedMedalhas = List<String>.from(_currentState!.earnedMedalhas);
    updatedMedalhas.add(medalha.name);

    final updatedState = _currentState!.copyWith(
      earnedMedalhas: updatedMedalhas,
    );

    await updateState(updatedState);
    await _repository.syncWithSupabase(updatedState);

    LoggerService.instance.gamification('🏅 Medalha concedida: ${medalha.name}');
    return true;
  }

  /// Revoga uma medalha (método interno)
  Future<bool> _revokeMedalhaInternal(MoneySavingMedalEntity medalha) async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('MoneySavingMedalhaService não inicializado');
      return false;
    }

    if (!_currentState!.earnedMedalhas.contains(medalha.name)) {
      LoggerService.instance.w('Medalha ${medalha.name} não encontrada para revogar');
      return false;
    }

    final updatedMedalhas = List<String>.from(_currentState!.earnedMedalhas);
    updatedMedalhas.remove(medalha.name);

    final updatedState = _currentState!.copyWith(
      earnedMedalhas: updatedMedalhas,
    );

    await updateState(updatedState);
    await _repository.syncWithSupabase(updatedState);

    LoggerService.instance.gamification('🗑️ Medalha revogada: ${medalha.name}');
    return true;
  }

  /// Obtém medalhas conquistadas
  @override
  Future<List<String>> getEarnedMedalhas() async {
    if (!_isInitialized || _currentState == null) {
      return [];
    }
    return List.from(_currentState!.earnedMedalhas);
  }

  /// Obtém a próxima medalha a ser conquistada
  MoneySavingMedalEntity? getNextMedalha() {
    if (!_isInitialized || _currentState == null) {
      return null;
    }
    for (final medal in MoneySavingMedalEntity.values) {
      if (!_currentState!.earnedMedalhas.contains(medal.name)) {
        return medal;
      }
    }
    return null;
  }

  /// Calcula o progresso para a próxima medalha
  double getProgressToNextMedalha() {
    if (!_isInitialized || _currentState == null) {
      return 0.0;
    }
    final nextMedal = getNextMedalha();
    if (nextMedal == null) return 1.0;
    
    final required = nextMedal.requiredChallenges;
    if (required == 0) return 1.0;
    
    // Usar earnedMedalhas.length como aproximação de desafios concluídos
    final completed = _currentState!.earnedMedalhas.length;
    return (completed / required).clamp(0.0, 1.0);
  }

  /// Verifica se conquistou medalha Diamante
  bool get hasDiamondMedalha {
    if (!_isInitialized || _currentState == null) {
      return false;
    }
    return _currentState!.earnedMedalhas.contains(MoneySavingMedalEntity.diamante.name);
  }

  /// Obtém contador de insignias Disciplinum
  int get disciplinumCount {
    if (!_isInitialized || _currentState == null) {
      return 0;
    }
    return _currentState!.disciplinumCount;
  }

  /// Reseta todas as medalhas
  @override
  Future<void> resetMedalhas() async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('MoneySavingMedalhaService não inicializado');
      return;
    }

    final updatedState = _currentState!.copyWith(
      earnedMedalhas: [],
      disciplinumCount: 0,
    );

    await updateState(updatedState);
    await _repository.syncWithSupabase(updatedState);

    LoggerService.instance.gamification('🗑️ Todas as medalhas resetadas');
  }

  /// Interface ModuleMedalhaInterface implementation
  @override
  List<String> getAllMedalhaIds() {
    return MoneySavingMedalEntity.values.map((m) => m.name).toList();
  }

  @override
  String getMedalhaName(String medalhaId) {
    final medalha = MoneySavingMedalEntity.values
        .where((m) => m.name == medalhaId)
        .firstOrNull;
    
    return medalha?.nameBr ?? medalhaId;
  }

  @override
  String getMedalhaAsset(String medalhaId) {
    final medalha = MoneySavingMedalEntity.values
        .where((m) => m.name == medalhaId)
        .firstOrNull;
    
    return medalha?.asset ?? 'assets/gamification/medals/moneySaving/default.png';
  }

  @override
  String getMedalhaRequirement(String medalhaId) {
    final medalha = MoneySavingMedalEntity.values
        .where((m) => m.name == medalhaId)
        .firstOrNull;
    
    if (medalha == null) return 'Requisito não disponível';
    
    return medalha.requirementDescription;
  }

  @override
  Future<bool> hasEarnedMedalha(String medalhaId) async {
    if (!_isInitialized || _currentState == null) {
      return false;
    }
    return _currentState!.earnedMedalhas.contains(medalhaId);
  }

  @override
  Future<void> awardMedalha(String medalhaId) async {
    final medalha = MoneySavingMedalEntity.values
        .where((m) => m.name == medalhaId)
        .firstOrNull;
    
    if (medalha != null) {
      await _awardMedalhaInternal(medalha);
    }
  }

  @override
  Future<void> revokeMedalha(String medalhaId) async {
    final medalha = MoneySavingMedalEntity.values
        .where((m) => m.name == medalhaId)
        .firstOrNull;
    
    if (medalha != null) {
      await _revokeMedalhaInternal(medalha);
    }
  }

  Future<List<String>> getEarnedMedalhaList() async {
    return await getEarnedMedalhas();
  }

  @override
  Future<List<String>> checkForNewMedalhas(Map<String, dynamic> moduleData) async {
    final disciplinumCount = moduleData['disciplinumCount'] ?? 0;
    final awardedMedalhas = await checkAndAwardMedalhas(disciplinumCount);
    return awardedMedalhas.map((m) => m.name).toList();
  }

  Future<void> resetMedalhasInterface() async {
    await resetMedalhas();
  }

  @override
  Future<int> getConquestCounter() async {
    return disciplinumCount;
  }

  @override
  Future<void> incrementConquestCounter() async {
    // Implementação para incrementar contador de conquistas
    // Pode ser usado para incrementar disciplinumCount
    LoggerService.instance.gamification('Incrementando contador de conquistas');
  }
}
