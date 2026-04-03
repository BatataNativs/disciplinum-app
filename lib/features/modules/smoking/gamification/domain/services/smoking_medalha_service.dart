import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_medalha.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_celebration_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';

/// Service de medalhas específico do módulo Smoking
/// Implementa a interface base com lógica específica do Smoking
class SmokingMedalhaService implements ModuleMedalhaInterface {
  SmokingModuleState? _currentState;

  @override
  List<String> getAllMedalhaIds() {
    return SmokingMedalhaEntity.values.map((m) => m.name).toList();
  }

  dynamic getMedalhaData(String medalhaId) {
    final entity = SmokingMedalhaEntity.values.firstWhere(
      (m) => m.name == medalhaId,
      orElse: () => SmokingMedalhaEntity.bronze,
    );
    return {
      'id': entity.name,
      'name': entity.nameBr,
      'asset': entity.asset,
      'description': entity.description,
      'requirementDescription': entity.requirementDescription,
      'emoji': entity.emoji,
      'category': entity.category,
      'themeColor': entity.themeColor,
      'rarity': entity.rarity,
      'isMaximumCategory': entity.isMaximumCategory,
      'isLegendary': entity.isLegendary,
    };
  }

  @override
  Future<void> awardMedalha(String medalhaId) async {
    try {
      _currentState ??= SmokingModuleState();

      if (!_currentState!.hasMedalha(medalhaId)) {
        _currentState!.awardMedalha(medalhaId);
        await _saveState(_currentState!);
        LoggerService.instance.gamification('Medalha Smoking concedida: $medalhaId');
        
        // Mostra celebração de conquista
        await _showMedalhaCelebration(medalhaId);
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao conceder medalha Smoking: $medalhaId', error: e);
    }
  }

  @override
  Future<void> revokeMedalha(String medalhaId) async {
    try {
      if (_currentState != null && _currentState!.hasMedalha(medalhaId)) {
        _currentState!.revokeMedalha(medalhaId);
        await _saveState(_currentState!);
        LoggerService.instance.gamification('Medalha Smoking revogada: $medalhaId');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao revogar medalha Smoking: $medalhaId', error: e);
    }
  }

  @override
  Future<List<String>> checkForNewMedalhas(Map<String, dynamic> moduleData) async {
    try {
      final earnedInsignias = moduleData['earnedInsignias'] as List<String>? ?? [];
      final newMedalhas = <String>[];
      
      for (final medalha in SmokingMedalhaEntity.values) {
        if (!_currentState!.hasMedalha(medalha.name) && 
            medalha.canBeAwarded(earnedInsignias)) {
          newMedalhas.add(medalha.name);
        }
      }
      
      return newMedalhas;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar novas medalhas Smoking', error: e);
      return [];
    }
  }

  @override
  String getMedalhaRequirement(String medalhaId) {
    final entity = SmokingMedalhaEntity.values.firstWhere(
      (m) => m.name == medalhaId,
      orElse: () => SmokingMedalhaEntity.bronze,
    );
    return entity.requirementDescription;
  }

  @override
  Future<bool> hasEarnedMedalha(String medalhaId) async {
    return _currentState?.hasMedalha(medalhaId) ?? false;
  }

  @override
  Future<List<String>> getEarnedMedalhas() async {
    return _currentState?.earnedMedalhas ?? [];
  }

  @override
  Future<void> resetMedalhas() async {
    try {
      if (_currentState != null) {
        _currentState!.resetMedalhas();
        await _saveState(_currentState!);
        LoggerService.instance.gamification('Medalhas Smoking resetadas');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar medalhas Smoking', error: e);
    }
  }

  @override
  Future<int> getConquestCounter() async {
    return _currentState?.disciplinumCount ?? 0;
  }

  @override
  Future<void> incrementConquestCounter() async {
    try {
      _currentState ??= SmokingModuleState();
      
      // Usar copyWith para atualizar o campo final
      _currentState = _currentState!.copyWith(
        disciplinumCount: _currentState!.disciplinumCount + 1,
      );
      await _saveState(_currentState!);
      LoggerService.instance.gamification('Contador Disciplinum incrementado: ${_currentState!.disciplinumCount}');
    } catch (e) {
      LoggerService.instance.e('Erro ao incrementar contador Disciplinum', error: e);
    }
  }

  /// Mostra celebração de conquista de medalha
  Future<void> _showMedalhaCelebration(String medalhaId) async {
    try {
      final medalhaName = getMedalhaName(medalhaId);
      LoggerService.instance.gamification('🎉 Parabéns! Você conquistou a medalha $medalhaName!');
      
      // Dispara celebração visual completa com confetes
      await SmokingCelebrationService.instance.celebrarMedalhaConquistada(
        medalhaId: medalhaId,
        medalhaName: medalhaName,
      );
      
      LoggerService.instance.gamification('🏆 Medalha $medalhaName conquistada com sucesso!');
    } catch (e) {
      LoggerService.instance.e('Erro na celebração de medalha', error: e);
    }
  }

  @override
  String getMedalhaName(String medalhaId) {
    final entity = SmokingMedalhaEntity.values.firstWhere(
      (m) => m.name == medalhaId,
      orElse: () => SmokingMedalhaEntity.bronze,
    );
    return entity.nameBr;
  }

  @override
  String getMedalhaAsset(String medalhaId) {
    final entity = SmokingMedalhaEntity.values.firstWhere(
      (m) => m.name == medalhaId,
      orElse: () => SmokingMedalhaEntity.bronze,
    );
    return entity.asset;
  }

  /// Verifica se pode conceder medalha baseada nas insígnias
  bool canAwardMedalha(String medalhaId, List<String> earnedInsignias) {
    final entity = SmokingMedalhaEntity.values.firstWhere(
      (m) => m.name == medalhaId,
      orElse: () => SmokingMedalhaEntity.bronze,
    );
    return entity.canBeAwarded(earnedInsignias);
  }

  /// Obtém medalhas disponíveis para concessão
  List<SmokingMedalhaEntity> getAvailableMedalhas(List<String> earnedInsignias) {
    return SmokingMedalhaEntity.values
        .where((medalha) => medalha.canBeAwarded(earnedInsignias))
        .toList();
  }

  /// Obtém medalhas já conquistadas
  Future<List<SmokingMedalhaEntity>> getEarnedMedalhaEntities() async {
    if (_currentState == null) return [];
    
    final earnedIds = await getEarnedMedalhas();
    return SmokingMedalhaEntity.values
        .where((medalha) => earnedIds.contains(medalha.name))
        .toList();
  }

  /// Obtém progresso para próxima medalha
  Map<String, dynamic> getNextMedalhaProgress() {
    if (_currentState == null) {
      return {
        'nextMedalha': SmokingMedalhaEntity.bronze.name,
        'nextMedalhaName': 'Medalha de Bronze',
        'requiredInsignias': 1,
        'currentInsignias': 0,
        'progress': 0.0,
        'canAward': false,
      };
    }
    
    final earnedInsignias = _currentState!.earnedInsignias;
    final disciplinumCount = earnedInsignias.where((i) => i == 'disciplinum').length;
    
    // Encontra a próxima medalha não conquistada
    SmokingMedalhaEntity? nextMedalha;
    for (final medalha in SmokingMedalhaEntity.values) {
      if (!_currentState!.hasMedalha(medalha.name) && 
          medalha.canBeAwarded(earnedInsignias)) {
        nextMedalha = medalha;
        break;
      }
    }
    
    if (nextMedalha == null) {
      // Todas conquistadas
      return {
        'nextMedalha': null,
        'nextMedalhaName': 'Todas conquistadas',
        'requiredInsignias': 0,
        'currentInsignias': disciplinumCount,
        'progress': 100.0,
        'canAward': false,
      };
    }
    
    final requiredInsignias = switch (nextMedalha.name) {
      'bronze' => 1,
      'prata' => 2,
      'ouro' => 3,
      'diamante' => 4,
      _ => 0,
    };
    
    final progress = (disciplinumCount / requiredInsignias * 100).clamp(0.0, 100.0);
    
    return {
      'nextMedalha': nextMedalha.name,
      'nextMedalhaName': nextMedalha.nameBr,
      'requiredInsignias': requiredInsignias,
      'currentInsignias': disciplinumCount,
      'progress': progress,
      'canAward': disciplinumCount >= requiredInsignias,
    };
  }

  /// Verifica se há medalhas disponíveis para concessão
  bool hasAvailableMedalhas() {
    if (_currentState == null) return false;
    
    final earnedInsignias = _currentState!.earnedInsignias;
    return getAvailableMedalhas(earnedInsignias).isNotEmpty;
  }

  /// Obtém estatísticas das medalhas
  Future<Map<String, dynamic>> getMedalhaStatistics() async {
    if (_currentState == null) {
      return {
        'totalEarned': 0,
        'totalAvailable': SmokingMedalhaEntity.values.length,
        'byRarity': {},
        'byCategory': {},
        'completionPercentage': 0.0,
      };
    }
    
    final earned = await getEarnedMedalhaEntities();
    final byRarity = <String, int>{};
    final byCategory = <String, int>{};
    
    for (final medalha in earned) {
      byRarity[medalha.rarity] = (byRarity[medalha.rarity] ?? 0) + 1;
      byCategory[medalha.category] = (byCategory[medalha.category] ?? 0) + 1;
    }
    
    return {
      'totalEarned': earned.length,
      'totalAvailable': SmokingMedalhaEntity.values.length,
      'byRarity': byRarity,
      'byCategory': byCategory,
      'completionPercentage': (earned.length / SmokingMedalhaEntity.values.length * 100),
    };
  }

  /// Salva o estado atual usando Isar + Supabase
  Future<void> _saveState(SmokingModuleState state) async {
    try {
      // Salva localmente com Isar
      await SmokingGamificationRepository.instance.saveSmokingState(state);
      
      // Sincroniza com Supabase
      await SmokingGamificationRepository.instance.syncWithSupabase(state);
      
      _currentState = state;
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado medalhas Smoking', error: e);
    }
  }

  /// Carrega o estado salvo usando Isar + Supabase
  Future<void> loadState() async {
    try {
      // Tenta carregar do Isar local primeiro
      _currentState = await SmokingGamificationRepository.instance.getSmokingState();
      
      // Se não encontrar local, tenta do Supabase
      if (_currentState == null) {
        _currentState = await SmokingGamificationRepository.instance.loadFromSupabase();
        
        // Se encontrou no Supabase, salva localmente
        if (_currentState != null) {
          await SmokingGamificationRepository.instance.saveSmokingState(_currentState!);
        }
      }
      
      // Se ainda não encontrou, usa estado padrão
      _currentState ??= SmokingModuleState();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado medalhas Smoking', error: e);
      _currentState = SmokingModuleState();
    }
  }

  /// Obtém o estado atual
  SmokingModuleState? getCurrentState() => _currentState;

  /// Inicializa o serviço
  Future<void> initialize() async {
    await loadState();
    LoggerService.instance.gamification('SmokingMedalhaService inicializado');
  }
}
