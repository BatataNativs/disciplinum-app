import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_insignia.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_medal.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_health_benefit.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_economic_benefit.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_celebration_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_special_notifications_service.dart';

/// Service de insígnias específico do módulo Smoking
/// Implementa a interface base com lógica específica do Smoking
class SmokingInsigniaService implements ModuleInsigniaInterface {
  SmokingModuleState? _currentState;

  @override
  List<String> getAllInsigniaIds() {
    return SmokingInsigniaEntity.values.map((i) => i.name).toList();
  }

  @override
  String getInsigniaName(String insigniaId) {
    final entity = SmokingInsigniaEntity.values.firstWhere(
      (i) => i.name == insigniaId,
      orElse: () => SmokingInsigniaEntity.madeira,
    );
    return entity.nameBr;
  }

  @override
  String getInsigniaAsset(String insigniaId) {
    final entity = SmokingInsigniaEntity.values.firstWhere(
      (i) => i.name == insigniaId,
      orElse: () => SmokingInsigniaEntity.madeira,
    );
    return entity.asset;
  }

  @override
  String getInsigniaRequirement(String insigniaId) {
    final entity = SmokingInsigniaEntity.values.firstWhere(
      (i) => i.name == insigniaId,
      orElse: () => SmokingInsigniaEntity.madeira,
    );
    return entity.requirementDescription;
  }

  @override
  Future<bool> hasEarnedInsignia(String insigniaId) async {
    return _currentState?.hasInsignia(insigniaId) ?? false;
  }

  @override
  Future<List<String>> getEarnedInsignias() async {
    return _currentState?.earnedInsignias ?? [];
  }

