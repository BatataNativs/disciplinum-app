import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repositório 100% Local-First com ObjectBox para Gamificação de Leitura
class ReadingGamificationRepository {
  static ReadingGamificationRepository? _instance;
  static ReadingGamificationRepository get instance => _instance ??= ReadingGamificationRepository._();
  ReadingGamificationRepository._();

  Box<ReadingGamificationEntity> get _box => ObjectBoxService.instance.store.box<ReadingGamificationEntity>();

  Future<void> saveReadingState(ReadingGamificationEntity entity) async {
    try {
      final existingEntity = _box.get(1);
      if (existingEntity != null) {
        entity.id = existingEntity.id;
      } else {
        entity.id = 1;
      }
      _box.put(entity);
      LoggerService.instance.gamification('✅ Estado Reading gamificação salvo com ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Reading gamificação', error: e, stackTrace: stackTrace);
    }
  }

  Future<ReadingGamificationEntity?> getReadingState() async {
    try {
      return _box.get(1);
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar estado Reading gamificação', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> clearReadingState() async {
    try {
      _box.removeAll();
      LoggerService.instance.gamification('🗑️ Estado Reading gamificação limpo');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar estado Reading gamificação', error: e, stackTrace: stackTrace);
    }
  }

  /// Inicializa o repositório
  Future<void> initialize() async {
    LoggerService.instance.gamification('ReadingGamificationRepository inicializado localmente');
  }
}
