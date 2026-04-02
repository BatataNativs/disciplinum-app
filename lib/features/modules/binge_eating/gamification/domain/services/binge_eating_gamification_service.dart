import 'package:disciplinum/core/gamification/interfaces/module_gamification_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/repositories/binge_eating_gamification_repository.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_module_state.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/services/binge_eating_insignia_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/services/binge_eating_medalha_service.dart';

/// Service principal de gamificação do módulo Binge Eating
/// Orquestra todos os serviços de gamificação do módulo
class BingeEatingGamificationService implements ModuleGamificationInterface {
  final BingeEatingGamificationRepository _repository;
  late final BingeEatingInsigniaService _insigniaService;
  late final BingeEatingMedalhaService _medalhaService;
  
  BingeEatingModuleState? _currentState;
  bool _isInitialized = false;

  BingeEatingGamificationService(this._repository) {
    _insigniaService = BingeEatingInsigniaService(_repository);
    _medalhaService = BingeEatingMedalhaService(_repository);
  }

  @override
  String get moduleId => 'binge_eating';

  @override
  String get moduleName => 'Controle da Compulsão Alimentar';

  @override
  ModuleInsigniaInterface get insigniaService => _insigniaService;

  @override
  ModuleMedalhaInterface get medalhaService => _medalhaService;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      LoggerService.instance.gamification('Inicializando BingeEatingGamificationService...');
      
      // Carrega o estado do repositório
      _currentState = await _repository.performFullSync();
      
      // Inicializa os serviços
      await _insigniaService.initialize();
      await _medalhaService.initialize();
      
      // Atualiza os serviços com o estado atual
      await _insigniaService.updateFromModuleState(_currentState);
      await _medalhaService.updateFromModuleState(_currentState);
      
      _isInitialized = true;
      LoggerService.instance.gamification('BingeEatingGamificationService inicializado com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar BingeEatingGamificationService', error: e);
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
        await updateConsecutivePositiveDays(days);
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
      'isActive': _currentState!.isActive,
      'consecutivePositiveDays': _currentState!.consecutivePositiveDays,
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
      'consecutivePositiveDays': _currentState!.consecutivePositiveDays,
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
    // Binge Eating não tem notificações especiais como Smoking
    // Apenas log para debugging
    LoggerService.instance.gamification('Notificações especiais não aplicáveis ao Binge Eating');
  }

  Future<void> updateFromModuleState(BingeEatingModuleState state) async {
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

  /// Atualiza o contador de dias positivos consecutivos
  Future<void> updateConsecutivePositiveDays(int days) async {
    await _insigniaService.updateConsecutivePositiveDays(days);
    await _updateCurrentState();
  }

  /// Obtém o estado atual
  BingeEatingModuleState? get currentState => _currentState;

  /// Verifica se o módulo está ativo
  bool get isActive => _currentState?.isActive ?? false;

  /// Obtém o contador de dias positivos consecutivos
  int get consecutivePositiveDays => _currentState?.consecutivePositiveDays ?? 0;

  /// Obtém o contador de insignias Disciplinum
  int get disciplinumCount => _currentState?.disciplinumCount ?? 0;

  /// Atualiza o estado atual com base nos serviços
  Future<void> _updateCurrentState() async {
    try {
      final earnedInsignias = await _insigniaService.getEarnedInsignias();
      final earnedMedalhas = await _medalhaService.getEarnedMedalhas();
      
      _currentState = BingeEatingModuleState(
        earnedInsignias: earnedInsignias,
        earnedMedalhas: earnedMedalhas,
        consecutivePositiveDays: _currentState?.consecutivePositiveDays ?? 0,
        disciplinumCount: _currentState?.disciplinumCount ?? 0,
        updatedAt: DateTime.now(),
        isActive: earnedInsignias.isNotEmpty,
      );

      // Salva o estado atualizado
      await _repository.saveBingeEatingState(_currentState!);
      
      LoggerService.instance.gamification('Estado Binge Eating atualizado');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado Binge Eating', error: e);
    }
  }

  /// Obtém estatísticas detalhadas
  Map<String, dynamic> getStatistics() {
    if (_currentState == null) return {};

    return {
      'isActive': isActive,
      'consecutivePositiveDays': consecutivePositiveDays,
      'disciplinumCount': disciplinumCount,
      'earnedInsigniasCount': _currentState!.earnedInsignias.length,
      'earnedMedalhasCount': _currentState!.earnedMedalhas.length,
      'lastUpdated': _currentState!.updatedAt.toIso8601String(),
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
  bool get isInStreak => consecutivePositiveDays > 0;

  /// Obtém o progresso para a próxima insignia
  double getProgressToNextInsignia() {
    if (_currentState == null) return 0.0;

    final nextInsignia = _getNextInsignia();
    if (nextInsignia == null) return 1.0;

    // Mapeia os requisitos de dias para cada insignia
    final requirements = {
      'ferro': 1,
      'aluminio': 2,
      'latao': 3,
      'bronze': 5,
      'prata': 10,
      'ouro': 15,
      'diamante': 20,
      'disciplinum': 30,
    };

    final requiredDays = requirements[nextInsignia] ?? 0;
    if (requiredDays == 0) return 0.0;

    return (consecutivePositiveDays / requiredDays).clamp(0.0, 1.0);
  }
}
