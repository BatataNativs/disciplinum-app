import '../entities/digital_detox_fasting_break_info.dart';
import 'package:disciplinum/objectbox.g.dart';

/// RepositÃ³rio para gerenciar Quebras de Jejum Digital
class DigitalDetoxFastingBreakRepository {
  final Box<DigitalDetoxFastingBreakInfo> _fastingBreakBox;

  DigitalDetoxFastingBreakRepository(this._fastingBreakBox);

  /// Busca todas as quebras de jejum de um usuÃ¡rio
  List<DigitalDetoxFastingBreakInfo> getAllForUser(String userId) {
    return _fastingBreakBox
        .query(DigitalDetoxFastingBreakInfo_.userId.equals(userId))
        .build()
        .find();
  }

  /// Busca quebras de jejum ativas de um usuÃ¡rio
  List<DigitalDetoxFastingBreakInfo> getActiveForUser(String userId) {
    return _fastingBreakBox
        .query(DigitalDetoxFastingBreakInfo_.userId.equals(userId))
        .order(DigitalDetoxFastingBreakInfo_.createdAt, flags: Order.descending)
        .build()
        .find()
        .where((breakInfo) => breakInfo.isActive)
        .toList();
  }

  /// Busca uma quebra de jejum pelo ID
  DigitalDetoxFastingBreakInfo? getById(int id) {
    return _fastingBreakBox.get(id);
  }

  /// Salva uma nova quebra de jejum
  Future<int> save(DigitalDetoxFastingBreakInfo fastingBreak) async {
    return await _fastingBreakBox.putAsync(fastingBreak);
  }

  /// Atualiza uma quebra de jejum existente
  Future<void> update(DigitalDetoxFastingBreakInfo fastingBreak) async {
    await _fastingBreakBox.putAsync(fastingBreak);
  }

  /// Marca uma quebra como usada
  Future<void> markAsUsed(int id) async {
    final fastingBreak = getById(id);
    if (fastingBreak != null && fastingBreak.isActive) {
      final updated = fastingBreak.markAsUsed();
      await update(updated);
    }
  }

  /// Marca uma quebra como expirada
  Future<void> markAsExpired(int id) async {
    final fastingBreak = getById(id);
    if (fastingBreak != null && fastingBreak.isActive) {
      final updated = fastingBreak.markAsExpired();
      await update(updated);
    }
  }

  /// Exclui uma quebra de jejum
  Future<void> delete(int id) async {
    await _fastingBreakBox.removeAsync(id);
  }

  /// Exclui quebras expiradas de um usuÃ¡rio
  Future<void> deleteExpiredForUser(String userId) async {
    final expiredBreaks = getAllForUser(userId)
        .where((breakInfo) => breakInfo.isExpired);
    
    for (final breakInfo in expiredBreaks) {
      await delete(breakInfo.id);
    }
  }

  /// Conta quebras ativas de um usuÃ¡rio
  int countActiveForUser(String userId) {
    return getActiveForUser(userId).length;
  }

  /// Busca quebras que expiraram recentemente (Ãºltimos 7 dias)
  List<DigitalDetoxFastingBreakInfo> getRecentlyExpiredForUser(String userId) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final query = _fastingBreakBox
        .query(DigitalDetoxFastingBreakInfo_.userId.equals(userId))
        .build();
    
    return query.find().where((breakInfo) => 
            breakInfo.isExpired && 
            breakInfo.expiresAt != null && 
            breakInfo.expiresAt!.isAfter(sevenDaysAgo))
        .toList();
  }

  /// Limpa todas as quebras de um usuÃ¡rio (para reset/teste)
  Future<void> clearAllForUser(String userId) async {
    final userBreaks = getAllForUser(userId);
    for (final breakInfo in userBreaks) {
      await delete(breakInfo.id);
    }
  }
}
