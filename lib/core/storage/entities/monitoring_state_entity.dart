import 'package:isar/isar.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

part 'monitoring_state_entity.g.dart';

/// Entidade para persistir o estado de monitoramento ativo
/// Recupera automaticamente o monitoramento quando o app reinicia
@Collection()
class MonitoringState {
  Id? id = 1; // ID fixo, sempre apenas um registro
  
  @Index()
  @enumerated // ✅ CORRIGIDO: Não nullable
  late NicheId activeNicheId; // Mudado de NicheId? para NicheId
  
  @Index()
  late bool isMonitoringActive;
  
  /// Lista de apps monitorados (serializada como JSON)
  late List<String> monitoredApps;
  
  /// Timestamp do último heartbeat
  late DateTime lastHeartbeat;
  
  /// Timestamp de início do monitoramento atual
  late DateTime? monitoringStartTime;
  
  /// Contador de violações na sessão atual
  late int violationCount;
  
  /// Timestamp da última violação
  late DateTime? lastViolationTime;
  
  MonitoringState({
    required this.activeNicheId, // ✅ Mudado para required NicheId
    this.isMonitoringActive = false,
    this.monitoredApps = const [],
    required this.lastHeartbeat,
    this.monitoringStartTime,
    this.violationCount = 0,
    this.lastViolationTime,
  });
  
  /// Verifica se o monitoramento está obsoleto (mais de 5 minutos sem heartbeat)
  bool get isStale {
    final now = DateTime.now();
    final diff = now.difference(lastHeartbeat);
    return diff.inMinutes > 5;
  }
  
  /// Atualiza o heartbeat
  void updateHeartbeat() {
    lastHeartbeat = DateTime.now();
  }
  
  /// Inicia o monitoramento
  void startMonitoring(NicheId nicheId, List<String> apps) {
    activeNicheId = nicheId;
    isMonitoringActive = true;
    monitoredApps = apps;
    monitoringStartTime = DateTime.now();
    violationCount = 0;
    lastViolationTime = null;
    updateHeartbeat();
  }
  
  /// Para o monitoramento
  void stopMonitoring() {
    isMonitoringActive = false;
    activeNicheId = NicheId.reading; // ✅ Valor default em vez de null
    monitoredApps = [];
    monitoringStartTime = null;
    updateHeartbeat();
  }
  
  /// Registra uma violação
  void registerViolation() {
    violationCount++;
    lastViolationTime = DateTime.now();
    updateHeartbeat();
  }
  
  /// Tempo de monitoramento ativo
  @ignore // ✅ Isar não suporta Duration? como propriedade
  Duration? get activeDuration {
    if (!isMonitoringActive || monitoringStartTime == null) return null;
    return DateTime.now().difference(monitoringStartTime!);
  }
  
  /// Converte para JSON (para compatibilidade)
  Map<String, dynamic> toJson() {
    return {
      'activeNicheId': activeNicheId.index, // ✅ Removido ? porque não é mais nullable
      'isMonitoringActive': isMonitoringActive,
      'monitoredApps': monitoredApps,
      'lastHeartbeat': lastHeartbeat.millisecondsSinceEpoch,
      'monitoringStartTime': monitoringStartTime?.millisecondsSinceEpoch,
      'violationCount': violationCount,
      'lastViolationTime': lastViolationTime?.millisecondsSinceEpoch,
    };
  }
  
  /// Cria a partir de JSON (para compatibilidade)
  factory MonitoringState.fromJson(Map<String, dynamic> json) {
    return MonitoringState(
      activeNicheId: json['activeNicheId'] != null 
          ? NicheId.values[json['activeNicheId']] 
          : NicheId.reading, // ✅ Valor default
      isMonitoringActive: json['isMonitoringActive'] ?? false,
      monitoredApps: List<String>.from(json['monitoredApps'] ?? []),
      lastHeartbeat: DateTime.fromMillisecondsSinceEpoch(json['lastHeartbeat']),
      monitoringStartTime: json['monitoringStartTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['monitoringStartTime'])
          : null,
      violationCount: json['violationCount'] ?? 0,
      lastViolationTime: json['lastViolationTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastViolationTime'])
          : null,
    );
  }
}
