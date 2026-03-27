import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/entities/diet_insignia.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/entities/diet_module_state.dart';

/// Service de insignias específico do módulo Dieta
/// Implementa a interface base com lógica específica da Dieta
class DietInsigniaService implements ModuleInsigniaInterface {
  final DietGamificationRepository _repository;
  final List<String> _earnedInsignias = [];
  int _consecutiveDays = 0;

  DietInsigniaService(this._repository);

  Future<void> initialize() async {
    try {
      final state = await _repository.getDietState();
      if (state != null) {
        _earnedInsignias.clear();
        _earnedInsignias.addAll(state.earnedInsignias);
        _consecutiveDays = state.consecutiveDays;
        LoggerService.instance.gamification('DietInsigniaService inicializado');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar DietInsigniaService', error: e);
    }
  }

  Future<void> updateFromModuleState(dynamic state) async {
    if (state is DietModuleState) {
      _earnedInsignias.clear();
      _earnedInsignias.addAll(state.earnedInsignias);
      _consecutiveDays = state.consecutiveDays;
    }
  }

  Future<void> loadState() async {
    await initialize();
  }

  Future<void> _saveState() async {
    try {
      final currentState = DietModuleState(
        earnedInsignias: _earnedInsignias,
        earnedMedalhas: [], // Será gerenciado pelo MedalhaService
        consecutiveDays: _consecutiveDays,
        disciplinumCount: _earnedInsignias.where((id) => id == 'disciplinum').length,
        lastUpdated: DateTime.now(),
        isActive: true,
      );
      
      await _repository.saveDietState(currentState);
      LoggerService.instance.gamification('Estado DietInsigniaService salvo');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado DietInsigniaService', error: e);
    }
  }

  @override
  List<String> getAllInsigniaIds() {
    return DietInsignia.values.map((insignia) => insignia.name).toList();
  }

  @override
  String getInsigniaName(String insigniaId) {
    try {
      return DietInsignia.values.firstWhere((insignia) => insignia.name == insigniaId).nameBr;
    } catch (e) {
      return insigniaId;
    }
  }

  @override
  String getInsigniaAsset(String insigniaId) {
    const prefix = 'assets/gamification/insignias/diet/';
    switch (insigniaId) {
      case 'madeira':
        return '${prefix}madeira.png';
      case 'ferro':
        return '${prefix}ferro.png';
      case 'aluminio':
        return '${prefix}aluminio.png';
      case 'latao':
        return '${prefix}latao.png';
      case 'bronze':
        return '${prefix}bronze.png';
      case 'prata':
        return '${prefix}prata.png';
      case 'ouro':
        return '${prefix}ouro.png';
      case 'diamante':
        return '${prefix}diamante.png';
      case 'disciplinum':
        return '${prefix}disciplinum.png';
      default:
        return '${prefix}default.png';
    }
  }

  @override
  String getInsigniaRequirement(String insigniaId) {
    try {
      return DietInsignia.values.firstWhere((insignia) => insignia.name == insigniaId).description;
    } catch (e) {
      return 'Requisito não encontrado';
    }
  }

  @override
  Future<bool> hasEarnedInsignia(String insigniaId) async {
    return _earnedInsignias.contains(insigniaId);
  }

  @override
  Future<void> awardInsignia(String insigniaId) async {
    if (!_earnedInsignias.contains(insigniaId)) {
      _earnedInsignias.add(insigniaId);
      
      LoggerService.instance.gamification('Insignia concedida na Dieta: $insigniaId');
      
      await _saveState();
    }
  }

  @override
  Future<void> revokeInsignia(String insigniaId) async {
    if (_earnedInsignias.contains(insigniaId)) {
      _earnedInsignias.remove(insigniaId);
      
      LoggerService.instance.gamification('Insignia revogada na Dieta: $insigniaId');
      
      await _saveState();
    }
  }

  @override
  Future<List<String>> getEarnedInsignias() async {
    return List.unmodifiable(_earnedInsignias);
  }

  @override
  Future<List<String>> checkForNewInsignias(Map<String, dynamic> moduleData) async {
    final newInsignias = <String>[];
    final consecutiveDays = moduleData['consecutiveDays'] ?? _consecutiveDays;

    for (final insignia in DietInsignia.values) {
      if (!await hasEarnedInsignia(insignia.name) && 
          insignia.requiredDays <= consecutiveDays &&
          insignia.canBeAwarded(_earnedInsignias)) {
        newInsignias.add(insignia.name);
        await awardInsignia(insignia.name);
      }
    }

    return newInsignias;
  }

  @override
  Future<void> resetInsignias() async {
    _earnedInsignias.clear();
    _consecutiveDays = 0;
    await _saveState();
    LoggerService.instance.gamification('Insignias da Dieta resetadas');
  }

  /// Atualiza o contador de dias consecutivos
  Future<void> updateConsecutiveDays(int days) async {
    _consecutiveDays = days;
    
    // Verifica se há novas insignias
    await checkForNewInsignias({'consecutiveDays': days});
  }

  /// Verifica se o módulo está ativo
  bool get isActive => _earnedInsignias.isNotEmpty;

  /// Concede insignia madeira ao ativar o módulo
  Future<void> activateModule() async {
    if (!await hasEarnedInsignia('madeira')) {
      await awardInsignia('madeira');
    }
  }

  /// Processa um check-in positivo
  Future<void> processPositiveCheckIn() async {
    _consecutiveDays++;
    await updateConsecutiveDays(_consecutiveDays);
  }

  /// Processa uma recaída (reseta progresso)
  Future<void> processRelapse() async {
    _consecutiveDays = 0;
    
    // Remove todas as insignias exceto madeira
    final toRemove = _earnedInsignias.where((id) => id != 'madeira').toList();
    for (final insigniaId in toRemove) {
      await revokeInsignia(insigniaId);
    }
    
    await _saveState();
    LoggerService.instance.gamification('Recaída processada na Dieta');
  }
}