  @override
  Future<void> awardInsignia(String insigniaId) async {
    try {
      _currentState ??= SmokingModuleState();

      if (!_currentState!.hasInsignia(insigniaId)) {
        _currentState!.awardInsignia(insigniaId);
        await _saveState(_currentState!);
        LoggerService.instance.gamification('Insignia Smoking concedida: $insigniaId');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao conceder insígnia Smoking: $insigniaId', error: e);
    }
  }

  @override
  Future<void> revokeInsignia(String insigniaId) async {
    try {
      if (_currentState != null && _currentState!.hasInsignia(insigniaId)) {
        _currentState!.revokeInsignia(insigniaId);
        await _saveState(_currentState!);
        LoggerService.instance.gamification('Insignia Smoking revogada: $insigniaId');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao revogar insígnia Smoking: $insigniaId', error: e);
    }
  }

  @override
  Future<List<String>> checkForNewInsignias(Map<String, dynamic> moduleData) async {
    try {
      final currentDays = moduleData['consecutiveDays'] as int? ?? 0;
      final newInsignias = <String>[];
      
      for (final insignia in SmokingInsigniaEntity.values) {
        if (!_currentState!.hasInsignia(insignia.name) && 
            currentDays >= insignia.requiredDays) {
          newInsignias.add(insignia.name);
        }
      }
      
      return newInsignias;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar novas insígnias Smoking', error: e);
      return [];
    }
  }

  @override
  Future<void> resetInsignias() async {
    try {
      if (_currentState != null) {
        _currentState!.resetInsignias();
        await _saveState(_currentState!);
        LoggerService.instance.gamification('Insignias Smoking resetadas');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar insígnias Smoking', error: e);
    }
  }

  /// Atualiza o estado com base em check-ins positivos
  Future<void> updateFromCheckIns(int consecutivePositiveDays) async {
    try {
      _currentState ??= SmokingModuleState();

      // Usar copyWith para atualizar o campo final
      _currentState = _currentState!.copyWith(
        consecutivePositiveDays: consecutivePositiveDays,
      );
      
      // Verifica por novas insígnias
      final moduleData = {'consecutiveDays': consecutivePositiveDays};
      final newInsignias = await checkForNewInsignias(moduleData);
      
      // Concede novas insígnias encontradas e dispara celebrações
      for (final insigniaId in newInsignias) {
        await awardInsignia(insigniaId);
        
        // Dispara evento de celebração para a nova insígnia
        final insignia = SmokingInsigniaEntity.values.firstWhere(
          (i) => i.name == insigniaId,
          orElse: () => SmokingInsigniaEntity.madeira,
        );
        
        // Celebração para insígnia conquistada
        SmokingCelebrationService.instance.celebrarInsigniaConquistada(
          insigniaId: insigniaId,
          insigniaName: insignia.nameBr,
        );
        
        LoggerService.instance.gamification('🎉 Celebração disparada para insígnia: ${insignia.nameBr}');
      }
      
      // Verifica e concede medalhas baseadas nas insígnias conquistadas
      await _checkAndAwardMedalhas();
      
      // Verifica e concede novos marcos de saúde
      await _checkAndAwardHealthBenefits(consecutivePositiveDays);
      
      // Verifica e concede novos marcos econômicos
      await _checkAndAwardEconomicBenefits(consecutivePositiveDays);
      
      // Envia notificações especiais de saúde e economia
      await _sendSpecialNotifications(consecutivePositiveDays);
      
      await _saveState(_currentState!);
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar check-ins Smoking', error: e);
    }
  }

  /// Verifica e concede medalhas baseadas nas insígnias Disciplinum conquistadas
  Future<void> _checkAndAwardMedalhas() async {
    try {
      final currentMedalhas = _currentState?.earnedMedalhas ?? [];
      
      for (final medalha in SmokingMedalEntity.values) {
        // Verifica se a medalha pode ser concedida e ainda não foi
        if (medalha.canBeAwarded(_currentState?.earnedInsignias ?? []) &&
            !currentMedalhas.contains(medalha.name)) {
          
          // Concede a medalha
          _currentState = _currentState!.copyWith(
            earnedMedalhas: [...currentMedalhas, medalha.name],
          );
          
          // Dispara celebração para a medalha
          SmokingCelebrationService.instance.celebrarMedalhaConquistada(
            medalhaId: medalha.name,
            medalhaName: medalha.nameBr,
          );
          
          LoggerService.instance.gamification('🏆 Medalha concedida e celebrada: ${medalha.nameBr}');
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar/conceder medalhas', error: e);
    }
  }

  /// Verifica e concede novos marcos de saúde baseados nos dias sem fumar
  Future<void> _checkAndAwardHealthBenefits(int consecutiveDays) async {
    try {
      final currentBenefits = _currentState?.earnedHealthBenefits ?? [];
      
      // Calcular tempo total em minutos desde o início
      final totalMinutes = consecutiveDays * 24 * 60;
      
      for (final benefit in SmokingHealthBenefitEntity.values) {
        // Verifica se o benefício foi atingido e ainda não foi concedido
        if (totalMinutes >= benefit.timeInMinutes &&
            !currentBenefits.contains(benefit.name)) {
          
          // Concede o benefício
          _currentState = _currentState!.awardHealthBenefit(benefit.name);
          
          // Dispara celebração para o marco de saúde
          SmokingCelebrationService.instance.celebrarMarcoSaude(
            dias: benefit.timeInMinutes ~/ (24 * 60), // Converte para dias
            mensagem: benefit.notificationBody,
          );
          
          LoggerService.instance.gamification('❤️ Marco de saúde concedido: ${benefit.notificationTitle}');
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar/conceder marcos de saúde', error: e);
    }
  }

  /// Verifica e concede novos marcos econômicos baseados nos maços economizados
  Future<void> _checkAndAwardEconomicBenefits(int consecutiveDays) async {
    try {
      final dailyCost = _currentState?.dailyCost ?? 0.0;
      final packCost = _currentState?.packCost ?? 0.0;
      
      if (dailyCost <= 0 || packCost <= 0) return;
      
      // Calcula maços economizados
      final totalSaved = dailyCost * consecutiveDays;
      final packsSaved = (totalSaved / packCost).floor();
      
      // Lista de marcos econômicos configuráveis
      final economicMilestones = [1, 2, 5, 10, 20, 30];
      
      // Verifica se atingiu algum marco econômico
      for (final milestone in economicMilestones) {
        if (packsSaved >= milestone) {
          final benefit = SmokingEconomicBenefitEntity.values.firstWhere(
            (b) => b.packsCount == milestone,
            orElse: () => SmokingEconomicBenefitEntity.onePack,
          );
          
          // Dispara celebração para o marco econômico
          SmokingCelebrationService.instance.celebrarMarcoEconomia(
            macos: milestone,
            mensagem: benefit.notificationBody,
          );
          
          LoggerService.instance.gamification('💰 Marco econômico atingido: $milestone maços economizados');
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar marcos econômicos', error: e);
    }
  }

  /// Envia notificações especiais de saúde e economia
  Future<void> _sendSpecialNotifications(int consecutiveDays) async {
    try {
      final dailyCost = _currentState?.dailyCost ?? 0.0;
      final packCost = _currentState?.packCost ?? 0.0;
      
      // Envia notificação especial de saúde se aplicável
      await SmokingSpecialNotificationsService.instance.sendHealthNotification(consecutiveDays);
      
      // Calcula e envia notificação de economia se aplicável
      if (dailyCost > 0 && packCost > 0) {
        final totalSaved = dailyCost * consecutiveDays;
        final packsSaved = (totalSaved / packCost).floor();
        await SmokingSpecialNotificationsService.instance.sendEconomyNotification(packsSaved);
      }
      
      LoggerService.instance.gamification('📱 Notificações especiais enviadas: $consecutiveDays dias');
    } catch (e) {
      LoggerService.instance.e('Erro ao enviar notificações especiais', error: e);
    }
  }

  /// Obtém o progresso para uma insígnia específica
  double getProgressForInsignia(String insigniaId) {
    if (_currentState == null) return 0.0;
    
    final entity = SmokingInsigniaEntity.values.firstWhere(
      (i) => i.name == insigniaId,
      orElse: () => SmokingInsigniaEntity.madeira,
    );
    
    if (_currentState!.hasInsignia(insigniaId)) return 100.0;
    
    final current = _currentState!.consecutivePositiveDays.toDouble();
    final required = entity.requiredDays.toDouble();
    
    if (required <= 0) return 100.0;
    return (current / required * 100).clamp(0.0, 100.0);
  }

  /// Obtém a próxima insígnia a ser conquistada
  SmokingInsigniaEntity? getNextInsignia() {
    if (_currentState == null) return SmokingInsigniaEntity.ferro;
    
    final currentDays = _currentState!.consecutivePositiveDays;
    
    for (final insignia in SmokingInsigniaEntity.values) {
      if (!_currentState!.hasInsignia(insignia.name) && 
          currentDays < insignia.requiredDays) {
        return insignia;
      }
    }
    
    return null; // Todas conquistadas
  }

  /// Obtém informações do progresso atual
  Map<String, dynamic> getProgressInfo() {
    if (_currentState == null) {
      return {
        'consecutiveDays': 0,
        'totalInsignias': 0,
        'nextInsignia': SmokingInsigniaEntity.ferro.name,
        'nextInsigniaDays': 1,
        'progressToNext': 0.0,
      };
    }
    
    final nextInsignia = getNextInsignia();
    final progressToNext = nextInsignia != null 
        ? getProgressForInsignia(nextInsignia.name)
        : 100.0;
    
    return {
      'consecutiveDays': _currentState!.consecutivePositiveDays,
      'totalInsignias': _currentState!.earnedInsignias.length,
      'nextInsignia': nextInsignia?.name,
      'nextInsigniaDays': nextInsignia?.requiredDays,
      'progressToNext': progressToNext,
    };
  }

  /// Verifica se o usuário tem a insígnia Disciplinum
  bool hasDisciplinumInsignia() {
    return _currentState?.hasInsignia('disciplinum') ?? false;
  }

  /// Obtém o número de insígnias Disciplinum conquistadas
  int getDisciplinumCount() {
    if (_currentState == null) return 0;
    return _currentState!.earnedInsignias.where((i) => i == 'disciplinum').length;
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
      LoggerService.instance.e('Erro ao salvar estado Smoking', error: e);
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
      LoggerService.instance.e('Erro ao carregar estado Smoking', error: e);
      _currentState = SmokingModuleState();
    }
  }

  /// Obtém o estado atual
  SmokingModuleState? getCurrentState() => _currentState;

  /// Inicializa o serviço
  Future<void> initialize() async {
    await loadState();
    LoggerService.instance.gamification('SmokingInsigniaService inicializado');
  }
}
