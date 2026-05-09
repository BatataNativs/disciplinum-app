import '../entities/digital_detox_gamification_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

class DigitalDetoxGamificationRepository {
  final Box<DigitalDetoxGamificationEntity> _box;

  DigitalDetoxGamificationRepository(this._box);

  // Salvar ou atualizar gamificação
  Future<void> save(DigitalDetoxGamificationEntity gamification) async {
    await _box.putAsync(gamification);
  }

  // Obter gamificação do usuário
  DigitalDetoxGamificationEntity? getByUserId(String userId) {
    final builder = _box.query(DigitalDetoxGamificationEntity_.userId.equals(userId));
    return builder.build().findFirst();
  }

  // Obter ou criar gamificação do usuário
  DigitalDetoxGamificationEntity getOrCreateByUserId(String userId) {
    var gamification = getByUserId(userId);
    
    if (gamification == null) {
      // Criar nova gamificação
      gamification = DigitalDetoxGamificationEntity(userId: userId);
      save(gamification);
    }
    
    return gamification;
  }

  // Obter todas as gamificações
  List<DigitalDetoxGamificationEntity> getAll() {
    return _box.getAll();
  }

  // Limpar todos os dados
  Future<void> clearAll() async {
    await _box.removeAllAsync();
  }

  // Atualizar gamificação
  Future<void> update(DigitalDetoxGamificationEntity gamification) async {
    await _box.putAsync(gamification);
  }
}
