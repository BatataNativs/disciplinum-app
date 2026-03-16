import 'package:isar/isar.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

part 'detection_session_entity.g.dart';

/// Entidade para persistir sessões de detecção ativas
/// Usada para recuperar timers quando o Android mata o processo
@Collection()
class DetectionSession {
  Id? id;
  
  @Index()
  late String packageName;
  
  @Index()
  late DateTime startTime;
  
  late int duration; // duração em segundos
  
  @Index()
  late bool isActive;
  
  @Index()
  @enumerated // ✅ ADICIONAR ESTA ANOTAÇÃO
  late NicheId nicheId;
  
  /// Timestamp da última atualização
  late DateTime lastUpdated;
  
  /// Tempo restante quando a sessão foi pausada/salva
  late int remainingSeconds;
  
  DetectionSession({
    required this.packageName,
    required this.startTime,
    required this.duration,
    required this.isActive,
    required this.nicheId,
    required this.remainingSeconds,
  }) : lastUpdated = DateTime.now();
  
  /// Calcula o tempo restante baseado no tempo decorrido
  int get calculatedRemainingSeconds {
    if (!isActive) return remainingSeconds;
    
    final elapsed = DateTime.now().difference(startTime);
    final remaining = duration - elapsed.inSeconds;
    return remaining > 0 ? remaining : 0;
  }
  
  /// Verifica se a sessão expirou
  bool get isExpired {
    return calculatedRemainingSeconds <= 0;
  }
  
  /// Marca a sessão como inativa
  void markAsInactive() {
    isActive = false;
    remainingSeconds = calculatedRemainingSeconds;
    lastUpdated = DateTime.now();
  }
  
  /// Converte para JSON (para compatibilidade)
  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'startTime': startTime.millisecondsSinceEpoch,
      'duration': duration,
      'isActive': isActive,
      'nicheId': nicheId.index,
      'remainingSeconds': remainingSeconds,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
  
  /// Cria a partir de JSON (para compatibilidade)
  factory DetectionSession.fromJson(Map<String, dynamic> json) {
    return DetectionSession(
      packageName: json['packageName'],
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      duration: json['duration'],
      isActive: json['isActive'],
      nicheId: NicheId.values[json['nicheId']],
      remainingSeconds: json['remainingSeconds'] ?? 0,
    );
  }
}
