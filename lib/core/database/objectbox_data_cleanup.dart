import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_gamification_entity.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_gamification_entity.dart';

/// Utilitário para limpar dados potencialmente corrompidos do ObjectBox
/// após correções de serialização.
/// 
/// ⚠️ Use apenas em desenvolvimento/teste, ou implemente migração para produção.
class ObjectBoxDataCleanup {
  static final ObjectBoxDataCleanup _instance = ObjectBoxDataCleanup._internal();
  factory ObjectBoxDataCleanup() => _instance;
  ObjectBoxDataCleanup._internal();

  /// Limpa todas as entidades de gamificação dos módulos afetados
  /// 
  /// Útil após correções de formato de dados para garantir que não haja
  /// dados legados no formato incorreto.
  Future<void> cleanupAffectedEntities() async {
    try {
      final store = ObjectBoxService.instance.store;
      
      // Limpar entidades dos módulos corrigidos
      final focusBox = store.box<FocusGamificationEntity>();
      final readingBox = store.box<ReadingGamificationEntity>();
      final smokingBox = store.box<SmokingGamificationEntity>();
      
      final focusCount = focusBox.count();
      final readingCount = readingBox.count();
      final smokingCount = smokingBox.count();
      
      focusBox.removeAll();
      readingBox.removeAll();
      smokingBox.removeAll();
      
      LoggerService.instance.gamification(
        '🧹 ObjectBox cleanup concluído: '
        'Focus($focusCount), Reading($readingCount), Smoking($smokingCount) entidades removidas'
      );
    } catch (e, stackTrace) {
      LoggerService.instance.e(
        'Erro ao limpar dados do ObjectBox',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Verifica se há dados salvos que podem estar no formato incorreto
  /// 
  /// Retorna true se detectar potenciais problemas de formato.
  Future<bool> hasLegacyFormatData() async {
    try {
      final store = ObjectBoxService.instance.store;
      
      // Verificar Focus
      final focusBox = store.box<FocusGamificationEntity>();
      final focusEntities = focusBox.getAll();
      for (final entity in focusEntities) {
        // Se earnedInsignias não começa com '[', pode ser formato legado
        if (!entity.earnedInsignias.startsWith('[')) {
          LoggerService.instance.w(
            '⚠️ Possível formato legado detectado em FocusGamificationEntity.earnedInsignias: ${entity.earnedInsignias}'
          );
          return true;
        }
      }
      
      // Verificar Reading
      final readingBox = store.box<ReadingGamificationEntity>();
      final readingEntities = readingBox.getAll();
      for (final entity in readingEntities) {
        if (!entity.earnedInsignias.startsWith('[')) {
          LoggerService.instance.w(
            '⚠️ Possível formato legado detectado em ReadingGamificationEntity.earnedInsignias: ${entity.earnedInsignias}'
          );
          return true;
        }
      }
      
      // Verificar Smoking
      final smokingBox = store.box<SmokingGamificationEntity>();
      final smokingEntities = smokingBox.getAll();
      for (final entity in smokingEntities) {
        if (!entity.earnedInsignias.startsWith('[')) {
          LoggerService.instance.w(
            '⚠️ Possível formato legado detectado em SmokingGamificationEntity.earnedInsignias: ${entity.earnedInsignias}'
          );
          return true;
        }
      }
      
      return false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar formato legado', error: e);
      return false;
    }
  }
}
