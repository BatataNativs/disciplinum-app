import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_insignia.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_module_state.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';

/// Service de insignias do módulo Money Saving Challenge
/// Gerencia conquista e progressão de insignias
class MoneySavingInsigniaService implements ModuleInsigniaInterface {
  final MoneySavingGamificationRepository _repository;
  MoneySavingModuleState? _currentState;
  bool _isInitialized = false;

  MoneySavingInsigniaService(this._repository);

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
      LoggerService.instance.gamification('MoneySavingInsigniaService inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar MoneySavingInsigniaService', error: e);
      rethrow;
    }
  }

  /// Atualiza o estado atual
  Future<void> updateState(MoneySavingModuleState newState) async {
    _currentState = newState;
    await _repository.saveMoneySavingState(newState);
  }

  /// Verifica e concede novas insignias baseadas no percentual da grid preenchida
  Future<List<MoneySavingInsignia>> checkAndAwardInsignias(int gridPercentage) async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('MoneySavingInsigniaService não inicializado');
      return [];
    }

    final awardedInsignias = <MoneySavingInsignia>[];
    final updatedInsignias = List<String>.from(_currentState!.earnedInsignias);

    for (final insignia in MoneySavingInsignia.values) {
      if (insignia.canBeAwarded(gridPercentage, updatedInsignias)) {
        updatedInsignias.add(insignia.name);
        awardedInsignias.add(insignia);
        
        LoggerService.instance.gamification(
      '🏆 Insignia conquistada: ${insignia.name} ($consecutiveDays dias)'
    );
      }
    }

    if (awardedInsignias.isNotEmpty) {
      final updatedState = _currentState!.copyWith(
        earnedInsignias: updatedInsignias,
        lastUpdated: DateTime.now(),
      );
      
      await updateState(updatedState);
      await _repository.syncWithSupabase(updatedState);
    }

    return awardedInsignias;
  }

  /// Concede uma insignia específica (método interno)
  Future<bool> _awardInsigniaInternal(MoneySavingInsignia insignia) async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('MoneySavingInsigniaService não inicializado');
      return false;
    }

    if (_currentState!.earnedInsignias.contains(insignia.name)) {
      LoggerService.instance.w('Insignia ${insignia.name} já conquistada');
      return false;
    }

    final updatedInsignias = List<String>.from(_currentState!.earnedInsignias);
    updatedInsignias.add(insignia.name);

    final updatedState = _currentState!.copyWith(
      earnedInsignias: updatedInsignias,
      lastUpdated: DateTime.now(),
    );

    await updateState(updatedState);
    await _repository.syncWithSupabase(updatedState);

    LoggerService.instance.gamification('🏆 Insignia concedida: ${insignia.name}');
    return true;
  }

  /// Revoga uma insignia (método interno)
  Future<bool> _revokeInsigniaInternal(MoneySavingInsignia insignia) async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('MoneySavingInsigniaService não inicializado');
      return false;
    }

    if (!_currentState!.earnedInsignias.contains(insignia.name)) {
      LoggerService.instance.w('Insignia ${insignia.name} não encontrada para revogar');
      return false;
    }

    final updatedInsignias = List<String>.from(_currentState!.earnedInsignias);
    updatedInsignias.remove(insignia.name);

    final updatedState = _currentState!.copyWith(
      earnedInsignias: updatedInsignias,
      lastUpdated: DateTime.now(),
    );

    await updateState(updatedState);
    await _repository.syncWithSupabase(updatedState);

    LoggerService.instance.gamification('🗑️ Insignia revogada: ${insignia.name}');
    return true;
  }

  /// Obtém a próxima insignia a ser conquistada
  MoneySavingInsignia? getNextInsignia() {
    if (!_isInitialized || _currentState == null) {
      return null;
    }
    return MoneySavingInsignia.getNextInsignia(_currentState!.earnedInsignias);
  }

  /// Calcula o progresso para a próxima insignia
  double getProgressToNextInsignia() {
    if (!_isInitialized || _currentState == null) {
      return 0.0;
    }
    return MoneySavingInsignia.calculateProgress(
      _currentState!.consecutiveDays, // Progress based on consecutive days of saving
      _currentState!.earnedInsignias,
    );
  }

  /// Calcula o progresso para a próxima insignia baseado no percentual da grid
  double getProgressByGrid(int gridPercentage) {
    if (!_isInitialized || _currentState == null) {
      return 0.0;
    }
    return MoneySavingInsignia.calculateProgress(
      gridPercentage,
      _currentState!.earnedInsignias,
    );
  }

  /// Verifica se tem streak ativo
  bool get isInStreak {
    if (!_isInitialized || _currentState == null) {
      return false;
    }
    return _currentState!.isInStreak;
  }

  /// Obtém dias consecutivos
  int get consecutiveDays {
    if (!_isInitialized || _currentState == null) {
      return 0;
    }
    return _currentState!.consecutiveDays;
  }

  /// Reseta todas as insígnias exceto a inicial
  @override
  Future<void> resetInsignias() async {
    if (!_isInitialized || _currentState == null) {
      LoggerService.instance.w('MoneySavingInsigniaService não inicializado');
      return;
    }

    try {
      // Preserva apenas a insígnia inicial (Madeira)
      final initialInsignia = MoneySavingInsignia.madeira.name;
      final hasInitialInsignia = _currentState!.earnedInsignias.contains(initialInsignia);
      
      final updatedInsignias = <String>[];
      
      // Restaura a inicial se o usuário já tinha
      if (hasInitialInsignia) {
        updatedInsignias.add(initialInsignia);
      }

      final updatedState = _currentState!.copyWith(
        earnedInsignias: updatedInsignias,
        disciplinumCount: 0,
        lastUpdated: DateTime.now(),
      );

      await updateState(updatedState);
      await _repository.syncWithSupabase(updatedState);

      LoggerService.instance.gamification('🗑️ Insignias resetadas (preservando inicial)');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar insignias', error: e);
    }
  }

  /// Interface ModuleInsigniaInterface implementation
  @override
  List<String> getAllInsigniaIds() {
    return MoneySavingInsignia.getAllInsignias().map((i) => i.name).toList();
  }

  @override
  String getInsigniaName(String insigniaId) {
    final insignia = MoneySavingInsignia.getAllInsignias()
        .where((i) => i.name == insigniaId)
        .firstOrNull;
    
    return insignia?.name ?? insigniaId;
  }

  @override
  String getInsigniaAsset(String insigniaId) {
    return 'assets/images/insignias/money_saving/${insigniaId.toLowerCase().replaceAll(' ', '_')}.png';
  }

  @override
  String getInsigniaRequirement(String insigniaId) {
    final insignia = MoneySavingInsignia.getAllInsignias()
        .where((i) => i.name == insigniaId)
        .firstOrNull;
    
    if (insignia == null) return 'Requisito não disponível';
    
    return '${insignia.requiredGridPercentage}% da grid preenchida';
  }

  @override
  Future<bool> hasEarnedInsignia(String insigniaId) async {
    if (!_isInitialized || _currentState == null) {
      return false;
    }
    return _currentState!.earnedInsignias.contains(insigniaId);
  }

  @override
  Future<void> awardInsignia(String insigniaId) async {
    final insignia = MoneySavingInsignia.getAllInsignias()
        .where((i) => i.name == insigniaId)
        .firstOrNull;
    
    if (insignia != null) {
      await _awardInsigniaInternal(insignia);
    }
  }

  @override
  Future<void> revokeInsignia(String insigniaId) async {
    final insignia = MoneySavingInsignia.getAllInsignias()
        .where((i) => i.name == insigniaId)
        .firstOrNull;
    
    if (insignia != null) {
      await _revokeInsigniaInternal(insignia);
    }
  }

  @override
  Future<List<String>> getEarnedInsignias() async {
    if (!_isInitialized || _currentState == null) {
      return [];
    }
    return List.from(_currentState!.earnedInsignias);
  }

  @override
  Future<List<String>> checkForNewInsignias(Map<String, dynamic> moduleData) async {
    final consecutiveDays = moduleData['consecutiveDays'] ?? 0;
    final awardedInsignias = await checkAndAwardInsignias(consecutiveDays);
    return awardedInsignias.map((i) => i.name).toList();
  }
}
