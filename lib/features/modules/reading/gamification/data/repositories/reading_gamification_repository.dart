import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class ReadingGamificationRepository {
  static ReadingGamificationRepository? _instance;
  static ReadingGamificationRepository get instance => _instance ??= ReadingGamificationRepository._();
  ReadingGamificationRepository._();

  Isar get _isar => IsarService.instance.database;

  Future<void> saveReadingState(ReadingGamificationEntity entity) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.readingGamificationEntitys.put(entity);
      });
      LoggerService.instance.gamification('✅ Estado Reading gamificação salvo com Isar');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar estado Reading gamificação', error: e);
    }
  }

  Future<ReadingGamificationEntity?> getReadingState() async {
    try {
      // Pega o primeiro registro (sempre 1 para simplificar como outros módulos)
      return await _isar.readingGamificationEntitys.get(1);
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Reading gamificação', error: e);
      return null;
    }
  }

  Future<void> clearReadingState() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.readingGamificationEntitys.clear();
      });
      LoggerService.instance.gamification('🗑️ Estado Reading gamificação limpo');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar estado Reading gamificação', error: e);
    }
  }
}
