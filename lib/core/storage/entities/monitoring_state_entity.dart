import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

@Entity()
class MonitoringState {
  @Id()
  int id = 1;

  // Armazenado como int para ObjectBox (enum não é suportado no construtor)
  late int activeNicheIdIndex;
  
  // Transient - não armazenado no banco, converte int para enum
  @Transient()
  NicheId get activeNicheId => NicheId.values[activeNicheIdIndex];
  
  // Setter para facilitar uso
  set activeNicheId(NicheId value) => activeNicheIdIndex = value.index;

  late bool isMonitoringActive;
  late List<String> monitoredApps;
  late DateTime lastHeartbeat;
  late DateTime? monitoringStartTime;
  late int violationCount;
  late DateTime? lastViolationTime;

  // Construtor padrão necessário para ObjectBox
  MonitoringState()
      : activeNicheIdIndex = 8, // NicheId.reading.index = 8
        isMonitoringActive = false,
        monitoredApps = const [],
        lastHeartbeat = DateTime.now(),
        monitoringStartTime = null,
        violationCount = 0,
        lastViolationTime = null;

  // Factory method para criar instâncias validadas
  factory MonitoringState.create({
    required NicheId activeNicheId,
    bool isMonitoringActive = false,
    List<String> monitoredApps = const [],
    required DateTime lastHeartbeat,
    DateTime? monitoringStartTime,
    int violationCount = 0,
    DateTime? lastViolationTime,
  }) {
    final entity = MonitoringState();
    entity.activeNicheIdIndex = activeNicheId.index;
    entity.isMonitoringActive = isMonitoringActive;
    entity.monitoredApps = monitoredApps;
    entity.lastHeartbeat = lastHeartbeat;
    entity.monitoringStartTime = monitoringStartTime;
    entity.violationCount = violationCount;
    entity.lastViolationTime = lastViolationTime;
    return entity;
  }

  bool get isStale {
    final now = DateTime.now();
    final diff = now.difference(lastHeartbeat);
    return diff.inMinutes > 5;
  }

  void updateHeartbeat() {
    lastHeartbeat = DateTime.now();
  }

  void startMonitoring(NicheId nicheId, List<String> apps) {
    activeNicheIdIndex = nicheId.index;
    isMonitoringActive = true;
    monitoredApps = apps;
    monitoringStartTime = DateTime.now();
    violationCount = 0;
    lastViolationTime = null;
    updateHeartbeat();
  }

  void stopMonitoring() {
    isMonitoringActive = false;
    activeNicheIdIndex = 8; // NicheId.reading.index = 8
    monitoredApps = [];
    monitoringStartTime = null;
    updateHeartbeat();
  }

  void registerViolation() {
    violationCount++;
    lastViolationTime = DateTime.now();
    updateHeartbeat();
  }

  Duration? get activeDuration {
    if (!isMonitoringActive || monitoringStartTime == null) return null;
    return DateTime.now().difference(monitoringStartTime!);
  }

  Map<String, dynamic> toJson() {
    return {
      'activeNicheId': activeNicheIdIndex,
      'isMonitoringActive': isMonitoringActive,
      'monitoredApps': monitoredApps,
      'lastHeartbeat': lastHeartbeat.millisecondsSinceEpoch,
      'monitoringStartTime': monitoringStartTime?.millisecondsSinceEpoch,
      'violationCount': violationCount,
      'lastViolationTime': lastViolationTime?.millisecondsSinceEpoch,
    };
  }

  factory MonitoringState.fromJson(Map<String, dynamic> json) {
    return MonitoringState.create(
      activeNicheId: json['activeNicheId'] != null
          ? NicheId.values[json['activeNicheId']]
          : NicheId.reading,
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
