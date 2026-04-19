import 'package:disciplinum/core/gamification/interfaces/module_gamification_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_module_state.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/services/diet_insignia_service.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/services/diet_medalha_service.dart';

/// Service principal de gamificação do módulo Dieta
/// Orquestra todos os serviços de gamificação do módulo
class DietGamificationService implements ModuleGamificationInterface {
  final DietGamificationRepository _repository;
  late final DietInsigniaService _insigniaService;
  late final DietMedalhaService _medalhaService;
  
  DietModuleState? _currentState;
  bool _isInitialized = false;

  DietGamificationService(this._repository) {
    _insigniaService = DietInsigniaService(_repository);
    _medalhaService = DietMedalhaService(_repository);
  }

  @override
  String get moduleId => 'diet';

  @override
  String get moduleName => 'Controle Nutricional';

  @override
  ModuleInsigniaInterface get insigniaService => _insigniaService;

  @override
  ModuleMedalhaInterface get medalhaService => _medalhaService;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      LoggerService.instance.gamification('Inicializando DietGamificationService...');
      
      // Carrega o estado do repositório
      _currentState = await _repository.performFullSync();
      
      // Inicializa os serviços
      await _insigniaService.initialize();
      await _medalhaService.initialize();
      
      // Atualiza os serviços com o estado atual
      await _insigniaService.updateFromModuleState(_currentState);
      await _medalhaService.updateFromModuleState(_currentState);
      
      _isInitialized = true;
      LoggerService.instance.gamification('DietGamificationService inicializado com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar DietGamificationService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> processModuleEvent(Map<String, dynamic> eventData) async {
    final eventType = eventData['type'];
    
    switch (eventType) {
      case 'positive_checkin':
        await processPositiveCheckIn();
        break;
      case 'relapse':
        await processRelapse();
        break;
      case 'activate':
        await activateModule();
        break;
      case 'update_days':
        final days = eventData['days'] as int;
        await updateConsecutiveDays(days);
        break;
      default:
        LoggerService.instance.w('Tipo de evento desconhecido: $eventType');
    }
  }

  @override
  Future<void> resetProgress() async {
    await _repository.resetProgress();
    await _insigniaService.resetInsignias();
    await _medalhaService.resetMedalhas();
    await initialize();
  }

  @override
  Future<Map<String, dynamic>> getCurrentState() async {
    if (_currentState == null) return {};
    
    return {
      'moduleId': moduleId,
      'moduleName': moduleName,
      'isModuleActive': _currentState!.isModuleActive,
      'consecutiveDays': _currentState!.consecutiveDays,
      'disciplinumCount': _currentState!.disciplinumCount,
      'earnedInsignias': _currentState!.earnedInsignias,
      'earnedMedalhas': _currentState!.earnedMedalhas,
      'lastUpdated': _currentState!.lastUpdated.toIso8601String(),
      'isInStreak': isInStreak,
      'progressToNextInsignia': getProgressToNextInsignia(),
      'statistics': getStatistics(),
    };
  }

  @override
  Future<void> checkForNewAchievements() async {
    if (_currentState == null) return;

    // Verifica novas insignias
    final newInsignias = await _insigniaService.checkForNewInsignias({
      'consecutiveDays': _currentState!.consecutiveDays,
    });

    // Verifica novas medalhas
    _medalhaService.checkDisciplinumMedalhas(_currentState!.disciplinumCount);

    // Atualiza o estado se houver novas conquistas
    if (newInsignias.isNotEmpty) {
      await _updateCurrentState();
    }
  }

  @override
  Future<void> sendSpecialNotifications() async {
    // Dieta não tem notificações especiais como Smoking
    // Apenas log para debugging
    LoggerService.instance.gamification('Notificações especiais não aplicáveis à Dieta');
  }

  Future<void> updateFromModuleState(DietModuleState state) async {
    _currentState = state;
    await _insigniaService.updateFromModuleState(state);
    await _medalhaService.updateFromModuleState(state);
  }

  /// Ativa o módulo (concede insignia madeira)
  Future<void> activateModule() async {
    await _insigniaService.activateModule();
    await _updateCurrentState();
  }

  /// Processa um check-in positivo
  Future<void> processPositiveCheckIn() async {
    await _insigniaService.processPositiveCheckIn();
    await _updateCurrentState();
  }

