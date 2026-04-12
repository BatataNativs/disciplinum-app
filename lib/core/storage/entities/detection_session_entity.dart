import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

@Entity()
class DetectionSession {
  @Id()
  int id = 0;

  late String packageName;
  late DateTime startTime;
  late int duration;
  late bool isActive;
  
  // Armazenado como int para ObjectBox (enum não é suportado no construtor)
  late int nicheIdIndex;
  
  // Transient - não armazenado no banco, converte int para enum
  @Transient()
  NicheId get nicheId => NicheId.values[nicheIdIndex];
  
  late DateTime lastUpdated;
  late int remainingSeconds;

  // Construtor padrão necessário para ObjectBox
  DetectionSession()
      : packageName = '',
        startTime = DateTime.now(),
        duration = 0,
        isActive = true,
        nicheIdIndex = 0,
        lastUpdated = DateTime.now(),
        remainingSeconds = 0;

  // Factory method para criar instâncias validadas
  factory DetectionSession.create({
    required String packageName,
    required DateTime startTime,
    required int duration,
    required bool isActive,
    required NicheId nicheId,
    required int remainingSeconds,
  }) {
    final entity = DetectionSession();
    entity.packageName = packageName;
    entity.startTime = startTime;
    entity.duration = duration;
    entity.isActive = isActive;
    entity.nicheIdIndex = nicheId.index;
    entity.lastUpdated = DateTime.now();
    entity.remainingSeconds = remainingSeconds;
    return entity;
  }

  int get calculatedRemainingSeconds {
    if (!isActive) return remainingSeconds;
    final elapsed = DateTime.now().difference(startTime);
    final remaining = duration - elapsed.inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  bool get isExpired => calculatedRemainingSeconds <= 0;

  void markAsInactive() {
    isActive = false;
    remainingSeconds = calculatedRemainingSeconds;
    lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'startTime': startTime.millisecondsSinceEpoch,
      'duration': duration,
      'isActive': isActive,
      'nicheId': nicheIdIndex,
      'remainingSeconds': remainingSeconds,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory DetectionSession.fromJson(Map<String, dynamic> json) {
    return DetectionSession.create(
      packageName: json['packageName'],
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      duration: json['duration'],
      isActive: json['isActive'],
      nicheId: NicheId.values[json['nicheId']],
      remainingSeconds: json['remainingSeconds'] ?? 0,
    );
  }
}
