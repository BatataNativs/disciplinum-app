import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

@Entity()
class DailyCheckin {
  @Id()
  int id = 0;

  @Unique()
  String nicheIdDate; // Formato: "nicheId_yyyy-MM-dd"

  // Armazenado como int para ObjectBox
  int nicheIdIndex;
  
  // Transient - não armazenado no banco
  @Transient()
  NicheId get nicheId => NicheId.values[nicheIdIndex];
  
  String dateStr;
  DateTime createdAt;

  // Construtor padrão necessário para ObjectBox
  DailyCheckin()
      : nicheIdDate = '',
        nicheIdIndex = 0,
        dateStr = '',
        createdAt = DateTime.now();

  // Factory method para criar instâncias validadas
  factory DailyCheckin.create({
    required NicheId nicheId,
    required String dateStr,
  }) {
    final entity = DailyCheckin();
    entity.nicheIdIndex = nicheId.index;
    entity.nicheIdDate = '${nicheId.index}_$dateStr';
    entity.dateStr = dateStr;
    entity.createdAt = DateTime.now();
    return entity;
  }
}