  /// Processa uma recaída (reseta progresso)
  Future<void> processRelapse() async {
    await _insigniaService.processRelapse();
    await _medalhaService.resetMedalhas();
    await _updateCurrentState();
  }

  /// Atualiza o contador de dias consecutivos
  Future<void> updateConsecutiveDays(int days) async {
    await _insigniaService.updateConsecutiveDays(days);
    await _updateCurrentState();
  }

  /// Obtém o estado atual
  DietModuleState? get currentState => _currentState;

  /// Verifica se o módulo está ativo
  bool get isModuleActive => _currentState?.isModuleActive ?? false;

  /// Obtém as insignias conquistadas
  Future<List<String>> getEarnedInsignias() async {
    return await _insigniaService.getEarnedInsignias();
  }

  /// Obtém as medalhas conquistadas
  Future<List<String>> getEarnedMedalhas() async {
    return await _medalhaService.getEarnedMedalhas();
  }

  /// Obtém o contador de dias consecutivos
  int get consecutiveDays => _currentState?.consecutiveDays ?? 0;

  /// Obtém o contador de insignias Disciplinum
  int get disciplinumCount => _currentState?.disciplinumCount ?? 0;

  /// Sincroniza com o Supabase
  Future<void> syncWithSupabase() async {
    if (_currentState != null) {
      await _repository.syncWithSupabase(_currentState!);
    }
  }

  /// Atualiza o estado atual com base nos serviços
  Future<void> _updateCurrentState() async {
    try {
      final earnedInsignias = await _insigniaService.getEarnedInsignias();
      final earnedMedalhas = await _medalhaService.getEarnedMedalhas();
      
      _currentState = DietModuleState(
        earnedInsignias: earnedInsignias,
        earnedMedalhas: earnedMedalhas,
        consecutiveDays: _currentState?.consecutiveDays ?? 0,
        disciplinumCount: _currentState?.disciplinumCount ?? 0,
        isModuleActive: earnedInsignias.isNotEmpty,
      );

      // Salva o estado atualizado
      await _repository.saveDietState(_currentState!);
      
      LoggerService.instance.gamification('Estado Dieta atualizado');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado Dieta', error: e);
    }
  }

  /// Obtém estatísticas detalhadas
  Map<String, dynamic> getStatistics() {
    if (_currentState == null) return {};

    return {
      'isModuleActive': isModuleActive,
      'consecutiveDays': consecutiveDays,
      'disciplinumCount': disciplinumCount,
      'earnedInsigniasCount': _currentState!.earnedInsignias.length,
      'earnedMedalhasCount': _currentState!.earnedMedalhas.length,
      'lastUpdated': _currentState!.lastUpdated.toIso8601String(),
      'nextInsignia': _getNextInsignia(),
      'nextMedalha': _getNextMedalha(),
    };
  }

  /// Obtém a próxima insignia a ser conquistada
  String? _getNextInsignia() {
    if (_currentState == null) return null;

    for (final insignia in ['ferro', 'aluminio', 'latao', 'bronze', 'prata', 'ouro', 'diamante', 'disciplinum']) {
      if (!_currentState!.earnedInsignias.contains(insignia)) {
        return insignia;
      }
    }
    return null;
  }

  /// Obtém a próxima medalha a ser conquistada
  String? _getNextMedalha() {
    if (_currentState == null) return null;

    for (final medalha in ['bronze', 'prata', 'ouro', 'diamante']) {
      if (!_currentState!.earnedMedalhas.contains(medalha)) {
        return medalha;
      }
    }
    return null;
  }

  /// Verifica se o usuário está em streak
  bool get isInStreak => consecutiveDays > 0;

  /// Obtém o progresso para a próxima insignia
  double getProgressToNextInsignia() {
    if (_currentState == null) return 0.0;

    final nextInsignia = _getNextInsignia();
    if (nextInsignia == null) return 1.0;

    // Mapeia os requisitos de dias para cada insignia
    final requirements = {
      'ferro': 1,
      'aluminio': 7,
      'latao': 15,
      'bronze': 30,
      'prata': 60,
      'ouro': 90,
      'diamante': 180,
      'disciplinum': 365,
    };

    final requiredDays = requirements[nextInsignia] ?? 0;
    if (requiredDays == 0) return 0.0;

    return (consecutiveDays / requiredDays).clamp(0.0, 1.0);
  }
}
