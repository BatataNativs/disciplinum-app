import 'package:disciplinum/core/gamification/entities/pending_achievement_entity.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório para gerenciar conquistas pendentes de exibição
/// 
/// Armazena conquistas (insígnias/medalhas) que o usuário ganhou
/// mas ainda não viu o dialog celebrativo.
class PendingAchievementsRepository {
  static PendingAchievementsRepository? _instance;
  static PendingAchievementsRepository get instance => 
      _instance ??= PendingAchievementsRepository._();
  
  PendingAchievementsRepository._();

  late Store _store;
  bool _isInitialized = false;

  Box<PendingAchievementEntity> get _box => _store.box<PendingAchievementEntity>();

  /// Inicializa o repositório
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _store = ObjectBoxService.instance.store;
      _isInitialized = true;
      LoggerService.instance.gamification('✅ PendingAchievementsRepository inicializado');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao inicializar PendingAchievementsRepository', error: e);
      rethrow;
    }
  }

  /// Adiciona uma conquista pendente
  Future<void> addPendingAchievement({
    required String userId,
    required String type,
    required String moduleId,
    required String achievementId,
    required String achievementName,
    String? achievementDescription,
    String? assetPath,
    String? rarity,
  }) async {
    try {
      await initialize();

      // Verifica se já existe conquista igual pendente
      final query = _box.query(
        PendingAchievementEntity_.userId.equals(userId)
          .and(PendingAchievementEntity_.moduleId.equals(moduleId))
          .and(PendingAchievementEntity_.achievementId.equals(achievementId))
          .and(PendingAchievementEntity_.wasShown.equals(false))
      ).build();
      final existing = query.findFirst();
      query.close();

      if (existing != null) {
        LoggerService.instance.gamification('⚠️ Conquista já existe como pendente: $achievementName');
        return;
      }

      // Cria nova entidade
      final entity = PendingAchievementEntity(
        userId: userId,
        type: type,
        moduleId: moduleId,
        achievementId: achievementId,
        achievementName: achievementName,
        achievementDescription: achievementDescription,
        assetPath: assetPath,
        rarity: rarity,
        earnedAt: DateTime.now(),
        wasShown: false,
      );

      _box.put(entity);

      LoggerService.instance.gamification('✅ Conquista salva como pendente: $achievementName');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao adicionar conquista pendente', error: e);
    }
  }

  /// Obtém todas as conquistas pendentes de um usuário
  Future<List<PendingAchievementEntity>> getPendingAchievements(String userId) async {
    try {
      await initialize();

      final query = _box.query(
        PendingAchievementEntity_.userId.equals(userId)
          .and(PendingAchievementEntity_.wasShown.equals(false))
      ).order(PendingAchievementEntity_.earnedAt, flags: Order.descending).build();
      final pending = query.find();
      query.close();

      return pending;
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao obter conquistas pendentes', error: e);
      return [];
    }
  }

  /// Marca uma conquista como exibida
  Future<void> markAsShown(int id) async {
    try {
      await initialize();

      final entity = _box.get(id);
      if (entity != null) {
        entity.wasShown = true;
        entity.shownAt = DateTime.now();
        _box.put(entity);

        LoggerService.instance.gamification('✅ Conquista marcada como exibida: ${entity.achievementName}');
      }
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao marcar conquista como exibida', error: e);
    }
  }

  /// Marca todas as conquistas pendentes como exibidas
  Future<void> markAllAsShown(String userId) async {
    try {
      await initialize();

      final pending = await getPendingAchievements(userId);
      final now = DateTime.now();

      for (final entity in pending) {
        entity.wasShown = true;
        entity.shownAt = now;
      }
      _box.putMany(pending);

      LoggerService.instance.gamification('✅ ${pending.length} conquistas marcadas como exibidas');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao marcar todas como exibidas', error: e);
    }
  }

  /// Limpa conquistas já exibidas (mais de X dias)
  Future<void> clearOldShownAchievements(String userId, {int daysOld = 7}) async {
    try {
      await initialize();

      final cutoffTimestamp = DateTime.now().subtract(Duration(days: daysOld)).millisecondsSinceEpoch;

      final query = _box.query(
        PendingAchievementEntity_.userId.equals(userId)
          .and(PendingAchievementEntity_.wasShown.equals(true))
          .and(PendingAchievementEntity_.shownAt.lessThan(cutoffTimestamp))
      ).build();
      final oldAchievements = query.find();
      query.close();

      if (oldAchievements.isNotEmpty) {
        _box.removeMany(oldAchievements.map((e) => e.id).toList());

        LoggerService.instance.gamification('🗑️ ${oldAchievements.length} conquistas antigas removidas');
      }
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao limpar conquistas antigas', error: e);
    }
  }

  /// Limpa todas as conquistas de um usuário
  Future<void> clearAll(String userId) async {
    try {
      await initialize();

      final query = _box.query(PendingAchievementEntity_.userId.equals(userId)).build();
      final all = query.find();
      query.close();

      if (all.isNotEmpty) {
        _box.removeMany(all.map((e) => e.id).toList());

        LoggerService.instance.gamification('🗑️ ${all.length} conquistas removidas');
      }
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao limpar todas as conquistas', error: e);
    }
  }

  /// Obtém contagem de conquistas pendentes
  Future<int> getPendingCount(String userId) async {
    try {
      await initialize();

      final query = _box.query(
        PendingAchievementEntity_.userId.equals(userId)
          .and(PendingAchievementEntity_.wasShown.equals(false))
      ).build();
      final count = query.count();
      query.close();
      return count;
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao contar conquistas pendentes', error: e);
      return 0;
    }
  }

  /// Verifica se há conquistas pendentes
  Future<bool> hasPendingAchievements(String userId) async {
    final count = await getPendingCount(userId);
    return count > 0;
  }
}
