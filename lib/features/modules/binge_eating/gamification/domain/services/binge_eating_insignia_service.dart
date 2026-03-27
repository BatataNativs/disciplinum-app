import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/entities/binge_eating_insignia.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/repositories/binge_eating_gamification_repository.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/entities/binge_eating_module_state.dart';

/// Service de insignias específico do módulo Binge Eating
/// Implementa a interface base com lógica específica do Binge Eating
class BingeEatingInsigniaService implements ModuleInsigniaInterface {
  final BingeEatingGamificationRepository _repository;
  final List<String> _earnedInsignias = [];
  int _consecutivePositiveDays = 0;

  BingeEatingInsigniaService(this._repository);

  Future<void> initialize() async {
    try {
      final state = await _repository.getBingeEatingState();
      if (state != null) {
        _earnedInsignias.clear();
        _earnedInsignias.addAll(state.earnedInsignias);
        _consecutivePositiveDays = state.consecutivePositiveDays;
        LoggerService.instance.gamification('BingeEatingInsigniaService inicializado');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar BingeEatingInsigniaService', error: e);
    }
  }

  Future<void> updateFromModuleState(dynamic state) async {
    if (state is BingeEatingModuleState) {
      _earnedInsignias.clear();
      _earnedInsignias.addAll(state.earnedInsignias);
      _consecutivePositiveDays = state.consecutivePositiveDays;
    }
  }

  Future<void> loadState() async {
    await initialize();
  }

  Future<void> _saveState() async {
    try {
      final currentState = BingeEatingModuleState(
        earnedInsignias: _earnedInsignias,
        earnedMedalhas: [], // Será gerenciado pelo MedalhaService
        consecutivePositiveDays: _consecutivePositiveDays,
        disciplinumCount: _earnedInsignias.where((id) => id == 'disciplinum').length,
        lastUpdated: DateTime.now(),
        isActive: true,
      );
      
      await _repository.saveBingeEatingState(currentState);
      LoggerService.instance.gamification('Estado BingeEatingInsigniaService salvo');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado BingeEatingInsigniaService', error: e);
    }
  }

  @override
  List<String> getAllInsigniaIds() {
    return BingeEatingInsignia.values.map((insignia) => insignia.name).toList();
  }

  @override
  String getInsigniaName(String insigniaId) {
    try {
      return BingeEatingInsignia.values.firstWhere((insignia) => insignia.name == insigniaId).nameBr;
    } catch (e) {
      return insigniaId;
    }
  }

  @override
  String getInsigniaAsset(String insigniaId) {
    const prefix = 'assets/gamification/insignias/binge_eating/';
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
      return BingeEatingInsignia.values.firstWhere((insignia) => insignia.name == insigniaId).description;
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
      
      LoggerService.instance.gamification('Insignia concedida no Binge Eating: $insigniaId');
      
      await _saveState();
    }
  }

  @override
  Future<void> revokeInsignia(String insigniaId) async {
    if (_earnedInsignias.contains(insigniaId)) {
      _earnedInsignias.remove(insigniaId);
      
      LoggerService.instance.gamification('Insignia revogada no Binge Eating: $insigniaId');
      
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
    final consecutiveDays = moduleData['consecutivePositiveDays'] ?? _consecutivePositiveDays;

    for (final insignia in BingeEatingInsignia.values) {
      if (!await hasEarnedInsignia(insignia.name) && 
          insignia.requiredDays <= consecutiveDays) {
        newInsignias.add(insignia.name);
        await awardInsignia(insignia.name);
      }
    }

    return newInsignias;
  }

  @override
  Future<void> resetInsignias() async {
    // Preserva apenas a insígnia de madeira (inicial)
    final madeiraInsignia = BingeEatingInsignia.madeira.name;
    final hasMadeira = _earnedInsignias.contains(madeiraInsignia);
    
    _earnedInsignias.clear();
    _consecutivePositiveDays = 0;
    
    // Restaura a madeira se o usuário já tinha
    if (hasMadeira) {
      _earnedInsignias.add(madeiraInsignia);
    }
    
    await _saveState();
    LoggerService.instance.gamification('🗑️ Insignias do Binge Eating resetadas (preservando madeira)');
  }

  /// Atualiza o contador de dias positivos consecutivos
  Future<void> updateConsecutivePositiveDays(int days) async {
    _consecutivePositiveDays = days;
    
    // Verifica se há novas insignias
    await checkForNewInsignias({'consecutivePositiveDays': days});
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
    _consecutivePositiveDays++;
    await updateConsecutivePositiveDays(_consecutivePositiveDays);
  }

  /// Processa uma recaída (reseta progresso)
  Future<void> processRelapse() async {
    _consecutivePositiveDays = 0;
    
    // Remove todas as insignias exceto madeira
    final toRemove = _earnedInsignias.where((id) => id != 'madeira').toList();
    for (final insigniaId in toRemove) {
      await revokeInsignia(insigniaId);
    }
    
    await _saveState();
    LoggerService.instance.gamification('Recaída processada no Binge Eating');
  }
}
