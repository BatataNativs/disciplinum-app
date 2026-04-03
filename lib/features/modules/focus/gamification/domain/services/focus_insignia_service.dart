import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_module_state.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';

/// Service de insígnias específico do módulo Focus
/// Implementa a interface base com lógica específica do Focus
class FocusInsigniaService implements ModuleInsigniaInterface {
  final FocusService _focusService;
  FocusModuleState? _currentState;

  FocusInsigniaService(this._focusService);

  @override
  List<String> getAllInsigniaIds() {
    return [
      'madeira',
      'ferro',
      'aluminio',
      'latao',
      'bronze',
      'prata',
      'ouro',
      'diamante',
      'disciplinum',
    ];
  }

  @override
  String getInsigniaName(String insigniaId) {
    switch (insigniaId) {
      case 'madeira':
        return 'Focado Madeira';
      case 'ferro':
        return 'Focado Ferro';
      case 'aluminio':
        return 'Focado Alumínio';
      case 'latao':
        return 'Focado Latão';
      case 'bronze':
        return 'Focado Bronze';
      case 'prata':
        return 'Focado Prata';
      case 'ouro':
        return 'Focado Ouro';
      case 'diamante':
        return 'Focado Diamante';
      case 'disciplinum':
        return 'Focado Disciplinum';
      default:
        return 'Insignia Desconhecida';
    }
  }

  @override
  String getInsigniaAsset(String insigniaId) {
    return 'assets/gamification/insignias/focus/$insigniaId.png';
  }

  @override
  String getInsigniaRequirement(String insigniaId) {
    switch (insigniaId) {
      case 'madeira':
        return 'Ative o módulo de Foco';
      case 'ferro':
        return '1 período de foco respeitado';
      case 'aluminio':
        return '2 períodos de foco respeitados';
      case 'latao':
        return '3 períodos de foco respeitados';
      case 'bronze':
        return '4 períodos de foco respeitados';
      case 'prata':
        return '5 períodos de foco respeitados';
      case 'ouro':
        return '6 períodos de foco respeitados';
      case 'diamante':
        return '9 períodos de foco respeitados';
      case 'disciplinum':
        return '10 períodos de foco respeitados';
      default:
        return 'Requisito desconhecido';
    }
  }

  @override
  Future<bool> hasEarnedInsignia(String insigniaId) async {
    final state = await getCurrentState();
    return state.earnedInsignias.contains(insigniaId);
  }

  @override
  Future<void> awardInsignia(String insigniaId) async {
    try {
      final state = await getCurrentState();
      
      if (!state.earnedInsignias.contains(insigniaId)) {
        final updatedState = state.copyWith(
          earnedInsignias: [...state.earnedInsignias, insigniaId],
        );
        
        await _saveState(updatedState);
        _currentState = updatedState;
        
        LoggerService.instance.gamification('Insignia concedida no Focus: $insigniaId');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao conceder insígnia $insigniaId no Focus', error: e);
    }
  }

  @override
  Future<void> revokeInsignia(String insigniaId) async {
    try {
      final state = await getCurrentState();
      
      if (state.earnedInsignias.contains(insigniaId)) {
        final updatedState = state.copyWith(
          earnedInsignias: state.earnedInsignias.where((id) => id != insigniaId).toList(),
        );
        
        await _saveState(updatedState);
        _currentState = updatedState;
        
        LoggerService.instance.gamification('Insignia revogada no Focus: $insigniaId');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao revogar insígnia $insigniaId no Focus', error: e);
    }
  }

  @override
  Future<List<String>> getEarnedInsignias() async {
    final state = await getCurrentState();
    return List.from(state.earnedInsignias);
  }

  @override
  Future<List<String>> checkForNewInsignias(Map<String, dynamic> moduleData) async {
    final state = await getCurrentState();
    final newInsignias = <String>[];

    // Verifica cada insígnia em ordem
    final insigniaRequirements = {
      'ferro': 1,
      'aluminio': 2,
      'latao': 3,
      'bronze': 4,
      'prata': 5,
      'ouro': 6,
      'diamante': 9,
      'disciplinum': 10,
    };

    for (final entry in insigniaRequirements.entries) {
      final insigniaId = entry.key;
      final requiredPeriods = entry.value;

      if (!state.hasInsignia(insigniaId) && state.respectedPeriodsCount >= requiredPeriods) {
        newInsignias.add(insigniaId);
      }
    }

    return newInsignias;
  }

  @override
  Future<void> resetInsignias() async {
    try {
      final resetState = (_currentState ?? FocusModuleState.initial()).reset();
      await _saveState(resetState);
      _currentState = resetState;
      
      LoggerService.instance.gamification('Insignias do Focus resetadas');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar insígnias do Focus', error: e);
    }
  }

  /// Obtém o estado atual da gamificação
  Future<FocusModuleState> getCurrentState() async {
    if (_currentState != null) return _currentState!;
    
    try {
      // Carrega estado do FocusService
      final earnedInsignias = await _focusService.getEarnedInsignias();
      
      _currentState = FocusModuleState(
        earnedInsignias: earnedInsignias.map((e) => e.name).toList(),
        respectedPeriods: [],
      );
      
      return _currentState!;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado do Focus', error: e);
      return FocusModuleState.initial();
    }
  }

  /// Salva o estado atual
  Future<void> _saveState(FocusModuleState state) async {
    try {
      await FocusGamificationRepository.instance.saveFocusState(state);
      _currentState = state;
      
      LoggerService.instance.gamification('Estado Focus salvo com Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Focus com Isar', error: e);
    }
  }

  /// Carrega o estado salvo
  Future<void> loadState() async {
    try {
      // Tenta carregar do Isar local primeiro
      _currentState = await FocusGamificationRepository.instance.getFocusState();
      
      // Se não encontrar local, tenta do Supabase
      if (_currentState == null) {
        _currentState = await FocusGamificationRepository.instance.loadFromSupabase();
        
        // Se encontrou no Supabase, salva localmente
        if (_currentState != null) {
          await _saveState(_currentState!);
        }
      }
      
      LoggerService.instance.gamification('Estado Focus carregado');
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Focus', error: e);
    }
  }

  /// Inicializa o serviço
  Future<void> initialize() async {
    await loadState();
    LoggerService.instance.gamification('FocusInsigniaService inicializado');
  }
}
